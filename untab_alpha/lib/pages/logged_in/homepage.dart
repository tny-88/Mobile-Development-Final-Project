import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untab_alpha/classes/api_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String username = "User";
  List<dynamic> medications = [];
  List<dynamic> emergencyContacts = [];
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userData = await ApiService.fetchUserData();
    if (userData != null && mounted) {
      setState(() {
        username = userData['fname'];
      });
    }

    final fetchedMedications = await ApiService.fetchMedications();
    if (fetchedMedications != null && mounted) {
      setState(() {
        medications = fetchedMedications;
      });
    }

    final fetchedContacts = await ApiService.fetchEmergencyContacts();
    if (fetchedContacts != null && mounted) {
      setState(() {
        emergencyContacts = fetchedContacts;
      });
    }
}


  Future<void> _logout() async {
    await _storage.delete(key: 'jwt_token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _addMedication() async {
    final TextEditingController dosageController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController scheduleController = TextEditingController();

    String dosageUnit = 'ml'; // Default value
    String frequencyUnit = 'daily'; // Default value
    String frequencyValue = ''; // Frequency number value

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dosageController,
                        decoration: InputDecoration(labelText: 'Dosage'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: dosageUnit,
                      onChanged: (String? newValue) {
                        setState(() {
                          dosageUnit = newValue!;
                        });
                      },
                      items: <String>['ml', 'tablets']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Frequency Number'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          frequencyValue = value;
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: frequencyUnit,
                      onChanged: (String? newValue) {
                        setState(() {
                          frequencyUnit = newValue!;
                        });
                      },
                      items: <String>['daily', 'hourly', 'weekly', 'biweekly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                TextField(
                  controller: scheduleController,
                  decoration: InputDecoration(labelText: 'Schedule'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                final name = nameController.text;
                final dosage = '${dosageController.text} $dosageUnit';
                final frequency = '$frequencyValue $frequencyUnit';
                final notes = notesController.text;
                final schedule = scheduleController.text;

                if (name.isNotEmpty && dosage.isNotEmpty && frequency.isNotEmpty) {
                  // Call API to add medication
                  final success = await ApiService.addMedication(
                    name: name,
                    dosage: dosage,
                    frequency: frequency,
                    notes: notes,
                    schedule: schedule,
                  );
                  if (success) {
                    // Reload data
                    loadData();
                    Navigator.of(context).pop();
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to add medication.'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in all required fields.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[200],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Medications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 10),
            medications.isNotEmpty
              ? SizedBox(
                height: 150,  // Fixed height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Container(
                      width: 150,  // Set a fixed width for the cards
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            // Navigate to detailed medication page
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication['name'],
                                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Dosage: ${medication['dosage']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Frequency: ${medication['frequency']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
              : Text('No medications available.'),
            SizedBox(height: 20),
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...emergencyContacts.take(5).map((contact) {
                      return Text(
                        '${contact['fname']} ${contact['lname']}: ${contact['phoneNumber']}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      );
                    }).toList(),
                    if (emergencyContacts.length > 5)
                      Text(
                        '...',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[200],
      ),
    );
  }
}
