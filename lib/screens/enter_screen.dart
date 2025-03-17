import 'package:flutter/material.dart';

import '../widgets/gradient_text.dart';

class EnterScreen extends StatelessWidget {
  const EnterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.pinkAccent,Colors.purple])
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
              Text("Toque para continuar",style: TextStyle(
                color: Colors.white,fontWeight: FontWeight.w400
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
