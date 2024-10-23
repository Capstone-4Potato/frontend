import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  var _bottomNavIndex = 0; //default index of a first screen

  final iconList = <IconData>[
    Icons.home,
    Icons.info,
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 393;
    double height = MediaQuery.of(context).size.height / 852;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Stack(
        children: [
          Container(
            height: 380 * height,
            color: primary,
          ),
          Container(
            alignment: Alignment.center,
            height: height * 323,
            child: const CircleAvatar(
              radius: 101,
              backgroundColor: Color.fromARGB(255, 242, 235, 227),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 529 / 852,
            minChildSize: 529 / 852,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 245, 245, 245),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  height: MediaQuery.of(context).size.height,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const <IconData>[
          Icons.home,
          Icons.info,
        ],
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.sharpEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        backgroundColor: const Color.fromARGB(255, 242, 235, 227),
      ),
    );
  }
}
