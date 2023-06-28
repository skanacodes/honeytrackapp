import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:honeytrackapp/services/size_config.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen();

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Neumorphic(
              drawSurfaceAboveChild: true,
              style: NeumorphicStyle(
                color: Colors.white,
                shape: NeumorphicShape.convex,
                intensity: 1,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                depth: 8,
                lightSource: LightSource.topLeft,
              ),
              child: Container(
                  height: getProportionateScreenHeight(50),
                  width: getProportionateScreenWidth(double.infinity),
                  child: Center(child: Text("Flutter")))),
        )
      ],
    );
  }
}
