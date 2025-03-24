import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

void showDeleteAccountDialog(BuildContext context, Function onConfirmTap) {
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
                        'Are you sure?',
                        style: TextStyle(
                          color: AppColors.orange_000,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0.h, bottom: 24.h, right: 18.w, left: 18.w),
                        child: Text(
                          'If you proceed, you will lose all your personal data. Are you sure you want to delete your account?',
                          style: TextStyle(
                            fontSize: 14.sp,
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
                            onTap: () async {
                              Navigator.pop(context);
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
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.gray_003,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              onConfirmTap();
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
                                'Confirm',
                                style: TextStyle(
                                  color: AppColors.white_000,
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
                      ImagePath.deleteDialogCryingBalbam.path,
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
