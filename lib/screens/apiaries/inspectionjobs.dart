import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/screens/apiaries/InspectionMainScreen.dart';
import 'package:honeytrackapp/screens/apiaries/harvesting_main.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/screenArguments.dart';
import 'package:honeytrackapp/services/size_config.dart';

class InspectionJobs extends StatefulWidget {
  final String id;
  //final String taskName;
  InspectionJobs({required this.id});
  @override
  _InspectionJobsState createState() => _InspectionJobsState();
}

class _InspectionJobsState extends State<InspectionJobs> {
  List? jobs = [];
  List? listApiary;
  bool isLoading = false;
  Future getAllJobs(String id) async {
    setState(() {
      isLoading = true;
    });
    print(id);
    var res = await DBProvider.db.getJobs(id);
    print(res);
    setState(() {
      jobs = res;
      isLoading = false;
    });
    print(res);
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    this.getAllJobs(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: isLoading
                ? SpinKitCircle(
                    color: kPrimaryColor,
                  )
                : jobs!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            // height: getProportionateScreenHeight(60),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Icon(Icons.donut_large_outlined),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.hourglass_empty_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                title: Text(
                                  "No Tasks Found",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                // subtitle: Text(""),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: getProportionateScreenHeight(600),
                        color: Colors.white,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            //shrinkWrap: true,
                            itemCount: jobs!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      elevation: 10,
                                      shadowColor: Colors.grey,
                                      child: Container(
                                        child: ListTile(
                                          onTap: () {
                                            print(jobs![index]["hiveNo"]);
                                            jobs![index]["tasktype"]
                                                        .toString() ==
                                                    "Inspection"
                                                ? Navigator.pushNamed(
                                                    context,
                                                    InspectionMainScreen
                                                        .routeName,
                                                    arguments: ScreenArguments(
                                                        widget.id,
                                                        jobs![index]["job_id"]
                                                            .toString(),
                                                        jobs![index]["jobname"]
                                                            .toString(),
                                                        jobs![index]["activity"]
                                                            .split("[]"),
                                                        jobs![index]
                                                                ["apiary_id"]
                                                            .split(
                                                          "[]",
                                                        ),
                                                        jobs![index]["hiveNo"]
                                                            .split(
                                                          "[]",
                                                        ),
                                                        jobs![index][
                                                                "hive_attended"]
                                                            .toString(),
                                                        taskId: jobs![index][
                                                                "task_activity_id"]
                                                            .toString()),
                                                  )
                                                : Navigator.pushNamed(
                                                    context,
                                                    HarvestingMainScreen
                                                        .routeName,
                                                    arguments: ScreenArguments(
                                                        widget.id,
                                                        jobs![index]["job_id"]
                                                            .toString(),
                                                        jobs![index]["jobname"]
                                                            .toString(),
                                                        jobs![index]["activity"]
                                                            .split("[]"),
                                                        jobs![index]
                                                                ["apiary_id"]
                                                            .split("[]"),
                                                        jobs![index]["hiveNo"]
                                                            .split(
                                                          "[]",
                                                        ),
                                                        jobs![index][
                                                                "hive_attended"]
                                                            .toString(),
                                                        taskId: jobs![index][
                                                                "task_activity_id"]
                                                            .toString()));
                                          },
                                          trailing: Icon(
                                            Icons.arrow_right,
                                            color: Colors.cyan,
                                          ),
                                          leading: CircleAvatar(
                                              child: Text('${index + 1}')),
                                          title: Text("Task Name: " +
                                              jobs![index]["jobname"]
                                                  .toString()),
                                          subtitle: Text('Task-Type: ' +
                                              jobs![index]["tasktype"]
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
    );
  }
}
