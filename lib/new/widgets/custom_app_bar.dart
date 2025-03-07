import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarColor,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.icon_001,
            iconSize: 24.sp,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      title: Text(
        'Delete Account',
        style: TextStyle(fontSize: 20.sp),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // 기본 AppBar 높이
}
