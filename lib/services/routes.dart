import 'package:honeytrackapp/screens/apiaries/InspectionMainScreen.dart';
import 'package:honeytrackapp/screens/apiaries/apiariesscreen.dart';
import 'package:honeytrackapp/screens/apiaries/harvesting_main.dart';

import 'package:honeytrackapp/screens/apiaries/inspection.dart';

import 'package:honeytrackapp/screens/apiaries/jobScreen.dart';
import 'package:honeytrackapp/screens/beeProduct/exportForm.dart';
import 'package:honeytrackapp/screens/beeProduct/importForm.dart';
import 'package:honeytrackapp/screens/beeProduct/internalMarket.dart';
import 'package:honeytrackapp/screens/beeProduct/managePermitt.dart';
import 'package:honeytrackapp/screens/beeProduct/permitList.dart';
import 'package:honeytrackapp/screens/beeProduct/permitmanagement.dart';
import 'package:honeytrackapp/screens/dashboard/dashboardScreen.dart';
import 'package:honeytrackapp/screens/dataupload/dataupload.dart';
import 'package:honeytrackapp/screens/login/login.dart';
import 'package:honeytrackapp/screens/splash/splashscreen.dart';
import 'package:flutter/widgets.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  ApiariesScreen.routeName: (context) => ApiariesScreen(),
  JobScreen.routeName: (context) => JobScreen(),
  Inspection.routeName: (context) => Inspection(
        jobId: '',
        userId: '',
        jobname: '',
        apiaries: [],
        apiaryId: [],
        apiaryNum: [],
        hiveattend: '',
        taskId: '',
      ),
  PermitManagement.routeName: (context) => PermitManagement(),
  InspectionMainScreen.routeName: (context) => InspectionMainScreen(),
  HarvestingMainScreen.routeName: (context) => HarvestingMainScreen(),
  //QRViewExample.routeName: (context) => QRViewExample(),
  UploadData.routeName: (context) => UploadData(),
  ManagePermit.routeName: (context) => ManagePermit(),
  PermittList.routeName: (context) => PermittList(),
  ExportForm.routeName: (context) => ExportForm(),
  ImportForm.routeName: (context) => ImportForm(),
  InternalMarketForm.routeName: (context) => InternalMarketForm()
};
