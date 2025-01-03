import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

/// 홈화면
class HomeTutorialScreen1 extends StatelessWidget {
  const HomeTutorialScreen1({
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
      // Avatar 위치와 크기
      final RenderBox? avatarRenderBox =
          keys['avatarKey']?.currentContext?.findRenderObject() as RenderBox?;
      if (avatarRenderBox != null) {
        final avatarSize = avatarRenderBox.size;
        final avatarPosition = avatarRenderBox.localToGlobal(Offset.zero);
      }

      // ProgressBar 위치와 크기
      final RenderBox? progressBarRenderBox = keys['progressbarKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (progressBarRenderBox != null) {
        final progressBarSize = progressBarRenderBox.size;
        final progressBarPosition =
            progressBarRenderBox.localToGlobal(Offset.zero);
      }

      // levelTag 위치와 크기
      final RenderBox? levelTagRenderBox =
          keys['levelTagKey']?.currentContext?.findRenderObject() as RenderBox?;
      if (levelTagRenderBox != null) {
        final levelTagSize = levelTagRenderBox.size;
        final levelTagPosition = levelTagRenderBox.localToGlobal(Offset.zero);
      }
    });

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 반투명 배경
          Container(
            color: Colors.black.withOpacity(0.6),
            width: width,
            height: height,
          ),
          Builder(
            builder: (context) {
              // Avatar 위치와 크기
              final RenderBox? avatarRenderBox = keys['avatarKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;
              final RenderBox? progressBarRenderBox = keys['progressbarKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;
              final RenderBox? levelTagRenderBox = keys['levelTagKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;

              if (avatarRenderBox != null &&
                  progressBarRenderBox != null &&
                  levelTagRenderBox != null) {
                // Avatar 위치와 크기
                final avatarSize = avatarRenderBox.size;
                final avatarPosition =
                    avatarRenderBox.localToGlobal(Offset.zero);

                // ProgressBar 위치와 크기
                final progressBarSize = progressBarRenderBox.size;
                final progressBarPosition =
                    progressBarRenderBox.localToGlobal(Offset.zero);

                // ProgressBar 위치와 크기
                final levelTagSize = levelTagRenderBox.size;
                final levelTagPosition =
                    levelTagRenderBox.localToGlobal(Offset.zero);

                return Stack(
                  children: [
                    // ProgressBar
                    Positioned(
                      top: progressBarPosition.dy,
                      left: progressBarPosition.dx,
                      child: SimpleCircularProgressBar(
                        size: progressBarSize.width,
                        maxValue: 100,
                        progressStrokeWidth: 6.w,
                        backStrokeWidth: 6.w,
                        progressColors: [
                          progress_color,
                        ],
                        backColor: back_progress_color,
                        startAngle: 180,
                        valueNotifier: ValueNotifier(40), // 진행 상태 연결
                      ),
                    ),
                    // Avatar
                    Positioned(
                      top: avatarPosition.dy,
                      left: avatarPosition.dx,
                      child: CircleAvatar(
                        radius: avatarSize.width / 2,
                        backgroundColor:
                            const Color.fromARGB(255, 242, 235, 227),
                        child: SvgPicture.asset(
                          'assets/image/bam_character.svg',
                          width: 130.w,
                        ),
                      ),
                    ),
                    Positioned(
                      top: levelTagPosition.dy,
                      left: levelTagPosition.dx,
                      child: Column(
                        children: [
                          Container(
                            width: levelTagSize.width,
                            height: levelTagSize.height,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0.w, vertical: 6.0.h),
                            decoration: BoxDecoration(
                              color: progress_color,
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: DefaultTextStyle(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: bam,
                                  fontSize: 16.h,
                                  fontWeight: FontWeight.w400),
                              child: const Text(
                                'Level 1',
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
                      alignment: const Alignment(0, 0),
                      child: SizedBox(
                        width: 300.w,
                        height: 100.h,
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
                                'This is your profile section.\n',
                              ),
                            ),
                            DefaultTextStyle(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.h,
                                  fontWeight: FontWeight.w500),
                              child: const Text(
                                'Your level will go up\nas you practice more word cards!',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink(); // 키가 없을 때 빈 위젯 반환
            },
          ),
        ],
      ),
    );
  }
}