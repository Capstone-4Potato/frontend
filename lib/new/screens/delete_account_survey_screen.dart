import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_application_1/new/services/api/withdrawal_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/models/survey_reason.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/new/widgets/dialogs/delete_account_dialog.dart';
import 'package:flutter_application_1/new/services/api/profile_api.dart';

/// 계정 탈퇴 설문조사 화면
class DeleteAccountSurveyScreen extends StatefulWidget {
  const DeleteAccountSurveyScreen({super.key});

  @override
  State<DeleteAccountSurveyScreen> createState() =>
      _DeleteAccountSurveyScreenState();
}

class _DeleteAccountSurveyScreenState extends State<DeleteAccountSurveyScreen> {
  List<String> surveyOptions = SurveyReason.values.map((e) => e.label).toList();

  final TextEditingController _customInputController = TextEditingController();
  String? _selectedValue;
  int _selectedReasonCode = 0; // 이유 코드
  String _detail = ""; // 이유 저장
  bool _showTextField = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _customInputController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _customInputController.removeListener(_validateForm);
    _customInputController.dispose();
    super.dispose();
  }

  /// form 유효성 검사
  void _validateForm() {
    setState(() {
      _isButtonEnabled = _selectedValue != null &&
          (!_showTextField || _customInputController.text.trim().isNotEmpty);
      _detail = _showTextField ? _customInputController.text : _selectedValue!;
    });
  }

  /// 메뉴 아이템 높이
  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < surveyOptions.length; i++) {
      i == surveyOptions.length - 1
          ? itemsHeights.add(30.0.h)
          : itemsHeights.add(46.0.h);
    }
    return itemsHeights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.0.w, vertical: 26.0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSurveyContent(),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  /// 설문 내용 빌드
  Widget _buildSurveyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Are you leaving? I\'m so sad.'),
        _buildDescription(
            'If you leave the account and return within 30 days, you can recover it.'),
        _buildSectionTitle('I wonder why you want to delete your account.'),
        _buildDropdownField(),
        // text 입력 시에 보여줌
        if (_showTextField) _buildTextField(),
      ],
    );
  }

  /// 드롭 다운 필드 빌드
  Widget _buildDropdownField() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _inputDecoration(),
      hint: Text('Select a reason.',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          )),
      items: surveyOptions.map((item) => _buildDropdownItem(item)).toList(),
      validator: (value) => value == null ? 'Please choose a reason.' : null,
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
          _selectedReasonCode = surveyOptions.indexOf(value!) + 1;

          _showTextField = value == SurveyReason.other.label;

          _customInputController.clear();
        });
        _validateForm();
      },
      selectedItemBuilder: (context) {
        return surveyOptions.map((item) {
          return Text(
            item, // 선택된 값에는 아이콘 없이 텍스트만 표시

            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.gray_003,
            ),
          );
        }).toList();
      },
      buttonStyleData: ButtonStyleData(height: 30.h),
      dropdownStyleData:
          DropdownStyleData(decoration: _dropdownDecoration(), width: 280.w),
      iconStyleData: const IconStyleData(iconSize: 0),
      menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          customHeights: _getCustomItemsHeights()),
    );
  }

  /// 드롭 다운 메뉴 item 스타일 지정
  DropdownMenuItem<String> _buildDropdownItem(String item) {
    return DropdownMenuItem<String>(
      value: item,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 5.0.w,
            children: [
              SizedBox(width: 3.0.w),
              Icon(Icons.check,
                  color: _selectedValue == item ? Colors.black : Colors.white,
                  size: 18.sp),
              Text(
                item,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: FontFamily.madeTommySoft.fontName,
                ),
              ),
            ],
          ),
          if (item != surveyOptions.last) // 마지막 아이템에는 Divider 추가하지 않음
            Divider(
              color: AppColors.gray_001,
              thickness: 1,
              height: 10.0.h,
            ),
        ],
      ),
    );
  }

  /// 텍스트 필드 빌드
  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0.h),
      child: TextFormField(
        controller: _customInputController,
        decoration: _inputDecoration(hintText: "Please specify"),
        validator: (value) =>
            _showTextField && (value == null || value.trim().isEmpty)
                ? 'Please enter a reason.'
                : null,
        onChanged: (value) => _validateForm(),
        cursorColor: AppColors.primary,
      ),
    );
  }

  /// 계정 탈퇴 시 처리 함수
  void onConfirmTap() async {
    // 이유 전송 api 요청
    await sendWithdrawalReasonRequest(_selectedReasonCode, _detail);

    // 계정 탈퇴 api 요청
    // ignore: use_build_context_synchronously
    await deleteUsersAccountRequest(UserInfo().name, context);
  }

  /// 삭제 버튼 빌드
  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _isButtonEnabled
          ? () => showDeleteAccountDialog(context, onConfirmTap)
          : null,
      child: Ink(
        decoration: BoxDecoration(
          color: _isButtonEnabled ? AppColors.primary : AppColors.gray_001,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
          child: Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// drop down 필드 custom
  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
          color: AppColors.gray_003,
          fontSize: 20.sp,
          fontWeight: FontWeight.w400),
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 21.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: const BorderSide(color: AppColors.gray_001),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: const BorderSide(color: AppColors.gray_001),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: const BorderSide(color: AppColors.gray_001),
      ),
    );
  }

  /// 드롭다운 전체 컨테이너 css
  BoxDecoration _dropdownDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.white,
        boxShadow: const <BoxShadow>[],
      );

  /// 질문 텍스트 빌드
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(text,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500)),
    );
  }

  /// 설명 텍스트 빌드
  Widget _buildDescription(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Text(text,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400)),
    );
  }
}
