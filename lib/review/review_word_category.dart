import 'package:flutter/material.dart';
import 'package:flutter_application_1/review/review_word_consonant_tab.dart';
import 'package:flutter_application_1/review/review_word_final_consonant_tab.dart';
import 'package:flutter_application_1/review/review_word_vowel_tab.dart';

class ReviewWordsCategoryScreen extends StatefulWidget {
  const ReviewWordsCategoryScreen({super.key});

  @override
  State<ReviewWordsCategoryScreen> createState() =>
      _ReviewWordsCategoryScreenState();
}

class _ReviewWordsCategoryScreenState extends State<ReviewWordsCategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Define the number of tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Reviewing"),
          content: Text("Do you want to end reviewing?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("Continue Reviewing"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("End"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the learning screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviewing Words',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 3.8, 0),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
                size: 30,
              ),
              onPressed: _showExitDialog,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor:
              const Color(0xffFF6F50), // Color of the text for the selected tab
          unselectedLabelColor:
              Colors.grey, // Color of the text for the unselected tabs
          indicatorColor: const Color(
              0xffFF6F50), // Color of the indicator shown below the selected tab

          tabs: const [
            Tab(
                child: Text(
              'Initial consonant',
              style: TextStyle(fontSize: 14.0),
              textAlign: TextAlign.center,
            )),
            Tab(
                child: Text(
              'Medial vowel',
              style: TextStyle(fontSize: 14.0),
              textAlign: TextAlign.center,
            )),
            Tab(
                child: Text(
              'Final consonant',
              style: TextStyle(fontSize: 14.0),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReviewWordConsonantTab(),
          ReviewWordVowelTab(),
          ReviewWordFinalConsonantTab(),
        ],
      ),
    );
  }
}
