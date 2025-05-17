// lib/screens/theme_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:trivia_world/models/question.dart';
import 'package:trivia_world/screens/question_screen.dart';
import 'package:trivia_world/services/question_service.dart';
import 'package:trivia_world/widgets/build_theme.dart'; // Seu widget de card de tema
import 'package:trivia_world/widgets/gradient_text.dart';

class ThemeSelectionScreen extends StatefulWidget {
  // Passaremos as perguntas já carregadas para evitar recarregar desnecessariamente
  final Map<String, List<Question>> questionsByCategory;
  final Function onThemeSelected; // Callback para quando um tema é selecionado

  const ThemeSelectionScreen({
    Key? key,
    required this.questionsByCategory,
    required this.onThemeSelected,
  }) : super(key: key);

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  final QuestionService _questionService = QuestionService();

  // Assets para os temas, como você tinha na MenuScreen
  final Map<String, Map<String, dynamic>> themeAssets = {
    'geral': {'icon': 'assets/globe.png', 'color': Color(0xFF4A90E2)},
    'história': {'icon': 'assets/history.png', 'color': Color(0xFFE6526E)},
    'ciência': {'icon': 'assets/science.png', 'color': Color(0xFF50C878)},
    'futebol': {'icon': 'assets/soccer.png', 'color': Color(0xFFFF9933)},
    'filmes': {'icon': 'assets/movie.png', 'color': Color(0xFF9966CC)},
    'games': {'icon': 'assets/games.png', 'color': Color(0xFF1A73E8)},
  };

  List<Widget> _buildThemeCardsForSelection() {
    if (widget.questionsByCategory.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_outlined, color: Colors.white70, size: 48),
                SizedBox(height: 16),
                Text(
                  'Nenhum tema disponível no momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    List<Widget> themeCards = [];
    widget.questionsByCategory.forEach((category, questions) {
      if (questions.isNotEmpty) {
        final themeData = themeAssets[category] ??
            {'icon': 'assets/globe.png', 'color': Color(0xFF4A90E2)};

        themeCards.add(
          buildThemeCard( // Reutilizando seu widget buildThemeCard
            context,
            category[0].toUpperCase() + category.substring(1),
            themeData['icon'],
            themeData['color'],
                () async {
              widget.onThemeSelected(category);
            },
          ),
        );
      }
    });

    if (themeCards.isEmpty && widget.questionsByCategory.isNotEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list_off_outlined, color: Colors.white70, size: 48),
                SizedBox(height: 16),
                Text(
                  'Nenhuma pergunta encontrada para os temas disponíveis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return themeCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha um Tema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Cor do ícone de voltar
      ),
      extendBodyBehindAppBar: true, // Para o gradiente ir por baixo da AppBar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Use o mesmo gradiente ou um similar ao da MenuScreen
            colors: [Color(0xFF9C156F), Colors.deepPurpleAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight + 20), // Espaço para a AppBar transparente
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.questionsByCategory.isEmpty && themeAssets.isEmpty
                      ? Center( // Se não há categorias carregadas E não há assets (improvável)
                    child: Text(
                      'Carregando temas...', // Ou um CircularProgressIndicator
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: _buildThemeCardsForSelection(),
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