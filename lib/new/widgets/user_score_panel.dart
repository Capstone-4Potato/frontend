import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 피드백 창에서 사용자 점수 표시 패널
class UserScorePanel extends StatelessWidget {
  const UserScorePanel({
    super.key,
    required this.userScore,
  });

  final int userScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.0.h,
      constraints: const BoxConstraints(
        minWidth: 120.0, // 최소 너비
      ),
      margin: EdgeInsets.only(top: 32.0.h),
      decoration: BoxDecoration(
          color: AppColors.dialogBackground_000,
          borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.only(left: 12.0.w, right: 13.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.0.h),
              child: Text(
                'Score',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.gray_002,
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 13.0.h),
              child: Text.rich(
                // 사용자 점수 표시
                TextSpan(
                  text: '$userScore',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontFamily: FontFamily.pretendard.fontName,
                    fontWeight: FontWeight.bold,
                    height: 0.708,
                    color: AppColors.orange_000,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '/100',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
