// import 'package:fremisAppV2/screens/RejectedTp/rejectedTpScreen.dart';
// import 'package:fremisAppV2/screens/statistics/statisticsScreen.dart';
// import 'package:fremisAppV2/screens/verifiedTpScreen/verifiedTpScreen.dart';
import 'package:badges/badges.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/providers/db_provider.dart';

import 'package:honeytrackapp/screens/apiaries/jobScreen.dart';

import 'package:honeytrackapp/screens/beeProduct/permitList.dart';
import 'package:honeytrackapp/services/constants.dart';

import 'package:honeytrackapp/services/usermodel.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:fremisAppV2/screens/verification/verificationScreen.dart';
//import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

class DashboardUiComponents extends StatefulWidget {
  final String role;
  final String id;
  final String dealers;
  final String apiaries;
  DashboardUiComponents(
      {required this.role,
      required this.apiaries,
      required this.id,
      required this.dealers});
  @override
  _DashboardUiComponentsState createState() => _DashboardUiComponentsState();
}

class _DashboardUiComponentsState extends State<DashboardUiComponents> {
  int numbers = 0;
  List? data1;
  Widget gridTile(String title, SvgPicture icon) {
    return Container(
      height: getProportionateScreenHeight(120),
      width: getProportionateScreenWidth(152),
      decoration: BoxDecoration(
          color: Colors.grey[100]!,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400]!,
              blurRadius: 1,
              offset: Offset(3, 5), // Shadow position
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26)),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                  badgeColor: kPrimaryLightColor,
                  animationType: BadgeAnimationType.slide,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      title == "Tasks"
                          ? numbers.toString()
                          : title == 'Apiaries'
                              ? widget.apiaries.toString()
                              : title == "Bee Keepers"
                                  ? widget.dealers.toString()
                                  : '0',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: icon,
                ),
              )
            ],
          ),
          //icon,
          Text(
            title,
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          )
        ],
      )),
    );
  }

  getNumber() async {
    // var stats = await DBProvider.db.getstats();
    //print("*****************/////////");
    // data1 = stats.toList();
    //print(widget.dealers.toString() + "reerh");
    int? num1 = await DBProvider.db.countTasks(widget.id);
    setState(() {
      numbers = num1!;
    });
    // print(numbers);
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 8), () {
// Here you can write your code

      getNumber();
    });

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as User;
    return Container(
      //  height: getProportionateScreenHeight(300),
      width: getProportionateScreenWidth(400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.transparent,
        // boxShadow: [
        //   BoxShadow(color: kPrimaryColor, blurRadius: 10, offset: Offset.zero)
        // ],
        // border: Border.all(
        //     color: Colors.black26, style: BorderStyle.solid, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: Column(
              children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              delay: const Duration(milliseconds: 375),
              curve: Curves.easeOutQuad,
              duration: const Duration(milliseconds: 600),
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, JobScreen.routeName,
                          arguments: args.id);
                    },
                    child: gridTile(
                      'Tasks',
                      SvgPicture.asset(
                        "assets/icons/Bill Icon.svg",
                        height: 6.h,
                        width: 6.w,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.pushNamed(
                      //   context,
                      //   ApiariesScreen.routeName,
                      // );
                    },
                    child: gridTile(
                      'Apiaries',
                      SvgPicture.asset(
                        "assets/icons/beehive.svg",
                        height: 6.h,
                        width: 6.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, PermittList.routeName,
                          arguments: args.id);
                    },
                    child: gridTile(
                      'Permit Management',
                      SvgPicture.asset(
                        "assets/icons/kyc.svg",
                        height: 6.h,
                        width: 6.w,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, RejectedTpScreen.routeName,
                      //     arguments: widget.role);
                    },
                    child: gridTile(
                      'Bee Keepers',
                      SvgPicture.asset(
                        "assets/icons/beekeeper.svg",
                        height: 6.h,
                        width: 6.w,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}
