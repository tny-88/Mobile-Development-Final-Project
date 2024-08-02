import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:untab_alpha/classes/api_service.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = "";
  String email = "";
  String phoneNumber = "";
  String dob = "";
  String gender = "";
  bool _isBiometricEnabled = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final _storage = FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _logout() async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _pickDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkBiometricStatus();
  }

  Future<void> _fetchUserData() async {
    final userData = await ApiService.fetchUserData();
    if (userData != null && mounted) {
      setState(() {
        username = "${userData['fname']} ${userData['lname']}";
        email = userData['email'];
        phoneNumber = userData['phoneNumber'];
        dob = userData['dob'];
        gender = userData['gender'];

        _fnameController.text = userData['fname'];
        _lnameController.text = userData['lname'];
        _phoneController.text = userData['phoneNumber'];
        _dobController.text = userData['dob'];
        _genderController.text = userData['gender'];
      });
    }
  }

  Future<void> _checkBiometricStatus() async {
    final isEnabled = await _storage.read(key: 'biometric_enabled') == 'true';
    setState(() {
      _isBiometricEnabled = isEnabled;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ApiService.updateUserDetails(
        fname: _fnameController.text,
        lname: _lnameController.text,
        phoneNumber: _phoneController.text,
        dob: _dobController.text,
        gender: _genderController.text,
      );

      if (success) {
        _fetchUserData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile.'),
        ));
      }
    }
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to enable biometrics',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        await _storage.write(key: 'biometric_enabled', value: 'true');
        setState(() {
          _isBiometricEnabled = true;
        });
      }
    } else {
      await _storage.delete(key: 'biometric_enabled');
      setState(() {
        _isBiometricEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[200],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/profile.png'), // Replace with your own image
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showEditProfileDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Enable Biometric Authentication'),
              value: _isBiometricEnabled,
              onChanged: _toggleBiometric,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoRow(Icons.email, "Email", email),
                  const Divider(color: Colors.purple),
                  _buildProfileInfoRow(Icons.phone, "Phone Number", phoneNumber),
                  const Divider(color: Colors.purple),
                  _buildProfileInfoRow(Icons.cake, "Date of Birth", dob),
                  const Divider(color: Colors.purple),
                  _buildProfileInfoRow(Icons.person, "Gender", gender),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _fnameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lnameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: false,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.black),
                        onPressed: () => _pickDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your date of birth';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _genderController.text,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _genderController.text = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _updateProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
