import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:adhan/adhan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../widgets/namaj_time_card.dart';
import '../models/namaj_time_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  IconData notifyIcon = Icons.notifications;
  bool status = false;
  var location = '';
  double latitude = 23.777176;
  double longitude = 90.39945;

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

  Map<String, dynamic> namajData = {};

  void fetchData() {
    NamajTimeModel namajTimeModel;
    _database.child('namaj').child('time').once().then((DatabaseEvent event) {
      Map<String, dynamic> data = {};

      final values = event.snapshot.value as Map;
      values.forEach((key, value) {
        data[key] = value;
      });

      setState(() {
        namajData = data;
        namajTimeModel = NamajTimeModel.fromJson(data);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    _determinePosition();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        statusBarHeight;
    var width = MediaQuery.of(context).size.width;
    var screen = height * width;

    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    getCurrentPrayer(int index) {
      if (index == 2 || index == 0) return 'Fajar';
      if (index == 3) return 'Zuhor';
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
        stopMinute += 60;
        --stopHour;
      }
      if (startSecond > stopSecond) {
        stopSecond += 60;
        --stopSecond;
      }

      String diffMinute = (stopMinute - startMinute).toString();
      String diffHours = (stopHour - startHour).toString();
      String diffSeconds = (stopSecond - startSecond).toString();

      return [diffHours, diffMinute, diffSeconds];
    }

    DateTime now = DateTime.now();

    double responsiveFontSize = (height * width) / 11000;

    return Scaffold(
        drawer: Drawer(
          width: width * 0.6,
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
                      size: responsiveFontSize * 2.5,
                      color: Colors.white,
                    ),
                    Text(
                      'Faithful',
                      style: TextStyle(
                          fontSize: responsiveFontSize * 1.1,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Workspace',
                      style: TextStyle(
                          fontSize: responsiveFontSize / 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Item 2'),
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
                    Column(
                      children: [
                        Text(
                          "${getRemainingTime(now.minute, now.hour, getNextPrayer(prayerTimes.nextPrayer().index)!.minute, getNextPrayer(prayerTimes.nextPrayer().index)!.hour, now.second, getNextPrayer(prayerTimes.nextPrayer().index)!.second)[0]}:",
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: responsiveFontSize * 3,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text("Hour"),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "${getRemainingTime(now.minute, now.hour, getNextPrayer(prayerTimes.nextPrayer().index)!.minute, getNextPrayer(prayerTimes.nextPrayer().index)!.hour, now.second, getNextPrayer(prayerTimes.nextPrayer().index)!.second)[1]}:",
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: responsiveFontSize * 3,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text("Minutes")
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          getRemainingTime(
                              now.minute,
                              now.hour,
                              getNextPrayer(prayerTimes.nextPrayer().index)!
                                  .minute,
                              getNextPrayer(prayerTimes.nextPrayer().index)!
                                  .hour,
                              now.second,
                              getNextPrayer(prayerTimes.nextPrayer().index)!
                                  .second)[2],
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: responsiveFontSize * 3,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text("Seconds")
                      ],
                    )
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
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "WAKTO",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Text(
                        "JAMA'AT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              NamajTimeCard(
                  title: 'Fajr',
                  wakto: getCurrentPrayerTime(2)!,
                  height: height,
                  color: Colors.white70,
                  jamat: namajData['fajr'] ?? "",
                  textSize: responsiveFontSize),
              NamajTimeCard(
                  title: 'Zuhor',
                  wakto: getCurrentPrayerTime(3)!,
                  height: height,
                  color: Colors.white70,
                  jamat: namajData['zuhor'] ?? "",
                  textSize: responsiveFontSize),
              NamajTimeCard(
                  title: 'Asr',
                  wakto: getCurrentPrayerTime(4)!,
                  height: height,
                  color: Colors.white38,
                  jamat: namajData['asr'] ?? "",
                  textSize: responsiveFontSize),
              NamajTimeCard(
                  title: 'Maghrib',
                  wakto: getCurrentPrayerTime(5)!,
                  height: height,
                  color: Colors.white70,
                  jamat: namajData['maghrib'] ?? "",
                  textSize: responsiveFontSize),
              NamajTimeCard(
                  title: 'Esha',
                  wakto: getCurrentPrayerTime(6)!,
                  height: height,
                  color: Colors.white38,
                  jamat: namajData['isha'] ?? "",
                  textSize: responsiveFontSize),
            ],
          ),
        ));
  }
}
