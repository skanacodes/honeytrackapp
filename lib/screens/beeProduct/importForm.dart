import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:honeytrackapp/services/screenArguments.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as path;

class ImportForm extends StatefulWidget {
  static String routeName = "/ImportForm";
  ImportForm({Key? key}) : super(key: key);

  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  bool isLoading = false;
  String local = '';
  String dealerName = '';
  String regNo = '';
  String quantity = '';
  String waterContent = '';
  String packingMaterials = '';
  String value = '';
  String color = '';
  String destinationCountry = '';
  String typeOfProduct = '';
  String feePaid = '';
  String address = '';
  String containerNo = '';
  String sealNo = '';
  String physicalHygiene = '';
  String exitPoint = '';
  String weight = '';
  String typeOfBeekeepingAppliances = '';
  String beeProductImported = '';
  String importLicence = '';
  String billOfLanding = '';
  String copyOfSanitary = '';
  String distributeChannel = '';
  String evidenceOfStorageFacility = '';
  String expiringDate = '';
  String? currency1;

  List<String> currency = ['USD', 'EURO', 'TZS'];
  bool isStepOneComplete = false;
  bool isStepTwoComplete = false;
  bool isStepThreeComplete = false;
  bool showPermitType = false;
  String imageErr = '';
  final _formKey = GlobalKey<FormState>();
  // final _formKey1 = GlobalKey<FormState>();
  List? beeProduct;
  String img1 = '';
  String img2 = '';
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  final String uploadUrl = 'https://api.imgur.com/3/upload';
  final ImagePicker _picker = ImagePicker();
  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

  // Future<DateTime?> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: DateTime.now(),
  //       initialDatePickerMode: DatePickerMode.day,
  //       firstDate: DateTime.now(),
  //       lastDate: DateTime(2025));
  //   print(picked);
  //   setState(() {
  //     formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
  //   });
  //   return picked;
  // }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: 'Import',
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

  Future<String> uploadData(jobId, userId) async {
    try {
      print(jobId);
      print(userId);
      // print("am here");
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      // int checkpointId = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getInt('checkpointId'));

      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = new BaseOptions(
          baseUrl: "$baseUrl",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        'id': jobId,
        'evidence_of_storage': evidenceOfStorageFacility,
        'consignment_value': value,
        'currency': currency1,
        'consignment_image[]': [
          await MultipartFile.fromFile(
            img1,
            filename: 'image',
          ),
          await MultipartFile.fromFile(
            img2,
            filename: 'images',
          ),
        ],
        'inspected_by': userId,
      });

      var response = await dio.post('$baseUrl/api/v1/imp-inspection/update',
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
      if (response.statusCode == 201) {
        //var res = json.decode(response.data);
        var res = response.data;
        print(res);
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

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
        )
      ],
    ).show();
  }

  Widget _submitButton(String jobid, String userId) {
    return InkWell(
      onTap: () async {
        //  print(_connectionStatus.toString());
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          if (isImageTaken & isImageTaken1) {
            setState(() {
              imageErr = "";
              isLoading = true;
            });
            var x = await uploadData(jobid, userId);
            setState(() {
              isImageTaken = false;
              isImageTaken1 = false;
              print(x);
              isLoading = false;
            });
            _formKey.currentState!.reset();
          } else {
            setState(() {
              imageErr = "Please Capture The Image";
              isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    print(args.jobId);
    print(args.personId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Import Inspection Form',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
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
                                  title: _title(),
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
                  forms(args.jobId, args.personId)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms(id, userId) {
    return
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
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.only(top: 10, right: 16, left: 16),
                    //   child: Container(
                    //     child: TextFormField(
                    //       keyboardType: TextInputType.number,
                    //       key: Key("quantity"),
                    //       onSaved: (val) => quantity = val!,
                    //       decoration: InputDecoration(
                    //         focusedBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(10.0),
                    //           borderSide: BorderSide(
                    //             color: Colors.cyan,
                    //           ),
                    //         ),
                    //         fillColor: Color(0xfff3f3f4),
                    //         filled: true,
                    //         labelText: "Quantity",
                    //         border: InputBorder.none,
                    //         isDense: true,
                    //         contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                    //       ),
                    //       validator: (value) {
                    //         if (value!.isEmpty) return "This Field Is Required";
                    //         return null;
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.only(top: 10, right: 16, left: 16),
                    //   child: Container(
                    //     child: TextFormField(
                    //       keyboardType: TextInputType.number,
                    //       key: Key("water"),
                    //       onSaved: (val) => weight = val!,
                    //       decoration: InputDecoration(
                    //         focusedBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(10.0),
                    //           borderSide: BorderSide(
                    //             color: Colors.cyan,
                    //           ),
                    //         ),
                    //         fillColor: Color(0xfff3f3f4),
                    //         filled: true,
                    //         labelText: "Weight",
                    //         border: InputBorder.none,
                    //         isDense: true,
                    //         contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                    //       ),
                    //       validator: (value) {
                    //         if (value!.isEmpty) return "This Field Is Required";
                    //         return null;
                    //       },
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("packs"),
                          onSaved: (val) => evidenceOfStorageFacility = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Suitability Of Storage",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return "This Field Is Required";
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 1, right: 16, left: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                key: Key("val"),
                                onSaved: (val) => value = val!,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Consignment Value",
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
                          Expanded(
                            flex: 4,
                            child: SafeArea(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.cyan,
                                      ),
                                    ),
                                    fillColor: const Color(0xfff3f3f4),
                                    filled: true,
                                    isDense: true,
                                    enabled: true,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        30, 10, 15, 10),
                                    labelText: "Currency",
                                    border: InputBorder.none),
                                isExpanded: true,
                                value: currency1,
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: 'Ubuntu'),

                                //elevation: 5,
                                //style: TextStyle(color: Colors.white),

                                items: currency.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xfff3f3f4),
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 1, color: kPrimaryColor),
                                        ),
                                      ),
                                      child: Text(
                                        value.toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return "This Field is required";
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    currency1 = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
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
                                    onTap: () {
                                      _pickImage(1);
                                    },
                                    child: Card(
                                      elevation: 10,
                                      child: Center(
                                          child: FutureBuilder<void>(
                                        future: retriveLostData(_imageFile),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<void> snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                            case ConnectionState.waiting:
                                              return const Text(
                                                  'Picked an image');
                                            case ConnectionState.done:
                                              return _previewImage(_imageFile);
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
                                    onTap: () {
                                      _pickImage(2);
                                    },
                                    child: Card(
                                      elevation: 10,
                                      child: Center(
                                          child: FutureBuilder<void>(
                                        future: retriveLostData(_imageFile1),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<void> snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                            case ConnectionState.waiting:
                                              return const Text(
                                                  'Picked an image');
                                            case ConnectionState.done:
                                              return _previewImage(_imageFile1);
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
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(id, userId),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
