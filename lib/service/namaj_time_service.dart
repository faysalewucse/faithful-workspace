import 'package:firebase_database/firebase_database.dart';

class NamajTimeService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  getNamajTime() {
    _database.child('namaj').child('time').once().then((DatabaseEvent event) {
      return event.snapshot.value as Map;
    });
  }
}
