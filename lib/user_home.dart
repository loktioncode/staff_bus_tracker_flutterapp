import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './user_map.dart';

import 'dart:async';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  Position _currentPosition;

  @override
  void initState() {
    super.initState();

    //runs function on widget build
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    Widget map;

    if (_currentPosition != null) {
      map = MyLocator(position: _currentPosition);
    } else {
      map = Scaffold(
        appBar: AppBar(
          title: const Text('Passenger'),
        ),
        body: Column(
          children: <Widget>[
            new Image.network(
              'https://media.giphy.com/media/cR9cLG8VNa3m0/giphy.gif',
            ),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 290.0,
              child: Center(
                child: Text(
                  'Please turn ON your Location',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      );
      if (_currentPosition == null) {
        print("LOCATION NOT FOUND");
      }
    }

    return map;
  }

  Future _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((dynamic e) {
      print(e);
    });
  }
}
