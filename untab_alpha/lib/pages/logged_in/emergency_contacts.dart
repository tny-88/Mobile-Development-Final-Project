import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untab_alpha/classes/api_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({super.key});

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  List<dynamic> contacts = [];
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final fetchedContacts = await ApiService.fetchEmergencyContacts();
    if (fetchedContacts != null && mounted) {
      setState(() {
        contacts = fetchedContacts;
      });
    }
  }

  Future<void> _addContact() async {
    final TextEditingController fnameController = TextEditingController();
    final TextEditingController lnameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController relationshipController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: fnameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lnameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                ),
              ],
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
              child: const Text('Add'),
              onPressed: () async {
                final fname = fnameController.text;
                final lname = lnameController.text;
                final phoneNumber = phoneController.text;
                final relationship = relationshipController.text;

                if (fname.isNotEmpty && lname.isNotEmpty && phoneNumber.isNotEmpty && relationship.isNotEmpty) {
                  // Call API to add contact
                  final success = await ApiService.addEmergencyContact(
                    fname: fname,
                    lname: lname,
                    phoneNumber: phoneNumber,
                    relationship: relationship,
                  );
                  if (success) {
                    // Reload contacts
                    loadContacts();
                    Navigator.of(context).pop();
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to add contact.'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please check if all fields are valid.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editContact(Map<String, dynamic> contact) async {
    final TextEditingController fnameController = TextEditingController(text: contact['fname']);
    final TextEditingController lnameController = TextEditingController(text: contact['lname']);
    final TextEditingController phoneController = TextEditingController(text: contact['phoneNumber']);
    final TextEditingController relationshipController = TextEditingController(text: contact['relationship']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: fnameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lnameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                ),
              ],
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
              onPressed: () async {
                final fname = fnameController.text;
                final lname = lnameController.text;
                final phoneNumber = phoneController.text;
                final relationship = relationshipController.text;

                if (fname.isNotEmpty && lname.isNotEmpty && phoneNumber.isNotEmpty && relationship.isNotEmpty) {
                  // Call API to update contact
                  final success = await ApiService.updateEmergencyContact(
                    contactId: contact['contactID'],
                    fname: fname,
                    lname: lname,
                    phoneNumber: phoneNumber,
                    relationship: relationship,
                  );
                  if (success) {
                    // Reload contacts
                    loadContacts();
                    Navigator.of(context).pop();
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to update contact.'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please check if all fields are valid.'),
                  ));
                }
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final success = await ApiService.deleteEmergencyContact(contact['contactID']);
                if (success) {
                  // Reload contacts
                  loadContacts();
                  Navigator.of(context).pop();
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Failed to delete contact.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showContactOptions(Map<String, dynamic> contact) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Options'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Contact'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _editContact(contact);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Call Contact'),
                  onTap: () {
                    Navigator.of(context).pop();
                    FlutterPhoneDirectCaller.callNumber(contact['phoneNumber']);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[200],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadContacts,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: contacts.isNotEmpty
              ? ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('${contact['fname']} ${contact['lname']}'),
                        subtitle: Text('${contact['relationship']}\n${contact['phoneNumber']}'),
                        isThreeLine: true,
                        leading: Icon(Icons.contact_phone, color: Colors.purple[200]),
                        onTap: () => _showContactOptions(contact),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No emergency contacts available.')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: Colors.purple[200],
        child: const Icon(Icons.add),
      ),
    );
  }
}
