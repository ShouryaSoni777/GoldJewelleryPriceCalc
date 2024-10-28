import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gold_prices_per_carat/auth.dart';
import 'package:gold_prices_per_carat/firebase_options.dart';
import 'package:gold_prices_per_carat/goldpage.dart';
import 'package:gold_prices_per_carat/silverpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

int authkey = -1;
int referenceId = -1;
bool isAuthenticated = false;

enum gstOptions { applicable, notApplicable }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  String font = "Quicksand";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retail Jewellery Price Calculator',
      theme: ThemeData(
          fontFamily: font,
        ),
      // theme: ThemeData(
      //   primaryColor: Colors.transparent,
      // ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> isFirstLaunchfunc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstLaunch =
        prefs.getBool('isFirstLaunch') ?? true; // Default is true
    if (isFirstLaunch) {
      authkey = authKeyGenerator();
      referenceId = referenceIdGenerator();
      print("Auth Key: " + authkey.toString());
      print("Reference ID: " + referenceId.toString());
      await prefs.setBool('isFirstLaunch', false);
      await prefs.setInt('authkey', authkey);
      await prefs.setInt('referenceID', referenceId);
      await prefs.setBool('isAuthenticated', false);
      isAuthenticated = false;
      userCollection.doc(referenceId.toString()).set({
        'reference_id': referenceId,
        'authkey': authkey,
        'is_authenticated': false
      });
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  AuthPage(authkey: authkey, referenceId: referenceId)));
    } else if (isFirstLaunch == false) {
      int? storedkey = prefs.getInt('authkey');
      bool? isSauthenticated = prefs.getBool('isAuthenticated');
      int? referenceSID = prefs.getInt('referenceID');
      isAuthenticated = isSauthenticated ?? false;
      authkey = storedkey ?? -1;
      referenceId = referenceSID ?? -1;
      var userDocReference =
          await userCollection.doc(referenceId.toString()).get();
      var fAuthenticated =
          userDocReference.data()?['is_authenticated'] ?? false;
      if (isAuthenticated == false || fAuthenticated == false) {
        await prefs.setBool('isAuthenticated', false);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    AuthPage(authkey: authkey, referenceId: referenceId)));
      }
    }
  }

  List<Map> routes = [
    {'pageName': "Gold Price Calculator", 'route': const GoldPage()},
    {'pageName': "Silver Price Calculator", 'route': const SilverPage()}
  ];

  @override
  void initState() {
    super.initState();
    isFirstLaunchfunc();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Products",style: TextStyle(color: Colors.white),),centerTitle: true,backgroundColor: Color(0xFF002147),),
      body: Container(
        child: ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              return Card.outlined(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  visualDensity: VisualDensity(horizontal: VisualDensity.maximumDensity,vertical: VisualDensity.maximumDensity),
                  title: Text(routes[index]['pageName']),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => routes[index]['route']));
                  },
                  trailing: CupertinoListTileChevron(),
                ),
              );
            }),
      ),
    );
  }
}
