import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExitDialog extends StatelessWidget {
  ExitDialog({
    super.key,
    required this.page,
  });

  Widget page;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 26.w,
      ),
      backgroundColor: AppColors.white_000,
      child: Container(
        padding: EdgeInsets.all(16.h),
        width: 381.w,
        height: 179.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'End Learning',
              style: TextStyle(
                fontSize: 32.h,
                fontWeight: FontWeight.w500,
                color: AppColors.orange_000,
              ),
            ),
            Text(
              'Do you want to end learning?',
              style: TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.w400,
                color: AppColors.gray_003,
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
                      color: AppColors.gray_000,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                        child: Text(
                      'Continue',
                      style: TextStyle(
                        color: AppColors.gray_003,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
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
                    child: Center(
                        child: Text(
                      'End',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w500,
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
