// import 'package:fremisAppV2/screens/RejectedTp/rejectedTpScreen.dart';
// import 'package:fremisAppV2/screens/statistics/statisticsScreen.dart';
// import 'package:fremisAppV2/screens/verifiedTpScreen/verifiedTpScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:honeytrackapp/screens/apiaries/apiariesscreen.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:fremisAppV2/screens/verification/verificationScreen.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

class DashboardUiComponents extends StatefulWidget {
  final String role;
  DashboardUiComponents({required this.role});
  @override
  _DashboardUiComponentsState createState() => _DashboardUiComponentsState();
}

class _DashboardUiComponentsState extends State<DashboardUiComponents> {
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
          icon,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.role == 'FSUHQ' || widget.role == 'FSUZone'
          ? getProportionateScreenHeight(200)
          : getProportionateScreenHeight(300),
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
                      Navigator.pushNamed(
                        context,
                        ApiariesScreen.routeName,
                      );
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
                      // widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                      //     ? null
                      //     : Navigator.pushNamed(
                      //         context,
                      //         VerifiedTpScreen.routeName,
                      //       );
                    },
                    child: gridTile(
                      widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                          ? 'Beekepers'
                          : 'Beekepers',
                      SvgPicture.asset(
                        "assets/icons/beekeeper.svg",
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
                            'Dealers',
                            SvgPicture.asset(
                              "assets/icons/authorized-dealers.svg",
                              height: 6.h,
                              width: 6.w,
                            ),
                          ),
                        ),
                  widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                      ? Container()
                      : InkWell(
                          onTap: () {
                            // Navigator.pushNamed(
                            //   context,
                            //   StatisticsScreen.routeName,
                            // );
                          },
                          child: gridTile(
                            'Statistics',
                            SvgPicture.asset(
                              "assets/icons/statistics.svg",
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
