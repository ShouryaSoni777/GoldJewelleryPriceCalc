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
  int making = -1;
  TextEditingController makingController = TextEditingController();
  String font = "Quicksand";
  double kFontSize = 13;
  EdgeInsets padding = const EdgeInsets.all(05);
  EdgeInsets margin = const EdgeInsets.only(top: 0, right: 30, left: 10);
  double containerHeight = 55.0;
  double containerWidth = 130.0;
  double inputFieldHeight = 55.0;
  double inputFieldWidth = 180.0;

  BoxDecoration containerDecoration = BoxDecoration(
      color: const Color(0xFFc62828), borderRadius: BorderRadius.circular(10));

  final InputDecoration _decorationGold = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Fine Gold(999)",
      border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFc62828)),borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationWeight = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Weight",
      border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFc62828)),borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationPurity = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Purity",
      border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFc62828)),borderRadius: BorderRadius.circular(10)));

  final InputDecoration _makingDecoration = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Making",
      
      border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFc62828)),borderRadius: BorderRadius.circular(10)));

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

  int calculatePrice(int goldFinePrice, double weight, int purity, int making) {
    double wastage = making / 100; // 10 percent.
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
        if (purity != 0 &&
            weightInGrams != 0.0 &&
            fineGoldPrice != 0 &&
            making != -1) {
          totalPrice =
              calculatePrice(fineGoldPrice, weightInGrams, purity, making)
                  .toString();
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
            fontFamily: font,
          ),
          debugShowCheckedModeBanner: false,
          title: "Gold jewellery Price Calculator",
          home: Scaffold(
            body: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFfdd835), Color(0xFFf9b01e)])),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Container(
                                alignment: Alignment.topRight,
                                
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
                          Stack(children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    child: Column(
                                      children: [
                                        Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                                "Gold Jewellery Price Calculator",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: kColorRed))),
                                        Container(
                                          margin: EdgeInsets.only(top:15),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 0,
                                                    // left: 20,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: kColorRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
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
                                                    top: 0,
                                                    left: 40,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: kColorRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
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
                                  ),
                                ],
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
                                        height: containerHeight,
                                        width: containerWidth,
                                        decoration: containerDecoration,
                                        padding: padding,
                                        margin: margin,
                                        child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "Fine Gold(999)\nPrice(per gram):",
                                                style: TextStyle(
                                                    fontSize: kFontSize,
                                                    color: Colors.white,
                                                    fontFamily: font)))),
                                    Container(
                                      decoration: containerDecoration,
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextField(
                                          controller: textEditingController,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == "") {
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
                                        height: containerHeight,
                                        width: containerWidth,
                                        decoration: containerDecoration,
                                        padding: padding,
                                        margin: margin,
                                        child: Text(
                                          "Weight\n(in grams):\t\t\t\t\t\t\t\t\t",
                                          style: TextStyle(
                                              color: kColorWhite,
                                              fontSize: kFontSize),
                                        )),
                                    Container(
                                      decoration: containerDecoration,
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextField(
                                        controller: weightFieldController,
                                        onChanged: (value) => {
                                          setState(() {
                                            if (value == "") {
                                              value = "0.0";
                                            }
                                            if (value[0] == '.') {
                                              value = "0" + value;
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
                                        decoration: containerDecoration,
                                        alignment: Alignment.center,
                                        height: containerHeight,
                                        width: containerWidth,
                                        padding: padding,
                                        margin: margin,
                                        child: Text("Purity\n(in percentage):",
                                            style: TextStyle(
                                                fontSize: kFontSize,
                                                color: kColorWhite))),
                                    Container(
                                      decoration: containerDecoration,
                                      // margin: EdgeInsets.only(top: 20),
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextField(
                                          controller: purityController,
                                          onChanged: (value) {
                                            if (value == "") {
                                              purity = 0;
                                            } else {
                                              purity = int.parse(value);
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
                                        decoration: containerDecoration,
                                        alignment: Alignment.center,
                                        height: containerHeight,
                                        width: containerWidth,
                                        padding: padding,
                                        margin: margin,
                                        child: Text("Making \n(in percentage):",
                                            style: TextStyle(
                                                fontSize: kFontSize,
                                                color: kColorWhite))),
                                    Container(
                                      decoration: containerDecoration,
                                      // margin: EdgeInsets.only(top: 20),
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextField(
                                          controller: makingController,
                                          onChanged: (value) {
                                            if (value == "" || value == ",") {
                                              value = "-1";
                                              making = -1;
                                            } else {
                                              making = int.parse(value);
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
                                          decoration: _makingDecoration),
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
                                      height: containerHeight,
                                      width: containerWidth,
                                      padding: padding,
                                      margin: margin,
                                      decoration: containerDecoration,
                                      child: Text(
                                        "Total Price: ",
                                        style: TextStyle(
                                            fontSize: 15, color: kColorWhite),
                                      ),
                                    ),
                                    Container(
                                        height: inputFieldHeight,
                                        width: inputFieldWidth,
                                        decoration: containerDecoration,
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
                                    color: kColorWhite,
                                    fontSize: kFontSize,
                                  ),
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
