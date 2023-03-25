import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class UploadData extends StatefulWidget {
  static String routeName = "/dataUpload";
  UploadData({Key? key}) : super(key: key);

  @override
  _UploadDataState createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  int percentage = 0;
  int percentageTree = 0;
  bool isSavedPlot = false;
  bool isSavedTree = false;

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  postDataPlot() async {
    var dio = Dio();
    var res = await DBProvider.db.getInspectionForSyncDetails();
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));

    if (res.isEmpty) {
      message("error", "All Inspection Data Syncronized");
    } else {
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var response = await dio.post('$baseUrl/api/v1/apiary-inspection',
          data: json.encode(res), options: Options(headers: headers),
          onSendProgress: (received, total) {
        setState(() {
          percentage = ((received / total) * 100).floor();
        });
      });
      print(response.data);

      print(response.data["success"]);
      if (response.data["success"]) {
        DBProvider.db.updateInspectionList(res);
        setState(() {
          isSavedPlot = true;
        });
      } else {
        message("error", response.data.toString());
      }
    }
  }

  postDataTree() async {
    var dio = Dio();
    var res = await DBProvider.db.getHarvestingForSyncDetails();
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));

    if (res.isEmpty) {
      message("error", "All Harvesting Data Syncronized");
    } else {
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var response = await dio.post('$baseUrl/api/v1/apiary-harvest',
          data: json.encode(res), options: Options(headers: headers),
          onSendProgress: (received, total) {
        setState(() {
          // print(received);
          // print(total);
          percentageTree = ((received / total) * 100).floor();
        });
      });
      print(response.data);

      if (response.data["success"]) {
        await DBProvider.db.updateHarvestList(res);
        setState(() {
          isSavedTree = true;
        });
      } else {
        message("error", response.data.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sync Data")),
      body: Column(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: getProportionateScreenHeight(60),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ]),
              child: InkWell(
                onTap: () async {
                  await postDataPlot();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: getProportionateScreenHeight(60),
                      width: getProportionateScreenWidth(10),
                      color: kPrimaryColor,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sync Inspection Data ',
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.sync_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircularStepProgressIndicator(
                  totalSteps: 100,
                  currentStep: percentage,
                  width: 100,
                  roundedCap: (_, isSelected) => isSelected,
                ),
                Text(
                  "Percentage: $percentage%",
                  style: const TextStyle(color: Colors.black),
                ),
                isSavedPlot
                    ? Icon(
                        Icons.verified,
                        color: kPrimaryColor,
                        size: 20.sp,
                      )
                    : Icon(
                        Icons.pending_actions,
                        color: Colors.red,
                        size: 20.sp,
                      )
              ],
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: getProportionateScreenHeight(60),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ]),
              child: InkWell(
                onTap: (() async {
                  await postDataTree();
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: getProportionateScreenHeight(60),
                      width: getProportionateScreenWidth(10),
                      color: kPrimaryColor,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sync Harvesting Data ',
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.sync_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircularStepProgressIndicator(
                  totalSteps: 100,
                  currentStep: percentageTree,
                  width: 100,
                  roundedCap: (_, isSelected) => isSelected,
                ),
                Text(
                  "Percentage: $percentageTree%",
                  style: const TextStyle(color: Colors.black),
                ),
                isSavedTree
                    ? Icon(
                        Icons.verified,
                        color: kPrimaryColor,
                        size: 20.sp,
                      )
                    : Icon(
                        Icons.pending_actions,
                        color: Colors.red,
                        size: 20.sp,
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
