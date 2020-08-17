import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:page_transition/page_transition.dart';
import 'live.dart';

bool _isSelected = false;
String _selectedChip;
List<String> driveRoutes = List<String>();

class FilterChipWidget extends StatefulWidget {
  final String chipName;

  FilterChipWidget({Key key, this.chipName}) : super(key: key);

  @override
  _FilterChipWidgetState createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      //FilterChip adds a tick and allows to select multiple options
      label: Text(widget.chipName),
      labelStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      backgroundColor: Theme.of(context).primaryColorLight,
      selected: _isSelected,
      onSelected: (bool isSelected) {
        setState(() {
          driveRoutes.add(widget.chipName);
          _isSelected = isSelected;
          _selectedChip = widget.chipName;
          print(driveRoutes);
        });
      },
      selectedColor: Theme.of(context).primaryColor,
    );
  }
}

class MyLocator extends StatelessWidget {
  MyLocator({
    this.position,
  });

  final dynamic position;
  var myDatabase = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 12.0, bottom: 30.0),
        child: Container(
          width: 70.0,
          height: 70.0,
          child: FloatingActionButton(
              tooltip: 'Start Route',
              child: new Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.navigation,
                    size: 30.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: const Text('GO'),
                ),
              ]),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                //action on Press
                if (_isSelected == false || driveRoutes.length > 1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _dialog_Builder(context));
                  driveRoutes = [];
                  _isSelected = false;
                } else {
                  //print('ADDING TO DB');
                  createRecord();
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rotate,
                          child: LiveLocations(driveRoutes[0])));
                }
              }),
        ),
      ),
      body: _buildMap(),
    );
  }

  dynamic _dialog_Builder(BuildContext contextt) {
    return SimpleDialog(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 80.0,
            width: 50.0,
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text('Choose One Route ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text('(Restart App to Refresh Location)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.orangeAccent,
                        fontSize: 12)),
              ),
            ]),
          ),
        )
      ],
    );
  }

  void createRecord() async {
    var nhasi = DateTime.now().millisecondsSinceEpoch;

    //adding document with custom ID
    await myDatabase.collection('BusLocator').document(driveRoutes[0]).setData({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'route': driveRoutes[0],
      'time': nhasi
    });
  }

  Widget _buildMap() {
    return Stack(children: [
      FlutterMap(
        options: new MapOptions(
          center: new LatLng(position.latitude, position.longitude),
          zoom: 17.0,
        ),
        layers: [
          new TileLayerOptions(
              urlTemplate: "https://api.tiles.mapbox.com/v4/"
                  "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoicmFzLWJlcmUiLCJhIjoiY2s4a3BjNDNoMDNlNzNrbjEyaXpzazNvaSJ9.8ft038fVmbJ_48K8VCC45w',
                'id': 'mapbox.satellite', //
              }),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                    position.latitude,
                    position
                        .longitude), //LatLng(_currentPosition.latitude, _currentPosition.longitude),
                builder: (context) => new Container(
                  child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: Colors.blueAccent,
                      iconSize: 40.0,
                      onPressed: () {
                        print(position);
                      }),
                ),
              ),
            ],
          ),
        ],
      ),
      Positioned(
          top: 50.0,
          child: Row(
            children: <Widget>[
              SizedBox(width: 30),
              FilterChipWidget(chipName: 'Eastern '),
              SizedBox(width: 25),
              FilterChipWidget(chipName: 'Southern'),
              SizedBox(width: 25),
              FilterChipWidget(chipName: 'Western'),
            ],
          )),
    ]);
  }
}
