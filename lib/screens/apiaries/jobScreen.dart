import 'package:flutter/material.dart';
import 'package:honeytrackapp/screens/apiaries/inspectionjobs.dart';
import 'package:honeytrackapp/services/constants.dart';

class JobScreen extends StatelessWidget {
  static String routeName = "/inspectionsjobs";
  const JobScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String args = ModalRoute.of(context)!.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          "Task/Jobs",
          //style: TextStyle(fontFamily: 'Ubuntu', color: Colors.black),
        ),
      ),
      body: InspectionJobs(
        id: args,
      ),
    );
  }
}
