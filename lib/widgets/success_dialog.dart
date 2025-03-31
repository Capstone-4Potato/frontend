import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessDialog extends StatelessWidget {
  SuccessDialog({
    super.key,
    this.title = 'Success!',
    required this.subtitle,
    this.buttonText = "Continue",
    required this.onTap,
  });

  String title;
  String subtitle;
  String buttonText;
  VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white_000,
      alignment: Alignment.center,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 26.w,
      ),
      child: Container(
        padding: EdgeInsets.all(24.h),
        width: 333.w,
        height: 230.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 24.0.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24.h,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10.0.h),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.h,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 150, 150, 150),
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 148.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                    child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16.h),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
