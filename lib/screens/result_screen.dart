import 'package:flutter/material.dart';
import '../../models/question.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String tema;
  final VoidCallback onPlayAgain;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.tema,
    required this.onPlayAgain,
  }) : super(key: key);

  // Método para obter o apelido baseado na pontuação
  String getNickname(int score, int totalQuestions) {
    double percentage = score / totalQuestions;

    if (percentage >= 0.9) return "Gênio";
    if (percentage >= 0.7) return "Especialista";
    if (percentage >= 0.5) return "Conhecedor";
    if (percentage >= 0.3) return "Curioso";
    return "Aprendiz";
  }

  @override
  Widget build(BuildContext context) {
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
                      tema,
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
                      getNickname(score, totalQuestions),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF330066),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Você acertou $score de $totalQuestions perguntas!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF1493), // Rosa vibrante
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onPlayAgain,
                        child: Text(
                          'Jogar Novamente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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