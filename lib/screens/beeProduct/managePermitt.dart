import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class ManagePermit extends StatefulWidget {
  static String routeName = "/permit";
  ManagePermit({Key? key}) : super(key: key);

  @override
  _ManagePermitState createState() => _ManagePermitState();
}

class _ManagePermitState extends State<ManagePermit> {
  String? type;

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

  bool isStepOneComplete = false;
  bool isStepTwoComplete = false;
  bool isStepThreeComplete = false;
  bool showPermitType = false;

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  List? beeProduct;
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

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    print(picked);
    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

  void _pickImage(int numb) async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.camera);
      setState(() {
        numb == 1 ? _imageFile = pickedFile! : _imageFile1 = pickedFile!;

        numb == 1 ? isImageTaken = true : isImageTaken1 = true;
      });
      final File file = File(numb == 1 ? _imageFile.path : _imageFile1.path);
      // getting a directory path for saving
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      final fileName =
          path.basename(numb == 1 ? _imageFile.path : _imageFile1.path);
// copy the file to a new path
      final File newImage = await file.copy('$appDocPath/$fileName');
      print(newImage);
    } catch (e) {
      print("Image picker error " + e.toString());
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: type == 'Internal Market'
              ? 'Internal Market'
              : type == 'Export'
                  ? 'Export'
                  : 'Import',
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

  Future getData() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse(
          'https://mis.tfs.go.tz/honey-traceability/api/v1/exp-inspection');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            if (res['status'] == 'Authorization Token not found') {
              messages('success', 'Authorization Token Not Found');
            } else {
              messages('success', 'Data Successfull saved');
            }
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future postData() async {
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      var url = Uri.parse(
          'https://mis.tfs.go.tz/honey-traceability/api/v1/exp-inspection/update');
      final response = await http.post(
        url,
        body: jsonEncode({
          'id': 6,
          'quantity': quantity,
          'water_content': waterContent,
          'packing_materials': packingMaterials,
          'value': value,
          'color': color,
          'container_no': containerNo,
          'seal_no': sealNo,
          'consignment_image': "tyew",
          'inspected_by': 'onest',
          'physical_hygiene': physicalHygiene
        }),
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            messages('success', 'Data Successfull saved');
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState

    this.getData();
    super.initState();
  }

  final List<DropdownMenuItem<String>> _permitType = [
    DropdownMenuItem(
      child: new Text("Export"),
      value: "Export",
    ),
    DropdownMenuItem(
      child: new Text("Import"),
      value: "Import",
    ),
    DropdownMenuItem(
      child: new Text("Internal Market"),
      value: "Internal Market",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: [
              Container(
                // height: 50,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: 300,
                      child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                              labelStyle: TextStyle(),
                              labelText: 'Select Type Of Permit'),
                          items: _permitType,
                          value: type,
                          validator: (value) =>
                              value == null ? "This Field is Required" : null,
                          onChanged: (value) => type = value.toString()),
                    )
                  ],
                ),
              )
            ],
            leading: IconButton(
                icon: Icon(Icons.filter_1),
                onPressed: () {
                  // Do something
                }),
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            snap: true,
            elevation: 50,
            backgroundColor: Colors.pink,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('Permit Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Image.network(
                  'https://images.pexels.com/photos/443356/pexels-photo-443356.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                  fit: BoxFit.cover,
                )),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => forms(),
              childCount: 1,
            ), //SliverChildBuildDelegate
          ) //SliverList
          // new SliverList(delegate: new SliverChildListDelegate(forms())),
        ],
      ),
    );
  }

  // List<Widget>? _buildList(int count) {
  //   List<Widget>? listItems;

  //   for (int i = 0; i < count; i++) {
  //     listItems!.add(new Padding(
  //         padding: new EdgeInsets.all(20.0),
  //         child: new Text('Item ${i.toString()}',
  //             style: new TextStyle(fontSize: 25.0))));
  //   }

  //   return listItems;
  // }

  forms() {
    return Column(
      children: [
        Container(
          height: type == 'Export'
              ? getProportionateScreenHeight(1310)
              : type == 'Internal Market'
                  ? getProportionateScreenHeight(1100)
                  : getProportionateScreenHeight(1539),
          child: Column(
            children: <Widget>[
              // Adding the form here
              Form(
                key: _formKey1,
                child: Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 10,
                          shadowColor: kPrimaryColor,
                          child: Column(
                            children: <Widget>[
                              _title(),

                              type == 'Export' || type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("quantity"),
                                          onSaved: (val) => quantity = val!,
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
                                            labelText: "Quantity",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("quantity"),
                                          onSaved: (val) => quantity = val!,
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
                                                "Storage Facility And Suitability",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("weight"),
                                          onSaved: (val) => weight = val!,
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
                                            labelText: "Weight",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("weight"),
                                          onSaved: (val) =>
                                              typeOfBeekeepingAppliances = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Type of Appliances",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("weight"),
                                          onSaved: (val) =>
                                              beeProductImported = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Bee Product Imported",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Export' || type == 'Internal Market'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("water"),
                                          onSaved: (val) => waterContent = val!,
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
                                            labelText: "Water Content",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                30, 10, 15, 10),
                                          ),
                                          // validator: (value) {
                                          //   if (value.isEmpty)
                                          //     return "This Field Is Required";
                                          //   return null;
                                          // },
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("bill"),
                                          onSaved: (val) =>
                                              billOfLanding = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Bill Of Landing",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("import"),
                                          onSaved: (val) =>
                                              importLicence = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Import Licence",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("weight"),
                                          onSaved: (val) =>
                                              copyOfSanitary = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Copy Of Sanitary",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Import'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          key: Key("weight"),
                                          onSaved: (val) =>
                                              typeOfBeekeepingAppliances = val!,
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
                                            // hintText: "Type of Appliances",
                                            labelText: "Distribute Channel",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Export' || type == 'Internal Market'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("packs"),
                                          onSaved: (val) =>
                                              packingMaterials = val!,
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
                                            labelText: "Packing Materials",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Internal Market'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("packs"),
                                          onSaved: (val) =>
                                              packingMaterials = val!,
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
                                            labelText: "Product Form",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    key: Key("val"),
                                    onSaved: (val) => value = val!,
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
                                      labelText: "Values",
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
                              type == "Export" || type == "Internal Market"
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("color"),
                                          onSaved: (val) => color = val!,
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
                                            labelText: "color",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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

                              type == 'Export'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("container"),
                                          onSaved: (val) => containerNo = val!,
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
                                            labelText: "Container Number",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == 'Export'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("seal"),
                                          onSaved: (val) => sealNo = val!,
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
                                            labelText: "Seal Number",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == "Import"
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("exit"),
                                          onSaved: (val) =>
                                              evidenceOfStorageFacility = val!,
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
                                                "Evidence Of Storage Facility",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == "Import"
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                          child: Card(
                                        elevation: 1,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.calendar_today),
                                          ),
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                          title: Text(
                                            'Expire Date: $formattedDate',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ),
                                      )),
                                    )
                                  : Container(),
                              type == 'Export'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("hygien"),
                                          onSaved: (val) =>
                                              physicalHygiene = val!,
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
                                            labelText: "Physical Hygien",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              type == "Export"
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 16, left: 16),
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          key: Key("exit"),
                                          onSaved: (val) => exitPoint = val!,
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
                                            labelText: "Exit Point",
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                                  : type == "Import"
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 16, left: 16),
                                          child: Container(
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              key: Key("exit"),
                                              onSaved: (val) =>
                                                  exitPoint = val!,
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
                                                fillColor: Color(0xfff3f3f4),
                                                filled: true,
                                                labelText: "Entry Point",
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
                              // Container(
                              //   padding: EdgeInsets.all(16),
                              //   child: MultiSelectFormField(
                              //     autovalidate: false,
                              //     chipBackGroundColor: Colors.blue,
                              //     chipLabelStyle: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.white),
                              //     dialogTextStyle:
                              //         TextStyle(fontWeight: FontWeight.bold),
                              //     checkBoxActiveColor: Colors.blue,
                              //     checkBoxCheckColor: Colors.white,
                              //     dialogShapeBorder: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(12.0))),
                              //     title: Text(
                              //       "General Condition",
                              //       style: TextStyle(fontSize: 16),
                              //     ),
                              //     validator: (value) {
                              //       if (value == null || value.length == 0) {
                              //         return 'Please select one or more options';
                              //       }
                              //       return null;
                              //     },
                              //     dataSource: [
                              //       {
                              //         "display": "Rain",
                              //         "value": "Rain",
                              //       },
                              //       {
                              //         "display": "Sunny",
                              //         "value": "Sunny",
                              //       },
                              //     ],
                              //     textField: 'display',
                              //     valueField: 'value',
                              //     okButtonLabel: 'OK',
                              //     cancelButtonLabel: 'CANCEL',
                              //     hintWidget:
                              //         Text('Please choose one or more'),
                              //     // initialValue: _generalcondition,
                              //     // onSaved: (value) {
                              //     //   if (value == null) return;
                              //     //   setState(() {
                              //     //     _generalcondition = value;
                              //     //     //  print(_generalcondition);
                              //     //   });
                              //     // },
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 10, right: 16, left: 16),
                              //   child: Container(
                              //     child: TextFormField(
                              //       keyboardType: TextInputType.text,
                              //       key: Key("Blooming"),
                              //       // onSaved: (val) => task.drivername = val,
                              //       decoration: InputDecoration(
                              //         focusedBorder: OutlineInputBorder(
                              //           borderRadius:
                              //               BorderRadius.circular(10.0),
                              //           borderSide: BorderSide(
                              //             color: Colors.cyan,
                              //           ),
                              //         ),
                              //         fillColor: Color(0xfff3f3f4),
                              //         filled: true,
                              //         labelText: "Blooming Species",
                              //         border: InputBorder.none,
                              //         isDense: true,
                              //         contentPadding:
                              //             EdgeInsets.fromLTRB(30, 10, 15, 10),
                              //       ),
                              //       // validator: (value) {
                              //       //   if (value.isEmpty)
                              //       //     return "This Field Is Required";
                              //       //   return null;
                              //       // },
                              //     ),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 8),
                              //   child: Text("Expected For Harvest?"),
                              // ),
                              // Card(
                              //   elevation: 6,
                              //   child: new Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.center,
                              //       children: [
                              //         new Radio(
                              //           value: 0,
                              //           groupValue: _radioValue,
                              //           onChanged: (value) {
                              //             _handleRadioValueChange(value);
                              //           },
                              //         ),
                              //         new Text(
                              //           'Yes',
                              //           style: new TextStyle(fontSize: 16.0),
                              //         ),
                              //         new Radio(
                              //           value: 1,
                              //           groupValue: _radioValue,
                              //           onChanged: (value) {
                              //             _handleRadioValueChange(value);
                              //           },
                              //         ),
                              //         new Text(
                              //           'No',
                              //           style: new TextStyle(
                              //             fontSize: 16.0,
                              //           ),
                              //         ),
                              //       ]),
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
                                              onTap: () {
                                                _pickImage(1);
                                              },
                                              child: Card(
                                                elevation: 10,
                                                child: Center(
                                                    child: FutureBuilder<void>(
                                                  future: retriveLostData(
                                                      _imageFile),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<void>
                                                              snapshot) {
                                                    switch (snapshot
                                                        .connectionState) {
                                                      case ConnectionState.none:
                                                      case ConnectionState
                                                          .waiting:
                                                        return const Text(
                                                            'Picked an image');
                                                      case ConnectionState.done:
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
                                                  future: retriveLostData(
                                                      _imageFile1),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<void>
                                                              snapshot) {
                                                    switch (snapshot
                                                        .connectionState) {
                                                      case ConnectionState.none:
                                                      case ConnectionState
                                                          .waiting:
                                                        return const Text(
                                                            'Picked an image');
                                                      case ConnectionState.done:
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
                              // SizedBox(
                              //   height: getProportionateScreenHeight(20),
                              // ),
                              // _submitButton(),
                              // SizedBox(
                              //   height: getProportionateScreenHeight(40),
                              // ),
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
    );
  }
}
