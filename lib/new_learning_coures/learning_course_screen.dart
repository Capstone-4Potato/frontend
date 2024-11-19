import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';

class LearningCourseScreen extends StatefulWidget {
  const LearningCourseScreen({super.key});

  @override
  State<LearningCourseScreen> createState() => _LearningCourseScreenState();
}

class _LearningCourseScreenState extends State<LearningCourseScreen> {
  List<String> levels = ['Begginer', 'Intermediate', 'Advanced'];
  int? value;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 393;
    double height = MediaQuery.of(context).size.height / 852;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2EBE3),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: bam,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(
          'Learning Course',
          style: TextStyle(
            color: bam,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 8,
                  children: List<Widget>.generate(levels.length, (index) {
                    return SizedBox(
                      //width: 82 * width,
                      //height: 25 * height,
                      child: ChoiceChip(
                        padding: const EdgeInsets.all(0),
                        label: Container(
                          //width: 82 * width,
                          //height: 25 * height,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 8),
                          child: Text(
                            levels[index],
                            style: TextStyle(
                              color: value == index
                                  ? Colors.white
                                  : const Color(0xFF92918C),
                              fontSize: 12 * width,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * width,
                          fontWeight: FontWeight.w500,
                        ),
                        selected: value == index,
                        selectedColor: value == index
                            ? const Color(0xFFF26647)
                            : Colors.white,
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          setState(() {
                            value = selected ? index : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              'Each unit is organized by pronunciation difficulty.\nStart with Unit 1 and move up as you improve!',
              style: TextStyle(
                color: const Color(0xFf92918C),
                fontSize: 12 * width,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }
}
