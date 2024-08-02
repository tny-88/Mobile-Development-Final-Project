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

    String dosageUnit = 'ml'; // Default value
    String frequencyUnit = 'daily'; // Default value
    String frequencyValue = ''; // Frequency number value

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dosageController,
                        decoration: const InputDecoration(labelText: 'Dosage'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        decoration: const InputDecoration(labelText: 'Frequency Number'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          frequencyValue = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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
              child:const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
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
                    await loadData();
                    Navigator.of(context).pop();
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Failed to add medication.'),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
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
                                            Text(
                                              'Frequency: ${medication['frequency']}',
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
        child: const Icon(Icons.add)
      ),
    );
  }
}
