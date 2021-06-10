import 'package:honeytrackapp/screens/apiaries/apiariesscreen.dart';
import 'package:honeytrackapp/screens/dashboard/dashboardScreen.dart';
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
};
