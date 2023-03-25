import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honeytrackapp/modals/inspection_modal.dart';
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

class Inspection extends StatefulWidget {
  static String routeName = "/inspections";
  final String jobId;
  final String userId;
  final String jobname;
  final List apiaries;
  final List apiaryId;
  final List apiaryNum;
  final String hiveattend;
  final String taskId;
  Inspection(
      {required this.jobId,
      required this.userId,
      required this.apiaryNum,
      required this.jobname,
      required this.apiaries,
      required this.apiaryId,
      required this.hiveattend,
      required this.taskId});
  // Inspection({Key? key}) : super(key: key);

  @override
  _InspectionState createState() => _InspectionState();
}

class _InspectionState extends State<Inspection> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List? _expectedObservation;
  List? _actionTaken;
  List? _inspectionSeason;
  List? _generalcondition;
  String? result;
  List<String>? hiveTotal;
  String? dropdownvalue;
  String specifyExpectedObservations = "";
  String specifyActionTaken = "";
  String expectedHarvest = "";
  String kmSlashed = "";
  String noOfH = "";
  bool showExpectedOther = false;
  bool showActionOther = false;
  bool showSlashingKm = false;
  bool showHivesNumber = false;
  String? timeString;
  String? apiarName;
  String img1 = '';
  String img2 = '';
  String imageErr = ' ';
  String? apiaryIds;
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  String? uploadStatus;
  String? bloomingspecies;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  int hiveAttended = 0;
  List<String>? apiaryList;
  List<String>? apiaryId;
  final String uploadUrl = 'https://api.imgur.com/3/upload';
  final ImagePicker _picker = ImagePicker();

  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final formKey = new GlobalKey<FormState>();
  int _radioValue = 1;
  String? _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;

  _qrCallback(String? code) {
    setState(() {
      print(code);
      _camState = false;
      _qrInfo = json.decode(code!).toString();
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<String?> uploadImage(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('image', img1));
    var res = await request.send();
    print(res.statusCode);
    return res.reasonPhrase;
  }

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

  Future<String> uploadData() async {
    try {
      // print("am here");
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));

      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = new BaseOptions(
          baseUrl: "$baseUrl",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        'observations': _expectedObservation!.join(","),
        'action_taken': _actionTaken!.join(","),
        'blooming_species': bloomingspecies,
        'other_action_taken': specifyActionTaken.toString(),
        'other_observations': specifyExpectedObservations.toString(),
        'expected_harvest_kg': expectedHarvest.toString(),
        'apiary_id': apiaryIds,
        'harvest_expected': _radioValue,
        'task_activity_id': widget.taskId,
        'is_complete': hiveAttended == int.parse(hiveTotal![0]) ? true : false,
        'hive_code': _qrInfo,
        'colonization_date': formattedDate,
        'images[]': [
          await MultipartFile.fromFile(
            img1,
            filename: 'image_one',
          ),
          await MultipartFile.fromFile(
            img2,
            filename: 'image_two',
          ),
        ]
      });

      var response = await dio.post('$baseUrl/api/v1/apiary-inspection',
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
        if (res["success"]) {
          message('success', 'Data Submitted Successfull');

          return 'success';
        }
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
        print(img1 + "********************************");
      } else {
        print("Error While Taking Picture");
      }
    } catch (e) {
      print("Image picker error " + e.toString());
    }
  }

  void _handleRadioValueChange(var value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    print(picked);
    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

//  var apir;
  // getApiaries() {
  //   List x = widget.apiaries as List;
  //   print(x);
  //   setState(() {
  //     // apir = x.toList();
  //     //print(apir);
  //   });
  //   // return apir;
  // }
  count() async {
    var count = await DBProvider.db.hiveattendedNumber(widget.jobId);
    setState(() {
      hiveAttended = int.parse(count);
      // print(hiveAttended.toString() + "  bqfhhab Hive Attended");
    });
  }

  getDropdownList() {
    var x = widget.apiaries[0];
    var y = widget.apiaryId[0];
    var z = widget.apiaryNum[0];
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
      final removedBracket = y.substring(1, y.length - 1);
      print(removedBracket);
      final parts = removedBracket.split(', ');
      print(parts.runtimeType);
      setState(() {
        apiaryId = parts;
      });
    }
    if (z != "") {
      final removedBracket = z.substring(1, z.length - 1);
      print(removedBracket);
      final parts = removedBracket.split(', ');

      setState(() {
        hiveTotal = parts;
      });
      print(hiveTotal);
    }
  }

  @override
  void initState() {
    count();
    this.getDropdownList();
    initConnectivity();

    // timeString = _formatDateTime(DateTime.now());
    // Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  // void _getTime() {
  //   final DateTime now = DateTime.now();
  //   final String formattedDateTime = _formatDateTime(now);
  //   setState(() {
  //     timeString = formattedDateTime;
  //   });
  // }

  // String _formatDateTime(DateTime dateTime) {
  //   return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  // }

  //bool isLoading = false;
  // List data = List(); //edited line
  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fill',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Inspection ',
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
    print(img1);
    String response = await DBProvider.db.insertSingleApiaryInspection(
        InspectionModal(
            actionsTaken: _actionTaken.toString(),
            bloomingspecies: bloomingspecies!.toString(),
            inspectionSeason: _inspectionSeason.toString(),
            specifyExpectedObservation: specifyExpectedObservations,
            hiveCode: _qrInfo!,
            expectedHarvest: expectedHarvest,
            colonizationDate: formattedDate,
            expectedObservation: _expectedObservation.toString(),
            generalCondition: _generalcondition.toString(),
            expectedForHarvest: _radioValue.toString(),
            specifyActionTaken: specifyActionTaken,
            img1: img1,
            img2: img2,
            jobId: widget.jobId,
            userId: widget.userId,
            uploadStatus: status,
            apiaryId: apiaryIds.toString(),
            insetingWay: '1',
            isComplete:
                hiveAttended == int.parse(hiveTotal![0]) ? "true" : "false",
            apiaryName: apiarName!,
            taskActivityId: widget.taskId));
    if (response == "Success") {
      return 'success';
    } else {
      return 'fail';
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        // print(isImageTaken);
        // print(isImageTaken1);
        print(_connectionStatus.toString());
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (isImageTaken & isImageTaken1) {
            setState(() {
              imageErr = "";
              isLoading = true;
            });
            // var x = await uploadData();
            // // var x = await uploadImage(img1, uploadUrl);
            // // print(x);

            var response = await saveDataLocally('0');
            if (response == 'success') {
              setState(() {
                hiveAttended++;
              });
              var count = await DBProvider.db
                  .UpdateHiveAttended(widget.jobId, hiveAttended.toString());
              print(count);
              setState(() {
                hiveAttended = int.parse(count);
              });
              message('success', 'Data Stored Locally Successfull');
            } else {
              message('error', 'Failed To Store Data Locally');
            }

            apiaryList == null ? print('null') : apiaryList!.clear();

            _expectedObservation!.clear();
            _actionTaken!.clear();

            setState(() {
              isImageTaken = false;
              isImageTaken1 = false;
              getDropdownList();
              isLoading = false;
            });
            _formKey.currentState!.reset();
            hiveAttended > int.parse(hiveTotal![0])
                ? message("success", "This Task Is Completed SuccessFully")
                : print("done");
          } else {
            setState(() {
              imageErr = "Please Capture Image";
            });
          }
        }
      },
      child: isLoading
          ? SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _camState
          ? Center(
              child: SizedBox(
                height: 600,
                width: 400,
                child: QRBarScannerCamera(
                  onError: (context, error) => Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                  qrCodeCallback: (code) {
                    _qrCallback(code);
                  },
                ),
              ),
            )
          : Column(
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
                                      subtitle: hiveAttended >
                                              int.parse(hiveTotal![0])
                                          ? Text((hiveAttended - 1).toString() +
                                              " of " +
                                              hiveTotal![0].toString())
                                          : Text(hiveAttended.toString() +
                                              " of " +
                                              hiveTotal![0].toString()),
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
                      hiveAttended > int.parse(hiveTotal![0])
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Container(
                                  child: Card(
                                      elevation: 10,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.cloud_done_sharp,
                                          color: kPrimaryColor,
                                        ),
                                        title: Text("The Task Is Completed"),
                                      )),
                                ),
                              ),
                            )
                          : Form(
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
                                              height:
                                                  getProportionateScreenHeight(
                                                      10),
                                            ),
                                            apiaryList != null
                                                ? SafeArea(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 1,
                                                              right: 16,
                                                              left: 16),
                                                      child: Container(
                                                        // width: getProportionateScreenHeight(
                                                        //     320),
                                                        child:
                                                            DropdownButtonFormField<
                                                                String>(
                                                          decoration: InputDecoration(
                                                              isDense: true,
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white)),
                                                              fillColor: Color(
                                                                  0xfff3f3f4),
                                                              filled: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          20,
                                                                          5.5,
                                                                          0,
                                                                          0),
                                                              labelStyle:
                                                                  TextStyle(),
                                                              labelText:
                                                                  'Select the Apiary'),
                                                          focusColor:
                                                              Colors.white,
                                                          value: apiarName,
                                                          //elevation: 5,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                          iconEnabledColor:
                                                              Colors.black,
                                                          items: apiaryList!.map<
                                                              DropdownMenuItem<
                                                                  String>>((String
                                                              value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Text(
                                                                value,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            );
                                                          }).toList(),

                                                          onChanged: (value) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    new FocusNode());
                                                            setState(() {
                                                              apiarName =
                                                                  value!;
                                                              int index =
                                                                  apiaryList!
                                                                      .indexOf(
                                                                          apiarName!);
                                                              apiaryIds =
                                                                  apiaryId![
                                                                          index]
                                                                      .toString();
                                                              print(apiaryIds);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 16, left: 16),
                                              child: Text(
                                                "Scan To Capture The Hive Code",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 1, right: 16, left: 16),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 5,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 1,
                                                              right: 1,
                                                              left: 1),
                                                      child: Container(
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          key: Key("plat"),
                                                          // onSaved: (val) => task.licencePlateNumber = val,
                                                          decoration:
                                                              InputDecoration(
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color:
                                                                    Colors.cyan,
                                                              ),
                                                            ),
                                                            fillColor: Color(
                                                                0xfff3f3f4),
                                                            filled: true,
                                                            labelText: _qrInfo !=
                                                                    null
                                                                ? _qrInfo
                                                                : "Hive Code",
                                                            border: InputBorder
                                                                .none,
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                        30,
                                                                        10,
                                                                        15,
                                                                        10),
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
                                                        // _scanQR();
                                                        _scanCode();
                                                      },
                                                      child: DashedCircle(
                                                        dashes: 6,
                                                        gapSize: 10.0,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: CircleAvatar(
                                                            // radius: 70.0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            foregroundColor:
                                                                Colors
                                                                    .transparent,
                                                            radius: 16,
                                                            child: SvgPicture
                                                                .asset(
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
                                                  child: Card(
                                                elevation: 1,
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    child: Icon(
                                                        Icons.calendar_today),
                                                  ),
                                                  onTap: () {
                                                    _selectDate(context);
                                                  },
                                                  title: Text(
                                                    'Colonization Date: $formattedDate',
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                  ),
                                                ),
                                              )),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              child: MultiSelectFormField(
                                                chipBackGroundColor:
                                                    Colors.blue,
                                                chipLabelStyle: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                dialogTextStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                checkBoxActiveColor:
                                                    Colors.blue,
                                                checkBoxCheckColor:
                                                    Colors.white,
                                                dialogShapeBorder:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12.0))),
                                                title: Text(
                                                  " Observations",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.length == 0) {
                                                    return 'Please select one or more options';
                                                  }
                                                  return null;
                                                },
                                                dataSource: [
                                                  {
                                                    "display": "Egg Laying",
                                                    "value": "Egg Laying",
                                                  },
                                                  {
                                                    "display": "Enemies",
                                                    "value": "Enemies",
                                                  },
                                                  {
                                                    "display":
                                                        "Sealed Honey Combs",
                                                    "value":
                                                        "Sealed Honey Combs",
                                                  },
                                                  {
                                                    "display": "Brood",
                                                    "value": "Brood",
                                                  },
                                                  {
                                                    "display": "Strong Colony",
                                                    "value": "Strong Colony",
                                                  },
                                                  {
                                                    "display": "Weak Colony",
                                                    "value": "Weak Colony",
                                                  },
                                                  {
                                                    "display":
                                                        "Presence Of Queen Cells",
                                                    "value":
                                                        "Presence Of Queen Cells",
                                                  },
                                                  {
                                                    "display":
                                                        "Unsealed Honey Combs",
                                                    "value":
                                                        "Unsealed Honey Combs",
                                                  },
                                                  {
                                                    "display": "Others",
                                                    "value": "others",
                                                  },
                                                ],
                                                textField: 'display',
                                                valueField: 'value',
                                                okButtonLabel: 'OK',
                                                cancelButtonLabel: 'CANCEL',
                                                hintWidget: Text(
                                                    'Please choose one or more'),
                                                initialValue:
                                                    _expectedObservation,
                                                onSaved: (value) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                  if (value == null) return;
                                                  setState(() {
                                                    _expectedObservation =
                                                        value;
                                                    if (_expectedObservation!
                                                        .contains("others")) {
                                                      showExpectedOther = true;
                                                    } else {
                                                      showExpectedOther = false;
                                                    }

                                                    print(_expectedObservation);
                                                  });
                                                },
                                              ),
                                            ),
                                            showExpectedOther
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 16,
                                                            left: 16),
                                                    child: Container(
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType.text,
                                                        key: Key("specify"),
                                                        onSaved: (val) =>
                                                            specifyExpectedObservations =
                                                                val!,
                                                        decoration:
                                                            InputDecoration(
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.cyan,
                                                            ),
                                                          ),
                                                          fillColor:
                                                              Color(0xfff3f3f4),
                                                          filled: true,
                                                          labelText:
                                                              "If Other Specify",
                                                          border:
                                                              InputBorder.none,
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      30,
                                                                      10,
                                                                      15,
                                                                      10),
                                                        ),
                                                        // onChanged: (value) {},
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
                                                chipBackGroundColor:
                                                    Colors.blue,
                                                chipLabelStyle: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                dialogTextStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                checkBoxActiveColor:
                                                    Colors.blue,
                                                checkBoxCheckColor:
                                                    Colors.white,
                                                dialogShapeBorder:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12.0))),
                                                title: Text(
                                                  "Actions Taken",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.length == 0) {
                                                    return 'Please select one or more options';
                                                  }
                                                  return null;
                                                },
                                                dataSource: [
                                                  {
                                                    "display": "Cleaning",
                                                    "value": "Cleaning",
                                                  },
                                                  {
                                                    "display": "Rebaiting",
                                                    "value": "Rebaiting",
                                                  },
                                                  {
                                                    "display":
                                                        "Siting/Resiting",
                                                    "value": "Siting/Resiting",
                                                  },
                                                  {
                                                    "display": "Slashing",
                                                    "value": "Slashing",
                                                  },
                                                  {
                                                    "display": "Spot Weeding",
                                                    "value": "Spot Weeding",
                                                  },
                                                  {
                                                    "display": "Hive Repairing",
                                                    "value": "Hive Repairing",
                                                  },
                                                  {
                                                    "display": "Colony Uniting",
                                                    "value": "Colony Uniting",
                                                  },
                                                  {
                                                    "display":
                                                        "Colony Division",
                                                    "value": "Colony Division",
                                                  },
                                                  {
                                                    "display": "Queen Rearing",
                                                    "value": "Queen Rearing",
                                                  },
                                                  {
                                                    "display": "Harvesting",
                                                    "value": "Harvesting",
                                                  },
                                                  {
                                                    "display": "Others",
                                                    "value": "others",
                                                  },
                                                ],
                                                textField: 'display',
                                                valueField: 'value',
                                                okButtonLabel: 'OK',
                                                cancelButtonLabel: 'CANCEL',
                                                hintWidget: Text(
                                                    'Please choose one or more'),
                                                initialValue: _actionTaken,
                                                onSaved: (value) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                  if (value == null) return;
                                                  setState(() {
                                                    _actionTaken = value;
                                                    if (_actionTaken!
                                                        .contains("others")) {
                                                      showActionOther = true;
                                                    } else {
                                                      showActionOther = false;
                                                    }
                                                    if (_actionTaken!
                                                        .contains("Slashing")) {
                                                      showSlashingKm = true;
                                                    } else {
                                                      showSlashingKm = false;
                                                    }
                                                    if (_actionTaken!.contains(
                                                        "Spot Weeding")) {
                                                      showHivesNumber = true;
                                                    } else {
                                                      showHivesNumber = false;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            showActionOther
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 16,
                                                            left: 16),
                                                    child: Container(
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType.text,
                                                        key: Key("other"),
                                                        onSaved: (val) =>
                                                            specifyActionTaken =
                                                                val!,
                                                        decoration:
                                                            InputDecoration(
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.cyan,
                                                            ),
                                                          ),
                                                          fillColor:
                                                              Color(0xfff3f3f4),
                                                          filled: true,
                                                          labelText:
                                                              "If Other Specify",
                                                          border:
                                                              InputBorder.none,
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      30,
                                                                      10,
                                                                      15,
                                                                      10),
                                                        ),
                                                        // validator: (value) {
                                                        //   if (value.isEmpty)
                                                        //     return "This Field Is Required";
                                                        //   return null;
                                                        // },
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            // showSlashingKm
                                            //     ? Padding(
                                            //         padding: const EdgeInsets.only(
                                            //             top: 10, right: 16, left: 16),
                                            //         child: Container(
                                            //           child: TextFormField(
                                            //             keyboardType:
                                            //                 TextInputType.number,
                                            //             key: Key("other"),
                                            //             onSaved: (val) =>
                                            //                 kmSlashed = val!,
                                            //             decoration: InputDecoration(
                                            //               focusedBorder:
                                            //                   OutlineInputBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius.circular(
                                            //                         10.0),
                                            //                 borderSide: BorderSide(
                                            //                   color: Colors.cyan,
                                            //                 ),
                                            //               ),
                                            //               fillColor:
                                            //                   Color(0xfff3f3f4),
                                            //               filled: true,
                                            //               labelText:
                                            //                   "Specify km Slashed",
                                            //               border: InputBorder.none,
                                            //               isDense: true,
                                            //               contentPadding:
                                            //                   EdgeInsets.fromLTRB(
                                            //                       30, 10, 15, 10),
                                            //             ),
                                            //             // validator: (value) {
                                            //             //   if (value.isEmpty)
                                            //             //     return "This Field Is Required";
                                            //             //   return null;
                                            //             // },
                                            //           ),
                                            //         ),
                                            //       )
                                            //     : Container(),
                                            // showSlashingKm
                                            //     ? Padding(
                                            //         padding: const EdgeInsets.only(
                                            //             top: 10, right: 16, left: 16),
                                            //         child: Container(
                                            //           child: TextFormField(
                                            //             keyboardType:
                                            //                 TextInputType.number,
                                            //             key: Key("other"),
                                            //             onSaved: (val) =>
                                            //                 noOfH = val!,
                                            //             decoration: InputDecoration(
                                            //               focusedBorder:
                                            //                   OutlineInputBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius.circular(
                                            //                         10.0),
                                            //                 borderSide: BorderSide(
                                            //                   color: Colors.cyan,
                                            //                 ),
                                            //               ),
                                            //               fillColor:
                                            //                   Color(0xfff3f3f4),
                                            //               filled: true,
                                            //               labelText:
                                            //                   "No. Of Hives Where Spot Weeded",
                                            //               border: InputBorder.none,
                                            //               isDense: true,
                                            //               contentPadding:
                                            //                   EdgeInsets.fromLTRB(
                                            //                       30, 10, 15, 10),
                                            //             ),
                                            //             // validator: (value) {
                                            //             //   if (value.isEmpty)
                                            //             //     return "This Field Is Required";
                                            //             //   return null;
                                            //             // },
                                            //           ),
                                            //         ),
                                            //       )
                                            //     : Container(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 16, left: 16),
                                              child: Container(
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  key: Key("Blooming"),
                                                  onSaved: (val) =>
                                                      bloomingspecies = val,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide: BorderSide(
                                                        color: Colors.cyan,
                                                      ),
                                                    ),
                                                    fillColor:
                                                        Color(0xfff3f3f4),
                                                    filled: true,
                                                    labelText:
                                                        "Blooming Species",
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
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child:
                                                  Text("Expected For Harvest?"),
                                            ),
                                            Card(
                                              elevation: 6,
                                              child: new Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    new Radio(
                                                      value: 1,
                                                      groupValue: _radioValue,
                                                      onChanged: (value) {
                                                        _handleRadioValueChange(
                                                            value);
                                                      },
                                                    ),
                                                    new Text(
                                                      'Yes',
                                                      style: new TextStyle(
                                                          fontSize: 16.0),
                                                    ),
                                                    new Radio(
                                                      value: 0,
                                                      groupValue: _radioValue,
                                                      onChanged: (value) {
                                                        _handleRadioValueChange(
                                                            value);
                                                      },
                                                    ),
                                                    new Text(
                                                      'No',
                                                      style: new TextStyle(
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                            _radioValue == 1
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 16,
                                                            left: 16),
                                                    child: Container(
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        key: Key("other"),
                                                        onSaved: (val) =>
                                                            expectedHarvest =
                                                                val!,
                                                        decoration:
                                                            InputDecoration(
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.cyan,
                                                            ),
                                                          ),
                                                          fillColor:
                                                              Color(0xfff3f3f4),
                                                          filled: true,
                                                          labelText:
                                                              "Expected Harvest (in Kg)",
                                                          border:
                                                              InputBorder.none,
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      30,
                                                                      10,
                                                                      15,
                                                                      10),
                                                        ),
                                                        // validator: (value) {
                                                        //   if (value!.isEmpty)
                                                        //     return "This Field Is Required";
                                                        //   return null;
                                                        // },
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            Container(
                                              width: double.infinity,
                                              height:
                                                  getProportionateScreenHeight(
                                                      60),
                                              child: Card(
                                                elevation: 10,
                                                child: Center(
                                                  child: Text(
                                                      "Click On The Icons To Take Atleast Two Pictures"),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      200),
                                              width: double.infinity,
                                              child: Row(
                                                children: [
                                                  isImageTaken
                                                      ? Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              _pickImage(1);
                                                            },
                                                            child: Card(
                                                              elevation: 10,
                                                              child: Center(
                                                                  child:
                                                                      FutureBuilder<
                                                                          void>(
                                                                future: retriveLostData(
                                                                    _imageFile),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            void>
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
                                                            onTap: () {
                                                              _pickImage(1);
                                                            },
                                                            child: Card(
                                                              elevation: 10,
                                                              child: SvgPicture
                                                                  .asset(
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
                                                            onTap: () {
                                                              _pickImage(2);
                                                            },
                                                            child: Card(
                                                              elevation: 10,
                                                              child: Center(
                                                                  child:
                                                                      FutureBuilder<
                                                                          void>(
                                                                future: retriveLostData(
                                                                    _imageFile1),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            void>
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
                                                            onTap: () {
                                                              _pickImage(2);
                                                            },
                                                            child: Card(
                                                              elevation: 10,
                                                              child: SvgPicture
                                                                  .asset(
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
                                            isImageTaken == false ||
                                                    isImageTaken1 == false
                                                ? Card(
                                                    elevation: 10,
                                                    child: Center(
                                                      child: Text(
                                                        imageErr.toString(),
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      20),
                                            ),
                                            _submitButton(),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      40),
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
