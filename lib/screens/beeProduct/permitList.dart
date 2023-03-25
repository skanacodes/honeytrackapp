import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/screens/beeProduct/exportForm.dart';
import 'package:honeytrackapp/screens/beeProduct/importForm.dart';
import 'package:honeytrackapp/screens/beeProduct/internalMarket.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/screenArguments.dart';
import 'package:honeytrackapp/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PermittList extends StatefulWidget {
  static String routeName = "/permitList";
  PermittList({Key? key}) : super(key: key);

  @override
  _PermittListState createState() => _PermittListState();
}

class _PermittListState extends State<PermittList> {
  String? type;
  List data = [];
  bool isLoading = false;
  final List<DropdownMenuItem<String>> _permitType = [
    DropdownMenuItem(
      child: new Text("Export"),
      value: "Export",
    ),
    DropdownMenuItem(
      child: new Text("Import"),
      value: "Import",
    ),
    DropdownMenuItem(
      child: new Text("Internal Market"),
      value: "Internal Market",
    ),
  ];

  Future getData() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/exp-inspection');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['inspections'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataImport() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/imp-inspection');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['inspections'];
            //  print(data[0]["dealer"].toString() + "hjsdkjdskjdsjk");
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataInternalMarket() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/local-inspection');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['inspections'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    String args = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Bee Product Permit Management',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: getProportionateScreenHeight(700),
              child: Column(
                children: <Widget>[
                  Container(
                    height: getProportionateScreenHeight(140),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(100),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
                            color: kPrimaryColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              elevation: 20,
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                0, 5.5, 0, 0),
                                            labelStyle: TextStyle(),
                                            labelText: 'Select Type Of Permit'),
                                        items: _permitType,
                                        value: type,
                                        validator: (value) => value == null
                                            ? "This Field is Required"
                                            : null,
                                        onChanged: (value) async {
                                          setState(() {
                                            type = value.toString();
                                            isLoading = true;
                                          });
                                          type == 'Export'
                                              ? await getData()
                                              : type == 'Import'
                                                  ? await getDataImport()
                                                  : await getDataInternalMarket();
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Adding the List here
                  isLoading
                      ? SpinKitCircle(
                          color: kPrimaryColor,
                        )
                      : data.isEmpty
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Card(
                                elevation: 10,
                                child: Container(
                                    // height: getProportionateScreenHeight(40),
                                    // width: getProportionateScreenWidth(200),
                                    child: ListTile(
                                  title: Text('Data Not Found'),
                                  leading: CircleAvatar(
                                    child: Icon(Icons.hourglass_empty),
                                  ),
                                )),
                              ),
                            ))
                          : Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                height: getProportionateScreenHeight(520),
                                color: Colors.white,
                                child: AnimationLimiter(
                                  child: ListView.builder(
                                    // shrinkWrap: true,
                                    itemCount: data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 1375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Card(
                                              elevation: 10,
                                              shadowColor: Colors.grey,
                                              child: Container(
                                                child: ListTile(
                                                  onTap: () {
                                                    type == 'Export'
                                                        ? Navigator.pushNamed(
                                                            context, ExportForm.routeName,
                                                            arguments: ScreenArguments(
                                                                args,
                                                                data[index]["id"]
                                                                    .toString(),
                                                                "",
                                                                [],
                                                                [],
                                                                [],
                                                                ''))
                                                        : type == 'Import'
                                                            ? Navigator.pushNamed(context, ImportForm.routeName,
                                                                arguments: ScreenArguments(
                                                                    args,
                                                                    data[index]["id"]
                                                                        .toString(),
                                                                    "",
                                                                    [],
                                                                    [],
                                                                    [],
                                                                    ''))
                                                            : Navigator.pushNamed(
                                                                context, InternalMarketForm.routeName,
                                                                arguments: ScreenArguments(
                                                                    args,
                                                                    data[index]["id"].toString(),
                                                                    "",
                                                                    [],
                                                                    [],
                                                                    [],
                                                                    ''));

                                                    // data![index]["exit_point"]
                                                    //             .toString() ==
                                                    //         "Inspection"
                                                    //     ? Navigator.pushNamed(
                                                    //         context,
                                                    //         InspectionMainScreen
                                                    //             .routeName,
                                                    //         arguments:
                                                    //             ScreenArguments(
                                                    //                 widget.id,
                                                    //                 jobs![index][
                                                    //                         "job_id"]
                                                    //                     .toString()))
                                                    //     : Navigator.pushNamed(
                                                    //         context,
                                                    //         HarvestingMainScreen
                                                    //             .routeName);
                                                  },
                                                  trailing: Icon(
                                                    Icons.arrow_right,
                                                    color: Colors.cyan,
                                                  ),
                                                  leading: CircleAvatar(
                                                      child:
                                                          Text('${index + 1}')),
                                                  title: Text("Dealer Name: " +
                                                      data[index]["dealer_name"]
                                                          .toString()),
                                                  subtitle: Text(type ==
                                                          'Export'
                                                      ? 'Destination: ' +
                                                          data[index][
                                                                  "destination"]
                                                              .toString()
                                                      : type == 'Import'
                                                          ? 'Origin Country:' +
                                                              data[index][
                                                                      "origin_country"]
                                                                  .toString()
                                                          : 'Address:' +
                                                              data[index][
                                                                      "address"]
                                                                  .toString()),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
