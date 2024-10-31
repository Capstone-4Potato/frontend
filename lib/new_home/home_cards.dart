import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/new_home/custom_cards_screen.dart';
import 'package:flutter_application_1/new_home/learning_course_screen.dart';
import 'package:flutter_application_1/new_home/missed_cards_screen.dart';
import 'package:flutter_application_1/new_home/saved_cards_screen.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class CustomHomeCard extends StatelessWidget {
  CustomHomeCard({
    super.key,
    required this.contents,
    required this.boxColor,
  });

  final Widget contents;
  Color boxColor;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.17),
            offset: const Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
        child: contents,
      ),
    );
  }
}

class ContentTodayGoal extends StatelessWidget {
  ContentTodayGoal({
    super.key,
    required this.weeklyAttendance,
  });

  List<String> weeklyAttendance;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    List days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Goal",
          style: TextStyle(
            fontSize: 12,
            color: bam,
          ),
        ),
        Container(
          height: 5 * height,
        ),
        Row(
          children: [
            Container(
              width: 246,
              height: 13 * height,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 235, 235),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 13 * height,
                width: 13 / 20 * 246,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child: Container(
                padding: const EdgeInsets.only(top: 3.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 213, 213, 213),
                      width: 1.0, // 밑줄 두께
                    ),
                  ),
                ),
                child: Text(
                  '13/20',
                  style: TextStyle(
                    color: bam,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Text(
              '▼',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(255, 213, 213, 213),
          ),
        ),
        Center(
          child: Wrap(
            spacing: 11.0,
            children: List.generate(7, (index) {
              return weeklyAttendance[index] == "F" // 출석 안했으면
                  ? NoStamp(
                      days: days,
                      index: index,
                    ) // 스탬프 없음
                  : Stamp(
                      // 출석하면 스탬프
                      days: days,
                      index: index,
                    );
            }),
          ),
        ),
      ],
    );
  }
}

// 스탬프 없는 위젯
class NoStamp extends StatelessWidget {
  NoStamp({
    super.key,
    required this.days,
    required this.index,
  });

  final List days;
  int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color.fromARGB(255, 213, 213, 213),
          width: 3,
        ),
      ),
      child: Text(
        days[index],
        style: const TextStyle(
          color: Color.fromARGB(255, 213, 213, 213),
        ),
      ),
    );
  }
}

// 스탬프 찍힌 위젯
// ignore: must_be_immutable
class Stamp extends StatelessWidget {
  Stamp({
    super.key,
    required this.days,
    required this.index,
  });

  final List days;
  int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: primary,
          width: 3,
        ),
      ),
      child: Text(
        days[index],
        style: TextStyle(color: primary),
      ),
    );
  }
}

class ContentTodayCard extends StatelessWidget {
  ContentTodayCard({
    super.key,
    required this.dailyWord,
    required this.dailyWordPronunciation,
  });

  String? dailyWord;
  String? dailyWordPronunciation;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Card",
              style: TextStyle(
                fontSize: 12,
                color: bam,
              ),
            ),
            Text(
              dailyWord!,
              style: TextStyle(
                fontSize: 30,
                color: bam,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200 * width,
                  child: Text(
                    "[$dailyWordPronunciation]",
                    style: TextStyle(
                      fontSize: 12,
                      //fontSize: 18,
                      color: bam,
                    ),
                    softWrap: true,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Text(
                      'Try it →',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ContentCustomCard extends StatelessWidget {
  const ContentCustomCard({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Say your own\nCustom sentence!",
              style: TextStyle(
                fontSize: 21,
                color: bam,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Text(
                      'Try it →',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ContentTodayMenu extends StatelessWidget {
  ContentTodayMenu({
    super.key,
    required this.level,
    required this.savedCardNumber,
    required this.missedCardNumber,
    required this.customCardNumber,
  });

  int level;
  int savedCardNumber;
  int missedCardNumber;
  int customCardNumber;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Menu",
          style: TextStyle(
            fontSize: 16,
            color: bam,
          ),
        ),
        MenuItem(
          title: 'Learning Course',
          icon: Icons.menu,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LearningCourseScreen(
                  level: level,
                ),
              ),
            );
          },
          count: 0,
          showCount: false,
        ),
        MenuItem(
          title: 'Saved Cards',
          icon: Icons.bookmark_outline,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SavedCardScreen(),
              ),
            );
          },
          count: savedCardNumber,
          showCount: true,
        ),
        MenuItem(
          title: 'Missed Cards',
          icon: Icons.sentiment_dissatisfied_outlined,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const MissedCardsScreen(),
              ),
            );
          },
          count: missedCardNumber,
          showCount: true,
        ),
        MenuItem(
          title: 'Custom Sentence',
          icon: Icons.type_specimen,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CustomCardsScreen(),
              ),
            );
          },
          count: customCardNumber,
          showCount: true,
        ),
      ],
    );
  }
}

// Menu 에 목록들
class MenuItem extends StatelessWidget {
  MenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.count,
    required this.showCount,
  });

  String title;
  IconData icon;
  VoidCallback onTap;
  int count;
  bool showCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(255, 213, 213, 213),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: bam,
                ),
                Container(
                  width: 8,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: bam,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                showCount
                    ? Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: progress_color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$count",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 160, 87, 50),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Container(),
                Container(
                  width: 15,
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: bam,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
