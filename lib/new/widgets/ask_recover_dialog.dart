import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/services/api/join_api.dart';
import 'package:flutter_application_1/signup/signup_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 사용자 계정 복구 묻는 dialog
void askRecoverDialog(BuildContext context, String? socialId) {
  void onRecoverTap() async {
    // 계정 복구 API 요청
    await recoverUserAccount(socialId!);
    await getUserData();
    // 홈으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeNav()),
      (route) => false,
    );
  }

  /// delete 눌렀을 때
  void onDeleteTap() {
    // 계정 삭제 API 요청
    deleteUserAccount(socialId!);
    Navigator.pop(context);
    // 홈으로 이동
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => UserInputForm(
          socialId: socialId,
        ),
      ),
    );
  }

  showDialog(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.24),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        alignment: Alignment.center,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 26,
        ),
        child: Container(
          width: 340.0.w,
          height: 300.0.h,
          decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.01),
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Do you want to restore an account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.orange_000,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0.h, bottom: 24.h, right: 18.w, left: 18.w),
                        child: Text(
                          'If you restore your account, you can use your previous account.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray_002,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              onDeleteTap();
                            },
                            child: Container(
                              width: 140.w,
                              height: 43.h,
                              decoration: BoxDecoration(
                                color: AppColors.gray_000,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: const Center(
                                  child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppColors.gray_002,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              onRecoverTap();
                            },
                            child: Container(
                              width: 140.w,
                              height: 43.h,
                              decoration: BoxDecoration(
                                color: AppColors.orange_000,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: const Center(
                                  child: Text(
                                'Restore',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
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
                  width: 100.w,
                  height: 100.h,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      ImagePath.recoverDialogBalbam.path,
                      width: 100.0.w,
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
