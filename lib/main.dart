import 'package:honeytrackapp/screens/splash/splashscreen.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/routes.dart';
import 'package:honeytrackapp/services/theme.dart';
//import 'package:honeytrackapp/screens/splash/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HoneyTrackApp',
        theme: theme(),
        home: SplashScreen(),
        // We use routeName so that we dont need to remember the name
        initialRoute: SplashScreen.routeName,
        routes: routes,
      );
    });
  }
}
