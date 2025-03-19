import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TryAgainButton extends StatelessWidget {
  final int userScore;
  const TryAgainButton({
    super.key,
    required this.userScore,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
          backgroundColor: AppColors.button_000,
          minimumSize: Size(double.maxFinite, 48.0.h),
          padding: EdgeInsets.symmetric(vertical: 13.0.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.r),
          )),
      child: Text(
        userScore == 100 ? 'Complete' : 'Try again',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
