import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(CycleHelperApp());
}

class CycleHelperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CycleHomePage(),
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
    );
  }
}

class CycleHomePage extends StatefulWidget {
  @override
  _CycleHomePageState createState() => _CycleHomePageState();
}

class _CycleHomePageState extends State<CycleHomePage> {
  String message = "준비하세요!";
  int totalTimeLeft = 3 * 60; // 3분
  int currentPhaseTimeLeft = 40; // 현재 구간 남은 시간
  Timer? _timer;
  bool isStarted = false; // 시작 여부
  int shutdownTimer = 5; // 종료까지 남은 시간 (초)
  double fontSize = 24.0; // 텍스트 크기
  Color fontColor = Colors.grey.shade700; // 텍스트 색상

  void startTimer() {
    setState(() {
      isStarted = true;
      message = "천천히 타세요!";
      fontSize = 24.0; // 초기 크기
      fontColor = Colors.grey.shade700; // 초기 색상
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        totalTimeLeft--;
        currentPhaseTimeLeft--;

        if (currentPhaseTimeLeft <= 10) {
          // 남은 시간이 10초 이하일 때, 점점 빨간색으로 변하고 크기 커짐
          fontColor = Colors.red.shade700;
          fontSize = 24 + (40 - currentPhaseTimeLeft).toDouble(); // 크기 커짐
        } else {
          // 초기 상태로 돌아감
          fontColor = Colors.grey.shade700;
          fontSize = 24.0;
        }

        if (totalTimeLeft <= 0) {
          // 전체 시간이 끝나면 종료
          message = "";
          _timer?.cancel();
          startShutdownTimer();
        } else if (currentPhaseTimeLeft <= 0) {
          // 구간 전환
          message = message == "천천히 타세요!" ? "빨리 타세요!" : "천천히 타세요!";
          currentPhaseTimeLeft = message == "천천히 타세요!" ? 40 : 20;
          fontColor = Colors.grey.shade700; // 초기 색상
          fontSize = 24.0; // 초기 크기
        }
      });
    });
  }

  void startShutdownTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        shutdownTimer--;
      });

      if (shutdownTimer == 0) {
        timer.cancel();
        exit(0); // 앱 종료
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalTimeLeft / (3 * 60); // 진행 상황 계산

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 원형 프로그래스바
              if (totalTimeLeft > 0)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        color: Colors.grey.shade800,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Text(
                      '${totalTimeLeft ~/ 60}:${(totalTimeLeft % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 30),
              // 상태 메시지 애니메이션
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: fontColor,
                ),
                child: Text(message),
              ),
              SizedBox(height: 40),
              // 버튼
              if (!isStarted)
                OutlinedButton(
                  onPressed: startTimer,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade800, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              // 종료 카운트다운
              if (totalTimeLeft == 0)
                Text(
                  '$shutdownTimer 초 뒤 종료됩니다',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
