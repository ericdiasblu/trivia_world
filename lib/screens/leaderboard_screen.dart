import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _topPlayers = [];
  bool _isLoading = true;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _fetchTopPlayers();

    // Animação para o header
    _headerController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
  }

  Future<void> _fetchTopPlayers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50)
          .get();

      setState(() {
        _topPlayers = querySnapshot.docs.map((doc) {
          return {
            'username': doc['username'] ?? 'Usuário',
            'points': doc['points'] ?? 0,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar classificação: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar classificação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho animado
              FadeTransition(
                opacity: _headerAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'CLASSIFICAÇÃO TOP 50',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Conteúdo da leaderboard
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : _topPlayers.isEmpty
                    ? Center(
                  child: Text(
                    'Nenhum jogador encontrado',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _topPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _topPlayers[index];
                    return _buildAnimatedListItem(player, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir cada item com animação
  Widget _buildAnimatedListItem(Map<String, dynamic> player, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 30)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getLeaderboardColor(index),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          title: Text(
            player['username'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          trailing: Text(
            '${player['points']} pts',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Método auxiliar para definir cores diferenciadas para as primeiras posições
  Color _getLeaderboardColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.blueGrey;
      case 2:
        return Colors.brown;
      default:
        return Colors.deepPurple;
    }
  }
}
