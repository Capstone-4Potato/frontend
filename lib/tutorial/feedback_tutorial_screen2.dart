import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackTutorialScreen2 extends StatefulWidget {
  const FeedbackTutorialScreen2({
    super.key,
    required this.buttonKey,
    required this.onTap,
  });

  final GlobalKey buttonKey;
  final VoidCallback onTap;

  @override
  State<FeedbackTutorialScreen2> createState() =>
      _FeedbackTutorialScreen2State();
}

class _FeedbackTutorialScreen2State extends State<FeedbackTutorialScreen2> {
  Offset? buttonPosition;
  Size? buttonSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderMeasurements();
    });
  }

  void _updateHeaderMeasurements() {
    final RenderBox? headerRenderBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerRenderBox != null) {
      setState(() {
        buttonSize = headerRenderBox.size;
        buttonPosition = headerRenderBox.localToGlobal(Offset.zero);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.6),
          width: width,
          height: height,
        ),
        if (buttonPosition != null && buttonSize != null)
          Positioned(
            top: buttonPosition!.dy - 175.h - 136.h,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'STEP 2 : Repeat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.h,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Press the microphone button\nand try pronuncing it yourself!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.h,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 130.h,
                    width: 0.1.w,
                    decoration: DottedDecoration(
                      color: Colors.white,
                      shape: Shape.line,
                      linePosition: LinePosition.right,
                      strokeWidth: 2.w,
                    ),
                  ),
                  SizedBox(
                    width: 72.w,
                    height: 72.h,
                    child: FloatingActionButton(
                      onPressed: widget.onTap,
                      backgroundColor: const Color(0xFFF26647),

                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(35.r))), // 조건 업데이트
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Color.fromARGB(231, 255, 255, 255),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
