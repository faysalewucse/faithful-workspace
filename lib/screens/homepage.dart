import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:faithful_workspace/screens/admin_login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../widgets/namaj_time_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isAdmin = false;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  IconData notifyIcon = Icons.notifications;
  bool status = false;
  var location = '';
  double latitude = 23.777176;
  double longitude = 90.39945;
  Map<String, dynamic> namajData = {};
  late PrayerTimes prayerTimes; // Add this field

  // final myCoordinates = Coordinates(latitude, longitude);

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      location = "${place.subLocality}, ${place.locality}";
    });
  }

  void fetchData() {
    _database
        .child('namaj')
        .child('time')
        .onValue
        .listen((DatabaseEvent event) {
      Map<String, dynamic> data = {};

      final values = event.snapshot.value as Map;
      values.forEach((key, value) {
        data[key] = value;
      });

      setState(() {
        namajData = data;
      });
    });
  }

  onTimeChange() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final currentTime = DateTime.now();

      if ("${reduceTime(namajData[prayerTimes.currentPrayer().name] ?? "")}:01" ==
          DateFormat('h:mm:ss').format(currentTime)) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: -1,
                channelKey: 'alerts',
                title:
                    "It's ${prayerTimes.nextPrayer().name.toUpperCase()} Time",
                body: "আসি ভাই নামাজ এর প্রস্তুতি নেই",
                bigPicture: 'assets/namaj_time_back2.png',
                // largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
                notificationLayout: NotificationLayout.BigPicture,
                payload: {'notificationId': '1234567890'}),
            actionButtons: [
              NotificationActionButton(
                  key: 'DISMISS',
                  label: 'Dismiss',
                  actionType: ActionType.DismissAction,
                  isDangerousOption: true)
            ]);
      }
      setState(() {});
    });
  }

  String reduceTime(String inputTime) {
    print("input Time: $inputTime");
    if (inputTime.isNotEmpty) {
      // Parse the input time
      final DateFormat format = DateFormat('H:mm');
      DateTime parsedTime = format.parse(inputTime);

      // Subtract 5 minutes
      parsedTime = parsedTime.subtract(const Duration(minutes: 5));

      // Format the new time as a string
      String newTime = format.format(parsedTime);

      return newTime;
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    isAdmin = storage.read("loggedIn") ?? false;

    _determinePosition();
    fetchData();

    // Calculate prayer times here and store them in the 'prayerTimes' field
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);

    onTimeChange();
  }

  @override
  Widget build(BuildContext context) {
    var MAX_HEIGHT = MediaQuery.of(context).size.height;
    var MAX_WIDTH = MediaQuery.of(context).size.width;

    getCurrentPrayer(int index) {
      if (index == 2 || index == 0) return 'Fajar';
      if (index == 3) return 'Dhuhr';
      if (index == 4) return 'Asr';
      if (index == 5) return 'Maghrib';
      if (index == 6) return 'Isha';
    }

    getNextPrayer(int index) {
      if (index == 2 || index == 0) return prayerTimes.fajr;
      if (index == 3) return prayerTimes.dhuhr;
      if (index == 4) return prayerTimes.asr;
      if (index == 5) return prayerTimes.maghrib;
      if (index == 6) return prayerTimes.isha;
    }

    getCurrentPrayerTime(int index) {
      if (index == 2 || index == 0) {
        String Time;
        int time = prayerTimes.fajr.minute + 5;
        if (time < 10) {
          Time = "0$time";
        } else {
          Time = time.toString();
        }
        return ("0${prayerTimes.fajr.hour}:$Time");
      }
      if (index == 3) {
        return DateFormat.Hm().format(prayerTimes.dhuhr);
      }
      if (index == 4) {
        return DateFormat("hh:mm").format(prayerTimes.asr);
      }
      if (index == 5) {
        return DateFormat("hh:mm").format(prayerTimes.maghrib);
      }
      if (index == 6) {
        return DateFormat("hh:mm").format(prayerTimes.isha);
      }
      if (index == 7) {
        return DateFormat.Hm().format(prayerTimes.sunrise);
      }
      if (index == 8) {
        return DateFormat.Hm().format(prayerTimes.fajr);
      }
      if (index == 9) {
        return "${prayerTimes.sunrise.hour}:${prayerTimes.sunrise.minute + 15}";
      }
    }

    getRemainingTime(int startMinute, int startHour, int stopMinute,
        int stopHour, int startSecond, int stopSecond) {
      if (startHour > 12 && stopHour < 12) stopHour += 24;
      if (startMinute > stopMinute) {
        stopMinute += 61;
        --stopHour;
      }
      if (startSecond > stopSecond) {
        stopSecond += 61;
        stopSecond--;
      }

      String diffMinute = (stopMinute - startMinute).toString();
      String diffHours = (stopHour - startHour).toString();
      String diffSeconds = (stopSecond - startSecond).toString();

      return [diffHours, diffMinute, diffSeconds];
    }

    String getTimes(DateTime now, PrayerTimes prayerTimes, int index) {
      String time = getRemainingTime(
          now.minute,
          now.hour,
          getNextPrayer(prayerTimes.nextPrayer().index)!.minute,
          getNextPrayer(prayerTimes.nextPrayer().index)!.hour,
          now.second,
          getNextPrayer(prayerTimes.nextPrayer().index)!.second)[index];

      if (int.parse(time) < 10) {
        return "0$time";
      } else {
        return time;
      }
    }

    DateTime now = DateTime.now();

    return Scaffold(
      resizeToAvoidBottomInset: true,
        drawer: Drawer(
          width: MAX_WIDTH * 0.6,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: MAX_WIDTH * 0.1,
                      color: Colors.white,
                    ),
                    Text(
                      'Faithful',
                      style: TextStyle(
                          fontSize: MAX_WIDTH * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Workspace',
                      style: TextStyle(
                          fontSize: MAX_WIDTH * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                title:  Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.blueAccent,),
                    const SizedBox(width: 5,),
                    Text('Admin', style: TextStyle(fontSize: MAX_WIDTH * 0.04, fontWeight: FontWeight.w600),),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                },
              ),
              const Divider(),
              ListTile(
                title:  Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.blueAccent,),
                    const SizedBox(width: 5,),
                    Text('Settings', style: TextStyle(fontSize: MAX_WIDTH * 0.04, fontWeight: FontWeight.w600),),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text(
            'Faithful Workspace',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(FontAwesomeIcons.bars));
          }),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh))
          ],
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  "Next Prayer (${getCurrentPrayer(prayerTimes.nextPrayer().index)}) Time Remaining",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${getTimes(now, prayerTimes, 0)}:",
                      maxLines: 2,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: MAX_WIDTH * 0.15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${getTimes(now, prayerTimes, 1)}:",
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: MAX_WIDTH * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getTimes(now, prayerTimes, 2),
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: MAX_WIDTH * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "NAMAJ",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                    const Text(
                      "WAKTO",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Text(
                        "JAMA'AT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              NamajTimeCard(
                  title: 'Fajr',
                  wakto: getCurrentPrayerTime(2)!,
                  height: MAX_HEIGHT,
                  color: Colors.white70,
                  jamat: namajData['fajr'] ?? "",
                  textSize: MAX_WIDTH * 0.05,),
              NamajTimeCard(
                  title: 'Dhuhr',
                  wakto: getCurrentPrayerTime(3)!,
                  height: MAX_HEIGHT,
                  color: Colors.white70,
                  jamat: namajData['dhuhr'] ?? "",
                  textSize: MAX_WIDTH * 0.05,),
              NamajTimeCard(
                  title: 'Asr',
                  wakto: getCurrentPrayerTime(4)!,
                  height: MAX_HEIGHT,
                  color: Colors.white38,
                  jamat: namajData['asr'] ?? "",
                  textSize: MAX_WIDTH * 0.05,),
              NamajTimeCard(
                  title: 'Maghrib',
                  wakto: getCurrentPrayerTime(5)!,
                  height: MAX_HEIGHT,
                  color: Colors.white70,
                  jamat: namajData['maghrib'] ?? "",
                  textSize: MAX_WIDTH * 0.05,),
              NamajTimeCard(
                  title: 'Esha',
                  wakto: getCurrentPrayerTime(6)!,
                  height: MAX_HEIGHT,
                  color: Colors.white38,
                  jamat: namajData['isha'] ?? "",
                  textSize: MAX_WIDTH * 0.05,),
            ],
          ),
        ),);
  }
}
