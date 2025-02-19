import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 홈화면
class HomeTutorialScreen2 extends StatelessWidget {
  const HomeTutorialScreen2({
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
      // todayGoal 카드 위치와 크기
      final RenderBox? todayGoalRenderBox = keys['todayGoalKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (todayGoalRenderBox != null) {
        final todayGoalSize = todayGoalRenderBox.size;
        final todayGoalPosition = todayGoalRenderBox.localToGlobal(Offset.zero);
      }

      // homeNavigation bar 상자 위치와 크기
      final RenderBox? homeNavContainerRenderBox = keys['homeNavContainerKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (homeNavContainerRenderBox != null) {
        final homeNavContainerSize = homeNavContainerRenderBox.size;
        final homeNavContainerPosition =
            homeNavContainerRenderBox.localToGlobal(Offset.zero);
      }

      // homeNavigation bar FAB 위치와 크기
      final RenderBox? homeNavFabRenderBox = keys['homeNavFabKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (homeNavFabRenderBox != null) {
        final homeNavFabSize = homeNavFabRenderBox.size;
        final homeNavFabPosition =
            homeNavFabRenderBox.localToGlobal(Offset.zero);
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
              // todayGoal 위치와 크기
              final RenderBox? todayGoalRenderBox = keys['todayGoalKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;
              // todayGoal 위치와 크기
              final RenderBox? homeNavContainerRenderBox =
                  keys['homeNavContainerKey']
                      ?.currentContext
                      ?.findRenderObject() as RenderBox?;
              // todayGoal 위치와 크기
              final RenderBox? homeNavFabRenderBox = keys['homeNavFabKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;

              if (todayGoalRenderBox != null &&
                  homeNavContainerRenderBox != null &&
                  homeNavFabRenderBox != null) {
                // todayGoal 위치와 크기
                final todayGoalSize = todayGoalRenderBox.size;
                final todayGoalPosition =
                    todayGoalRenderBox.localToGlobal(Offset.zero);
                // homeNavContainer 위치와 크기
                final homeNavContainerSize = homeNavContainerRenderBox.size;
                final homeNavContainerPosition =
                    homeNavContainerRenderBox.localToGlobal(Offset.zero);
                // homeNavFav 위치와 크기
                final homeNavFabSize = homeNavFabRenderBox.size;
                final homeNavFabPosition =
                    homeNavFabRenderBox.localToGlobal(Offset.zero);

                return Stack(
                  children: [
                    // todayGoal Card
                    Positioned(
                      top: todayGoalPosition.dy,
                      left: todayGoalPosition.dx,
                      child: Column(
                        children: [
                          Container(
                            width: todayGoalSize.width,
                            height: todayGoalSize.height / 2.0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0.w, vertical: 10.0.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DefaultTextStyle(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.h,
                                    color: bam,
                                  ),
                                  child: const Text(
                                    "Today's Goal",
                                  ),
                                ),
                                Container(
                                  height: 5.h,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 246.w,
                                      height: 13.h,
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 235, 235, 235),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Container(
                                        height: 13.h,
                                        width: 36.w,
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.r),
                                              bottomLeft:
                                                  Radius.circular(20.r)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0.w),
                                      child: DefaultTextStyle(
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.h,
                                          color: bam,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              const Color(0xFFD5D5D5),
                                        ),
                                        child: const Text(
                                          "2/20",
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down_rounded),
                                  ],
                                )
                              ],
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
                          SizedBox(
                            height: 10.h,
                          ),
                          DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.h,
                                fontWeight: FontWeight.w500),
                            child: const Text(
                              'Set the number of cards\nyou’d like to study daily.',
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.h,
                                fontWeight: FontWeight.w500),
                            child: const Text(
                              'Then start with this button!\nIt will give you the cards\nbased on your goal each day.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // homeNavigationBar
                    Positioned(
                      top: homeNavContainerPosition.dy,
                      left: homeNavContainerPosition.dx,
                      child: Container(
                        width: homeNavContainerSize.width.w,
                        height: homeNavContainerSize.height.h,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 242, 235, 227),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 45.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home,
                                    size: 24,
                                    color: primary,
                                  ),
                                  DefaultTextStyle(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: primary,
                                        fontSize: 18.h,
                                        fontWeight: FontWeight.w500),
                                    child: const Text(
                                      'home',
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_2,
                                    size: 24,
                                    color: bam,
                                  ),
                                  DefaultTextStyle(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: bam,
                                        fontSize: 18.h,
                                        fontWeight: FontWeight.w500),
                                    child: const Text(
                                      'Report',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: homeNavFabPosition.dy - 49.h,
                      left: homeNavFabPosition.dx,
                      child: Column(
                        children: [
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
                            width: 98.w,
                            height: 98.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF26647),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.4),
                                  width: 4.0.w),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              size: 44,
                              color: Colors.white,
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
      ),
    );
  }
}
