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
      height: getProportionateScreenHeight(50),
      width: getProportionateScreenWidth(152),
      decoration: BoxDecoration(
          //  color: Color(0xFF0C9869),
          boxShadow: [
            BoxShadow(
                blurRadius: 2, color: Color(0xfff3f3f4), offset: Offset.zero),
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan)),
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

    // data1 = stats.toList();
    print(widget.dealers.toString() + "reerh");
    int? num1 = await DBProvider.db.countTasks(widget.id);
    setState(() {
      numbers = num1!;
    });
  }

  @override
  void initState() {
    this.getNumber();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as User;
    return Container(
      height: getProportionateScreenHeight(300),
      width: getProportionateScreenWidth(350),
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
          child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 2,
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
                  widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                      ? Container()
                      : InkWell(
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
              )),
        ),
      ),
    );
  }
}
