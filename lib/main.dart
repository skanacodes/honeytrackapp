import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:honeytrackapp/screens/splash/splashscreen.dart';

import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/routes.dart';
import 'package:honeytrackapp/services/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
//import 'package:honeytrackapp/screens/splash/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  // start/restart timer
  void _initializeTimer() {
    // print("jdsjdsj djds");
    if (_timer != null) {
      _timer!.cancel();
    }
    // setup action after 5 minutes
    _timer = Timer(const Duration(minutes: 1), () => _handleInactivity());
  }

  void _handleInactivity() {
    _timer?.cancel();
    _timer = null;

    // ignore: todo
    // TODO: type your desired code here
    // Navigator.of(context)
    //  alert();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    _initializeTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HoneyTrackApp',
        theme: theme(),
        home: GestureDetector(
            onTap: () => _initializeTimer(),
            onPanDown: (_) => _initializeTimer(),
            onPanUpdate: (_) => _initializeTimer(),
            behavior: HitTestBehavior.translucent,
            child: SplashScreen()),

        // We use routeName so that we dont need to remember the name
        // initialRoute: SplashScreen.routeName,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale('en', 'US'),
        supportedLocales: [
          const Locale('en', 'US'), // English
          //const Locale('th', 'TH'), // Thai
        ],
        routes: routes,
      );
    });
  }
}
