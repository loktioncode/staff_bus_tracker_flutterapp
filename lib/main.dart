import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'dash.dart';

void main() => runApp(MyApp());

enum AuthMode { LOGIN, SINGUP }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // To adjust the layout according to the screen size
  // so that our layout remains responsive ,we need to
  // calculate the screen height
  double screenHeight;
  String email;
  String password;

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  // Set intial mode to login
  AuthMode _authMode = AuthMode.LOGIN;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            lowerHalf(context),
            upperHalf(context),
            if (_authMode == AuthMode.LOGIN)
              loginCard(context)
            else
              singUpCard(context),
            pageTitle(),
          ],
        ),
      ),
    );
  }

  Widget pageTitle() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Center(
        child: Text(
          "Bus Locator",
          style: TextStyle(
              fontSize: 34, color: Colors.white, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget loginCard(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: screenHeight / 4),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                //autovalidate: _autoValidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          labelText: "Your Email",
                        ),
                        validator: (String value) {
                          final bool isValid = EmailValidator.validate(value);
                          if (!isValid) {
                            return 'Invalid email. add @domainname.com';
                          }
                        },
                        //set state on saved
                        onSaved: (String value) {
                          email = value;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        autofocus: true,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Password is Required';
                          }
                        },
                        //set state on saved
                        onSaved: (String value) {
                          password = value;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          child: Text("Login"),
                          color: Color(0xFF4B9DFE),
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 38, right: 38, top: 15, bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save(); //onSaved is called!
                              login();
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Text(
              "Don't have an account ?",
              style: TextStyle(color: Colors.grey),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  _authMode = AuthMode.SINGUP;
                });
              },
              textColor: Colors.black87,
              child: Text("Create Account"),
            )
          ],
        )
      ],
    );
  }

  Widget singUpCard(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: screenHeight / 5),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Your Name",
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Name is Required';
                        }
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          labelText: "Your Email",
                        ),
                        validator: (String value) {
                          final bool isValid = EmailValidator.validate(value);
                          if (!isValid) {
                            return 'Invalid email. add @domainname.com';
                          }
                        },
                        //set state on saved
                        onSaved: (String value) {
                          email = value;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Password required !!!';
                          }
                        },
                        //set state on saved
                        onSaved: (String value) {
                          password = value;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Password must be at least 8 characters and include a special character and number",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        FlatButton(
                          child: Text("Sign Up"),
                          color: Color(0xFF4B9DFE),
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 38, right: 38, top: 15, bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save(); //onSaved is called!
                              signUp(email, password);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Text(
              "Already have an account?",
              style: TextStyle(color: Colors.grey),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  _authMode = AuthMode.LOGIN;
                });
              },
              textColor: Colors.black87,
              child: Text("Login"),
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FlatButton(
            child: Text(
              "Terms & Conditions",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget upperHalf(BuildContext context) {
    return Container(
      height: screenHeight / 2,
      color: Colors.blue,
    );
  }

  Widget lowerHalf(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: screenHeight / 2,
        color: Color(0xFFECF0F3),
      ),
    );
  }

  void login() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        AuthResult user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        //Navigator.of(context).pushReplacementNamed('/home');
        if (user == null) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    height: 80.0,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              });
        } else {
          Navigator.push(context,
              PageTransition(type: PageTransitionType.rotate, child: Menu()));
          print('DONE');
        }
      } catch (error) {
        switch (error.code) {
          case "ERROR_USER_NOT_FOUND":
            {
              final String errorMsg = "User not Found. Please try again.";
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        height: 100.0,
                        child: Center(
                          child: Text(errorMsg,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  fontSize: 16)),
                        ),
                      ),
                    );
                  });
            }
            break;
          case "ERROR_WRONG_PASSWORD":
            {
              final String errorMsg = "Password doesn\'t match your email.";
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        height: 100.0,
                        child: Center(
                          child: Text(errorMsg,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  fontSize: 16)),
                        ),
                      ),
                    );
                  });
            }
            break;
          default:
            {
              final errorMsg = "";
            }
        }
      }
    }
  }

  Future<FirebaseUser> signUp(email, password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                //width: 30,
                height: 100,
                child: Column(children: [
                  const Center(child: CircularProgressIndicator()),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Creating Account ...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              fontSize: 16)),
                    ),
                  ),
                ]),
              ),
            );
          });
      try {
        AuthResult user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        //login()
        print("ADDED");
        Timer(const Duration(seconds: 4), () {
          login();
          //Navigator.pop(context);
        });
      } catch (error) {
        switch (error.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            {
              const errorMsg = 'This email is already in use.';
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        height: 100.0,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(errorMsg,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    );
                  });
            }
            break;
          case 'ERROR_WEAK_PASSWORD':
            {
              const errorMsg =
                  'The password must be 6 characters long or more.';
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        height: 100.0,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(errorMsg,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    );
                  });
            }
            break;
          default:
            {
              var errorMsg = "";
            }
        }
      }
    }
  }
}
