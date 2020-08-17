import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

bool _isSelected = false;
String _selectedChip;
List<String> myList = List<String>();
dynamic distance;
dynamic address;
dynamic arrivalTime;
dynamic address1;

List<Marker> _markers = [
];



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
          myList.add(widget.chipName);
          _isSelected = isSelected;
          _selectedChip = widget.chipName;
          print(myList);
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

  //final dynamic lat =  position.;
  Geoflutterfire geo = Geoflutterfire();
  //GeoFirePoint myLocation = geo.point(latitude: , longitude: 77.641603);

  final dynamic position;
  var myDatabase = Firestore.instance;

  final loading = 'Seaching Route';
  final chooseOne = 'Choose Only One Route';

  var busLocations = <LatLng>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 12.0, bottom: 30.0),
        child: Container(
          width: 70.0,
          height: 70.0,
          child: FloatingActionButton(
              tooltip: 'Search',
              child: Center(
                child: Icon(
                  Icons.refresh,
                  size: 35.0,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                //action on Press
                if (_isSelected == false || myList.length > 1) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return _dialogBuilderOne(context, chooseOne);
                      });
                  myList = [];
                 
                } else {
                  
                  getLocations();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _dialog_Builder(context, loading));
                  Future.delayed(const Duration(seconds: 5), () {
                    Navigator.of(context).pop(true);
                  });

                }

                //Navigator.pop(context);
              }),
        ),
      ),
      body: _buildMap(),
    );
  }

  dynamic _dialog_Builder(BuildContext context, dynamic loading) {
    return SimpleDialog(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 40.0,
            //width: 50.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(' $loading',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 16)),
                  ),
                  const Center(child: CircularProgressIndicator())
                ]),
          ),
        )
      ],
    );
  }

  dynamic _dialogBuilderOne(BuildContext context, dynamic chooseOne) {
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
                child: Text(' $chooseOne',
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

  Widget _buildMap() {
    return Stack(children: [
      FlutterMap(
        options: new MapOptions(
          center: new LatLng(position.latitude, position.longitude),
          zoom: 15.0,
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
                      icon: Icon(Icons.my_location),
                      color: Colors.blueAccent[400],
                      iconSize: 40.0,
                      onPressed: () {
                        if (arrivalTime == null && distance == null) {
                          showBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(children: [
                                Container(
                                  color: Colors.blueAccent,
                                  height: 60.0,
                                  width: MediaQuery.of(context).size.width,
                                  //margin: const EdgeInsets.all(30.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      ' Please select a route',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: CircularProgressIndicator(),
                                )
                                //CircularProgressIndicator(),
                              ]),
                            ),
                          );
                        } else {
                          showBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(children: [
                                Container(
                                  color: Colors.blueAccent,
                                  height: 60.0,
                                  width: MediaQuery.of(context).size.width,
                                  //margin: const EdgeInsets.all(30.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      ' Bus is ${(arrivalTime / 60).round()} mins Away',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 25,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Text(
                                        ' $address1, $address',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.blueAccent,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.directions_bus,
                                          size: 25,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Text(
                                        '$distance kilometres away (Aprox)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.blueAccent,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          );
                        }
                      }),
                ),
              ),
              //for (int i = 0; _markers.length > i; i++) _markers[i],
            ],
          ),
          //THE BELOW LINE DRAWS PATH ON MAP
          //PolylineLayerOptions(polylines: [
          //  Polyline(points: busLocations, strokeWidth: 3.0, color: Colors.blueAccent)
          //]),
        ],
      ),
      Positioned(
          top: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

  dynamic getLocations() {
    arrivalTime = null;
    distance = null;
    final Geoflutterfire geo = Geoflutterfire();

    final Query queryRef = myDatabase
        .collection('live_locations')
        .where('route', isEqualTo: myList[0]);

    var geoRef = geo.collection(collectionRef: queryRef);

    var res = geoRef.snapshot();
    res.forEach((QuerySnapshot f) async {
      if (f.documents.isNotEmpty) {
        for (int i = 0; i < f.documents.length; i++) {
          //print(f.documents[i].data['position']);
          final dynamic pos = f.documents[i].data['position'];
          final GeoPoint geoLoc = pos['geopoint'];
          final LatLng point = LatLng(geoLoc.latitude, geoLoc.longitude);

          final GeoFirePoint passengerLocation = geo.point(
              latitude: position.latitude, longitude: position.longitude);
          distance = passengerLocation.distance(
              lat: geoLoc.latitude, lng: geoLoc.longitude);

          arrivalTime = 80 / distance;
          //print(distance);

          final List<Placemark> p = await Geolocator()
              .placemarkFromCoordinates(geoLoc.latitude, geoLoc.longitude);
          final Placemark place = p[0];

          address = place.subLocality; //checks for road and area
          address1 = place.thoroughfare;

          busLocations.add(point);

          //adding point to markers list
          _markers.add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: point,
              builder: (BuildContext ctx) => Container(
                child: IconButton(
                    icon: Icon(Icons.location_on),
                    color: Colors.blueAccent,
                    iconSize: 40.0,
                    onPressed: () {
                      print(point);
                    }),
              ),
            ),
          );
        }
        print(_markers.length);
      } else {
        print('TRIP UNAVAILABLE');
        
        // SystemNavigator.pop();
      }
    });
    _markers = [];
  }
}
