import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'dart:math' as math;
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:dio/dio.dart';

class UploadData extends StatefulWidget {
  static String routeName = "/dataUpload";
  UploadData({Key? key}) : super(key: key);

  @override
  _UploadDataState createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  String uploadMessage = "0%";
  bool isUploading = false;
  int total = 1;
  int actual = 0;
  uploadData() async {
    setState(() {
      isUploading = !isUploading;
    });
    var dio = Dio();
    var response = await dio.post(
        'https://mis.tfs.go.tz/honey-traceability/api/v1/login',
        data: {'email': 'onestpaul8@gmail.com', 'password': '12345678'},
        onSendProgress: (int sent, int total) {
      // setState(() {
      //   uploadMessage = sent.toString();
      // });
      print('$sent $total');
    }, onReceiveProgress: (int actualbite, int totalByte) {
      var percentage = actualbite / totalByte * 100;
      print(percentage);
      setState(() {
        total = totalByte;
        actual = actualbite;
        uploadMessage = 'Uploading.... ${percentage.floor()}%';
      });
    });
    print(response.statusCode);
    print(response.data);
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(
            "Upload Offline Data",
            style: TextStyle(fontFamily: 'Ubuntu', color: Colors.black),
          ),
        ),
        body: Container(
            height: getProportionateScreenHeight(700),
            child: Column(children: <Widget>[
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
                              title: Text(
                                'Please Upload Offline Data',
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: getProportionateScreenHeight(400),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Click Button To Upload Data'),
                              InkWell(
                                onTap: () async {
                                  print('Progress');
                                  await uploadData();
                                },
                                child: Container(
                                  height: getProportionateScreenHeight(40),
                                  width: getProportionateScreenWidth(100),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Upload',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Icon(Icons.upload_file_outlined)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: kPrimaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              CircularStepProgressIndicator(
                                totalSteps: total,
                                currentStep: actual,
                                stepSize: 20,
                                selectedColor: Colors.red,
                                unselectedColor: Colors.purple[400],
                                padding: math.pi / 80,
                                width: 150,
                                height: 150,
                                startingAngle: -math.pi * 2 / 3,
                                arcSize: math.pi * 2 / 3 * 2,
                                gradientColor: LinearGradient(
                                  colors: [Colors.red, Colors.purple[400]!],
                                ),
                              ),
                              CircularStepProgressIndicator(
                                totalSteps: total,
                                currentStep: actual,
                                stepSize: 10,
                                selectedColor: Colors.greenAccent,
                                unselectedColor: Colors.grey[200],
                                padding: 0,
                                width: 150,
                                height: 150,
                                selectedStepSize: 15,
                                roundedCap: (_, __) => true,
                              ),
                            ],
                          ),
                        ),
                        Text(uploadMessage)
                      ],
                    ),
                  ),
                ),
              )
            ])));
  }
}
