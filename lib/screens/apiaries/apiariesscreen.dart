import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';
import 'package:honeytrackapp/services/constants.dart';

class ApiariesScreen extends StatefulWidget {
  static String routeName = "/apiaries";
  // ApiariesScreen({required Key key}) : super(key: key);

  @override
  _ApiariesScreenState createState() => _ApiariesScreenState();
}

class _ApiariesScreenState extends State<ApiariesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apiaries',
          style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 25.h,
            // color: kPrimaryColor,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 9.h,
                  color: kPrimaryColor,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      color: Colors.white,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 2,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1075),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: Colors.grey,
                                    child: Container(
                                      child: ListTile(
                                        trailing: Icon(
                                          Icons.arrow_right,
                                          color: Colors.cyan,
                                        ),
                                        leading: CircleAvatar(
                                            child: Icon(Icons.list)),
                                        title: Text(index == 0
                                            ? "Inspections"
                                            : "Vegetation"),
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
