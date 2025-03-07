import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class HomeTutorialScreen1 extends StatefulWidget {
  const HomeTutorialScreen1({
    super.key,
    required this.keys,
    required this.onTap,
  });

  final Map<String, GlobalKey> keys;
  final VoidCallback onTap;

  @override
  State<HomeTutorialScreen1> createState() => _HomeTutorialScreen1State();
}

class _HomeTutorialScreen1State extends State<HomeTutorialScreen1> {
  Offset? avatarPosition;
  Size? avatarSize;
  Offset? progressBarPosition;
  Size? progressBarSize;
  Offset? levelTagPosition;
  Size? levelTagSize;

  @override
  void initState() {
    super.initState();
    // 초기 측정 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateMeasurements();
      }
    });
  }

  @override
  void didUpdateWidget(HomeTutorialScreen1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 측정 시도
    if (mounted) {
      _updateMeasurements();
    }
  }

  void _updateMeasurements() {
    // 모든 RenderBox 측정 시도
    final RenderBox? avatarRenderBox = widget.keys['avatarKey']?.currentContext
        ?.findRenderObject() as RenderBox?;
    final RenderBox? progressBarRenderBox =
        widget.keys['progressbarKey']?.currentContext?.findRenderObject()
            as RenderBox?;
    final RenderBox? levelTagRenderBox =
        widget.keys['levelTagKey']?.currentContext?.findRenderObject()
            as RenderBox?;

    // 모든 RenderBox가 있을 때만 상태 업데이트
    if (avatarRenderBox != null &&
        progressBarRenderBox != null &&
        levelTagRenderBox != null) {
      setState(() {
        avatarSize = avatarRenderBox.size;
        avatarPosition = avatarRenderBox.localToGlobal(Offset.zero);
        progressBarSize = progressBarRenderBox.size;
        progressBarPosition = progressBarRenderBox.localToGlobal(Offset.zero);
        levelTagSize = levelTagRenderBox.size;
        levelTagPosition = levelTagRenderBox.localToGlobal(Offset.zero);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.6),
            width: width,
            height: height,
          ),
          if (avatarPosition != null &&
              progressBarPosition != null &&
              levelTagPosition != null)
            Stack(
              children: [
                // ProgressBar
                Positioned(
                  top: progressBarPosition!.dy,
                  left: progressBarPosition!.dx,
                  child: SimpleCircularProgressBar(
                    size: progressBarSize!.width,
                    maxValue: 100,
                    progressStrokeWidth: 6.w,
                    backStrokeWidth: 6.w,
                    progressColors: const [AppColors.primary],
                    backColor: AppColors.circularAvatar_000,
                    startAngle: 180,
                    valueNotifier: ValueNotifier(40),
                  ),
                ),
                // Avatar
                Positioned(
                  top: avatarPosition!.dy,
                  left: avatarPosition!.dx,
                  child: CircleAvatar(
                    radius: avatarSize!.width / 2,
                    backgroundColor: const Color.fromARGB(255, 242, 235, 227),
                    child: SvgPicture.asset(
                      ImagePath.balbamCharacter1.path,
                      width: 130.w,
                    ),
                  ),
                ),
                // Level Tag
                Positioned(
                  top: levelTagPosition!.dy,
                  left: 0, // 왼쪽부터 시작
                  right: 0, // 오른쪽까지 확장
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 수직 방향 정렬 유지
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 가로 방향 중앙 정렬
                    children: [
                      Container(
                        width: levelTagSize!.width,
                        height: levelTagSize!.height,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0.w, vertical: 6.0.h),
                        decoration: BoxDecoration(
                          color: AppColors.orange_003,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: bam,
                              fontSize: 16.h,
                              fontWeight: FontWeight.w400),
                          child: const Text('Level 1'),
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
                      SizedBox(
                        height: 5.h,
                      ),
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
                // Description Text
              ],
            ),
        ],
      ),
    );
  }
}
