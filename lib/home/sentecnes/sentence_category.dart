import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/home/sentecnes/sentencelist/sentence.dart';

class SentencesCategoryScreen extends StatefulWidget {
  const SentencesCategoryScreen({super.key});

  @override
  State<SentencesCategoryScreen> createState() =>
      _SentencesCategoryScreenState();
}

class _SentencesCategoryScreenState extends State<SentencesCategoryScreen> {
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return ExitDialog(
          width: width,
          height: height,
          page: const MainPage(initialIndex: 0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Sentences',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 3.8, 0),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 30,
              ),
              onPressed: _showExitDialog,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: CategoryLists.sentenceTitles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 6,
            childAspectRatio: 10 / 2.5,
          ),
          itemBuilder: (context, index) {
            return _buildSyllableCard(
                context, CategoryLists.sentenceTitles[index]);
          },
        ),
      ),
    );
  }

  // _buildSyllableCard 함수를 수정하여 타이틀과 서브타이틀을 함께 표시합니다.
  Widget _buildSyllableCard(BuildContext context, String title) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.sentenceTitles[0]: () => Sentence(
            category: '문장',
            subcategory: '기본회화',
            title: 'Basic Conversation',
          ),
      CategoryLists.sentenceTitles[1]: () => Sentence(
            category: '문장',
            subcategory: '학교대화',
            title: 'School Conversation',
          ),
      CategoryLists.sentenceTitles[2]: () => Sentence(
            category: '문장',
            subcategory: '카페주문',
            title: 'Ordering at a Cafe',
          ),
      CategoryLists.sentenceTitles[3]: () => Sentence(
            category: '문장',
            subcategory: '자기소개',
            title: 'Self Introduction',
          ),
    };

    return Card(
      elevation: 0, // 그림자 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xfff26647),
          width: 1.2,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        // InkWell을 사용하여 ListTile과 비슷한 탭 효과를 구현할 수 있습니다.
        onTap: () {
          if (navigationMap.containsKey(title)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigationMap[title]!()),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff525252),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
