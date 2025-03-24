import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_borders/glowy_borders.dart';

class LearningCourseTutorialScreen2 extends StatefulWidget {
  const LearningCourseTutorialScreen2({
    super.key,
    required this.beginnerKey,
    required this.onTap,
  });

  final GlobalKey beginnerKey;
  final VoidCallback onTap;

  @override
  State<LearningCourseTutorialScreen2> createState() =>
      _LearningCourseTutorialScreen2State();
}

class _LearningCourseTutorialScreen2State
    extends State<LearningCourseTutorialScreen2> {
  Offset? beginnerPosition;
  Size? beginnerSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderMeasurements();
    });
  }

  void _updateHeaderMeasurements() {
    final RenderBox? headerRenderBox =
        widget.beginnerKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerRenderBox != null) {
      setState(() {
        beginnerSize = headerRenderBox.size;
        beginnerPosition = headerRenderBox.localToGlobal(Offset.zero);
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
          color: Colors.black.withValues(alpha: 0.6),
          width: width,
          height: height,
        ),
        if (beginnerPosition != null && beginnerSize != null)
          Positioned(
            top: beginnerPosition!.dy - 10.h,
            left: beginnerPosition!.dx + 8.w,
            right: beginnerPosition!.dx + 8.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedGradientBorder(
                  borderSize: 3.5,
                  animationTime: 5,
                  glowSize: 0.5,
                  gradientColors: const [
                    Colors.transparent,
                    Color(0xFFFFF3E6),
                    Color(0xFFFB8A71),
                    Color(0xFFF26647),
                  ],
                  animationProgress: null,
                  borderRadius: BorderRadius.circular(24.0.r),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      height: 98.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0.r),
                        border: Border.all(
                          color: const Color(0xFFBEBDB8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 30.0.w,
                            top: 15.0.h,
                            bottom: 15.0.h,
                            right: 20.0.w),
                        child: Material(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Unit 1',
                                style: TextStyle(
                                  color: const Color(0xFF666560),
                                  fontSize: 24.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 300.w,
                                child: Text(
                                  'Basic consonants/vowels',
                                  style: TextStyle(
                                    color: const Color(0xFF63625C),
                                    fontSize: 16.h,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                Material(
                  color: Colors.transparent,
                  child: Text(
                    "Click to start learning!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.h,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
