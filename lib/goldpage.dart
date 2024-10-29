import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum GSTOptions { applicable, notApplicable }

class GoldPage extends StatefulWidget {
  const GoldPage({
    Key? key,
  }) : super(key: key);

  @override
  State<GoldPage> createState() => _GoldPageState();
}

class _GoldPageState extends State<GoldPage> {
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
  double purity = 0.0;
  String totalPrice = "0";
  double making = 0.0;
  TextEditingController makingController = TextEditingController();
  double kFontSize = 13;
  EdgeInsets padding = const EdgeInsets.all(05);
  EdgeInsets margin = const EdgeInsets.only(top: 0, right: 30, left: 10);
  EdgeInsets paddingContainerRow = const EdgeInsets.only(top: 18);
  double containerHeight = 55.0;
  double containerWidth = 130.0;
  double inputFieldHeight = 55.0;
  double inputFieldWidth = 180.0;
  String makingAmt = "0";
  String baseAmount = "0";
  String gstAmount = "0";
  GSTOptions gstApplicableOrNot = GSTOptions.applicable;
  double gst = 3 / 100;

  BoxDecoration containerDecoration = BoxDecoration(
      color: const Color(0xFFc62828), borderRadius: BorderRadius.circular(10));

  final InputDecoration _decorationGold = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Fine Gold(999)",
      hintStyle: const TextStyle(color: Colors.black54,fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationWeight = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Weight",
      hintStyle: const TextStyle(color: Colors.black54,fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)));

  final InputDecoration _decorationPurity = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Purity",
      hintStyle: const TextStyle(color: Colors.black54,fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)));

  final InputDecoration _makingDecoration = InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
          borderRadius: BorderRadius.circular(10)),
      hintText: "Making",
      hintStyle: const TextStyle(color: Colors.black54,fontWeight: FontWeight.w200),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFc62828)),
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
  void dispose(){
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
      int goldFinePrice, double weight, double purity, double making) {
    double wastage = making / 100;
    int makingCost = ((weight * wastage) * goldFinePrice).toInt();
    int basePrice = (((purity / 100) * goldFinePrice) * weight).toInt();
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
    void updateValues() {
      setState(() {
        if (textEditingController.text.isEmpty) {
          textEditingControllerInput = "0";
        }
        if (textEditingController.text.isNotEmpty) {
          textEditingControllerInput = textEditingController.text;
        }
        if (purity > 0.0 &&
            weightInGrams > 0.0 &&
            fineGoldPrice > 0 &&
            making >= 0) {
          List<int> priceList =
              calculatePrice(fineGoldPrice, weightInGrams, purity, making);
          baseAmount = priceList[0].toString();
          makingAmt = priceList[1].toString();
          totalPrice = priceList[2].toString();
          gstAmount = priceList[3].toString();
        } else {
          totalPrice = "0";
          baseAmount = "0";
          makingAmt = "0";
          gstAmount = "0";
        }
      });
    }

    void resetVals() {
      setState(() {
        weightFieldController.clear();
        weightInGrams = 0.0;
        purityController.clear();
        purity = 0.0;
        makingController.clear();
        making = 0.0;
        totalPrice = "0";
        baseAmount = "0";
        makingAmt = "0";
        gstAmount = "0";
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
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: height * 5 / 100,
              centerTitle: true,
              flexibleSpace: Container(
                  decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFfdd835), Color(0xFFfcd042)],
                ),
              )),
              title: Text("Gold Jewellery Price Calculator",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kColorRed)),
              bottom: PreferredSize(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
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
                              color: kColorRed,
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
                              color: kColorRed,
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
                preferredSize: Size.fromHeight(height * 5 / 100),
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
                      Future.delayed(const Duration(milliseconds: 500),
                          () async {
                        final image = await controller.capture();
                        takeScreenshots(image!);
                      });
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
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFfdd835), Color(0xFFf9b01e)])),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                        child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "Fine Gold(999)\nPrice(per gram):",
                                                style: TextStyle(
                                                    fontSize: kFontSize,
                                                    color: Colors.white,
                                                    fontFamily: "SF Pro Display")))),
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
                                              purity = double.parse(value);
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
                                              value = "0.0";
                                              making = 0.0;
                                            } else {
                                              making = double.parse(value);
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
                                            visualDensity:
                                                const VisualDensity(
                                                    vertical: VisualDensity
                                                        .minimumDensity,
                                                    horizontal: VisualDensity
                                                        .minimumDensity),
                                            title: const Text("Applicable",
                                                style:
                                                    TextStyle(fontSize: 12)),
                                            leading: Radio<GSTOptions>(
                                              activeColor: kColorRed,
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
                                            visualDensity:
                                                const VisualDensity(
                                                    vertical: VisualDensity
                                                        .minimumDensity,
                                                    horizontal: VisualDensity
                                                        .minimumDensity),
                                            title: const Text(
                                              "Not Applicable",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            leading: Radio<GSTOptions>(
                                              activeColor: kColorRed,
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
