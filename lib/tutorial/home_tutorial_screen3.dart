import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

/// 홈화면
class HomeTutorialScreen3 extends StatelessWidget {
  const HomeTutorialScreen3({
    super.key,
    required this.keys,
    required this.onTap,
  });

  final Map<String, GlobalKey> keys;
  final VoidCallback onTap; // onTap 콜백 추가

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // 렌더링된 후 위치와 크기를 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // todayCard 카드 위치와 크기
      final RenderBox? todayCardRenderBox = keys['todayCardKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (todayCardRenderBox != null) {
        final todayCardSize = todayCardRenderBox.size;
        final todayCardPosition = todayCardRenderBox.localToGlobal(Offset.zero);
      }
    });

    return Stack(
      children: [
        // 반투명 배경
        Container(
          color: Colors.black.withOpacity(0.6),
          width: width,
          height: height,
        ),
        Builder(
          builder: (context) {
            // todayCard 위치와 크기
            final RenderBox? todayCardRenderBox = keys['todayCardKey']
                ?.currentContext
                ?.findRenderObject() as RenderBox?;

            if (todayCardRenderBox != null) {
              // todayGoal 위치와 크기
              final todayCardSize = todayCardRenderBox.size;
              final todayCardPosition =
                  todayCardRenderBox.localToGlobal(Offset.zero);

              return Stack(
                children: [
                  // LearningCourseCard
                  Positioned(
                    top: todayCardPosition.dy - 120.h,
                    left: todayCardPosition.dx + 4,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350.w,
                          height: 70.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DefaultTextStyle(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.h,
                                    fontWeight: FontWeight.w500),
                                child: const Text(
                                  'If you want to study beyond\ndaily goals, check out Learning Course!',
                                ),
                              ),
                            ],
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
                          width: todayCardSize.width - 8,
                          height: todayCardSize.height - 5,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.0.w, vertical: 15.0.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFEAFB),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DefaultTextStyle(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 21.h,
                                  color: bam,
                                ),
                                child: const Text(
                                  "Let's go to study!",
                                ),
                              ),
                              DefaultTextStyle(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 18.h,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard'),
                                child: const Text(
                                  'Learning Course',
                                ),
                              ),
                              Container(
                                height: 5.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RippleAnimation(
                                    color: const Color.fromARGB(
                                        255, 251, 180, 104),
                                    delay: const Duration(milliseconds: 300),
                                    repeat: true,
                                    minRadius: 20,
                                    maxRadius: 25,
                                    ripplesCount: 7,
                                    duration:
                                        const Duration(milliseconds: 6 * 300),
                                    child: GestureDetector(
                                      onTap: onTap,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14.0.w,
                                              vertical: 8.0.h),
                                          child: const DefaultTextStyle(
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              'Try it →',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink(); // 키가 없을 때 빈 위젯 반환
          },
        ),
      ],
    );
  }
}
