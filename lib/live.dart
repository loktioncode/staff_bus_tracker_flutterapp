import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:caaz_track/map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

enum ConfirmAction { ACCEPT }
Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ending Trip?'),
        content: const Text('This will reset your Bus Location and Exit'),
        actions: <Widget>[
          FlatButton(
            child: const Text('ACCEPT'),
            onPressed: () {
              exit(0);
            },
          )
        ],
      );
    },
  );
}

class LiveLocations extends StatefulWidget {
  final String selectedRoute;

  const LiveLocations(this.selectedRoute);

  //LiveLocations({Key key, @required this.selectedRoute}) : super(key: key);

  @override
  _LiveLocationsState createState() => _LiveLocationsState();
}

class _LiveLocationsState extends State<LiveLocations> {
  Timer timer;
  String selectedRoute;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 600), (Timer t) => getLive());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String selectedRoute = widget.selectedRoute;

    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
          title: Text('$selectedRoute Route'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: new Image.network(
                'https://media.giphy.com/media/BCIRKxED2Y2JO/giphy.gif',
              ),
            ),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 290.0,
              child: Column(
                children: <Widget>[
                  Text(
                    '$selectedRoute Route Trip',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 17),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: FlatButton(
                      onPressed: () {
                        getData();
                      },
                      child: Container(
                        width: 180,
                        height: 50,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blueAccent, width: 1.0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'END TRIP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addLocation(Position position) async {
    final Firestore myDatabase = Firestore.instance;
    final Geoflutterfire geo = Geoflutterfire();

    GeoFirePoint busLocation =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    await myDatabase.collection('live_locations').add({
      'position': busLocation.data,
      'route': widget.selectedRoute,
      'time': DateTime.now()
    });
  }

  Future getLive() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      //logic code goes here
      addLocation(position);

      print(position);
    }).catchError((dynamic e) {
      print(e);
    });
  }

  void getData() {
    final Firestore myDatabase = Firestore.instance;
    String routeInDB;
    timer.cancel();
    myDatabase
        .collection('live_locations')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot f) => deleteData(
          f.documentID, routeInDB = f.data['route'])); //print(f.data['route'])
    });
  }

  Future deleteData(String documentID, String routeInDB) async {
    final Firestore myDatabase = Firestore.instance;
    try {
      if (widget.selectedRoute != routeInDB) {
        print(selectedRoute);
      } else {
        myDatabase.collection('live_locations').document(documentID).delete();
        await _asyncConfirmDialog(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
