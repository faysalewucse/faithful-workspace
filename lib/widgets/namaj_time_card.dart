import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class NamajTimeCard extends StatelessWidget {
  final String title;
  final String wakto;
  final String? jamat;
  final double height;
  final Color color;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    Future<void> updatePrayerTime(String prayer, String newTime) async {
      final databaseReference = FirebaseDatabase.instance.ref();

      try {
        // Specify the path to the "namaj" root and the specific prayer (e.g., "fajr").
        final prayerRef = databaseReference.child('namaj/time/$prayer');

        // Update the time with the new value.
        await prayerRef.set(newTime);

        print('Prayer time for $prayer updated successfully.');
      } catch (error) {
        print('Error updating prayer time: $error');
      }
    }

    TimeOfDay _convertToTimeOfDay(String timeString) {
      final List<String> parts = timeString.split(':');
      if (parts.length == 2) {
        final int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
      return TimeOfDay.now();
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay initialTime = _convertToTimeOfDay(jamat!);

      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (picked != null && jamat != null) {
        String formattedTime = picked.format(context).replaceAll(RegExp('[APM ]'), ''); // Remove AM/PM and spaces

        updatePrayerTime(title.toLowerCase(), formattedTime);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.blue[100]!, blurRadius: 3)]),
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: TextStyle(
                    fontSize: textSize, color: Theme.of(context).primaryColor)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(wakto,
                    style: TextStyle(
                        fontSize: textSize,
                        color: Theme.of(context).primaryColor)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final storage = GetStorage();
                        if(storage.read("loggedIn") ?? false){
                          _selectTime(context); // Show the time picker.
                        }
                      },
                      child: Text(
                        jamat!,
                        style: TextStyle(
                            fontSize: textSize,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.notifications,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  const NamajTimeCard({
    super.key,
    required this.title,
    required this.wakto,
    required this.height,
    required this.color,
    required this.textSize,
    required this.jamat,
  });
}
