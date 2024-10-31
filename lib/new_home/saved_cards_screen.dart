import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

class SavedCardScreen extends StatefulWidget {
  const SavedCardScreen({
    super.key,
  });

  @override
  State<SavedCardScreen> createState() => _SavedCardScreenState();
}

class _SavedCardScreenState extends State<SavedCardScreen> {
  List<int> idList = [];
  List<String> textList = [];
  List<String> cardPronunciationList = [];
  List<int> cardScoreList = [];
  List<bool> weakCardList = [];
  List<bool> bookmarkList = [];

  bool isLoading = true;

  Future<void> fetchSavedCardList() async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/home/bookmark');

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.get(url, headers: headers);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<dynamic> cardList = data['cardList'];

      setState(() {
        // 리스트 초기화
        idList.clear();
        textList.clear();
        cardScoreList.clear();
        weakCardList.clear();
        bookmarkList.clear();

        // 변수 리스트에 데이터 저장
        for (var card in cardList) {
          idList.add(card['id']);
          textList.add(card['text']);
          cardPronunciationList.add(card['cardPronunciation']);
          cardScoreList.add(card['cardScore']);
          weakCardList.add(card['weakCard']);
          bookmarkList.add(card['bookmark']);
        }
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load card list');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSavedCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Cards')),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : idList.isEmpty
              ? const Center(
                  child: Text(
                    "There is no Saved Cards!",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 6 / 4.3,
                  ),
                  itemCount: idList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // 추후 추가
                      },
                      child: Opacity(
                        // 카드의 학습 완료 정도에 따라 투명도 조절
                        opacity: cardScoreList[index] >= 1.0 ? 0.5 : 1.0,
                        child: Card(
                          elevation: 0.0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // 카드의 내용 표시
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      textList[index],
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: weakCardList[index]
                                              ? const Color.fromARGB(
                                                  236, 255, 85, 85)
                                              : Colors.black),
                                    ),
                                  ),
                                  Text(cardPronunciationList[index],
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
