import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/points_manager.dart';
import 'dart:math' as math;

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

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _scoreAnimation = Tween<double>(
        begin: 0.0,
        end: widget.score / widget.totalQuestions
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _loadPoints();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    // Calculate points earned in this quiz
    earnedPoints = PointsManager.calculatePoints(
      widget.score,
      widget.totalQuestions,
      widget.tema,
    );

    // Add points to the total
    totalPoints = await PointsManager.addPoints(earnedPoints);

    if (mounted) {
      setState(() {
        isLoading = false;
        _animationController.forward();
      });
    }
  }

  // Método para obter o apelido baseado na pontuação
  String getNickname(int score, int totalQuestions) {
    double percentage = score / totalQuestions;

    if (percentage >= 0.9) return "Gênio";
    if (percentage >= 0.7) return "Especialista";
    if (percentage >= 0.5) return "Conhecedor";
    if (percentage >= 0.3) return "Curioso";
    return "Aprendiz";
  }

  // Método para obter a cor do resultado com base na porcentagem
  Color getScoreColor(double percentage) {
    if (percentage >= 0.9) return Color(0xFF00C853); // Verde para excelente
    if (percentage >= 0.7) return Color(0xFF64DD17); // Verde-limão para muito bom
    if (percentage >= 0.5) return Color(0xFFFFD600); // Amarelo para médio
    if (percentage >= 0.3) return Color(0xFFFF9100); // Laranja para regular
    return Color(0xFFFF3D00); // Vermelho para ruim
  }

  // Método para obter ícone baseado na pontuação
  IconData getResultIcon(double percentage) {
    if (percentage >= 0.9) return Icons.emoji_events;
    if (percentage >= 0.7) return Icons.star;
    if (percentage >= 0.5) return Icons.thumb_up;
    if (percentage >= 0.3) return Icons.sentiment_satisfied;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.score / widget.totalQuestions;
    final scoreColor = getScoreColor(percentage);
    final resultIcon = getResultIcon(percentage);

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
          child: isLoading
              ? Center(
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
              // Fundo com partículas decorativas
              ...List.generate(12, (index) {
                final random = math.Random();
                final top = random.nextDouble() * MediaQuery.of(context).size.height;
                final left = random.nextDouble() * MediaQuery.of(context).size.width;
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
                          Color(0xFFA4045F),
                          Color(0xFF330066),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),

                      // Logo e nome do tema
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Trivia World',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Color(0xFFA4045F).withOpacity(0.7),
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.tema,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Gráfico circular de progresso
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Círculo de fundo
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 10,
                                    ),
                                  ),
                                ),

                                // Progresso circular
                                CustomPaint(
                                  size: Size(200, 200),
                                  painter: CircleProgressPainter(
                                    progress: _scoreAnimation.value,
                                    color: scoreColor,
                                    strokeWidth: 10,
                                  ),
                                ),

                                // Container central com o resultado
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFA4045F).withOpacity(0.3),
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
                                        size: 40,
                                        color: scoreColor,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${(percentage * 100).toInt()}%",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF330066),
                                        ),
                                      ),
                                      Text(
                                        "${widget.score}/${widget.totalQuestions}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF330066).withOpacity(0.8),
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

                      SizedBox(height: 24),

                      // Apelido do resultado
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: scoreColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            getNickname(widget.score, widget.totalQuestions),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Card de pontos ganhos
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
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
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "$earnedPoints",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      " pontos!",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Total: $totalPoints pontos",
                                        style: TextStyle(
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

                      SizedBox(height: 40),

                      // Botões de ação
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.replay,color: Colors.white,),
                                label: Text('Jogar Novamente'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF1493),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Color(0xFFFF1493).withOpacity(0.5),
                                ),
                                onPressed: widget.onPlayAgain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.home,color: Colors.white,),
                                label: Text('Voltar ao Menu'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFA4045F),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Color(0xFFA4045F).withOpacity(0.5),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter personalizado para desenhar o círculo de progresso
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Desenha o arco de progresso
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,  // Começa do topo
      2 * math.pi * progress,  // Progresso completo
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}