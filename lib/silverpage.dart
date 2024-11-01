import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum GSTOptions { applicable, notApplicable }

class SilverPage extends StatefulWidget {
  const SilverPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SilverPage> createState() => _SilverPageState();
}

class _SilverPageState extends State<SilverPage> {
  DateTime dt = DateTime.now();
  String df = formatDate(DateTime.now().toLocal(), [dd, '-', mm, '-', yyyy]);
  String time = DateFormat('hh:mm').format(DateTime.now());
  Timer? timer;
  TextEditingController silverController = TextEditingController();
  TextEditingController weightFieldController = TextEditingController();
  TextEditingController purityController = TextEditingController();
  String textEditingControllerInput = "0";
  Color kColorAccent = const Color(0xFFB9D9EB);
  Color kColorPrimary = const Color(0xFF002147);
  Color kColorContainerBackgrounds = const Color(0xFF002147);
  Color kColorBackground = const Color(0xFF76ABDF);
  Color kColorWhite = Colors.white;
  final Color _cursorColor = Colors.black;
  ScreenshotController controller = ScreenshotController();
  int silverPrice = 0;
  double weightInGrams = 0.0;
  double makingPerGram = 0.0;
  String totalPrice = "0";
  TextEditingController makingController = TextEditingController();
  double kFontSize = 13;
  EdgeInsets padding = const EdgeInsets.all(05);
  EdgeInsets margin = const EdgeInsets.only(top: 0, right: 30, left: 10);
  EdgeInsets paddingContainerRow = const EdgeInsets.only(top: 18);
  final snackBarDuration = const Duration(milliseconds: 750);
  double containerHeight = 55.0;
  double containerWidth = 130.0;
  double inputFieldHeight = 55.0;
  double inputFieldWidth = 180.0;
  String makingAmt = "0";
  String baseAmount = "0";
  String gstAmount = "0";
  GSTOptions gstApplicableOrNot = GSTOptions.applicable;
  double gst = 3 / 100;
  late bool showTextInputActionNext = true;
  late TextInputAction textInputAction = TextInputAction.next;

  BoxDecoration containerDecoration = BoxDecoration(
      color: const Color(0xFF002147), borderRadius: BorderRadius.circular(10));

  final InputDecoration _decorationSilver = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Fine Silver(999)",
      hintStyle:
          const TextStyle(color: Colors.white38, fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationWeight = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Weight",
      hintStyle:
          const TextStyle(color: Colors.white38, fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)));

  final InputDecoration _makingDecoration = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Making",
      hintStyle:
          const TextStyle(color: Colors.white38, fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF002147)),
          borderRadius: BorderRadius.circular(10)));

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

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  functest() async {
    await Permission.storage.request();
    timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) => setState(() {
              updateTime();
            }));
  }

  List<int> calculatePrice(
      int silverPrice, double weightInGrams, double makingPerGram) {
    double silverPricePerGram = silverPrice / 1000;
    int makingCost = (makingPerGram * weightInGrams).toInt();
    int basePrice = (silverPricePerGram * weightInGrams).toInt();
    int finalPrice = basePrice + makingCost;
    int gstAmt = (gst * finalPrice).toInt();
    if (gstApplicableOrNot == GSTOptions.applicable) {
      return [basePrice, makingCost, finalPrice + gstAmt, gstAmt];
    } else {
      return [basePrice, makingCost, finalPrice, 0];
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    double width = MediaQuery.of(context).size.width;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    void updateValues() {
      setState(() {
        if (silverController.text.isEmpty) {
          textEditingControllerInput = "0";
        }
        if (silverController.text.isNotEmpty) {
          textEditingControllerInput = silverController.text;
        }
        if (weightInGrams > 0.0 && silverPrice > 0 && makingPerGram >= 0) {
          textInputAction = TextInputAction.done;
          List<int> priceList =
              calculatePrice(silverPrice, weightInGrams, makingPerGram);
          baseAmount = priceList[0].toString();
          makingAmt = priceList[1].toString();
          totalPrice = priceList[2].toString();
          gstAmount = priceList[3].toString();
        } else {
          textInputAction = TextInputAction.next;
          totalPrice = "0";
          baseAmount = "0";
          makingAmt = "0";
          gstAmount = "0";
        }
      });
    }

    void resetVals() {
      setState(() {
          textInputAction = TextInputAction.next;
        weightFieldController.clear();
        weightInGrams = 0.0;
        makingController.clear();
        makingPerGram = 0.0;
        totalPrice = "0";
        baseAmount = "0";
        makingAmt = "0";
        gstAmount = "0";
      });
    }

    return Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: height * 5.5 / 100,
          centerTitle: true,
          backgroundColor: kColorAccent,
          title: Text("Silver Jewellery Price Calculator",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kColorPrimary)),
          bottom: PreferredSize(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(
                        top: 0,
                        // left: 20,
                      ),
                      decoration: BoxDecoration(
                          color: kColorPrimary,
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      width: 140,
                      height: 30,
                      child: Text(
                        "Date: $df",
                        style: TextStyle(color: kColorWhite),
                      )),
                  Container(
                      margin: const EdgeInsets.only(
                        top: 0,
                        left: 40,
                      ),
                      decoration: BoxDecoration(
                          color: kColorPrimary,
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      width: 140,
                      height: 30,
                      child: Text(
                        "Time: $time",
                        style: const TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ),
            preferredSize: Size.fromHeight(height * 5.5 / 100),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(top: height * 0.8 / 100),
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
                  final image = await controller.capture(
                      delay: const Duration(milliseconds: 500),
                      pixelRatio: pixelRatio);
                  takeScreenshots(image!);
                },
              ),
            ),
          ],
        ),
        body: StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: kColorBackground,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Form(
                            child: Column(children: [
                              Container(
                                padding: paddingContainerRow,
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
                                        child: Text("Silver Price per\nKG: ",
                                            style: TextStyle(
                                                color: kColorWhite,
                                                fontSize: kFontSize))),
                                    Container(
                                      decoration: containerDecoration,
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextFormField(
                                          cursorOpacityAnimates: true,
                                          controller: silverController,
                                          onChanged: (value) {
                                            int? trySilverPrice =
                                                int.tryParse(value);
                                            if (trySilverPrice != null) {
                                              setState(() {
                                                if (value == "" ||
                                                    (value[0] == '-' ||
                                                        value[0] == '+')) {
                                                  value = "0";
                                                }
                                                silverPrice = int.parse(value);
                                                updateValues();
                                              });
                                            } else {
                                              setState(() {
                                                silverPrice = 0;
                                                updateValues();
                                                if (value.isNotEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: snackBarDuration,
                                                    content: const Text(
                                                        "Please enter a valid whole number."),
                                                  ));
                                                }
                                              });
                                            }
                                          },
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          textInputAction: textInputAction,
                                          cursorColor: _cursorColor,
                                          decoration: _decorationSilver),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: paddingContainerRow,
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
                                      child: TextFormField(
                                        cursorOpacityAnimates: true,
                                        controller: weightFieldController,
                                        onChanged: (value) => {
                                          if (double.tryParse(value) != null)
                                            {
                                              setState(() {
                                                if (value == "") {
                                                  value = "0.0";
                                                }
                                                if (value[0] == '.') {
                                                  value = "0" + value;
                                                }
                                                weightInGrams =
                                                    double.parse(value);
                                                updateValues();
                                              })
                                            }
                                          else
                                            {
                                              setState(() {
                                                weightInGrams = 0.0;
                                                updateValues();
                                                if (value.isNotEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: snackBarDuration,
                                                    content: const Text(
                                                        "Please enter a valid value."),
                                                  ));
                                                }
                                              })
                                            }
                                        },
                                        decoration: _decorationWeight,
                                        textInputAction: textInputAction,
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
                                padding: paddingContainerRow,
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
                                        child: Text("Making per gram:",
                                            style: TextStyle(
                                                fontSize: kFontSize,
                                                color: kColorWhite))),
                                    Container(
                                      decoration: containerDecoration,
                                      // margin: EdgeInsets.only(top: 20),
                                      height: inputFieldHeight,
                                      width: inputFieldWidth,
                                      child: TextFormField(
                                          cursorOpacityAnimates: true,
                                          controller: makingController,
                                          onChanged: (value) {
                                            if (double.tryParse(value) !=
                                                null) {
                                              if (value == "") {
                                                value = "0.0";
                                                makingPerGram = 0.0;
                                              } else {
                                                makingPerGram =
                                                    double.parse(value);
                                              }
                                              updateValues();
                                            } else {
                                              makingPerGram = 0.0;
                                              updateValues();
                                              if (value.isNotEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration: snackBarDuration,
                                                  content: const Text(
                                                      "Please enter a valid value."),
                                                ));
                                              }
                                            }
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
                            ]),
                          ),
                          Container(
                            padding: paddingContainerRow,
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
                                    "Base Amount:",
                                    style: TextStyle(
                                        fontSize: kFontSize + 2,
                                        color: kColorWhite),
                                  ),
                                ),
                                Container(
                                    height: inputFieldHeight,
                                    width: inputFieldWidth,
                                    decoration: containerDecoration,
                                    alignment: Alignment.center,
                                    child: Text(
                                      baseAmount,
                                      style: TextStyle(
                                          fontSize: 20, color: kColorWhite),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding: paddingContainerRow,
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
                                    "Making Amount:",
                                    style: TextStyle(
                                        fontSize: kFontSize + 1,
                                        color: kColorWhite),
                                  ),
                                ),
                                Container(
                                    height: inputFieldHeight,
                                    width: inputFieldWidth,
                                    decoration: containerDecoration,
                                    alignment: Alignment.center,
                                    child: Text(
                                      makingAmt,
                                      style: TextStyle(
                                          fontSize: 20, color: kColorWhite),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding: paddingContainerRow,
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
                                    "GST:",
                                    style: TextStyle(
                                        fontSize: kFontSize + 1,
                                        color: kColorWhite),
                                  ),
                                ),
                                SizedBox(
                                  width: inputFieldWidth,
                                  height: inputFieldHeight + 40,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        visualDensity: const VisualDensity(
                                            vertical:
                                                VisualDensity.minimumDensity,
                                            horizontal:
                                                VisualDensity.minimumDensity),
                                        title: const Text("Applicable",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white)),
                                        leading: Radio<GSTOptions>(
                                          activeColor: kColorPrimary,
                                          splashRadius: 2,
                                          value: GSTOptions.applicable,
                                          groupValue: gstApplicableOrNot,
                                          onChanged: (GSTOptions? value) {
                                            setState(() {
                                              gstApplicableOrNot = value!;
                                              updateValues();
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        visualDensity: const VisualDensity(
                                            vertical:
                                                VisualDensity.minimumDensity,
                                            horizontal:
                                                VisualDensity.minimumDensity),
                                        title: const Text(
                                          "Not Applicable",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        leading: Radio<GSTOptions>(
                                          activeColor: kColorPrimary,
                                          value: GSTOptions.notApplicable,
                                          groupValue: gstApplicableOrNot,
                                          onChanged: (GSTOptions? value) {
                                            setState(() {
                                              gstApplicableOrNot = value!;
                                              updateValues();
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: paddingContainerRow,
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
                                    "GST Amount: ",
                                    style: TextStyle(
                                        fontSize: kFontSize + 2,
                                        color: kColorWhite),
                                  ),
                                ),
                                Container(
                                    height: inputFieldHeight,
                                    width: inputFieldWidth,
                                    decoration: containerDecoration,
                                    alignment: Alignment.center,
                                    child: Text(
                                      gstAmount,
                                      style: TextStyle(
                                          fontSize: 20, color: kColorWhite),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding: paddingContainerRow,
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
                                        fontSize: kFontSize + 2,
                                        color: kColorWhite),
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
                        margin: const EdgeInsets.only(top: 20, bottom: 5),
                        padding: const EdgeInsets.all(0),
                        decoration: containerDecoration,
                        child: TextButton(
                          onPressed: () {
                            resetVals();
                          },
                          child: Text(
                            "RESET VALUES",
                            style: TextStyle(color: kColorWhite),
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future takeScreenshots(Uint8List bytes) async {
    await [Permission.storage].request();
    final directory = await getExternalStorageDirectory();
    final image = await io.File('${directory!.path}/price$df|$time|${DateTime.now().second}.png').create();
    image.writeAsBytesSync(bytes);
    // await FlutterShare.shareFile(title: "..", filePath: image.path);
    Share.shareXFiles(
      [XFile(image.path)],
    );
  }
}
