import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackTutorialScreen1 extends StatefulWidget {
  const FeedbackTutorialScreen1({
    super.key,
    required this.buttonKey,
    required this.onTap,
  });

  final GlobalKey buttonKey;
  final VoidCallback onTap;

  @override
  State<FeedbackTutorialScreen1> createState() =>
      _FeedbackTutorialScreen1State();
}

class _FeedbackTutorialScreen1State extends State<FeedbackTutorialScreen1> {
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
            top: buttonPosition!.dy,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26647),
                      minimumSize: const Size(220, 40),
                    ),
                    onPressed: widget.onTap,
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Listen',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 40.h,
                    width: 0.1.w,
                    decoration: DottedDecoration(
                      color: Colors.white,
                      shape: Shape.line,
                      linePosition: LinePosition.right,
                      strokeWidth: 2.w,
                    ),
                  ),
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'STEP 1 : Listen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.h,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Listen to the correct pronunciation\ntailored to your gender and age.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.h,
                      fontWeight: FontWeight.w500,
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
