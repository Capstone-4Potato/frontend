import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 피드백 Dialog에 표시되는 도장
class FeedbackStamp extends StatelessWidget {
  final int userScore; // 사용자 점수
  final String recommendCardKey; // recommendCardKey 값 ex) "Try again"

  const FeedbackStamp({
    super.key,
    required this.userScore,
    required this.recommendCardKey,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = userScore == 100 // 100점일 경우
        ? ImagePath.feedbackStamp3.path
        : (recommendCardKey == "Try Agian" // try again인 경우
            ? ImagePath.feedbackStamp1.path
            : ImagePath.feedbackStamp2.path); // default 값

    return SvgPicture.asset(imagePath, height: 100.0.w);
  }
}

/// 피드백 Dialog에 표시되는 발음
class FeedbackText extends StatelessWidget {
  const FeedbackText({
    super.key,
    required this.feedbackData,
    required this.correctText,
  });

  final FeedbackData feedbackData;
  final String correctText;

  @override
  Widget build(BuildContext context) {
    return feedbackData.userScore == 100
        ? Text(
            correctText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.black,
                  fontFamily: FontFamily.pretendard.fontName,
                ),
          )
        : feedbackData.userText.length == correctText.length
            ?
            // 사용자 발음 텍스트와 잘못된 부분을 표시하는 텍스트 위젯
            buildTextSpans(
                feedbackData.userText,
                feedbackData.mistakenIndexes,
              )
            : buildTextSpansOmit(
                // 발음 안된 글자가 있을 때
                correctText,
                feedbackData.userText);
  }
}

/// feedback Dialog `Practice`, `Correct`, `User` 컨테이너
class FeedbackResultContainer extends StatelessWidget {
  const FeedbackResultContainer({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      height: 43.0.h,
      decoration: BoxDecoration(
        color: AppColors.gray_001,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.gray_004,
                ),
          ),
          content,
        ],
      ),
    );
  }
}

/// feddback Dialog에서 사용자 waveForm 담는 컨테이너
class FeedbackWaveformContainer extends StatelessWidget {
  final Color buttonBackgroundColor;
  final Color containerBackgroundColor;
  final PlayerController playerController;
  final VoidCallback onPressed;

  const FeedbackWaveformContainer({
    super.key,
    required this.buttonBackgroundColor,
    required this.containerBackgroundColor,
    required this.playerController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      height: 30.0.h,
      padding: EdgeInsets.symmetric(horizontal: 10.0.w),
      decoration: BoxDecoration(
        color: containerBackgroundColor,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18.w,
            height: 18.h,
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 4.0.w),
            decoration: BoxDecoration(
              color: buttonBackgroundColor,
              shape: BoxShape.circle, // 원형 테두리
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.play_arrow_rounded),
              color: AppColors.white_000,
              iconSize: 12.0.w,
              onPressed: onPressed,
            ),
          ),

          // 웨이브폼 추가
          AudioFileWaveforms(
            size: Size(95.w, 20.h),
            playerController: playerController,
            enableSeekGesture: true,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: buttonBackgroundColor,
              liveWaveColor: const Color.fromARGB(255, 206, 14, 14),
              spacing: 4.w, // spacing 값 증가
              waveThickness: 2.w, // waveThickness는 spacing보다 작아야 함
            ),
          ),
        ],
      ),
    );
  }
}

/// 그래프에 나타나는 라벨
class AudioGraphLabel extends StatelessWidget {
  final Color labelColor;
  final String labelText;

  const AudioGraphLabel({
    super.key,
    required this.labelColor,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.0.w,
          height: 8.0.h,
          margin: EdgeInsets.only(right: 5.0.w),
          decoration: BoxDecoration(
            color: labelColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          labelText,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
