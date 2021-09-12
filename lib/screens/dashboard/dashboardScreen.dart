import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/screens/dashboard/dashboarduicomponents.dart';
import 'package:honeytrackapp/screens/dashboard/drawer.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:honeytrackapp/services/usermodel.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int totalVerified = 0;
  int totalUnVerified = 0;
  int totalExpired = 0;
  String stationName = "";
  String f = "";
  String l = "";
  String apiari = "0";
  String dealer = "0";
  int totalCreatedTp = 0;
  Map<String, double> dataMap = {};
  Map<dynamic, dynamic> dataMap1 = {};
  bool isLoading = false;
  bool isLoadingCharts = false;
  String email = "";
  String roles = "";
  String lname = "";
  String fname = "";
  String checkpointName = "";
  int sum = 0;
  // CountdownTimer _countDownTimer;
  Future<void> didChangeAppLifeCycleState(AppLifecycleState state) async {
    print("AppLifeCycleState:::: $state");
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
    } else {
      print("SSD");
    }
  }

  Timer? _timer;
  // start/restart timer
  void _initializeTimer() {
    print("jdsjdsj djds");
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
    //     .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    //  alert();
  }

  alert() {
    return Alert(
      onWillPopActive: true,

      context: context,
      title: "RFLUTTER ALERT",
      desc: "Flutter is better with RFlutter Alert.",
      // image: Image.asset("assets/logo.png"),
    ).show();
  }

  Widget list(String title, String subtitle) {
    return Card(
      elevation: 10,
      shadowColor: kPrimaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.file_present,
            color: Colors.black,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }

  Future<void> data1() async {
    setState(() {
      isLoadingCharts = true;
    });
    var stats = await DBProvider.db.getstats();

    setState(() {
      var apiar = stats[0]['apiaries'];
      var beekeper = stats[0]['beekeepers'];
      var dealers = stats[0]['dealers'];
      dealer = beekeper.toString();
      apiari = stats[0]['apiaries'].toString();
      var transitpass = stats[0]['transitPass'];
      dataMap1 = stats[0];
      // print(dealers.toString() + "fdsgdfv");
      dataMap = {
        "beekepers [$apiar]": double.parse(stats[0]['apiaries'].toString()),
        "apiaries [$beekeper] ":
            double.parse(stats[0]['beekeepers'].toString()),
        "dealers [$dealers]": double.parse(stats[0]['dealers'].toString()),
        "transitPass [$transitpass]":
            double.parse(stats[0]['transitPass'].toString()),
      };
      isLoadingCharts = false;
    });
  }

  @override
  void initState() {
    dataMap = {
      "beekepers ": double.parse('78'),
      "apiaries ": double.parse('90'),
      "dealers": double.parse('97'),
      "transitPass": double.parse('89'),
    };
    // this._initializeTimer();
    // this.data1();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final User arguments = ModalRoute.of(context).settings.arguments;
    var args = ModalRoute.of(context)!.settings.arguments as User;

    print(args);
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text(
            'HoneyTrackApp Dashboard',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
          backgroundColor: kPrimaryColor,
          actions: [popBar()],
        ),
        body: SingleChildScrollView(
          child: AnimationLimiter(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: getProportionateScreenHeight(400),
                child: Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(200),
                      width: double.infinity,
                      color: kPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                        child: isLoadingCharts
                            ? SpinKitCircle(
                                color: kPrimaryColor,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Logged In As: ${args.fname} ${args.lname}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  Text(
                                    'Station Name: ${args.stationName}',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                        fontSize: 15),
                                  ),
                                  // Text(
                                  //   'Station Name: $checkpointName',
                                  //   style: TextStyle(
                                  //       color: Colors.black,
                                  //       fontSize: 15,
                                  //       fontStyle: FontStyle.italic),
                                  // ),
                                  // Container(
                                  //   height: getProportionateScreenHeight(100),
                                  //   width: getProportionateScreenWidth(350),
                                  //   child: Card(
                                  //     elevation: 10,
                                  //     child: Text("Honey Jobs"),
                                  //   ),
                                  // )
                                ],
                              ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: DashboardUiComponents(
                          role: roles,
                          apiaries: apiari,
                          dealers: dealer,
                          id: args.id,
                        ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  //  height: getProportionateScreenHeight(400),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10,
                      // shadowColor: kPrimaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 0),
                            child: Text(
                              'Summary Of The Honey TraceAbility Operations',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Center(
                              child: Text(
                                '',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          isLoadingCharts
                              ? SpinKitCircle(
                                  color: kPrimaryColor,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 8, right: 8, top: 2),
                                  child: Card(
                                    elevation: 10,
                                    child: PieChart(
                                      dataMap: dataMap,
                                      // emptyColor: Colors.amber,
                                      animationDuration:
                                          Duration(milliseconds: 1800),
                                      chartLegendSpacing: 32,
                                      chartRadius:
                                          MediaQuery.of(context).size.width /
                                              3.2,
                                      colorList: [
                                        Colors.blue,
                                        kPrimaryColor,
                                        Colors.pink,
                                        Colors.cyan
                                      ],
                                      initialAngleInDegree: 70,
                                      chartType: ChartType.ring,

                                      ringStrokeWidth: 45,
                                      centerText: "stats",
                                      legendOptions: LegendOptions(
                                        showLegendsInRow: false,
                                        legendPosition: LegendPosition.right,
                                        showLegends: true,
                                        legendShape: BoxShape.circle,
                                        legendTextStyle: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),

                                      chartValuesOptions: ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        showChartValuesOutside: true,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  popBar() {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: InkWell(
              onTap: () async {
                await SharedPreferences.getInstance().then((prefs) {
                  prefs.clear();
                });
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 5.0,
                    ),
                    child: Text(
                      'LogOut',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
