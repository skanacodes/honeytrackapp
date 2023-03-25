import 'dart:async';
import 'package:honeytrackapp/screens/login/login.dart';
import 'package:honeytrackapp/services/constants.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
//import 'package:TaxCollection/screens/login/login.dart';
// import 'package:honeytrackapp/screens/login/login.dart';
// import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    Timer(Duration(seconds: 10), () async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.photos,
        Permission.accessMediaLocation,

        Permission.manageExternalStorage
        //add more permission to request here.
      ].request();

      if (statuses[Permission.location]!.isDenied) {
        //check each permission status after.
        print("Location permission is denied.");
      }

      if (statuses[Permission.camera]!.isDenied) {
        //check each permission status after.
        print("Camera permission is denied.");
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      // SharedPreferences.getInstance().then((prefs) {
      //   print(prefs.get('id').toString());
      //   if (prefs.get('id').toString() != 'null') {
      //     // Navigator.push(context,
      //     //     MaterialPageRoute(builder: (context) => InventoryListScreen()));
      //   } else {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => LoginScreen()));
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0.h,
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: TextLiquidFill(
                text: 'HoneyTrackApp',
                waveColor: Colors.black,
                boxBackgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Port Lligat Slab',
                  fontWeight: FontWeight.bold,
                ),
                boxHeight: 150.0,
              ),
            ),
          ),
          Container(
            height: 25.0.h,
            width: 45.0.w,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 10.0.h,
          ),
          SpinKitSpinningLines(
            color: kPrimaryColor,
            size: 55.0.sp,
          )
        ],
      ),
    );
  }
}
