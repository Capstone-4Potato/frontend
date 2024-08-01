import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/vulnerablesoundtest/gettestlist.dart';
import 'package:flutter_application_1/vulnerablesoundtest/testcard.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Korean Pronunciation Test',
//       home: StartTestScreen(),
//     );
//   }
// }

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
    var data = await fetchTestData();
    print(data);

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
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 160.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Before we start learning,\n let's take a simple test.",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.0),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "It takes about 3 minutes.",
                style: TextStyle(
                    fontSize: 16.0,
                    //fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 74, 74)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Add navigation to the test page
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestCard(
                          testIds: testIds,
                          testContents: testContents,
                          testPronunciations: testPronunciations,
                          testEngPronunciations: testEngPronunciations),
                    ),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff26647),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(
                '  start  ',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                // skip 하면 메인으로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(
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
