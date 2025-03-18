import 'package:flutter/material.dart';
import 'package:trivia_world/widgets/build_theme.dart';

import '../widgets/gradient_text.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C156F), Colors.deepPurpleAccent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientText(
                'ESCOLHA O TEMA DO QUIZ',
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.red],
                  // Gradiente do branco ao vermelho
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30,),
              Row(children: [
                BuildTheme(image: AssetImage("assets/globe.png",), themeName: "Geral"),
                BuildTheme(image: AssetImage("assets/movie.png",), themeName: "Filmes"),
                BuildTheme(image: AssetImage("assets/soccer.png",), themeName: "Futebo"),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
