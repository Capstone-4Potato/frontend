import 'package:flutter/material.dart';
import 'package:flutter_application_1/learninginfo/progress.dart';
import 'package:flutter_application_1/learninginfo/vulnerable_phonemes.dart';

class StudyInfoPage extends StatefulWidget {
  @override
  _StudyInfoPageState createState() => _StudyInfoPageState();
}

class _StudyInfoPageState extends State<StudyInfoPage> {
  late Future<Map<String, dynamic>> combinedData;

  @override
  void initState() {
    super.initState();
    combinedData = fetchCombinedData();
  }

  Future<Map<String, dynamic>> fetchCombinedData() async {
    final progressDataFuture = fetchProgressData();
    final vulnerablePhonemesFuture = checkStatusAndFetchPhonemes();

    final results = await Future.wait([
      progressDataFuture,
      vulnerablePhonemesFuture,
    ]);

    final progressData = results[0] as Map<String, double>;
    final vulnerablePhonemes = results[1] as List<Map<String, dynamic>>;

    return {
      'progressData': progressData,
      'vulnerablePhonemes': vulnerablePhonemes,
    };
  }

  Future<void> _refreshData() async {
    setState(() {
      combinedData = fetchCombinedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Map<String, dynamic>>(
        future: combinedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final progressData = data['progressData'] as Map<String, double>;
            final vulnerablePhonemes =
                data['vulnerablePhonemes'] as List<Map<String, dynamic>>;

            return Column(
              children: [
                LearningProgressScreen(
                  syllableProgress: progressData['syllableProgress']!,
                  wordProgress: progressData['wordProgress']!,
                  sentenceProgress: progressData['sentenceProgress']!,
                ),
                VulnerablePhonemesScreen(phonemes: vulnerablePhonemes),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
