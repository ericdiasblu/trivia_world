import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trivia_world/screens/question_screen.dart';
import 'package:trivia_world/widgets/build_theme.dart';
import '../models/question.dart';
import '../widgets/gradient_text.dart';
import '../services/points_manager.dart';
import '../services/question_service.dart'; // Novo import para o serviço de perguntas

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int userPoints = 0;
  bool isLoading = true;
  final QuestionService _questionService = QuestionService(); // Nova instância do serviço
  Map<String, List<Question>> _questionsByCategory = {}; // Para armazenar as perguntas carregadas

  StreamSubscription? _pointsSubscription;

  @override
  void initState() {
    super.initState();
    _loadResources(); // Carrega pontos e perguntas

    // Inscreva-se para atualizações de pontos
    _pointsSubscription = PointsManager.pointsStream.listen((points) {
      if (mounted) {
        setState(() {
          userPoints = points;
        });
      }
    });

  }
  @override
  void dispose() {
    _pointsSubscription?.cancel();
    super.dispose();
  }

  // Método para carregar tanto os pontos quanto as perguntas
  Future<void> _loadResources() async {
    try {
      // Carrega os pontos
      final points = await PointsManager.getPoints();

      // Carrega as categorias e perguntas
      final questionsByCategory = await _questionService.loadAllQuestions();

      if (mounted) {
        setState(() {
          userPoints = points;
          _questionsByCategory = questionsByCategory;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar recursos: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9C156F), Colors.deepPurpleAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior com pontos
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Pontuação',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '$userPoints',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: GradientText(
                          'TEMAS',
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.pinkAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Grid de temas com perguntas carregadas do JSON
                      Expanded(
                        child: isLoading
                            ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: _buildThemeCards(),
                          ),
                        ),
                      ),
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

  Future<void> _updatePoints() async {
    try {
      final points = await PointsManager.getPoints();
      if (mounted) {
        setState(() {
          userPoints = points;
        });
      }
    } catch (e) {
      print('Erro ao atualizar pontos: $e');
    }
  }

  // Método para construir os cards de tema com base nas categorias carregadas
  List<Widget> _buildThemeCards() {
    Map<String, Map<String, dynamic>> themeAssets = {
      'geral': {
        'icon': 'assets/globe.png',
        'color': Color(0xFF4A90E2),
      },
      'história': {
        'icon': 'assets/history.png', // Adicione esta imagem aos seus assets
        'color': Color(0xFFE6526E),
      },
      'ciência': {
        'icon': 'assets/science.png', // Adicione esta imagem aos seus assets
        'color': Color(0xFF50C878),
      },
      'futebol': {
        'icon': 'assets/soccer.png',
        'color': Color(0xFFFF9933),
      },
      'filmes': {
        'icon': 'assets/movie.png',
        'color': Color(0xFF9966CC),
      },
    };

    // Se não houver categorias carregadas, mostre uma mensagem
    if (_questionsByCategory.isEmpty) {
      return [
        Center(
          child: Text(
            'Nenhum tema disponível',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        )
      ];
    }

    // Cria um card para cada categoria disponível
    List<Widget> themeCards = [];
    _questionsByCategory.forEach((category, questions) {
      // Usa o mapeamento padrão ou um fallback
      final themeData = themeAssets[category] ?? {
        'icon': 'assets/globe.png', // Ícone padrão
        'color': Color(0xFF4A90E2), // Cor padrão
      };

      themeCards.add(
        buildThemeCard(
          context,
          category[0].toUpperCase() + category.substring(1), // Primeira letra maiúscula
          themeData['icon'],
          themeData['color'],
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
                  questions: questions,
                  tema: category[0].toUpperCase() + category.substring(1),
                ),
              ),
            ).then((_) => _updatePoints());
          },
        ),
      );
    });

    return themeCards;
  }
}