import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExitDialog extends StatelessWidget {
  ExitDialog({
    super.key,
    required this.width,
    required this.height,
    required this.page,
  });

  final double width;
  final double height;
  Widget page;

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
        height: 179.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'End Learning',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Text(
              'Do you want to end learning?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 150, 150, 150),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 148.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 206, 201, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('Continue')),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => page),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 148.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                        child: Text(
                      'End',
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
