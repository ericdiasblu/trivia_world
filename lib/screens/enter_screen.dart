import 'package:flutter/material.dart';
import '../widgets/gradient_text.dart';

class EnterScreen extends StatefulWidget {
  const EnterScreen({super.key});

  @override
  _EnterScreenState createState() => _EnterScreenState();
}

class _EnterScreenState extends State<EnterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duração de cada ciclo de piscar
    )..repeat(reverse: true); // Repetir a animação em reverso
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpa o controlador ao descartar o widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.pink,Colors.deepPurpleAccent]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                GradientText(
                  'TRIVIA WORLD',
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.red], // Gradiente do branco ao vermelho
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              FadeTransition(
                opacity: _controller,
                child: Text(
                  "Toque para continuar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
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
