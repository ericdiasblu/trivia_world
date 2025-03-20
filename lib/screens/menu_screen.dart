import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trivia_world/screens/question_screen.dart';
import 'package:trivia_world/widgets/build_theme.dart';
import '../models/question.dart';
import '../widgets/gradient_text.dart';
import '../services/points_manager.dart';
import '../services/question_service.dart';
// Import the login screen
import '../screens/login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int userPoints = 0;
  bool isLoading = true;
  bool isLoggedIn = false; // Track login state
  String? username; // Store username when logged in
  final QuestionService _questionService = QuestionService();
  Map<String, List<Question>> _questionsByCategory = {};

  StreamSubscription? _pointsSubscription;

  @override
  void initState() {
    super.initState();
    _loadResources();
    _checkLoginStatus(); // Check if user is already logged in

    // Subscribe to points updates
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

  // Method to check login status
  Future<void> _checkLoginStatus() async {
    // You'll need to implement this based on your authentication method
    // Example using shared preferences:
    // final prefs = await SharedPreferences.getInstance();
    // final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    // final user = prefs.getString('username');

    // For now, just setting default values
    if (mounted) {
      setState(() {
        isLoggedIn = false;
        username = null;
      });
    }
  }

  // Method to load both points and question categories
  Future<void> _loadResources() async {
    try {
      // Load points
      final points = await PointsManager.getPoints();

      // Load categories and questions to display on screen
      final questionsByCategory = await _questionService.loadAllQuestions();

      if (mounted) {
        setState(() {
          userPoints = points;
          _questionsByCategory = questionsByCategory;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading resources: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of code unchanged
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
              // Top bar with points and login/profile button
              _buildTopBar(),

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

                      // Theme grid
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

  // New method to build the top bar with login button
  Widget _buildTopBar() {
    return Container(
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
          // Points section
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

          Row(
            children: [
              // Points display
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

              // Login/Profile button
              SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Navigate to login screen if not logged in
                  // or show profile options if logged in
                  if (!isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    ).then((_) {
                      // Refresh login status when returning from login screen
                      _checkLoginStatus();
                      _updatePoints();
                    });
                  } else {
                    // Show profile options (dialog or navigate to profile screen)
                    _showProfileOptions();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLoggedIn ? Colors.greenAccent.withOpacity(0.2) : Colors.purpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.login,
                    color: isLoggedIn ? Colors.greenAccent : Colors.purpleAccent,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to show profile options when logged in
  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF9C156F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Olá, ${username ?? "Usuário"}!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildProfileOption(Icons.person, 'Meu Perfil', () {
              Navigator.pop(context);
              // Navigate to profile screen
            }),
            _buildProfileOption(Icons.emoji_events, 'Minhas Conquistas', () {
              Navigator.pop(context);
              // Navigate to achievements screen
            }),
            _buildProfileOption(Icons.logout, 'Sair', () async {
              // Implement logout logic
              // Example:
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.setBool('isLoggedIn', false);
              // await prefs.remove('username');

              if (mounted) {
                setState(() {
                  isLoggedIn = false;
                  username = null;
                });
              }
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile option items
  Widget _buildProfileOption(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
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
      print('Error updating points: $e');
    }
  }

  // Method to build theme cards
  List<Widget> _buildThemeCards() {
    Map<String, Map<String, dynamic>> themeAssets = {
      'geral': {
        'icon': 'assets/globe.png',
        'color': Color(0xFF4A90E2),
      },
      'história': {
        'icon': 'assets/history.png',
        'color': Color(0xFFE6526E),
      },
      'ciência': {
        'icon': 'assets/science.png',
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
      'games': {
        'icon': 'assets/games.png',
        'color': Color(0xFF1A73E8),
      }
    };

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

    List<Widget> themeCards = [];
    _questionsByCategory.forEach((category, _) {
      final themeData = themeAssets[category] ?? {
        'icon': 'assets/globe.png',
        'color': Color(0xFF4A90E2),
      };

      themeCards.add(
        buildThemeCard(
          context,
          category[0].toUpperCase() + category.substring(1),
          themeData['icon'],
          themeData['color'],
              () async {

            try {
              // Load randomized questions for category
              final randomizedQuestions = await _questionService.loadQuestionsByCategory(category);

              // Verificar se o contexto ainda é válido
              if (!context.mounted) return;

              // Remove loading dialog
              Navigator.pop(context);

              // Navigate to quiz screen with randomized questions
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    questions: randomizedQuestions,
                    tema: category[0].toUpperCase() + category.substring(1),
                  ),
                ),
              ).then((_) => _updatePoints());
            } catch (e) {
              // Em caso de erro, garantir que o diálogo seja fechado
              if (context.mounted) {
                Navigator.pop(context);

                // Mostrar mensagem de erro
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao carregar perguntas: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              print('Erro ao carregar perguntas: $e');
            }
          },
        ),
      );
    });

    return themeCards;
  }
}