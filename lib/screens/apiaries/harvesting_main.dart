import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:honeytrackapp/screens/apiaries/harvestingjobs.dart';
import 'package:honeytrackapp/screens/apiaries/harvestinglist.dart';

import 'package:honeytrackapp/services/constants.dart';

import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/screenArguments.dart';

class HarvestingMainScreen extends StatefulWidget {
  static String routeName = "/mainHarvesting";
  @override
  _HarvestingMainScreenState createState() => _HarvestingMainScreenState();
}

class _HarvestingMainScreenState extends State<HarvestingMainScreen> {
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
          'Apiaries Harvesting',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            HarvestingJob(
              jobId: args.jobId,
              userId: args.personId,
              jobname: args.jobName,
              apiriesName: args.apiariesNames,
              apiriesId: args.apiariesId,
              apiaryNum: args.apiaryNum,
              taskId: args.taskId!,
            ),
            HarvestingList(
              jobId: args.jobId,
              userId: args.personId,
              jobname: args.jobName,
              apiariesName: args.apiariesNames,
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
                'Register',
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
