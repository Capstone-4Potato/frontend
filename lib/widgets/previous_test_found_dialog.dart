import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/new/models/colors.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviousTestDialog extends StatelessWidget {
  PreviousTestDialog({
    super.key,
    required this.leftTap,
    required this.rightTap,
  });

  VoidCallback leftTap;
  VoidCallback rightTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 26.w,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 381.w,
        height: 230.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Test Found',
              style: TextStyle(
                fontSize: 24.h,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              'There is a previous test in progress. Would you like to continue or start over?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 150, 150, 150),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: leftTap,
                  child: Container(
                    width: 148.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 206, 201, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('CONTINUE')),
                  ),
                ),
                GestureDetector(
                  onTap: rightTap,
                  child: Container(
                    width: 148.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                        child: Text(
                      'NEW START',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
