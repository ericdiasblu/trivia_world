import 'package:flutter/material.dart';
import 'package:trivia_world/screens/menu_screen.dart';
import '../widgets/gradient_text.dart';
import 'dart:math' as math;

class EnterScreen extends StatefulWidget {
  const EnterScreen({super.key});

  @override
  _EnterScreenState createState() => _EnterScreenState();
}

class _EnterScreenState extends State<EnterScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador para animação de pulso do texto
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Controlador para animação de rotação dos elementos decorativos
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Animação para o efeito de escala no título
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C156F), Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Elementos decorativos animados (símbolos de quiz)
              _buildAnimatedBackgroundElements(screenSize),

              // Conteúdo central
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo com efeito de brilho
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          );
                        },
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            Icons.lightbulb,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Título com efeito de gradiente melhorado
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: GradientText(
                        "TRIVIA WORLD",
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.shade100,
                            Colors.pink.shade100,
                            Colors.pinkAccent.shade100,
                          ],
                          stops: [0.1, 0.5, 0.9],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          // Você pode ajustar ou adicionar uma fonte customizada aqui:
                          // fontFamily: 'Montserrat',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(3, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),


                    SizedBox(height: 40),

                    // Botão para continuar com animação
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.5 + _pulseController.value * 0.5,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "TOQUE PARA INICIAR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 60),

                    // Texto de versão
                    Text(
                      "v1.0",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackgroundElements(Size screenSize) {
    // Lista de ícones relacionados a quiz
    final icons = [
      Icons.question_mark,
      Icons.lightbulb_outline,
      Icons.psychology,
      Icons.auto_awesome,
      Icons.school,
      Icons.emoji_objects,
    ];

    // Crie vários elementos flutuantes em posições aleatórias
    return Stack(
      children: List.generate(15, (index) {
        final random = math.Random();
        final posX = random.nextDouble() * screenSize.width;
        final posY = random.nextDouble() * screenSize.height;
        final iconIndex = random.nextInt(icons.length);
        final size = random.nextDouble() * 30 + 15;
        final opacity = random.nextDouble() * 0.3 + 0.1;
        final rotationSpeed = random.nextDouble() * 2 + 0.5;

        return Positioned(
          left: posX,
          top: posY,
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * math.pi * rotationSpeed,
                child: Icon(
                  icons[iconIndex],
                  size: size,
                  color: Colors.white.withOpacity(opacity),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}