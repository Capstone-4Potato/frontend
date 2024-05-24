import 'package:flutter/material.dart';

class AudioProgressWidget extends StatefulWidget {
  final double duration; // 음성의 duration

  AudioProgressWidget({Key? key, required this.duration}) : super(key: key);

  @override
  _AudioProgressWidgetState createState() => _AudioProgressWidgetState();
}

class _AudioProgressWidgetState extends State<AudioProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds:
              (widget.duration * 1000).toInt()), // 음성의 duration을 밀리초로 변환
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          // 애니메이션 값이 변경될 때마다 UI를 업데이트
        });
      });

    // _controller.forward(); // 애니메이션 시작 - 재생 버튼을 누를 때 시작하도록 수정
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 음성 재생 버튼
        ElevatedButton(
          onPressed: () {
            _controller.reset(); // 애니메이션을 처음부터 시작하도록 초기화
            _controller.forward(); // 애니메이션 시작
          },
          child: Text('음성 재생'),
        ),
        // 이미지와 빨간색 선을 포함하는 컨테이너
        Container(
          child: Stack(
            children: [
              // 이미지
              Image.asset(
                'assets/userwaveform.png',
                width: 240,
                height: 90,
              ),
              // 빨간색 선
              Positioned(
                left: MediaQuery.of(context).size.width *
                    _animation.value, // 애니메이션 값에 따라 선의 위치 조정
                top: 0,
                child: Container(
                  color: Colors.red,
                  width: 2, // 선의 너비
                  height:
                      MediaQuery.of(context).size.height, // 선의 높이를 화면 높이로 설정
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Audio Progress Example')),
      body: AudioProgressWidget(duration: 10.0), // 음성의 duration을 전달
    ),
  ));
}
