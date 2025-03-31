import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/re_test_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// ignore_for_file: use_build_context_synchronously

/// 'NEW START' 눌렀을 때 (새로운 테스트 시작)
void showPreviousTestFoundDialog(BuildContext context) {
  void onNewStartTap() {
    // 테스트 재시작 화면으로 이동
    context.navigateTo(
        screen: RestartTestScreen(
      check: false,
    ));
  }

  /// 'continue' 눌렀을 때 (테스트 이어하기)
  void onContinueTap() {
    // 이전 테스트 계속하기 로직 추가 가능
    // 테스트 재시작 화면으로 이동
    context.navigateTo(
        screen: RestartTestScreen(
      check: true,
    ));
  }

  showDialog(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.24),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        alignment: Alignment.center,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 26.w,
        ),
        child: Container(
          width: 340.0.w,
          height: 300.0.h,
          decoration: BoxDecoration(
              color: AppColors.white_000.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(20.r)),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      top: 50.0.h, bottom: 24.h, right: 24.w, left: 24.w),
                  width: 340.0.w,
                  height: 250.0.h,
                  decoration: BoxDecoration(
                    color: AppColors.white_000,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Previous Test Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.orange_000,
                          fontSize: 24.h,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0.h, bottom: 24.h, right: 18.w, left: 18.w),
                        child: Text(
                          'There is a previous test in progress. Would you like to continue or start over?',
                          style: TextStyle(
                            fontSize: 14.h,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray_003,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              onContinueTap();
                            },
                            child: Container(
                              width: 140.w,
                              height: 43.h,
                              decoration: BoxDecoration(
                                color: AppColors.gray_000,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                  child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                  color: AppColors.gray_003,
                                  fontSize: 14.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              onNewStartTap();
                            },
                            child: Container(
                              width: 140.w,
                              height: 43.h,
                              decoration: BoxDecoration(
                                color: AppColors.orange_000,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                  child: Text(
                                'NEW START',
                                style: TextStyle(
                                  color: AppColors.white_000,
                                  fontSize: 14.h,
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
              ),
              Positioned(
                top: 0,
                right: 50,
                left: 50,
                child: Container(
                  width: 100.h,
                  height: 100.h,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      ImagePath.recoverDialogBalbam.path,
                      width: 100.0.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
