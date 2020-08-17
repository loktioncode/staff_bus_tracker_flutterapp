import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import './home.dart';
import './user_home.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
          appBar: AppBar(elevation: 0, backgroundColor: Colors.white, actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () {
                  //exit app
                  SystemNavigator.pop();
                },
              ),
            ),
          ]),
          backgroundColor: Colors.white12,
          body: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 45.0),
                  child: Container(
                    decoration: new BoxDecoration(
                      image: DecorationImage(
                        image: new AssetImage('assets/images/logo.png'),
                        fit: BoxFit.fill,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    height: 200.0,
                    width: 280.0,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2,
                left: MediaQuery.of(context).size.width / 6,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)),
                        color: Colors.white,
                        textColor: Colors.blue,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rotate,
                                  child: UserHomePage()));
                        },
                        child: Text(
                          "PASSENGER".toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rotate,
                                  child: HomePage()));
                        },
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text("BUS DRIVER".toUpperCase(),
                            style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
