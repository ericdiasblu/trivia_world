// lib/screens/menu_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia_world/screens/question_screen.dart'; // Usado dentro da lógica de navegação
import 'package:trivia_world/screens/theme_selection_screen.dart'; // IMPORTADO
// import 'package:trivia_world/widgets/build_theme.dart'; // Removido, pois _buildThemeCards foi removido
import '../models/game_mode.dart'; // IMPORTADO
import '../models/question.dart';
import '../widgets/gradient_text.dart';
import '../services/points_manager.dart';
import '../services/question_service.dart';
import '../screens/login_screen.dart';
import 'leaderboard_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int userPoints = 0;
  bool isLoading = true;
  bool isLoggedIn = false;
  String? username;
  final QuestionService _questionService = QuestionService();
  Map<String, List<Question>> _questionsByCategory = {};

  StreamSubscription? _pointsSubscription;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Inicia isLoading como true aqui para garantir que o CircularProgressIndicator apareça
    // antes mesmo de _initialize começar, se houver algum delay.
    // _initialize também irá gerenciar o isLoading.
    // setState(() { isLoading = true; }); // Removido daqui, _initialize vai cuidar
    _initialize();

    _pointsSubscription = PointsManager.pointsStream.listen((points) {
      if (mounted) {
        setState(() {
          userPoints = points;
          // _getUser(); // Chamada redundante se _loadUserData já atualiza username.
          // Se precisar atualizar o username em tempo real com os pontos, mantenha.
        });
      }
    });
  }

  @override
  void dispose() {
    _pointsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (mounted) setState(() { isLoading = true; }); // Garante que isLoading é true no início
    await _checkLoginStatus();
    await _loadUserData();
    await _loadResources(); // Este deve ser o último a setar isLoading = false
  }

  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;
    // Não modifique isLoading aqui diretamente. Deixe _loadResources controlar o final.
    if (user != null) {
      try {
        final points = await PointsManager.getUserPoints();
        await _getUser(); // _getUser já faz setState para username

        if (mounted) {
          setState(() {
            isLoggedIn = true;
            userPoints = points;
          });
        }
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
      }
    } else {
      if (mounted) {
        setState(() {
          isLoggedIn = false;
          // Se não há usuário, e as perguntas ainda não foram carregadas,
          // isLoading deve permanecer true até _loadResources terminar.
        });
      }
    }
  }

  Future<String?> _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
        if (documentSnapshot.exists) {
          String? fetchedUsername = documentSnapshot.get('username');
          if (mounted) {
            setState(() {
              username = fetchedUsername ?? 'Usuario';
            });
          }
          return username;
        }
      } catch (e) {
        print('Erro ao obter usuário: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _loadResources() async {
    // Se _initialize não setou isLoading = true, garante aqui.
    if (!isLoading && mounted) setState(() { isLoading = true; });

    try {
      final questionsByCategory = await _questionService.loadAllQuestions();
      if (mounted) {
        setState(() {
          _questionsByCategory = questionsByCategory;
          isLoading = false; // *** Ponto principal onde isLoading vira false ***
        });
      }
    } catch (e) {
      print('Error loading resources: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // Também vira false em caso de erro
        });
      }
    }
  }

  Future<void> _updatePoints() async {
    try {
      final points = await PointsManager.getUserPoints();
      if (mounted) {
        setState(() {
          userPoints = points;
        });
      }
    } catch (e) {
      print('Error updating points: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar pontos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaderboardScreen()),
    );
  }

  // MÉTODO PARA CONSTRUIR CARDS DE MODO DE JOGO
  List<Widget> _buildGameModeCards() {
    if (availableGameModes.isEmpty) {
      return [
        Center(
          child: Text(
            'Nenhum modo de jogo disponível.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
          ),
        ),
      ];
    }

    return availableGameModes.map((mode) {
      return Card(
        elevation: 4,
        color: mode.color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            if (mode.type == GameModeType.classic) {
              // Não verificamos isLoading aqui, pois o build principal já faz isso.
              // Se chegamos aqui, isLoading é false.
              if (_questionsByCategory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nenhum tema encontrado para o modo clássico.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemeSelectionScreen(
                    questionsByCategory: _questionsByCategory,
                    onThemeSelected: (String category) async {
                      try {
                        final randomizedQuestions =
                        await _questionService.loadQuestionsByTheme(category);
                        if (!context.mounted) return;
                        if (randomizedQuestions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nenhuma pergunta para ${category[0].toUpperCase() + category.substring(1)}.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        // Guardar o navigator da ThemeSelectionScreen para poder dar pop nele
                        final themeScreenNavigator = Navigator.of(context);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              questions: randomizedQuestions,
                              tema: category[0].toUpperCase() + category.substring(1),
                            ),
                          ),
                        );
                        // Após o QuizScreen ser fechado (pop),
                        // o código aqui será executado.
                        themeScreenNavigator.pop(); // Fecha a ThemeSelectionScreen
                        _updatePoints();

                      } catch (e) {
                        if (context.mounted) {
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
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Modo "${mode.name}" ainda não implementado.')),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(mode.icon, size: 60, color: Colors.white),
              SizedBox(height: 10),
              Text(
                mode.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  _buildTopBar(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: GradientText(
                              // ***** ALTERAÇÃO PRINCIPAL AQUI *****
                              'MODOS DE JOGO', // Alterado de 'TEMAS'
                              // ***** FIM DA ALTERAÇÃO PRINCIPAL *****
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
                          Expanded(
                            child: isLoading // Verifica se os recursos (perguntas) ainda estão carregando
                                ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3, // Aumentado para melhor visibilidade
                              ),
                            )
                                : Padding( // Se não está carregando, mostra os cards de modo de jogo
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                // ***** ALTERAÇÃO PRINCIPAL AQUI *****
                                children: _buildGameModeCards(), // Alterado de _buildThemeCards()
                                // ***** FIM DA ALTERAÇÃO PRINCIPAL *****
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
          // Leaderboard Button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _navigateToLeaderboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Container(
                  width: 330, // Considere usar MediaQuery para largura responsiva
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Classificação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 24),
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
              isLoggedIn
                  ? Container(
                padding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Icon(Icons.star,
                        color: Colors.amber, size: 20),
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
              )
                  : SizedBox(),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  if (!isLoggedIn) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );

                    if (result == true) {
                      setState(() {
                        isLoading = true;
                      });
                      await _loadUserData();
                    }
                  } else {
                    _showProfileOptions();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLoggedIn
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.purpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.login,
                    color: isLoggedIn ? Colors.greenAccent : Colors.white,
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
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A11CB), // Deep Purple
                    Color(0xFF2575FC), // Bright Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Olá, $username!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildProfileOption(
              icon: Icons.person,
              text: 'Meu Perfil',
              color: Color(0xFF6A11CB),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildProfileOption(
              icon: Icons.emoji_events,
              text: 'Minhas Conquistas',
              color: Color(0xFF2575FC),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildProfileOption(
              icon: Icons.logout,
              text: 'Sair',
              color: Colors.red.shade400,
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  await PointsManager.resetPoints();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('username');

                  if (mounted) {
                    setState(() {
                      isLoggedIn = false;
                      username = null;
                      userPoints = 0;
                      isLoading = false;
                    });
                  }

                  if (context.mounted) Navigator.pop(context);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MenuScreen()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao fazer logout: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  print('Error during logout: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for profile options
  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}