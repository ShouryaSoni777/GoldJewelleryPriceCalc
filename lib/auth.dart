import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gold_prices_per_carat/main.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int authKeyGenerator() {
  Random random = Random();
  int min = 10000000;
  int max = 99999999;
  return min + random.nextInt(max - min + 1);
}

int referenceIdGenerator(){
  Random random = Random();
  int min = 1000000;
  int max = 9999999;
  return min + random.nextInt(max - min + 1);
}

class AuthPage extends StatefulWidget {
  final int authkey;
  final int referenceId;
  const AuthPage({Key? key,required this.authkey,required this.referenceId}) : super(key: key);
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isAuthentic = false;
  final scaffoldkey = GlobalKey<ScaffoldState>();
  String authText = "";
  final userCollection = FirebaseFirestore.instance.collection('users');

  authenticate(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (val == widget.authkey) {
      setState(() {
        authText = "Authentication successful.";
      });
      prefs.setBool('isAuthenticated', true);
      userCollection.doc(widget.referenceId.toString()).update({'is_authenticated':true});
      Navigator.pop(context);
    } else {
      setState(() {
        authText = "Authentication unsuccessful, Invalid Authentication key.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    TextEditingController authKeycontroller = TextEditingController();
    return PopScope(
      canPop: false,
          child: Scaffold(
            key: scaffoldkey,
            body: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFfdd835), Color(0xFFf9a825)])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text("Welcome!",
                        style: TextStyle(
                            color: Color(0xFFc62828),
                            fontSize: 30,
                            fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:height*2/100,bottom: height*2/100),
                    child: Text("Reference ID: " + referenceId.toString()),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, top: 10),
                    child: const Text(
                        "Please enter you Authentication key to continue",
                        style: TextStyle(
                            color: Color(0xFFc62828),
                            fontSize: 15,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: width * 7 / 100, right: width * 7 / 100),
                    child: PinCodeTextField(
                      controller: authKeycontroller,
                      onChanged: (val) {
                        authKeycontroller.text = val;
                      },
                      onCompleted: (val) {
                        authenticate(int.parse(val));
                      },
                      cursorColor: const Color(0xFFc62828),
                      textCapitalization: TextCapitalization.characters,
                      textStyle: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                          selectedColor: const Color(0xFFc62828),
                          activeColor: const Color(0xFFc62828),
                          inactiveColor: const Color(0xFFc62828),
                          fieldWidth: width * 9 / 100,
                          shape: PinCodeFieldShape.underline,
                          activeFillColor: const Color(0xFFc62828),
                          inactiveFillColor: const Color(0xFFc62828),
                          selectedFillColor: const Color(0xFFc62828)),
                      appContext: context,
                      length: 8,
                      animationType: AnimationType.fade,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:height*5/100),
                    child: Text(authText),
                  )
                ],
              ),
            ),
          )
    );
  }
}
