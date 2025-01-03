import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LearningCourseTutorialScreen extends StatefulWidget {
  const LearningCourseTutorialScreen({
    super.key,
    required this.headerKey,
    required this.onTap,
  });

  final GlobalKey headerKey;
  final VoidCallback onTap;

  @override
  State<LearningCourseTutorialScreen> createState() =>
      _LearningCourseTutorialScreenState();
}

class _LearningCourseTutorialScreenState
    extends State<LearningCourseTutorialScreen> {
  Offset? headerPosition;
  Size? headerSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderMeasurements();
    });
  }

  void _updateHeaderMeasurements() {
    final RenderBox? headerRenderBox =
        widget.headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerRenderBox != null) {
      setState(() {
        headerSize = headerRenderBox.size;
        headerPosition = headerRenderBox.localToGlobal(Offset.zero);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.6),
            width: width,
            height: height,
          ),
          if (headerPosition != null && headerSize != null)
            Positioned(
              top: headerPosition!.dy,
              left: headerPosition!.dx + 11.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: headerSize!.width - 22.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.0.w,
                      vertical: 15.0.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Material(
                      color: const Color(0xFFF5F5F5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 8.0.h, bottom: 15.0.w),
                            child: Row(
                              children: [
                                Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 16.w,
                                  children: List.generate(
                                    levels.length,
                                    (index) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 13.w,
                                        vertical: 6.h,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? const Color(0xFFF26647)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                      child: Text(
                                        levels[index],
                                        style: TextStyle(
                                          color: index == 0
                                              ? Colors.white
                                              : const Color(0xFF92918C),
                                          fontSize: 12.h,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0.h),
                            child: Text(
                              'Each unit is organized by pronunciation difficulty.\nStart with Unit 1 and move up as you improve!',
                              style: TextStyle(
                                color: const Color(0xFf92918C),
                                fontSize: 12.h,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 40.h,
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
                ],
              ),
            ),
          Align(
            alignment: const Alignment(0, -0.1),
            child: SizedBox(
              width: 300.w,
              height: 150.h,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'You\'ll find all the study materials\nwe offer in this page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.h,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      'Feel free to explore step by step\nor jump straight to what you need!',
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
          ),
        ],
      ),
    );
  }
}
