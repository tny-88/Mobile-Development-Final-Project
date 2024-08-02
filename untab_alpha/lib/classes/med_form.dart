import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untab_alpha/classes/api_service.dart';

class MedicationForm extends StatefulWidget {
  final Map<String, dynamic>? medication;
  final Function onSubmit;

  const MedicationForm({Key? key, this.medication, required this.onSubmit}) : super(key: key);

  @override
  _MedicationFormState createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  String dosageUnit = 'ml';
  String frequencyUnit = 'times per day';
  String frequencyValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      nameController.text = widget.medication!['name'];
      dosageController.text = widget.medication!['dosage'];
      notesController.text = widget.medication!['notes'] ?? '';
      scheduleController.text = widget.medication!['schedule'] ?? '';
      frequencyValue = widget.medication!['frequency'] ?? '';
    }
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        return DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
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
                  items: <String>['ml', 'tablets'].map<DropdownMenuItem<String>>((String value) {
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
                  items: <String>['times per day'].map<DropdownMenuItem<String>>((String value) {
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
              onTap: () async {
                DateTime? scheduledTime = await showDateTimePicker(context);
                if (scheduledTime != null) {
                  scheduleController.text = DateFormat('yyyy-MM-dd HH:mm').format(scheduledTime);
                }
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
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            final name = nameController.text;
            final dosage = '${dosageController.text} $dosageUnit';
            final frequency = frequencyValue;
            final notes = notesController.text;
            final schedule = scheduleController.text;

            if (name.isNotEmpty && dosage.isNotEmpty && frequency.isNotEmpty && schedule.isNotEmpty) {
              await widget.onSubmit({
                'name': name,
                'dosage': dosage,
                'frequency': frequency,
                'notes': notes,
                'schedule': schedule,
              });
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all required fields.')),
              );
            }
          },
        ),
      ],
    );
  }
}
