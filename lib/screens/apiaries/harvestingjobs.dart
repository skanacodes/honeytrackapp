import 'dart:async';

import 'dart:io';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honeytrackapp/modals/harvesting_modal.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:honeytrackapp/providers/db_provider.dart';

//import 'package:honeytrackapp/screens/QrCodeScanning.com/qrcodescann.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class HarvestingJob extends StatefulWidget {
  // HarvestingJob({Key? key}) : super(key: key);
  final String jobId;
  final String userId;
  final String jobname;
  final List apiriesName;
  final List apiriesId;
  HarvestingJob(
      {required this.jobId,
      required this.userId,
      required this.jobname,
      required this.apiriesName,
      required this.apiriesId});

  @override
  _HarvestingJobState createState() => _HarvestingJobState();
}

class _HarvestingJobState extends State<HarvestingJob> {
  final _formKey = GlobalKey<FormState>();
  final timeController = TextEditingController();
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String apiaryName = "";
  String hiveCode = "";
  bool isLoading = false;
  String noOfHives = "";
  String weightOfCombHoney = "";
  String moistureContent = "";
  String imageErr = ' ';
  List? _generalcondition;
  List? equipmentUsed;
  List? otherBeeProductHarvested;
  String beeVenomweight = "";
  String pollenWeight = "";
  String propolisWeight = "";
  String royalJellyweight = "";
  List? transportationMeans;
  String otherTransportationMeans = "";
  String stationAberyApiary = "";
  int harvestingCost = 0;
  String harvestedByName = "";
  String harvestedByTitle = "";
  String harvestedByDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String certifiedByName = "";
  String certifiedBytitle = "";
  String certifiedByDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool showBeevenowWeight = false;
  bool showOtherTransportMeans = false;
  bool showPollenWeight = false;
  bool showPropolisWeight = false;
  bool showRoyalJellyWeight = false;
  String? img1;
  String? img2;
  String? result;
  String? apiarName;
  bool isSubmitted = false;
  bool isSubmitted1 = false;
  String specifyExpectedObservations = "";
  String specifyActionTaken = "";
  String expectedHarvest = "";
  String otherEquipmentUsed = "";
  String specifyOtherBeeProduct = " ";
  bool showExpectedOther = false;
  bool showActionOther = false;
  bool showOtherEquipment = false;
  bool showOtherBeeProduct = false;
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  final String uploadUrl = 'https://api.imgur.com/3/upload';
  final ImagePicker _picker = ImagePicker();
  List<String>? apiaryList;
  List<String>? apiaryId;
  String? apiaryIds;
  //DateTime now = DateTime.now();

  // void _handleClearButtonPressed() {
  //   signatureGlobalKey.currentState!.clear();
  // }
  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Future _scanQR() async {
    var res = "";
    try {
      String? barcodeScanRes = await scanner.scan();
      // var x = barcodeScanRes == null ? null : barcodeScanRes.substring(11, 19);

      // barcodeScanRes
      if (barcodeScanRes != null) {
        setState(() {
          result = barcodeScanRes.toString();
        });
      }
    } on PlatformException catch (ex) {
      // print(ex.toString() + "klkjbjhvg");

      if (ex.code == scanner.CameraAccessDenied) {
        setState(() {
          res = "Camera permission was denied";
        });
        // message(result);
      } else {
        print(ex);
        setState(() {
          res = "$ex";
        });
        // message(result);
      }
    } on FormatException {
      setState(() {
        res = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      print(ex);
      setState(() {
        res = "Unknown Error $ex";
      });
      //  message(result);
    }
  }

  void _handleSaveButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    print(bytes);
    // await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (BuildContext context) {
    //       return Scaffold(
    //         appBar: AppBar(),
    //         body: Center(
    //           child: Container(
    //             color: Colors.grey[300],
    //             child: Image.memory(bytes!.buffer.asUint8List()),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Future<String> uploadData() async {
    try {
      // print("am here");
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = new BaseOptions(
          baseUrl: "$baseUrl",
          connectTimeout: 30000,
          receiveTimeout: 30000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        'apiary_name': apiarName,
        'apiary_id': apiaryIds,
        'hive_code': 'tz/js/7438',
        'hive_numbers': 50,
        'honey_comb_weight': 67,
        'moisture_content': "7348",
        'general_condition': _generalcondition,
        'equipment_used': equipmentUsed,
        'other_bee_products': otherBeeProductHarvested,
        'transport_mean': transportationMeans,
        'transport_time': timeController.text,
        'station_abrey_year': '',
        'harvesting_cost': 67.9,
        'harvested_by': '838jwej',
        'title': 'jasufj',
        'certified_by': 'hsahdsh',
        'images': [
          await MultipartFile.fromFile(
            img1!,
            filename: 'image',
          ),
          MultipartFile.fromFile(
            img2!,
            filename: 'images',
          ),
        ]
      });

      var response = await dio.post('$baseUrl/api/v1/apiary-harvest',
          data: formData, onSendProgress: (int sent, int total) {
        // setState(() {
        //   uploadMessage = sent.toString();
        // });
        print('$sent $total');
      });
      print(response.statusCode);
      print(response.statusMessage);
      var res = response.data;
      print(res);
      if (response.statusCode == 200) {
        message('success', 'Data Submitted Successfull');

        return 'success';
      } else {
        message('fail', 'Failed To Save Data');
        return 'fail';
      }
    } on DioError catch (e) {
      print('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectTimeout == e.type) {
        message(
            'error', 'Server Can Not Be Reached. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        print(e);

        setState(() {
          isLoading = false;
        });
        return 'fail';
      } else if (DioErrorType.response == e.type) {
        // throw Exception('Server Can Not Be Reached');
        message('error',
            'Failed To Get Response From Server. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        print(e);
        setState(() {
          isLoading = false;
        });
        return 'fail';
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          // throw Exception('Server Can Not Be Reached');
          message('error',
              'Network Connectivity Problem. Data Has Been Stored Localy');

          print(e);
          setState(() {
            isLoading = false;
          });
          return 'fail';
        }
      } else {
        //  throw Exception('Server Can Not Be Reached');
        message('error',
            'Network Connectivity Problem. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        print(e);
        setState(() {
          isLoading = false;
        });
        return 'fail';
      }
      return 'fail';
    }
  }

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final formKey = new GlobalKey<FormState>();

  Future<String?> uploadImage(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', filepath));
    var res = await request.send();
    return res.reasonPhrase;
  }

  Future<void> retriveLostData(var _imageFile) async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file!;
      });
    } else {
      print('Retrieve error ' + response.exception!.code);
    }
  }

  Widget _previewImage(var _imageFile) {
    // ignore: unnecessary_null_comparison
    if (_imageFile != null) {
      return Container(
        // height: 100,
        // width: 100,
        child: Image.file(File(_imageFile.path)),

        // RaisedButton(
        //   onPressed: () async {
        //     var res = await uploadImage(_imageFile.path, uploadUrl);
        //     print(res);
        //   },
        //   child: const Text('Upload'),
        // )
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _pickImage(int numb) async {
    try {
      await Future.delayed(Duration(milliseconds: 1000));
      final pickedFile = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: 40,
        preferredCameraDevice: CameraDevice.rear,
      );
      await Future.delayed(Duration(milliseconds: 100));
      if (pickedFile != null) {
        setState(() {
          numb == 1 ? _imageFile = pickedFile : _imageFile1 = pickedFile;

          numb == 1 ? isImageTaken = true : isImageTaken1 = true;
        });
        final File file = File(numb == 1 ? _imageFile.path : _imageFile1.path);
        // getting a directory path for saving
        Directory appDocDir = await getApplicationDocumentsDirectory();
        print(appDocDir);
        String appDocPath = appDocDir.path;
        print(appDocPath);
        final fileName =
            path.basename(numb == 1 ? _imageFile.path : _imageFile1.path);
        print(fileName);
// copy the file to a new path
        final File newImage = await file.copy('$appDocPath/$fileName');
        print(newImage);
        setState(() {
          numb == 1 ? img1 = newImage.path : img2 = newImage.path;
        });
        print(img1);
      } else {
        print("Error While Taking Picture");
      }
    } catch (e) {
      print("Image picker error " + e.toString());
    }
  }

  alertDialog() {
    return Alert(
        context: context,
        title: "Harvested By",
        content: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "This Field Is Required";
                  return null;
                },
                onChanged: (value) => harvestedByName = value,
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "This Field Is Required";
                  return null;
                },
                onChanged: (value) => harvestedByTitle = value,
                decoration: InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Title',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Enter Your Signature By Your Finger",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: getProportionateScreenHeight(150),
                    width: double.infinity,
                    child: SfSignaturePad(
                        key: signatureGlobalKey,
                        backgroundColor: Colors.white,
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 1.0,
                        maximumStrokeWidth: 2.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  " $formattedDate",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _handleSaveButtonPressed();

                setState(() {
                  isSubmitted = true;
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  String er = "";
  alertDialog1() {
    return Alert(
        context: context,
        title: "Certified By",
        content: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "This Field Is Required";
                  return null;
                },
                onChanged: (value) => certifiedByName = value,
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "This Field Is Required";
                  return null;
                },
                onChanged: (value) => certifiedBytitle = value,
                decoration: InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Title',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Enter Your Signature By Your Finger",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: getProportionateScreenHeight(150),
                    width: double.infinity,
                    child: SfSignaturePad(
                        key: signatureGlobalKey,
                        backgroundColor: Colors.white,
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 1.0,
                        maximumStrokeWidth: 2.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  " $formattedDate",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _handleSaveButtonPressed();

                setState(() {
                  isSubmitted1 = true;
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  getDropdownList() {
    var x = widget.apiriesName[0];
    var y = widget.apiriesId[0];
    print(x);
    print(y);
    if (x != "") {
      final removedBrackets = x.substring(1, x.length - 1);
      print(removedBrackets);
      final parts = removedBrackets.split(', ');
      print(parts.runtimeType);
      setState(() {
        apiaryList = parts;
      });
    }
    if (y != "") {
      final removedBrackets = y.substring(1, y.length - 1);
      print(removedBrackets);
      final parts = removedBrackets.split(', ');
      print(parts.runtimeType);
      setState(() {
        apiaryId = parts;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed

    timeController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    initConnectivity();
    getDropdownList();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fill',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Harvesting ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Form',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  Future<String> saveDataLocally(status) async {
    String response = await DBProvider.db.insertSingleHarvestData(
        HarvestingModal(
            jobId: widget.jobId,
            userId: widget.userId,
            transportationTime: timeController.text,
            apiaryName: apiarName ?? '',
            beeVenomweight: beeVenomweight,
            certifiedByDate: certifiedByDate,
            certifiedByName: certifiedByName,
            certifiedBytitle: certifiedBytitle,
            img1: img1!,
            img2: img1!,
            equipmentUsed: equipmentUsed.toString(),
            generalcondition: _generalcondition.toString(),
            harvestedByDate: harvestedByDate,
            harvestedByName: harvestedByName,
            harvestedByTitle: harvestedByTitle,
            harvestingCost: harvestingCost,
            hiveCode: "tz/bk/jad/823",
            moistureContent: moistureContent,
            noOfHives: noOfHives,
            otherBeeProductHarvested: otherBeeProductHarvested.toString(),
            otherTransportationMeans: otherTransportationMeans,
            pollenWeight: pollenWeight,
            propolisWeight: propolisWeight,
            royalJellyweight: royalJellyweight,
            stationAberyApiary: '',
            transportationMeans: transportationMeans.toString(),
            weightOfCombHoney: weightOfCombHoney,
            uploadStatus: status));
    if (response == "Success") {
      return 'success';
    } else {
      return 'fail';
    }
  }

  Widget _submitButton() {
    return isLoading
        ? SpinKitFadingCircle(
            color: kPrimaryColor,
            size: 30.0.sp,
          )
        : InkWell(
            onTap: () async {
              print(_connectionStatus.toString());
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (isImageTaken & isImageTaken1) {
                  setState(() {
                    imageErr = "";
                    isLoading = true;
                  });

                  if (_connectionStatus.toString() ==
                      'ConnectivityResult.none') {
                    var response = await saveDataLocally('0');
                    if (response == 'success') {
                      message('success', 'Data Stored Locally Successfull');
                    } else {
                      message('error', 'Failed To Store Data Locally');
                    }
                  } else {
                    var x = await uploadData();
                    if (x == 'success') {
                      // message('success', 'Data Submitted Successfull');
                      await saveDataLocally('1');
                    } else {
                      var response = await saveDataLocally('0');
                      if (response == 'success') {
                        message('success', 'Data Stored Locally Successfull');
                      } else {
                        message('error', 'Failed To Store Data Locally');
                      }
                    }
                  }
                  apiaryList == null ? print('null') : apiaryList!.clear();
                  _generalcondition!.clear();
                  equipmentUsed!.clear();
                  otherBeeProductHarvested!.clear();
                  transportationMeans!.clear();

                  setState(() {
                    isImageTaken = false;
                    isImageTaken1 = false;
                    getDropdownList();
                    isLoading = false;
                  });
                  _formKey.currentState!.reset();
                } else {
                  setState(() {
                    isLoading = false;
                    imageErr = "Please Capture Image";
                  });
                }
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Color(0xFFFED636)])),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.green[700]),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: getProportionateScreenHeight(700),
            child: Column(
              children: <Widget>[
                Container(
                  height: getProportionateScreenHeight(140),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: getProportionateScreenHeight(100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100)),
                          color: kPrimaryColor,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 20,
                            child: ListTile(
                                tileColor: Colors.white,
                                subtitle: Text(DateFormat('yyyy-MM-dd hh:mm:ss')
                                    .format(DateTime.now())
                                    .toString()),
                                title: Text(
                                  '${widget.jobname}  ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Adding the form here
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            elevation: 10,
                            shadowColor: kPrimaryColor,
                            child: Column(
                              children: <Widget>[
                                _title(),
                                SizedBox(
                                  height: getProportionateScreenHeight(10),
                                ),
                                apiaryList != null
                                    ? SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 1, right: 16, left: 16),
                                          child: Container(
                                            // width: getProportionateScreenHeight(
                                            //     320),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                  fillColor: Color(0xfff3f3f4),
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 5.5, 0, 0),
                                                  labelStyle: TextStyle(),
                                                  labelText:
                                                      'Select the Apiary'),
                                              focusColor: Colors.white,
                                              value: apiarName,
                                              //elevation: 5,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              iconEnabledColor: Colors.black,
                                              items: apiaryList!.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                );
                                              }).toList(),

                                              onChanged: (value) {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                setState(() {
                                                  apiarName = value!;
                                                  int index = apiaryList!
                                                      .indexOf(apiarName!);
                                                  apiaryIds = apiaryId![index]
                                                      .toString();
                                                  print(apiaryIds);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: getProportionateScreenHeight(15),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 1, right: 16, left: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 1, right: 1, left: 1),
                                          child: Container(
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              key: Key("plat"),
                                              // onSaved: (val) => task.licencePlateNumber = val,
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                fillColor: Color(0xfff3f3f4),
                                                filled: true,
                                                labelText: result != null
                                                    ? result
                                                    : "Hive Code",
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        30, 10, 15, 10),
                                              ),
                                              enabled: false,
                                              // validator: (value) {
                                              //   if (value.isEmpty)
                                              //     return "This Field Is Required";
                                              //   return null;
                                              // },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                            width: 1,
                                          )),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: InkWell(
                                          onTap: () {
                                            _scanQR();
                                            // Navigator.pushNamed(
                                            //   context,
                                            //   QRViewExample.routeName,
                                            // );
                                          },
                                          child: DashedCircle(
                                            dashes: 6,
                                            gapSize: 10.0,
                                            child: Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: CircleAvatar(
                                                // radius: 70.0,
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor:
                                                    Colors.transparent,
                                                radius: 16,
                                                child: SvgPicture.asset(
                                                  "assets/icons/qr-code-scan.svg",
                                                  height: 4.h,
                                                  width: 4.w,
                                                ),
                                              ),
                                            ),
                                            color: Colors.green,
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 16, left: 16),
                                  child: Container(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      key: Key("other"),
                                      onSaved: (val) =>
                                          weightOfCombHoney = val!,
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: Colors.cyan,
                                          ),
                                        ),
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true,
                                        labelText: "Weight Of Comb Honey",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(30, 10, 15, 10),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return "This Field Is Required";
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: MultiSelectFormField(
                                    autovalidate: false,
                                    chipBackGroundColor: Colors.blue,
                                    chipLabelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    dialogTextStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    checkBoxActiveColor: Colors.blue,
                                    checkBoxCheckColor: Colors.white,
                                    dialogShapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                    title: Text(
                                      "General Weather Condition",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length == 0) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: [
                                      {
                                        "display": "Rainy",
                                        "value": "Rainy",
                                      },
                                      {
                                        "display": "Sunny",
                                        "value": "Sunny",
                                      },
                                    ],
                                    textField: 'display',
                                    valueField: 'value',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintWidget:
                                        Text('Please choose one or more'),
                                    initialValue: _generalcondition,
                                    onSaved: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      if (value == null) return;
                                      setState(() {
                                        _generalcondition = value;
                                        //  print(_generalcondition);
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: MultiSelectFormField(
                                    autovalidate: false,
                                    chipBackGroundColor: Colors.blue,
                                    chipLabelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    dialogTextStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    checkBoxActiveColor: Colors.blue,
                                    checkBoxCheckColor: Colors.white,
                                    dialogShapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                    title: Text(
                                      "Equipment Used",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length == 0) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: [
                                      {
                                        "display": "Bee Smoker",
                                        "value": "Bee Smoker",
                                      },
                                      {
                                        "display": "Backet",
                                        "value": "Backet",
                                      },
                                      {
                                        "display": "Drum",
                                        "value": "Drum",
                                      },
                                      {
                                        "display": "Bee Brush",
                                        "value": "Bee Brush",
                                      },
                                      {
                                        "display": "Hive Tool",
                                        "value": "Hive Tool",
                                      },
                                      {
                                        "display": "Protective Gears",
                                        "value": "Protective Gears",
                                      },
                                      {
                                        "display": "Other",
                                        "value": "Other",
                                      },
                                    ],
                                    textField: 'display',
                                    valueField: 'value',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintWidget:
                                        Text('Please choose one or more'),
                                    initialValue: equipmentUsed,
                                    onSaved: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      if (value == null) return;
                                      setState(() {
                                        equipmentUsed = value;
                                        equipmentUsed!.contains('Other')
                                            ? showOtherEquipment = true
                                            : showOtherEquipment = false;
                                        //  print(_generalcondition);
                                      });
                                    },
                                  ),
                                ),
                                showOtherEquipment
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                otherEquipmentUsed = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "Specify Other Equipment Used?",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: MultiSelectFormField(
                                    autovalidate: false,
                                    chipBackGroundColor: Colors.blue,
                                    chipLabelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    dialogTextStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    checkBoxActiveColor: Colors.blue,
                                    checkBoxCheckColor: Colors.white,
                                    dialogShapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                    title: Text(
                                      "Other Bee Product Harvested",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length == 0) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: [
                                      {
                                        "display": "Bee Venom",
                                        "value": "Bee Venom",
                                      },
                                      {
                                        "display": "Pollen",
                                        "value": "Pollen",
                                      },
                                      {
                                        "display": "Propolis",
                                        "value": "Propolis",
                                      },
                                      {
                                        "display": "Royal Jelly(mils)",
                                        "value": "Royal Jelly(mils)",
                                      },
                                      {
                                        "display": "Other",
                                        "value": "Other",
                                      },
                                    ],
                                    textField: 'display',
                                    valueField: 'value',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintWidget:
                                        Text('Please choose one or more'),
                                    initialValue: otherBeeProductHarvested,
                                    onSaved: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        otherBeeProductHarvested = value;
                                        otherBeeProductHarvested!
                                                .contains('Other')
                                            ? showOtherBeeProduct = true
                                            : showOtherBeeProduct = false;
                                        otherBeeProductHarvested!
                                                .contains("Bee Venom")
                                            ? showBeevenowWeight = true
                                            : showBeevenowWeight = false;
                                        otherBeeProductHarvested!
                                                .contains("Pollen")
                                            ? showPollenWeight = true
                                            : showPollenWeight = false;
                                        otherBeeProductHarvested!
                                                .contains("Propolis")
                                            ? showPropolisWeight = true
                                            : showPropolisWeight = false;
                                        otherBeeProductHarvested!
                                                .contains("Royal Jelly(mils)")
                                            ? showRoyalJellyWeight = true
                                            : showRoyalJellyWeight = false;

                                        //  print(_generalcondition);
                                      });
                                    },
                                  ),
                                ),
                                showOtherBeeProduct
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                specifyOtherBeeProduct = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "specify Other Bee Product",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                showBeevenowWeight
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                beeVenomweight = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "Bee venom Weight in gram",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                showPollenWeight
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                pollenWeight = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "Pollen Weight in gram",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                showPropolisWeight
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                propolisWeight = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "Propolis Weight in gram",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                showRoyalJellyWeight
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                royalJellyweight = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "Royal Jelly Weight in gram",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: MultiSelectFormField(
                                    autovalidate: false,
                                    chipBackGroundColor: Colors.blue,
                                    chipLabelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    dialogTextStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    checkBoxActiveColor: Colors.blue,
                                    checkBoxCheckColor: Colors.white,
                                    dialogShapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                    title: Text(
                                      "Transportation Means",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length == 0) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: [
                                      {
                                        "display": "Car",
                                        "value": "Car",
                                      },
                                      {
                                        "display": "Motor Vehicle",
                                        "value": "Motor Vehicle",
                                      },
                                      {
                                        "display": "Bicycle",
                                        "value": "Bicyle",
                                      },
                                      {
                                        "display": "Other",
                                        "value": "Other",
                                      },
                                    ],
                                    textField: 'display',
                                    valueField: 'value',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintWidget:
                                        Text('Please choose one or more'),
                                    initialValue: transportationMeans,
                                    onSaved: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        transportationMeans = value;
                                        transportationMeans!.contains("Other")
                                            ? showOtherTransportMeans = true
                                            : showOtherTransportMeans = false;
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        //  print(_generalcondition);
                                      });
                                    },
                                  ),
                                ),
                                showOtherTransportMeans
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 16, left: 16),
                                        child: Container(
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            key: Key("other"),
                                            onSaved: (val) =>
                                                otherTransportationMeans = val!,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true,
                                              labelText:
                                                  "If Other Transportation Means Specify",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "This Field Is Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 16, left: 16),
                                  child: Container(
                                      child: Card(
                                    elevation: 1,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(Icons.timelapse_outlined),
                                      ),
                                      onTap: () async {
                                        var time = await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                            confirmText: "Ok");
                                        setState(() {
                                          timeController.text =
                                              time!.format(context);
                                        });
                                      },
                                      title: Text(
                                        'Transportation Time: ' +
                                            timeController.text,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  )),
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(15),
                                ),
                                // Card(
                                //   elevation: 10,
                                //   child: Container(
                                //     height: getProportionateScreenHeight(150),
                                //     width: double.infinity,
                                //     child: Column(
                                //       children: [
                                //         Text(
                                //             "Click Buttons To Enter Credentials"),
                                //         SizedBox(
                                //           height:
                                //               getProportionateScreenHeight(10),
                                //         ),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceEvenly,
                                //           children: [
                                //             InkWell(
                                //               onTap: () {
                                //                 alertDialog();
                                //               },
                                //               child: Container(
                                //                 height:
                                //                     getProportionateScreenHeight(
                                //                         40),
                                //                 width:
                                //                     getProportionateScreenWidth(
                                //                         100),
                                //                 decoration: BoxDecoration(
                                //                     color: Colors.green,
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             20)),
                                //                 child: Center(
                                //                     child: Text(
                                //                   "Harvested By",
                                //                   style: TextStyle(
                                //                       color: Colors.black),
                                //                 )),
                                //               ),
                                //             ),
                                //             InkWell(
                                //               onTap: () {
                                //                 alertDialog1();
                                //               },
                                //               child: Container(
                                //                 height:
                                //                     getProportionateScreenHeight(
                                //                         40),
                                //                 width:
                                //                     getProportionateScreenWidth(
                                //                         100),
                                //                 decoration: BoxDecoration(
                                //                     color: Colors.green,
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             20)),
                                //                 child: Center(
                                //                     child: Text(
                                //                   "Certified By",
                                //                   style: TextStyle(
                                //                       color: Colors.black),
                                //                 )),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //         SizedBox(height: 10),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceEvenly,
                                //           children: [
                                //             InkWell(
                                //                 onTap: () {
                                //                   //   alertDialog();
                                //                 },
                                //                 child: Container(
                                //                   height:
                                //                       getProportionateScreenHeight(
                                //                           40),
                                //                   width:
                                //                       getProportionateScreenWidth(
                                //                           100),
                                //                   child: isSubmitted
                                //                       ? Center(
                                //                           child:
                                //                               SvgPicture.asset(
                                //                             "assets/icons/checklist.svg",
                                //                             // height: 4.h,
                                //                             // width: 4.w,
                                //                           ),
                                //                         )
                                //                       : SvgPicture.asset(
                                //                           "assets/icons/pending.svg",
                                //                           // height: 4.h,
                                //                           // width: 4.w,
                                //                         ),
                                //                 )),
                                //             InkWell(
                                //                 onTap: () {
                                //                   // alertDialog1();
                                //                 },
                                //                 child: Container(
                                //                   height:
                                //                       getProportionateScreenHeight(
                                //                           40),
                                //                   width:
                                //                       getProportionateScreenWidth(
                                //                           100),
                                //                   // decoration: BoxDecoration(
                                //                   //     color: Colors.green,
                                //                   //     borderRadius:
                                //                   //         BorderRadius.circular(
                                //                   //             20)),
                                //                   child: isSubmitted1
                                //                       ? Center(
                                //                           child:
                                //                               SvgPicture.asset(
                                //                             "assets/icons/checklist.svg",
                                //                             // height: 4.h,
                                //                             // width: 4.w,
                                //                           ),
                                //                         )
                                //                       : SvgPicture.asset(
                                //                           "assets/icons/pending.svg",
                                //                           // height: 4.h,
                                //                           // width: 4.w,
                                //                         ),
                                //                 )),
                                //           ],
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  width: double.infinity,
                                  height: getProportionateScreenHeight(60),
                                  child: Card(
                                    elevation: 10,
                                    child: Center(
                                      child: Text(
                                          "Click On The Icons To Take Atleast Two Pictures"),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: getProportionateScreenHeight(200),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      isImageTaken
                                          ? Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  _pickImage(1);
                                                },
                                                child: Card(
                                                  elevation: 10,
                                                  child: Center(
                                                      child:
                                                          FutureBuilder<void>(
                                                    future: retriveLostData(
                                                        _imageFile),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot<void>
                                                                snapshot) {
                                                      switch (snapshot
                                                          .connectionState) {
                                                        case ConnectionState
                                                            .none:
                                                        case ConnectionState
                                                            .waiting:
                                                          return const Text(
                                                              'Picked an image');
                                                        case ConnectionState
                                                            .done:
                                                          return _previewImage(
                                                              _imageFile);
                                                        default:
                                                          return const Text(
                                                              'Picked an image');
                                                      }
                                                    },
                                                  )),
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  _pickImage(1);
                                                },
                                                child: Card(
                                                  elevation: 10,
                                                  child: SvgPicture.asset(
                                                    "assets/icons/addpic.svg",
                                                    // height: 4.h,
                                                    // width: 4.w,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      isImageTaken1
                                          ? Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  _pickImage(2);
                                                },
                                                child: Card(
                                                  elevation: 10,
                                                  child: Center(
                                                      child:
                                                          FutureBuilder<void>(
                                                    future: retriveLostData(
                                                        _imageFile1),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot<void>
                                                                snapshot) {
                                                      switch (snapshot
                                                          .connectionState) {
                                                        case ConnectionState
                                                            .none:
                                                        case ConnectionState
                                                            .waiting:
                                                          return const Text(
                                                              'Picked an image');
                                                        case ConnectionState
                                                            .done:
                                                          return _previewImage(
                                                              _imageFile1);
                                                        default:
                                                          return const Text(
                                                              'Picked an image');
                                                      }
                                                    },
                                                  )),
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  _pickImage(2);
                                                },
                                                child: Card(
                                                  elevation: 10,
                                                  child: SvgPicture.asset(
                                                    "assets/icons/addpic.svg",
                                                    // height: 4.h,
                                                    // width: 4.w,
                                                  ),
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                                isImageTaken == false || isImageTaken1 == false
                                    ? Card(
                                        elevation: 10,
                                        child: Center(
                                          child: Text(
                                            imageErr.toString(),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: getProportionateScreenHeight(20),
                                ),
                                _submitButton(),
                                SizedBox(
                                  height: getProportionateScreenHeight(40),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
