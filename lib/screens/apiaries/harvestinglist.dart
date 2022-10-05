import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

class HarvestingList extends StatefulWidget {
  //HarvestingList({Key? key}) : super(key: key);
  final String jobId;
  final String userId;
  final String jobname;
  final List apiariesName;
  HarvestingList(
      {required this.jobId,
      required this.userId,
      required this.jobname,
      required this.apiariesName});

  @override
  _HarvestingListState createState() => _HarvestingListState();
}

class _HarvestingListState extends State<HarvestingList> {
  var list;
  List product = [];
  bool isLoading = false;
  // String _imageFile = "";
  // String _imageFile1 = "";
  // final ImagePicker _picker = ImagePicker();
  getListOfApirieas() async {
    setState(() {
      isLoading = true;
    });
    var x = await DBProvider.db.getHarvesting(widget.jobId, widget.userId);
    print(x);
    setState(() {
      list = x;
    
      isLoading = false;
    });
  }

  // Future<void> retriveLostData(var _imageFile) async {
  //   final LostData response = await _picker.getLostData();
  //   if (response.isEmpty) {
  //     return;
  //   }
  //   if (response.file != null) {
  //     setState(() {
  //       _imageFile = response.file!;
  //     });
  //   } else {
  //     print('Retrieve error ' + response.exception!.code);
  //   }
  // }

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
                            height: getProportionateScreenHeight(650),
                            color: Colors.white,
                            child: AnimationLimiter(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: list!.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                                list![index]["upload_status"] ==
                                                        '0'
                                                    ? Icons.pending_actions
                                                    : Icons.verified,
                                                color: list![index]
                                                            ["upload_status"] ==
                                                        '0'
                                                    ? Colors.orange
                                                    : Colors.green,
                                              ),
                                              leading: CircleAvatar(
                                                  child: Text('${index + 1}')),
                                              title: Text("Apiary Name: " +
                                                  list![index]["apiary_name"]
                                                      .toString()),
                                              subtitle: Text('Hive-Code: ' +
                                                  list![index]["hive_code"]
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
                  title: new Text('Harvesting Details'),
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
                  title: new Text(
                      'Hive-Code: ' + list![index]["hive_code"].toString()),
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
                  title: new Text(
                      'Apiary Name: ' + list![index]["apiary_name"].toString()),
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
                  title: new Text('Moisture Content:  ' +
                      list![index]["moisture_content"].toString()),
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
                  title: new Text('Equipment Used: ' +
                      list![index]["equipment_used"].toString()),
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
                  title: new Text('Other Bee Product: ' +
                      list![index]["other_bee_product"].toString()),
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
                  title: new Text('Transportation Means: ' +
                      list![index]["transportation_means"].toString()),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),

                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Transportation Time: ' +
                      list![index]["transportation_time"].toString()),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.pushNamed(
                    //   context,
                    //   InspectionJobs.routeName,
                    // );
                  },
                ),

                ListTile(
                  leading: new Icon(
                    Icons.arrow_right,
                    color: Colors.green,
                  ),
                  title: new Text('Harvesting Cost: ' +
                      list![index]["harvesting_cost"].toString()),
                  onTap: () {
                    // Navigator.pop(context);
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
                // ListTile(
                //   leading: new Icon(
                //     Icons.arrow_right,
                //     color: Colors.green,
                //   ),
                //   title: new Text('Transportation Time: ' +
                //       list![index]["transportation_time"].toString()),
                //   onTap: () {
                //     // Navigator.pop(context);
                //     // Navigator.pushNamed(
                //     //   context,
                //     //   InspectionJobs.routeName,
                //     // );
                //   },
                // ),
              ],
            ),
          );
        });
  }
}
