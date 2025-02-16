import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/screens/login_screen.dart';
import 'package:flutter_application_1/new/services/api/profile_users.dart';
import 'package:flutter_application_1/new/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/new/widgets/delete_account_dialog.dart';
import 'package:flutter_application_1/settings/deleteaccount/withdrawal_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountSurveyScreen extends StatefulWidget {
  const DeleteAccountSurveyScreen({super.key});

  @override
  State<DeleteAccountSurveyScreen> createState() =>
      _DeleteAccountSurveyScreenState();
}

class _DeleteAccountSurveyScreenState extends State<DeleteAccountSurveyScreen> {
  final List<String> _items = [
    "I don’t use it",
    "It's not functional enough",
    "It's hard to use",
    "This app lacks learning content",
    "I want to make a new system",
    "Other (input)",
  ];

  final TextEditingController _customInputController = TextEditingController();
  String? _selectedValue;
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
    });
  }

  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < _items.length; i++) {
      i == _items.length - 1 ? itemsHeights.add(30) : itemsHeights.add(46);
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

  Widget _buildSurveyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Are you leaving? I\'m so sad.', 20.sp, FontWeight.w500),
        SizedBox(height: 16.h),
        _buildText(
            'If you leave the account and return within 30 days, you can recover it.',
            18.sp,
            FontWeight.w400),
        SizedBox(height: 28.h),
        _buildText('I wonder why you want to delete your account.', 20.sp,
            FontWeight.w500),
        SizedBox(height: 16.h),
        _buildDropdownField(),
        if (_showTextField) SizedBox(height: 16.h),
        if (_showTextField) _buildTextField(),
      ],
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _inputDecoration(),
      hint: Text('Select a reason.',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          )),
      items: _items.asMap().entries.map((entry) {
        String item = entry.value;

        return DropdownMenuItem<String>(
          value: item,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5.w,
                children: [
                  SizedBox(
                    width: 3.w,
                  ),
                  Icon(Icons.check,
                      color:
                          _selectedValue == item ? Colors.black : Colors.white,
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
              if (item != _items.last) // 마지막 아이템에는 Divider 추가하지 않음
                Divider(
                  color: AppColors.gray_001,
                  thickness: 1,
                  height: 10.h,
                ),
            ],
          ),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please choose a reason.' : null,
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
          _showTextField = value == "Other (input)";
          _customInputController.clear();
        });
        _validateForm();
      },
      selectedItemBuilder: (context) {
        return _items.map((item) {
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

  Widget _buildTextField() {
    return TextFormField(
      controller: _customInputController,
      decoration: _inputDecoration(hintText: "Please specify"),
      validator: (value) =>
          _showTextField && (value == null || value.trim().isEmpty)
              ? 'Please enter a reason.'
              : null,
      onChanged: (value) => _validateForm(),
    );
  }

  void onConfirmTap() {
    // 계정 삭제 api 요청
    deleteUsersAccountRequest(UserInfo().name);
    // 튜토 정보 삭제
    initiallizeTutoInfo(true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _isButtonEnabled
          ? () {
              // dialog 띄움
              showDeleteAccountDialog(context, onConfirmTap);

              debugPrint("Selected: $_selectedValue");
              if (_selectedValue == "Other (input)") {
                debugPrint("User Input: ${_customInputController.text}");
              }
            }
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

  Widget _buildText(String text, double fontSize, FontWeight fontWeight,
      [double? height]) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }

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
    );
  }

  BoxDecoration _dropdownDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.white,
        boxShadow: const <BoxShadow>[],
      );
}
