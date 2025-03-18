import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/question.dart';
import '../result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String tema;

  const QuizScreen({
    Key? key,
    required this.questions,
    required this.tema,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  int selectedAnswerIndex = -1;

  void checkAnswer(int index) {
    setState(() {
      answered = true;
      selectedAnswerIndex = index;
      if (index == widget.questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
    });

    // Espera 1.5 segundos antes de avançar para a próxima pergunta
    Timer(Duration(milliseconds: 1500), () {
      if (mounted) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex >= widget.questions.length - 1) {
      // Se for a última pergunta, mostrar a tela de resultados
      showResultScreen();
    } else {
      setState(() {
        answered = false;
        selectedAnswerIndex = -1;
        currentQuestionIndex++;
      });
    }
  }

  void showResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: widget.questions.length,
          tema: widget.tema,
          onPlayAgain: () {
            // Reinicia o quiz
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
                  questions: widget.questions,
                  tema: widget.tema,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Nenhuma pergunta disponível.')),
      );
    }

    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF000066),
              Color(0xFF990099),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Trivia World',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFA4045F),
                      ),
                    ),
                    Text(
                      widget.tema,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF330066),
                      ),
                    ),
                    Divider(
                      color: Color(0xFFA4045F),
                      thickness: 2.0,
                      height: 32.0,
                    ),
                    Text(
                      "${currentQuestionIndex + 1}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        question.questionText,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24),
                    ...List.generate(question.answers.length, (index) {
                      final answerText = question.answers[index];

                      // Define a cor do botão baseado na resposta
                      Color buttonColor;
                      Color textColor = Colors.black87;

                      if (answered) {
                        if (index == question.correctAnswerIndex) {
                          // Resposta correta
                          buttonColor = Colors.green;
                          textColor = Colors.white;
                        } else {
                          // Resposta incorreta
                          buttonColor = Colors.red;
                          textColor = Colors.white;
                        }
                      } else {
                        buttonColor = Colors.white;
                      }

                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: buttonColor,
                            foregroundColor: textColor,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: answered ? () {} : () {
                            checkAnswer(index);
                          },
                          child: Text(
                            answerText,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA4045F),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Voltar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}