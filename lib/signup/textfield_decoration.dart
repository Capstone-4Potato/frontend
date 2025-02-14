import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

InputDecoration textfieldDecoration(
    bool isTapped, bool isButtonEnabled, String hintText) {
  return InputDecoration(
    fillColor: isTapped
        ? isButtonEnabled
            ? const Color.fromARGB(255, 248, 241, 227)
            : const Color.fromARGB(255, 247, 222, 217)
        : const Color.fromARGB(255, 248, 241, 227),
    filled: true, // 배경색 채우기 활성화
    hintText: hintText, // 힌트 텍스트 설정
    hintStyle: TextStyle(
      color: bam.withValues(alpha: 0.5),
      fontFamily: 'BM_Jua',
      fontSize: 20.sp,
    ),
    helperText: ' ',
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 195, 185, 182),
        width: 0.5.w,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      // 포커스 상태일 때의 테두리 스타일
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: primary,
        width: 1.0.w, // 테두리 너비
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 232, 57, 26),
        width: 1.5,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 232, 57, 26),
        width: 1.5,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 15.0.h,
      horizontal: 15.0.w,
    ), // 내부 여백 설정
  );
}
