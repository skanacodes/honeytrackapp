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

class InternalMarketForm extends StatefulWidget {
  static String routeName = "/InternalMarketForm";
  InternalMarketForm({Key? key}) : super(key: key);

  @override
  _InternalMarketFormState createState() => _InternalMarketFormState();
}

class _InternalMarketFormState extends State<InternalMarketForm> {
  bool isLoading = false;
  String local = '';
  String? form;
  String quantity = '';
  String waterContent = '';
  String? packingMaterials;
  String value = '';
  String? color;
  String destinationCountry = '';
  String refusalReason = '';
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
  bool showPackagingMaterial = false;
  bool isStepOneComplete = false;
  bool isStepTwoComplete = false;
  bool isStepThreeComplete = false;
  bool showPermitType = false;
  String? modeling;

  final _formKey = GlobalKey<FormState>();
  // final _formKey1 = GlobalKey<FormState>();
  List<String> currency = ['USD', 'EURO', 'TZS'];
  String? currency1;
  List<String> ModelingBeeWax = [
    'Uniform Blocks',
    'Uniform Pallets',
    'Uniform Parcel'
  ];
  List? beeProduct;
  String img1 = '';
  String img2 = '';
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  String imageErr = '';
  final String uploadUrl = 'https://api.imgur.com/3/upload';
  final ImagePicker _picker = ImagePicker();
  //DateTime now = DateTime.now();
  String? ask1;
  List<String> ask = [
    'Yes',
    'No',
  ];
  List<String> packagingBeeWax = [
    'Hessian Cloth',
    'Guny Bags',
    'Polythene Bags',
  ];
  List<String> packagingMaterialOther = [
    'Glass jar',
    'Food grade Plastic bottle',
  ];
  List<String> colorList = [
    'Water white',
    'Extra white',
    'White',
    'Extra Light Amber',
    'Light Amber',
    'Amber',
    'Dark Amber',
  ];
  List<String> packaging = [
    'Stainless Steel Drums',
    'Plastic Drums',
    'Plastic Buckets',
    'Plastic Jerry Cans',
    'Plastic Jars',
    'Stainless Steel Jerry Cans',
    'Glass Jars',
    'Plastic bottles',
    'Glass bottles',
    'Lacquered Drums'
  ];
  List<String> formlist = [
    'Comb Honey',
    'Strained Honey',
    'Granulated Honey',
  ];
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
          text: 'Internal Market',
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
        'id': int.parse(jobId),
        'form': form.toString(),
        'water_content': waterContent.toString(),
        'color': color.toString(),
        'packaging_material': packingMaterials.toString(),
        'storage_facility_suitability': evidenceOfStorageFacility.toString(),
        'value': value.toString(),
        'beeswax_modeling': modeling.toString(),
        'currency': currency1.toString(),
        'is_sanitary_granted': _radioValue1 == 0 ? true : false,
        'refusal_reason': refusalReason.toString(),
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
        'inspected_by': int.parse(userId),
      });

      var response = await dio.post('$baseUrl/api/v1/local-inspection/update',
          data: formData, onSendProgress: (int sent, int total) {
        // setState(() {
        //   uploadMessage = sent.toString();
        // });
        print('$sent $total');
      });
      print(response.statusCode);
      print(response.data);
      // print(response.statusMessage);
      // print("********************************");
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

  int _radioValue1 = 0;
  void _handleRadioValueChange1(var value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
          setState(() {
            showPermitType = true;
          });
          break;
        case 1:
          setState(() {
            showPermitType = false;
          });
          break;
      }
    });
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
              imageErr = '';
              isLoading = true;
            });
            var x = await uploadData(jobid, userId);
            setState(() {
              isImageTaken = false;
              isImageTaken1 = false;
              print(x);
              isLoading = false;
              color = null;
              form = null;
              ask1 = null;
              packingMaterials = null;
            });

            _formKey.currentState!.reset();
          }
        } else {
          // print('ASDADC');
          setState(() {
            imageErr = 'Please Capture The Image';
          });
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
          '${args.productType} Inspection Form',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: getProportionateScreenHeight(600),
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
                  args.productType.toString() == "Beeswax"
                      ? formBeeWax(args.jobId, args.personId)
                      : args.productType.toString() == "Honey"
                          ? forms(args.jobId, args.personId)
                          : formRoyalJell(args.jobId, args.personId)
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          key: Key("Water Content"),
                          onSaved: (val) => waterContent = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Water Content",
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Select Color",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: color,
                            //elevation: 5,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),
                            iconEnabledColor: Colors.black,
                            items: colorList
                                .map<DropdownMenuItem<String>>((String value) {
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
                                    style: const TextStyle(color: Colors.black),
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
                                color = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
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
                            contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return "This Field Is Required";
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Select Form",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: form,
                            //elevation: 5,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),
                            iconEnabledColor: Colors.black,
                            items: formlist
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'This Field Is Required';
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                form = value!;
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Is Proper Packaging Material ?",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: ask1,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),

                            //elevation: 5,
                            //style: TextStyle(color: Colors.white),

                            items: ask
                                .map<DropdownMenuItem<String>>((String value) {
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
                                    style: const TextStyle(color: Colors.black),
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
                                ask1 = value!;
                                ask1 == "Yes"
                                    ? showPackagingMaterial = true
                                    : showPackagingMaterial = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    showPackagingMaterial
                        ? SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 1, right: 16, left: 16),
                              child: Container(
                                // width: getProportionateScreenHeight(
                                //     320),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                      labelText: "Select Packaging Material",
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  value: packingMaterials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Ubuntu'),
                                  //elevation: 5,

                                  iconEnabledColor: Colors.black,
                                  items: packaging
                                      .map<DropdownMenuItem<String>>(
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
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    setState(() {
                                      packingMaterials = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("Suitability Of Storage"),
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
                    Card(
                      elevation: 6,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Center(child: Text('Is Sanitary Granted?')),
                          ),
                          new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Radio(
                                  value: 0,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'Yes',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 1,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'No',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                    _radioValue1 == 1
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                key: Key("Refusal Reason"),
                                onSaved: (val) => refusalReason = val!,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Refusal Reason",
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
                          )
                        : Container(),
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
                      height: getProportionateScreenHeight(10),
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

  formBeeWax(id, userId) {
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Is Proper Packaging Material ?",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: ask1,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),

                            //elevation: 5,
                            //style: TextStyle(color: Colors.white),

                            items: ask
                                .map<DropdownMenuItem<String>>((String value) {
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
                                    style: const TextStyle(color: Colors.black),
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
                                ask1 = value!;
                                ask1 == "Yes"
                                    ? showPackagingMaterial = true
                                    : showPackagingMaterial = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    showPackagingMaterial
                        ? SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 1, right: 16, left: 16),
                              child: Container(
                                // width: getProportionateScreenHeight(
                                //     320),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                      labelText: "Select Packaging Material",
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  value: packingMaterials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Ubuntu'),
                                  //elevation: 5,

                                  iconEnabledColor: Colors.black,
                                  items: packagingBeeWax
                                      .map<DropdownMenuItem<String>>(
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
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    setState(() {
                                      packingMaterials = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 1, right: 16, left: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
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
                                      EdgeInsets.fromLTRB(30, 7, 15, 7),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return "This Field Is Required";
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
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
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(30, 5, 15, 5),
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
                      height: 10,
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Select Beeswax Modeling",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: modeling,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),
                            //elevation: 5,

                            iconEnabledColor: Colors.black,
                            items: ModelingBeeWax.map<DropdownMenuItem<String>>(
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
                                    style: const TextStyle(color: Colors.black),
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
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              setState(() {
                                modeling = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("Suitability Of Storage"),
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
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("hygien"),
                          onSaved: (val) => physicalHygiene = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Physical Hygien",
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
                    Card(
                      elevation: 6,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Center(child: Text('Is Sanitary Granted?')),
                          ),
                          new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Radio(
                                  value: 0,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'Yes',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 1,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'No',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                    _radioValue1 == 1
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                key: Key("Refusal Reason"),
                                onSaved: (val) => refusalReason = val!,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Refusal Reason",
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
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
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

//Royal Jelly Form
  formRoyalJell(id, userId) {
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Is Proper Packaging Material ?",
                                border: InputBorder.none),
                            isExpanded: true,
                            value: ask1,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),

                            //elevation: 5,
                            //style: TextStyle(color: Colors.white),

                            items: ask
                                .map<DropdownMenuItem<String>>((String value) {
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
                                    style: const TextStyle(color: Colors.black),
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
                                ask1 = value!;
                                ask1 == "Yes"
                                    ? showPackagingMaterial = true
                                    : showPackagingMaterial = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    showPackagingMaterial
                        ? SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 1, right: 16, left: 16),
                              child: Container(
                                // width: getProportionateScreenHeight(
                                //     320),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                      labelText: "Select Packaging Material",
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  value: packingMaterials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Ubuntu'),
                                  //elevation: 5,

                                  iconEnabledColor: Colors.black,
                                  items: packagingMaterialOther
                                      .map<DropdownMenuItem<String>>(
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
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    setState(() {
                                      packingMaterials = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 1, right: 16, left: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
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
                                      EdgeInsets.fromLTRB(30, 7, 15, 7),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return "This Field Is Required";
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
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
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(30, 5, 15, 5),
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("Suitability Of Storage"),
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
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("hygien"),
                          onSaved: (val) => physicalHygiene = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Physical Hygien",
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
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      elevation: 6,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Center(child: Text('Is Sanitary Granted?')),
                          ),
                          new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Radio(
                                  value: 0,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'Yes',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 1,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                    _handleRadioValueChange1(value);
                                  },
                                ),
                                new Text(
                                  'No',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                    _radioValue1 == 1
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                key: Key("Refusal Reason"),
                                onSaved: (val) => refusalReason = val!,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                  labelText: "Refusal Reason",
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
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
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
