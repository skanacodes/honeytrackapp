import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

class InspectionList extends StatefulWidget {
  final String jobId;
  final String userId;
  final List apiaries;
  InspectionList(
      {required this.jobId, required this.userId, required this.apiaries});
  //InspectionList({Key? key}) : super(key: key);

  @override
  _InspectionListState createState() => _InspectionListState();
}

class _InspectionListState extends State<InspectionList> {
  var list;
  bool isLoading = false;
  getListOfApirieas() async {
    setState(() {
      isLoading = true;
    });
    var x = await DBProvider.db.getsta(widget.jobId, widget.userId);
    print(x);
    setState(() {
      list = x;
      isLoading = false;
    });
  }

  Widget _previewImage(var _imageFile) {
    // ignore: unnecessary_null_comparison
    if (_imageFile != null) {
      return Container(
        // height: 100,
        // width: 100,
        child: Image.file(File(_imageFile)),

        // RaisedButton(
        //   onPressed: () async {
        //     var res = await uploadImage(_imageFile.path, uploadUrl);
        //     print(res);
        //   },
        //   child: const Text('Upload'),
        // )
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  void initState() {
    this.getListOfApirieas();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: list == []
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: ListTile(
                        title: Text("No Data Found"),
                        leading: CircleAvatar(child: Icon(Icons.list))),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: isLoading
                        ? SpinKitCircle(
                            color: kPrimaryColor,
                          )
                        : Container(
                            color: Colors.white,
                            child: AnimationLimiter(
                              child: Container(
                                height: getProportionateScreenHeight(650),
                                child: ListView.builder(
                                  itemCount: list!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return AnimationConfiguration.staggeredList(
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
                                                  showModal(index);
                                                },
                                                trailing: Icon(
                                                  list![index][
                                                              "upload_status"] ==
                                                          '0'
                                                      ? Icons.pending_actions
                                                      : Icons.verified,
                                                  color: list![index][
                                                              "upload_status"] ==
                                                          '0'
                                                      ? Colors.orange
                                                      : Colors.green,
                                                ),
                                                leading: CircleAvatar(
                                                    child:
                                                        Text('${index + 1}')),
                                                title: Text("Apiary Name: " +
                                                    list![index]["apiary_name"]
                                                        .toString()),
                                                subtitle: Text(
                                                    'Colonization-Date: ' +
                                                        list![index][
                                                                "colonization_date"]
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
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(100),
                )
              ],
            ),
    );
  }

  showModal(int index) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: new Icon(
                    Icons.select_all_outlined,
                    color: Colors.green,
                  ),
                  title: new Text('Inspection Details'),
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text(list![index]["upload_status"] == '0'
                      ? "Upload Status: Pending"
                      : "Upload Status: Uploaded"),
                  onTap: () {
                    // Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title:
                      new Text('Apiary Name: ' + list![index]["apiary_name"]),
                  onTap: () {},
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Hive-Code: ' + list![index]["hivecode"]),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Inspection-Seasons: ' +
                      list![index]["inspection_season"]),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('General-Condition: ' +
                      list![index]["general_condition"]),
                  onTap: () {
                    //   Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Colonization-Date:  ' +
                      list![index]["colonization_date"]),
                  onTap: () {
                    //  Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Expected-Observations: ' +
                      list![index]["expected_observation"]),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text(
                      'Actions-Taken: ' + list![index]["action_taken"]),
                  onTap: () {
                    //   Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text(
                      'Blooming-Species: ' + list![index]["blooming_species"]),
                  onTap: () {
                    //Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text(list![index]["expectedForHarvest"] == '1'
                      ? "Expected For Harvest: true"
                      : "Expected For Harvest: false"),
                  onTap: () {
                    // Navigator.pop(context);
                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text(
                      'Expected-Harvest: ' + list![index]["expected_harvest"]),
                  onTap: () {
                    //Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),
                Container(
                  width: double.infinity,
                  height: getProportionateScreenHeight(60),
                  child: Card(
                    elevation: 10,
                    child: Center(
                      child: Text("Images Taken At The Site"),
                    ),
                  ),
                ),
                Container(
                  height: getProportionateScreenHeight(200),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            //  _pickImage(1);
                          },
                          child: Card(
                            elevation: 10,
                            child: Center(
                                child: _previewImage(
                                    list![index]["img1"].toString())),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            //  _pickImage(2);
                          },
                          child: Card(
                            elevation: 10,
                            child: Center(
                                child: _previewImage(
                                    list![index]["img2"].toString())),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
