// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:honeytrackapp/services/size_config.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final List<String> imgList = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpeg',
    'assets/images/image3.jpeg',
    'assets/images/image4.jpeg',
    'assets/images/image5.jpeg',
    'assets/images/image6.jpeg',
  ];
  late final List<Widget> imageSliders;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SizedBox(
          // height: 300,
          width: double.infinity,
          child: Builder(builder: (context) {
            return CarouselSlider(
                options: CarouselOptions(
                    height: getProportionateScreenHeight(200),
                    viewportFraction: 1.0,
                    // enlargeCenterPage: false,

                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }
                    // autoPlay: false,
                    ),
                items: imgList
                    .map((item) => SizedBox(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                child: Stack(
                                  children: <Widget>[
                                    Image.asset(item,
                                        fit: BoxFit.cover, width: 1000.0),
                                    Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromARGB(200, 0, 0, 0),
                                              Color.fromARGB(0, 0, 0, 0)
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child: Text(
                                          'Reseach Suggest That  bees are critical to our environment,climate change and even the production of coffee',
                                          style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: imgList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          return GestureDetector(
                                            onTap: () => _controller
                                                .animateToPage(entry.key),
                                            child: Container(
                                              width: 5,
                                              height: 6,
                                              // ignore: prefer_const_constructors
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 4.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: (Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.white
                                                          : kPrimaryColor)
                                                      .withOpacity(
                                                          _current == entry.key
                                                              ? 0.9
                                                              : 0.4)),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ))
                    .toList());
          }),
        ),
      )
    ]);
  }
}
