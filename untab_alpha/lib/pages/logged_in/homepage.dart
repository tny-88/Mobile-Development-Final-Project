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
  final _storage = const FlutterSecureStorage();
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = loadData();
  }

  Future<void> loadData() async {
    try {
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
    } catch (e) {
      // Handle errors appropriately
      if (mounted) {
        setState(() {
          username = "Error loading data";
        });
      }
    }
  }

  Future<void> _addMedication() async {
    final TextEditingController dosageController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController scheduleController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Medication'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(labelText: 'Dosage'),
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    TextField(
                      controller: scheduleController,
                      decoration: const InputDecoration(labelText: 'Schedule'),
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
                  child: isLoading ? CircularProgressIndicator() : const Text('Add'),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final name = nameController.text;
                    final dosage = dosageController.text;
                    final notes = notesController.text;
                    final schedule = scheduleController.text;

                    if (name.isNotEmpty && dosage.isNotEmpty && notes.isNotEmpty && schedule.isNotEmpty) {
                      // Call API to add medication
                      final success = await ApiService.addMedication(
                        name: name,
                        dosage: dosage,
                        notes: notes,
                        schedule: schedule,
                      );
                      if (success) {
                        // Reload data
                        await loadData();
                        Navigator.of(context).pop();
                      } else {
                        // Show error message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Failed to add medication.'),
                          ));
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill in all fields.'),
                        ));
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editMedication(Map<String, dynamic> medication) async {
    final TextEditingController dosageController = TextEditingController(text: medication['dosage']);
    final TextEditingController nameController = TextEditingController(text: medication['name']);
    final TextEditingController notesController = TextEditingController(text: medication['notes']);
    final TextEditingController scheduleController = TextEditingController(text: medication['schedule']);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Medication'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(labelText: 'Dosage'),
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    TextField(
                      controller: scheduleController,
                      decoration: const InputDecoration(labelText: 'Schedule'),
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
                  child: isLoading ? CircularProgressIndicator() : const Text('Update'),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final name = nameController.text;
                    final dosage = dosageController.text;
                    final notes = notesController.text;
                    final schedule = scheduleController.text;

                    if (name.isNotEmpty && dosage.isNotEmpty && notes.isNotEmpty && schedule.isNotEmpty && medication['medicationID'] != null && medication['medicationID'] is String) {
                      // Call API to update medication
                      final success = await ApiService.updateMedication(
                        id: medication['medicationID'],
                        name: name,
                        dosage: dosage,
                        notes: notes,
                        schedule: schedule,
                      );
                      if (success) {
                        // Reload data
                        await loadData();
                        Navigator.of(context).pop();
                      } else {
                        // Show error message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Failed to update medication.'),
                          ));
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill in all fields.'),
                        ));
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: FutureBuilder<void>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    const SizedBox(height: 20),
                    Text(
                      'Your Medications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    medications.isNotEmpty
                        ? SizedBox(
                            height: 150, // Fixed height for the horizontal list
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: medications.length,
                              itemBuilder: (context, index) {
                                final medication = medications[index];
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Card(
                                    child: InkWell(
                                      onTap: () {
                                        _editMedication(medication);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medication['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Dosage: ${medication['dosage']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
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
                        : const Text('No medications available.'),
                    const SizedBox(height: 20),
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                  style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              );
                            }).toList(),
                            if (emergencyContacts.length > 5)
                              const Text(
                                '...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        backgroundColor: Colors.purple[200],
        child: const Icon(Icons.add),
      ),
    );
  }
}
