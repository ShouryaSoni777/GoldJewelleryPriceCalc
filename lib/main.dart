import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retail Jewellery Price Calculator',

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
  final GlobalKey _key = GlobalKey();
  DateTime dt = DateTime.now();
  String df = formatDate(DateTime.now().toLocal(), [dd, '-', mm, '-', yyyy]);
  String time = DateFormat('hh:mm').format(DateTime.now());
  Timer? timer;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController weightFieldController = TextEditingController();
  TextEditingController purityController = TextEditingController();
  String textEditingControllerInput = "0";
  Color kColorRed = const Color(0xFFc62828);
  Color kColorWhite = Colors.white;
  final Color _cursorColor = Colors.black;
  ScreenshotController controller = ScreenshotController();
  int fineGoldPrice = 0;
  double weightInGrams = 0.0;
  int purity = 0;
  String totalPrice = "0";

  final InputDecoration _decorationGold = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Fine Gold(999)",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationWeight = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Weight (in grams)",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationPurity = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Karat Index",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

  updateTime() {
    setState(() {
      time = DateFormat('hh:mm').format(DateTime.now());
    });
  }

  @override
  void initState() {
    super.initState();
    functest();
  }

  functest() async {
    await Permission.storage.request();
    timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) => setState(() {
              updateTime();
            }));
  }

  int calculatePrice(int goldFinePrice, double weight, int purity) {
    double wastage = 10 / 100; // 10 percent.
    int makingCost = ((weight * wastage) * goldFinePrice).toInt();
    // print(purity);
    int basePrice = (((purity / 100) * goldFinePrice) * weight).toInt();
    return basePrice + makingCost;
  }

  @override
  Widget build(BuildContext context) {

    void updateValues() {
      setState(() {
        if (textEditingController.text.isEmpty) {
          textEditingControllerInput = "0";
        }
        if (textEditingController.text.isNotEmpty) {
          textEditingControllerInput = textEditingController.text;
        }
        if (purity != 0 && weightInGrams != 0.0 && fineGoldPrice != 0) {
          totalPrice =
              calculatePrice(fineGoldPrice, weightInGrams, purity).toString();
        } else {
          totalPrice = "0";
        }
      });
    }

    return Screenshot(
      controller: controller,
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFfdd835), Color(0xFFf9a825)])),
        child: MaterialApp(
          theme: ThemeData(
            fontFamily: "Quicksand",
          ),
          debugShowCheckedModeBanner: false,
          title: "Gold jewellery Price Calculator",
          home: Scaffold(
            body: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFfdd835), Color(0xFFf9b01e)])),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Stack(children: [
                            Positioned(
                                child: Container(
                              height: 250,
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFfdd835),
                                        Color(0xFFfbc02d)
                                      ])),
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.center,
                                          padding:
                                              const EdgeInsets.only(left: 0, top: 0),
                                          child: Text(
                                              "Gold Jewellery Price Calculator",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: kColorRed))),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                  top: 15,
                                                  // left: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: kColorRed,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                alignment: Alignment.center,
                                                width: 140,
                                                height: 30,
                                                child: Text(
                                                  "Date: $df",
                                                  style: TextStyle(
                                                      color: kColorWhite),
                                                )),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                  top: 15,
                                                  left: 40,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: kColorRed,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                alignment: Alignment.center,
                                                width: 140,
                                                height: 30,
                                                child: Text(
                                                  "Time: $time",
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(
                                top: 50,
                              ),
                              child: PopupMenuButton(
                                color: Colors.black,
                                itemBuilder: (context) => [
                                  const PopupMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      "Share",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                                onSelected: (item) async {
                                  Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () async {
                                    final image = await controller.capture();
                                    takeScreenshots(image!);
                                  });
                                },
                              ),
                            ),
                          ]),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                      child: Text("Jewellery Price",
                                          style: TextStyle(
                                            color: kColorRed,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ))),
                              Container(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        alignment: Alignment.center,
                                        height: 55,
                                        width: 130,
                                        decoration: BoxDecoration(
                                            color: kColorRed,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(
                                            top: 0, right: 30, left: 10),
                                        child: RichText(
                                            text: TextSpan(
                                                text: "Fine Gold(999)\n",
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          "Price(per gram):",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: kColorWhite,
                                                          fontFamily:
                                                              "Quicksand"))
                                                ],
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontFamily: "Quicksand")))),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: kColorRed,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 55,
                                      width: 180,
                                      child: TextField(
                                          controller: textEditingController,
                                          onChanged: (value) {
                                            setState(() {
                                              if(value == ""){
                                                value = "0";
                                              }
                                              fineGoldPrice = int.parse(value);
                                              updateValues();
                                            });
                                          },
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          cursorColor: _cursorColor,
                                          decoration: _decorationGold),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        alignment: Alignment.center,
                                        height: 55,
                                        width: 130,
                                        decoration: BoxDecoration(
                                            color: kColorRed,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(
                                            top: 0, right: 30, left: 10),
                                        child: RichText(
                                          text: const TextSpan(
                                            text: "Weight\n",
                                            children: [
                                              TextSpan(
                                                style: TextStyle(fontSize: 13,fontFamily: "Quicksand"),
                                                  text:
                                                      "(in grams)")
                                            ],
                                            style: TextStyle(fontSize: 13,fontFamily: "Quicksand"),
                                          ),
                                        )),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: kColorRed,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 55,
                                      width: 180,
                                      child: TextField(
                                        controller: weightFieldController,
                                        onChanged: (value) => {
                                          setState(() {
                                            if(value == ""){
                                              value = "0.0";
                                            }
                                            if(value[0]=='.'){
                                              value = "0"+value;
                                            }
                                            weightInGrams = double.parse(value);
                                            updateValues();
                                          })
                                        },
                                        decoration: _decorationWeight,
                                        cursorColor: _cursorColor,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color: kColorRed,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        height: 55,
                                        width: 130,
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(
                                            top: 0, right: 30, left: 10),
                                        child: Text("Karat:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: kColorWhite))),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: kColorRed,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      // margin: EdgeInsets.only(top: 20),
                                      height: 55,
                                      width: 180,
                                      child: TextField(
                                          controller: purityController,
                                          onChanged: (value) {
                                            if (value == "") {
                                              purity = 0;
                                            } else {
                                              purity = ((100 / 24) *
                                                          int.parse(value))
                                                      .toInt() +
                                                  1;
                                            }

                                            updateValues();
                                          },
                                          keyboardType: TextInputType.number,
                                          cursorColor: _cursorColor,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          decoration: _decorationPurity),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 55,
                                      width: 130,
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(
                                          top: 0, right: 30, left: 10),
                                      decoration: BoxDecoration(
                                          color: kColorRed,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        "Total Price: ",
                                        style: TextStyle(
                                            fontSize: 15, color: kColorWhite),
                                      ),
                                    ),
                                    Container(
                                        height: 55,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: kColorRed,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          totalPrice,
                                          style: TextStyle(
                                              fontSize: 20, color: kColorWhite),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(30),
                            child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: kColorWhite, fontSize: 13,fontFamily: "Quicksand"),
                                  text:
                                      "Note:- Above rates are without 3%GST\n",
                            ),
                          )),
                          Container(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Future takeScreenshots(Uint8List bytes) async {
    await [Permission.storage].request();
    await ImageGallerySaver.saveImage(bytes, name: "price.png");

    final directory = await getExternalStorageDirectory();
    // print("path${directory!.path}");
    final image = io.File('${directory!.path}/price.png');
    // print("image: ${image.path}");
    image.writeAsBytesSync(bytes);
    // await FlutterShare.shareFile(title: "..", filePath: image.path);
    Share.shareXFiles(
      [XFile(image.path)],
    );
  }
}
