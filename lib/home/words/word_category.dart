import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/words/word_consonant_tab.dart';
import 'package:flutter_application_1/home/words/word_final_consonant_tab.dart';
import 'package:flutter_application_1/home/words/word_vowel_tab.dart';

class WordsCategoryScreen extends StatefulWidget {
  const WordsCategoryScreen({super.key});

  @override
  State<WordsCategoryScreen> createState() => _WordsCategoryScreenState();
}

class _WordsCategoryScreenState extends State<WordsCategoryScreen>
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
          title: Text("End Learning"),
          content: Text("Do you want to end learning?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("Continue Learning"),
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
          'Learning Words',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            //color: Color(0xfff26647),
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
          WordConsonantTab(),
          WordVowelTab(),
          WordFinalConsonantTab(),
        ],
      ),
    );
  }
}
