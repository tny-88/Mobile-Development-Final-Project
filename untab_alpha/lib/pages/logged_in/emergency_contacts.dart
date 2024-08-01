import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untab_alpha/classes/api_service.dart';

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
          title: Text('Add Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: fnameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lnameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(labelText: 'Relationship'),
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to add contact.'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in all fields.'),
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
        title: Text('Emergency Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: contacts.isNotEmpty
            ? ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('${contact['fname']} ${contact['lname']}'),
                      subtitle: Text('${contact['relationship']}\n${contact['phoneNumber']}'),
                      isThreeLine: true,
                      leading: Icon(Icons.contact_phone, color: Colors.purple[200]),
                    ),
                  );
                },
              )
            : Center(child: Text('No emergency contacts available.')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[200],
      ),
    );
  }
}
