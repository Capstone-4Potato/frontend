import 'package:flutter/material.dart';
import 'package:flutter_application_1/learninginfo/deletephonemes.dart';
import 'package:flutter_application_1/vulnerablesoundtest/gettestlist.dart';
import 'package:flutter_application_1/vulnerablesoundtest/testcard.dart';

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
    var data =
        widget.check ? await getTestContinueData() : await getTestNewData();

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
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 160.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Before we start learning,\n let's take a simple test.",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
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
                    //fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 74, 74)),
                textAlign: TextAlign.center,
              ),
            ),
            //SizedBox(height: 30.0),
            const SizedBox(height: 5.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "It takes about 3 minutes.",
                style: TextStyle(
                    fontSize: 16.0,
                    //fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 74, 74)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                // Add navigation to the test page
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TestCard(
                              testIds: testIds,
                              testContents: testContents,
                              testPronunciations: testPronunciations,
                              testEngPronunciations: testEngPronunciations,
                              isRetest: true,
                            )),
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
          ],
        ),
      ),
    );
  }
}
