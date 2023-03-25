import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:honeytrackapp/screens/apiaries/inspection.dart';
import 'package:honeytrackapp/screens/apiaries/inspectionList.dart';

import 'package:honeytrackapp/services/constants.dart';

import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/screenArguments.dart';

class InspectionMainScreen extends StatefulWidget {
  static String routeName = "/maininspection";
  @override
  _InspectionMainScreenState createState() => _InspectionMainScreenState();
}

class _InspectionMainScreenState extends State<InspectionMainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Apiaries Inspection',
         // style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Inspection(
              jobId: args.jobId,
              userId: args.personId,
              jobname: args.jobName,
              apiaries: args.apiariesNames,
              apiaryId: args.apiariesId,
              apiaryNum: args.apiaryNum,
              hiveattend: args.hiveattended,
              taskId: args.taskId!,
            ),
            InspectionList(
              jobId: args.jobId,
              userId: args.personId,
              apiaries: args.apiariesNames,
              hiveattend: args.hiveattended,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        showElevation: true,
        containerHeight: 50,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text(
                'Inspection',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.pink,
              )),
          BottomNavyBarItem(
              title: Text(
                'List',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.list,
                color: Colors.purple,
              )),
        ],
      ),
    );
  }
}
