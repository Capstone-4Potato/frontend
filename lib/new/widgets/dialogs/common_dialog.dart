import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// Dialog 위젯
class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    this.imagePath = "",
    this.title = "Great Job",
    this.content = "Please try recording again.",
    this.buttonText = "Go ahead",
    this.onPressed,
  });

  final String imagePath;
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 200.0.h),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: AppColors.dialogBackground_000,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 28.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 18.0.h),
                child: SvgPicture.asset(
                  imagePath,
                  height: 110.0.h,
                ),
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(color: AppColors.orange_000),
              ),
              SizedBox(height: 15.0.h),
              Text(content,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.gray_003)),
              SizedBox(height: 16.0.h),
              TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.button_000,
                  padding: EdgeInsets.symmetric(
                      horizontal: 36.0.w, vertical: 15.0.h),
                ),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
