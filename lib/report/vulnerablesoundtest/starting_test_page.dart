import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/models/navigation_type.dart';
import 'package:flutter_application_1/new/services/api/weak_sound_test_api.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/testcard.dart';

/// 로그인 -> 회원가입 -> 튜토리얼 -> 취약음테스트 시작 페이지
class StartTestScreen extends StatefulWidget {
  const StartTestScreen({super.key});

  @override
  State<StartTestScreen> createState() => _StartTestScreenState();
}

class _StartTestScreenState extends State<StartTestScreen> {
  late List<int> testIds = [];
  late List<String> testContents = [];
  late List<String> testPronunciations = [];
  late List<String> testEngPronunciations = [];

  @override
  void initState() {
    super.initState();
    initTestData();
  }

  Future<void> initTestData() async {
    var data = await getTestNewDataRequest(); // 새 test 데이터 요청

    if (data != null) {
      setState(() {
        testIds = List.generate(data.length, (index) => data[index]['id']);
        testContents =
            List.generate(data.length, (index) => data[index]['text']);
        testPronunciations = List.generate(
            data.length, (index) => data[index]['engTranslation']);
        testEngPronunciations = List.generate(
            data.length, (index) => data[index]['engPronunciation']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
      ),
      backgroundColor: background,
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 160.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Before we start learning,\n let's take a simple test.",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Marine',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "View the pronunciation guide on the card,\nand record yourself mimicking it slowly.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 74, 74, 74),
                  fontFamily: 'Marine',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "It takes about 3 minutes.",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 74, 74, 74),
                  fontFamily: 'Marine',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Add navigation to the test page
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestCard(
                        testIds: testIds,
                        testContents: testContents,
                        testTranslations: testPronunciations,
                        testEngPronunciations: testEngPronunciations,
                        isRetest: false,
                        exitIndex: 0,
                      ),
                    ),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff26647),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text(
                '  start  ',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                // skip 하면 메인으로 이동
                context.navigateTo(
                    screen: HomeNav(), type: NavigationType.pushAndRemoveUntil);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text(
                '  skip  ',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
