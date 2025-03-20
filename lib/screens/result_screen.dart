import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/points_manager.dart';
import '../../services/question_service.dart';
import 'dart:math' as math;

import '../widgets/circle_progress_painter.dart';
import '../widgets/viral_button.dart';

class ResultScreen extends StatefulWidget {
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

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  int earnedPoints = 0;
  int totalPoints = 0;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  final QuestionService _questionService = QuestionService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / widget.totalQuestions,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _loadPoints();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    earnedPoints = PointsManager.calculatePoints(
      widget.score,
      widget.totalQuestions,
      widget.tema,
    );

    totalPoints = await PointsManager.addPoints(earnedPoints);

    if (mounted) {
      setState(() {
        isLoading = false;
        _animationController.forward();
      });
    }
  }

  String getNickname(int score, int totalQuestions) {
    double percentage = score / totalQuestions;
    if (percentage >= 0.9) return "Gênio";
    if (percentage >= 0.7) return "Especialista";
    if (percentage >= 0.5) return "Conhecedor";
    if (percentage >= 0.3) return "Curioso";
    return "Aprendiz";
  }

  Color getScoreColor(double percentage) {
    if (percentage >= 0.9) return const Color(0xFF00C853);
    if (percentage >= 0.7) return const Color(0xFF64DD17);
    if (percentage >= 0.5) return const Color(0xFFFFD600);
    if (percentage >= 0.3) return const Color(0xFFFF9100);
    return const Color(0xFFFF3D00);
  }

  IconData getResultIcon(double percentage) {
    if (percentage >= 0.9) return Icons.emoji_events;
    if (percentage >= 0.7) return Icons.star;
    if (percentage >= 0.5) return Icons.thumb_up;
    if (percentage >= 0.3) return Icons.sentiment_satisfied;
    return Icons.school;
  }

  Future<void> _playAgainWithRandomQuestions() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );

    try {
      final String categoryName = widget.tema.toLowerCase();
      List<Question> newQuestions = await _questionService.loadQuestionsByCategory(categoryName);
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onPlayAgain();
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar novas questões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.score / widget.totalQuestions;
    final scoreColor = getScoreColor(percentage);
    final resultIcon = getResultIcon(percentage);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final circleSize = isSmallScreen
        ? screenSize.width * 0.45
        : math.min(screenSize.width * 0.5, 200.0);
    final innerCircleSize = circleSize * 0.75;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
          child: isLoading
              ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFA4045F),
                  strokeWidth: 5,
                ),
                SizedBox(height: 24),
                Text(
                  "Calculando pontuação...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : Stack(
            children: [
              ...List.generate(12, (index) {
                final random = math.Random();
                final top = random.nextDouble() * screenSize.height;
                final left = random.nextDouble() * screenSize.width;
                final size = random.nextDouble() * 15 + 5;
                return Positioned(
                  top: top,
                  left: left,
                  child: Opacity(
                    opacity: 0.2 + random.nextDouble() * 0.3,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: [
                          const Color(0xFFA4045F),
                          const Color(0xFF330066),
                          Colors.white,
                        ][random.nextInt(3)],
                        borderRadius: BorderRadius.circular(size),
                      ),
                    ),
                  ),
                );
              }),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA4045F).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Trivia World',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 26 : 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: const Color(0xFFA4045F).withOpacity(0.7),
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.tema,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Container(
                              width: circleSize,
                              height: circleSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: circleSize,
                                    height: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.1),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: circleSize * 0.05,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomPaint(
                                    size: Size(circleSize, circleSize),
                                    painter: CircleProgressPainter(
                                      progress: _scoreAnimation.value,
                                      color: scoreColor,
                                      strokeWidth: circleSize * 0.05,
                                    ),
                                  ),
                                  Container(
                                    width: innerCircleSize,
                                    height: innerCircleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFA4045F).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          resultIcon,
                                          size: isSmallScreen ? 30 : 40,
                                          color: scoreColor,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${(percentage * 100).toInt()}%",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 24 : 32,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF330066),
                                          ),
                                        ),
                                        Text(
                                          "${widget.score}/${widget.totalQuestions}",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 14 : 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF330066).withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        FadeTransition(
                          opacity: _opacityAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: scoreColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scoreColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              getNickname(widget.score, widget.totalQuestions),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        FadeTransition(
                          opacity: _opacityAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFA4045F),
                                  Color(0xFFFF1493),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFA4045F).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_circle,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "$earnedPoints",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 28 : 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        " pontos!",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 20 : 24,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Total: $totalPoints pontos",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        // Botões com o novo design viral
                        FadeTransition(
                          opacity: _opacityAnimation,
                          child: Column(
                            children: [
                              ViralButton(
                                icon: Icons.replay,
                                label: 'Jogar Novamente',
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF81890), Color(0xFF000066),],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onPressed: _playAgainWithRandomQuestions,
                              ),
                              const SizedBox(height: 16),
                              ViralButton(
                                icon: Icons.home,
                                label: 'Voltar ao Menu',
                                gradient: const LinearGradient(
                                  colors: [Colors.red,Color(0xFFFF1493), Color(0xFFA4045F)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/home');
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
