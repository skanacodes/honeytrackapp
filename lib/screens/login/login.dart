import 'dart:async';
import 'dart:convert';

//import 'package:honeytrackapp/screens/dashboard/dashboardScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/providers/jobApiProviders.dart';
import 'package:honeytrackapp/providers/stasticsApiProviders.dart';

import 'package:honeytrackapp/screens/dashboard/dashboardScreen.dart';
import 'package:honeytrackapp/screens/login/Widget/bezierContainer.dart';
import 'package:honeytrackapp/modals/user_modal.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/form_error.dart';
import 'package:honeytrackapp/services/size_config.dart';
//import 'package:honeytrackapp/services/usermodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honeytrackapp/services/usermodel.dart' as user;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isaUser = false;
  bool isLoading = false;
  String username = "";
  String password = "";
  var data;
  final List<String> errors = [];
  var roles = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
// Future storeJobs(String jobname,String tasktype,String activities,String role) {
//      var y=  JobsApiProvider.store
//    }
  _loadStatsFromApi(String token) async {
    setState(() {
      isLoading = true;
    });

    var apiProvider = StatisticsApiProvider();
    await apiProvider.getstats(token);

    // wait for 2 seconds to simulate loading of data
    //await Future.delayed(const Duration(seconds: 2));

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
    String role,
  ) async {
    await JobsApiProvider.storeJob(
      personId,
      id,
      activities,
      jobname,
      tasktype,
      ids,
      hiveno,
      role,
    );
  }

  Future<void> createUser(
    String token,
    int userId,
    int stationId,
    String fname,
    String lname,
    String email,
    String phoneNumber,
  ) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('user_id', userId);
      prefs.setString('token', token);
      prefs.setInt('station_id', stationId);

      prefs.setString('fname', fname);
      prefs.setString('lname', lname);
      prefs.setString('email', email);
      prefs.setString('phoneNumber', phoneNumber);
    });
  }

  Future<String> storetUserDetailsLocaly(int id, String fname, String lname,
      String email, String password, String stationName) async {
    int? count = await DBProvider.db.checkId(email);
    if (count! > 0) {
      print("User Exists");
    } else {
      List output = [
        {
          'email': email,
          'id': id,
          'firstName': fname,
          'lastName': lname,
          'password': password,
          'stationName': stationName
        }
      ];
      var result = (output as List).map((user) async {
        print('Inserting $user');

        await DBProvider.db.createUser(User.fromJson(user));
      }).toList();
    }

    return 'success';
  }

  Future<String> checkUserStatus(String email, String password) async {
    int? count = await DBProvider.db.checkId(email);
    if (count! > 0) {
      print("The User Exists");
      var x = await DBProvider.db.verifyUser(email, password);
      if (x == 'success') {
        return 'success';
      } else {
        setState(() {
          addError(error: 'Incorrect Password or Username');
        });
        return 'fail';
      }
    } else {
      var y = await getUserDetails();
      if (y == 'success') {
        return 'success';
      } else {
        return 'fail';
      }
    }
  }

  Future<String> getUserDetails() async {
    try {
      var url = Uri.parse('$baseUrl/api/v1/login');
      final response = await http.post(
        url,
        body: {'email': username, 'password': password},
      );
      int len = 0;
      var res;
      var tasks;
      //final sharedP prefs=await
      print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            tasks = res["task"];
            len = res["task"].length;
          });
          for (var i = 0; i < len; i++) {
            if (tasks[i]["tasks"] == null) {
              print("Null Task");
            } else {
              print(tasks[i]["tasks"]["id"].toString());
              List apiaries = [];
              List hiveNo = [];
              List apiariesId = [];

              for (var j = 0; j < tasks[i]["tasks"]["activities"].length; j++) {
                String? ap;
                String? ids;
                String? nohive;

                tasks[i]["tasks"]["activities"][j]["apiary"] != null
                    ? ap = tasks[i]["tasks"]["activities"][j]["apiary"]["name"]
                    : ap = '';
                tasks[i]["tasks"]["activities"][j]["apiary"] != null
                    ? ids = tasks[i]["tasks"]["activities"][j]["apiary"]["id"]
                        .toString()
                    : ids = '';
                tasks[i]["tasks"]["activities"][j]["apiary"] != null
                    ? nohive = tasks[i]["tasks"]["activities"][j]["apiary"]
                            ["size"]
                        .toString()
                    : nohive = '';
                apiaries.add(ap);
                apiariesId.add(ids);
                hiveNo.add(nohive);
              }

              await storeJobs(
                  res['user']['id'].toString(),
                  tasks[i]["tasks"]["id"].toString(),
                  tasks[i]["tasks"]["name"],
                  tasks[i]["tasks"]["task_type"]["name"],
                  apiaries.toString(),
                  apiariesId.toString(),
                  hiveNo.toString(),
                  tasks[i]["roles"]["name"]);
            }
          }
          //print(res['station']['name']);

          var x = await storetUserDetailsLocaly(
              res['user']['id'],
              res['user']['first_name'],
              res['user']['last_name'],
              res['user']['email'],
              password,
              res['station']['name']);
          print("am Here");
          await _loadStatsFromApi(res['token']);
          if (x == "success") {
            await createUser(
              res['token'],
              res['user']['id'],
              res['user']['station_id'],
              res['user']['first_name'],
              res['user']['last_name'],
              res['user']['email'],
              res['user']['phone'],
              //  res['user']['station']['name'],
            );
          }

          return 'success';
          break;
        case 422:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: 'Password Must Be Atleast 6 Characters');
          });
          return 'fail';
          break;

        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: 'Incorrect Password or Username');
          });
          return 'fail';
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: res['Something Went Wrong']);
          });
          return 'fail';
          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        addError(error: 'Server Or Network Connectivity Error');
      });
      return 'fail';
    }
  }

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error!);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  errors.contains('Server Or Network Connectivity Error')
                      ? removeError(
                          error: 'Server Or Network Connectivity Error')
                      : errors.contains('Incorrect Password or Username')
                          ? removeError(error: 'Incorrect Password or Username')
                          : errors.contains(
                                  'Password Must Be Atleast 6 Characters')
                              ? removeError(
                                  error:
                                      'Password Must Be Atleast 6 Characters')
                              : errors.contains(
                                      'Your Not Authourized To Use This App')
                                  ? removeError(
                                      error:
                                          'Your Not Authourized To Use This App')
                                  : removeError(
                                      error:
                                          'Your Not Authourized To Use This App');
                }
                return null;
              },
              validator: (value) => value == ''
                  ? '* This  Field Is Required'
                  : emailValidatorRegExp.hasMatch(value!)
                      ? null
                      : !isPassword
                          ? 'Please Provide Valid Email Address'
                          : null,
              onSaved: (value) {
                setState(() {
                  isPassword ? password = value! : username = value!;
                });
              },
              keyboardType: TextInputType.emailAddress,
              cursorColor: kPrimaryColor,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        print(_connectionStatus.toString());

        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          setState(() {
            isLoading = true;
          });
          if (_connectionStatus.toString() == 'ConnectivityResult.none') {
            String val = await checkUserStatus(username, password);
            if (val == 'success') {
              var y = await DBProvider.db.getUserData(username);
              setState(() {
                data = y;
              });
              //  print(data);
              Navigator.pushNamed(context, DashboardScreen.routeName,
                  arguments: user.User(
                      fname: data[0]["firstName"],
                      lname: data[0]["lastName"],
                      email: data[0]["email"],
                      id: data[0]["id"].toString(),
                      stationName: data[0]["stationName"]));
            }
          } else {
            var res = await getUserDetails();
            if (res == 'success') {
              var y = await DBProvider.db.getUserData(username);
              setState(() {
                data = y;
              });
              //  print(data);
              Navigator.pushNamed(context, DashboardScreen.routeName,
                  arguments: user.User(
                      fname: data[0]["firstName"],
                      lname: data[0]["lastName"],
                      email: data[0]["email"],
                      id: data[0]["id"].toString(),
                      stationName: data[0]["stationName"]));
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      },
      child: isLoading
          ? SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Color(0xFFFED636)])),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 20, color: Colors.green[700]),
              ),
            ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('v.1.0.0'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Tanzania  ',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0XFF105F01),
          ),
          children: [
            TextSpan(
              text: 'Forest  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Services  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Agency  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: '(TFS).',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
          ]),
    );
  }

  Widget _title2() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Honey',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: 'Track',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'App',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username"),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    // Clean up the controller when the widget is removed

    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: getProportionateScreenHeight(100)),
                      _title(),
                      Container(
                        decoration: BoxDecoration(
                            // border: Border.all(
                            //     color: Colors.cyan,
                            //     style: BorderStyle.solid,
                            //     width: 1),
                            ),
                        height: getProportionateScreenHeight(150),
                        width: getProportionateScreenHeight(150),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _title2(),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _emailPasswordWidget(),
                      FormError(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _submitButton(),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _divider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
