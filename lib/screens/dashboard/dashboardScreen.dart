import 'dart:async';
import 'dart:convert';
import 'package:honeytrackapp/providers/apiary_jobs_inserts.dart';
import 'package:honeytrackapp/providers/jobApiProviders.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/screens/dashboard/appBarItem.dart';
import 'package:honeytrackapp/screens/dashboard/dashboarduicomponents.dart';
import 'package:honeytrackapp/screens/dashboard/drawer.dart';
import 'package:honeytrackapp/screens/dashboard/image_slider.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:honeytrackapp/services/usermodel.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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
  // Map<dynamic, dynamic> dataMap1 = {};
  bool isLoading = false;
  bool isLoadingCharts = false;
  String email = "";
  String roles = "";
  String lname = "";
  String fname = "";
  String checkpointName = "";
  int sum = 0;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
      // dataMap1 = stats[0];
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

  Future getJobs() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var userId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('user_id'));
      print(userId.toString() + "vdsghfcdvsygvc gdysvcgdvcgsd ysvc ds ");
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url;
      url = Uri.parse('$baseUrl/api/v1/get-tasks');
      final response = await http.get(url, headers: headers);
      int len = 0;
      var res;
      var tasks;
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            tasks = res["data"];
            len = res["data"].length;
          });
          for (var i = 0; i < len; i++) {
            if (tasks[i] == null) {
              print("Null Task");
            } else {
              print(tasks[i]["activities"].toString());
              List apiaries = [];
              List hiveNo = [];
              List apiariesId = [];
              String? taskActivityId;
              print("*********************************");
              print(tasks[i]);
              print("*********************************");
              for (var j = 0; j < tasks[i]["activities"].length; j++) {
                String? ap;
                String? ids;
                String? nohive;
                // int sum = 0;
                print("Task two");
                tasks[i]["activities"][j]["apiary"] != null
                    ? ap = tasks[i]["activities"][j]["apiary"]["name"]
                    : ap = '';
                tasks[i]["activities"][j]["apiary"] != null
                    ? ids = tasks[i]["activities"][j]["apiary"]["id"].toString()
                    : ids = '';
                nohive = tasks[i]["activities"][j]["hive_number"].toString();
                taskActivityId = tasks[i]["activities"][j]["id"].toString();
                print("Task Three");
                // sum = sum +
                //     int.parse(
                //         tasks[i]["tasks"]["activities"][j]["hive_number"]);
                //print(sum);
                apiaries.add(ap);
                apiariesId.add(ids);
                hiveNo.add(nohive);
              }
              print(taskActivityId);
              // print()
              tasks[i]["activities"].length == 0
                  ? print("ignore")
                  : await storeJobs(
                      userId.toString(),
                      tasks[i]["id"].toString(),
                      tasks[i]["name"],
                      tasks[i]["task_type"]["name"],
                      apiaries.toString(),
                      apiariesId.toString(),
                      hiveNo.toString(),
                      taskActivityId!,
                      tasks[i]["name"]);
            }
          }

          break;

        default:
          setState(() {
            res = json.decode(response.body);
          });

          break;
      }
    } catch (e) {
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> storeJobs(
    String personId,
    String id,
    String jobname,
    String tasktype,
    String activities,
    String ids,
    String hiveno,
    String taskActivityId,
    String role,
  ) async {
    print("ns fjsdfsd");
    print(personId);
    print(id +
        jobname +
        tasktype +
        activities +
        ids +
        hiveno +
        taskActivityId +
        role);
    await JobsApiProvider.storeJob(
      personId,
      id,
      activities,
      jobname,
      tasktype,
      ids,
      hiveno,
      taskActivityId,
      role,
    );
  }

  Future<void> checkNetwork() async {
    print(_connectionStatus);

    if (_connectionStatus == ConnectivityResult.mobile) {
      await getJobs();
    } else if (_connectionStatus == ConnectivityResult.wifi) {
      await getJobs();
    } else {
      //getJobsOffline();
    }
  }

  @override
  void initState() {
    this.data1();
    // getInvJobs();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    Future.delayed(const Duration(seconds: 1)).then((value) => checkNetwork());
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      //developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      print(_connectionStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //final User arguments = ModalRoute.of(context).settings.arguments;
    var args = ModalRoute.of(context)!.settings.arguments as User;

    //print(args);
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
                color: Colors.black, fontFamily: 'Ubuntu', fontSize: 13.sp),
          ),
          backgroundColor: kPrimaryColor,
          actions: [
            AppBarActionItems(
              roles: [],
              username: args.fname + " " + args.lname,
              station: args.stationName.toString(),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: AnimationLimiter(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: getProportionateScreenHeight(120),
                child: Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(70),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 10,
                            child: Container(
                              height: getProportionateScreenHeight(90),
                              child: ListTile(
                                tileColor: Colors.white,
                                leading: const CircleAvatar(
                                  foregroundColor: Colors.green,
                                  backgroundColor: Colors.black12,
                                  child: Icon(Icons.verified_user_rounded),
                                ),
                                title: Text(
                                  'Logged In As: ${args.fname} ${args.lname}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Station Name: ${args.stationName}',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              ImageSlider(),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: DashboardUiComponents(
                    role: roles,
                    apiaries: apiari,
                    dealers: dealer,
                    id: args.id,
                  )),
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
