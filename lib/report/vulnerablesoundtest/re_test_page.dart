import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/services/api/weak_sound_test_api.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/testcard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestartTestScreen extends StatefulWidget {
  RestartTestScreen({
    super.key,
    required this.check,
  });

  bool check;

  @override
  State<RestartTestScreen> createState() => _RestartTestScreenState();
}

class _RestartTestScreenState extends State<RestartTestScreen> {
  late List<int> testIds = [];
  late List<String> testContents = [];
  late List<String> testPronunciations = [];
  late List<String> testEngPronunciations = [];
  late List<String> testEngTranslation = [];

  @override
  void initState() {
    super.initState();
    initTestData();
  }

  Future<void> initTestData() async {
    List<dynamic>? data = widget.check
        ? await getTestContinueDataRequest()
        : await getTestNewDataRequest();
    if (data != null) {
      setState(() {
        testIds = List.generate(data.length, (index) => data[index]['id']);
        testContents =
            List.generate(data.length, (index) => data[index]['text']);
        testPronunciations =
            List.generate(data.length, (index) => data[index]['pronunciation']);
        testEngPronunciations = List.generate(
            data.length, (index) => data[index]['engPronunciation']);
        testEngTranslation = List.generate(
            data.length, (index) => data[index]['engTranslation']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Before we start learning,\n let's take a simple test.",
                style: TextStyle(fontSize: 22.0.h, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "View the pronunciation guide on the card,\nand record yourself mimicking it slowly.",
                style: TextStyle(
                    fontSize: 16.0.h,
                    color: const Color.fromARGB(255, 74, 74, 74)),
                textAlign: TextAlign.center,
              ),
            ),
            //SizedBox(height: 30.0),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "It takes about 3 minutes.",
                style: TextStyle(
                    fontSize: 16.0.h,
                    color: const Color.fromARGB(255, 74, 74, 74)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0.h),
            ElevatedButton(
              onPressed: () async {
                // Add navigation to the test page
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TestCard(
                              testIds: testIds,
                              testContents: testContents,
                              testTranslations: testEngTranslation,
                              testEngPronunciations: testEngPronunciations,
                              isRetest: true,
                              exitIndex: 1,
                            )),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff26647),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18.h,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text(
                '  start  ',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
