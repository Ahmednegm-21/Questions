import 'dart:async';
import 'package:flutter/material.dart';
import '../model/question_model.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_header.dart';
import '../widgets/next_button.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int selectedIndex = -1;
  bool answered = false;

  int timeLeft = 30;
  Timer? timer;

  final List<Question> questions = [
    Question(
      text: "What is the most popular sport throughout the world?",
      options: ["Volleyball", "Football", "Basketball", "Badminton"],
      correctIndex: 1,
    ),
    Question(
      text: "Which country has won the most FIFA World Cup titles in men's football?",
      options: ["Argentina", "Brazil", "Germany", "Italy"],
      correctIndex: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();

        // if time over and not have answer
        if (!answered) {
          setState(() {
            answered = true;
            selectedIndex = questions[currentIndex].correctIndex;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                " Time over ! ",
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          Future.delayed(const Duration(seconds: 3), () {
            goToNextQuestion();
          });
        } else {
          goToNextQuestion();
        }
      }
    });
  }

  void goToNextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = -1;
        answered = false;
      });
      startTimer();
    } else {
      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question currentQ = questions[currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QuestionHeader(
                current: currentIndex + 1,
                total: questions.length,
                timeLeft: timeLeft,
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 100, 63, 163),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentQ.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: currentQ.options.length,
                  itemBuilder: (context, index) {
                    bool isCorrect = answered && index == currentQ.correctIndex;
                    bool isWrong = answered &&
                        index == selectedIndex &&
                        selectedIndex != currentQ.correctIndex;
                    return OptionTile(
                      text: currentQ.options[index],
                      isCorrect: isCorrect,
                      isWrong: isWrong,
                      onTap: () {
                        if (!answered) {
                          setState(() {
                            selectedIndex = index;
                            answered = true;
                          });
                        }
                      },
                    );
                  },
                ),
              ),

                  NextButton(
                    isLast: currentIndex == questions.length - 1,
                      onPressed: () {
                        if (currentIndex == questions.length - 1) {
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const ResultPage()), // زميلك يعمل ResultPage
                              // );
                        } else {
                          goToNextQuestion();
                        }
            },
            ),
            ],
          ),
        ),
      ),
    );
  }
}
