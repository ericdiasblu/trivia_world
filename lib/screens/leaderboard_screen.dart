import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback

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
  late AnimationController _listController; // Para animação da lista

  final ScrollController _scrollController = ScrollController(); // Para efeitos de parallax/fade

  @override
  void initState() {
    super.initState();
    _fetchTopPlayers();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800), // Um pouco mais rápido
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic, // Curva mais suave
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Iniciar animações após um pequeno delay para garantir que a busca de dados comece
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _headerController.forward();
      }
    });
  }

  Future<void> _fetchTopPlayers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50) // Mantém o limite de 50
          .get();

      if (mounted) {
        setState(() {
          _topPlayers = querySnapshot.docs.map((doc) {
            return {
              'username': doc['username'] ?? 'Usuário Anônimo', // Nome mais descritivo
              'points': doc['points'] ?? 0,
              // Poderia adicionar 'avatarUrl': doc['avatarUrl'] se tivesse
            };
          }).toList();
          _isLoading = false;
        });
        // Iniciar animação da lista após os dados serem carregados
        _listController.forward();
      }
    } catch (e) {
      print('Erro ao buscar classificação: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar classificação.'),
            backgroundColor: Colors.red.shade700, // Cor de erro mais forte
            behavior: SnackBarBehavior.floating, // Para um look mais moderno
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPodiumItem(Map<String, dynamic> player, int rank, IconData icon, Color color) {
    // Widget para os 3 primeiros, um pouco mais destacado
    return FadeTransition(
      opacity: _headerAnimation, // Usa a mesma animação do header para sincronia
      child: ScaleTransition(
        scale: _headerAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 10, top: rank == 1 ? 0 : 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15 + (0.05 * (3-rank))), // Mais opaco para os primeiros
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: rank == 1 ? 40 : 30),
              SizedBox(height: 8),
              Text(
                player['username'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: rank == 1 ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${player['points']} pts',
                style: TextStyle(
                  color: color,
                  fontSize: rank == 1 ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Para um gradiente mais sutil e "premium"
    final List<Color> gradientColors = [
      Color(0xFF231539), // Roxo escuro profundo
      Color(0xFF4A148C), // Roxo mais vibrante
      Color(0xFF7B1FA2), // Roxo médio
    ];

    return Scaffold(
      backgroundColor: gradientColors[0], // Cor de fundo base
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0], // Controla a transição do gradiente
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho Animado e Modernizado
              ScaleTransition( // Adiciona um leve scale na entrada
                scale: _headerAnimation,
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
                    child: Row( // Para adicionar um botão de voltar
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 22),
                            onPressed: () {
                              HapticFeedback.lightImpact(); // Feedback tátil sutil
                              Navigator.of(context).pop();
                            }
                        ),
                        Text(
                          'HALL DA FAMA', // Nome mais chamativo
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24, // Um pouco menor para mais elegância
                            fontWeight: FontWeight.w900, // Mais peso
                            letterSpacing: 2, // Mais espaçamento
                            shadows: [
                              Shadow(blurRadius: 15, color: Colors.black.withOpacity(0.5), offset: Offset(0, 3)),
                            ],
                          ),
                        ),
                        SizedBox(width: 40), // Espaço para centralizar o título
                      ],
                    ),
                  ),
                ),
              ),

              // Destaque para os Top 3 (Pódio)
              if (!_isLoading && _topPlayers.length >= 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end, // Alinha na base para efeito pódio
                    children: [
                      Expanded(flex:3, child: _buildPodiumItem(_topPlayers[1], 2, Icons.military_tech_outlined, Color(0xFFC0C0C0))), // Prata
                      SizedBox(width: 10),
                      Expanded(flex:4, child: _buildPodiumItem(_topPlayers[0], 1, Icons.emoji_events, Color(0xFFFFD700))), // Ouro
                      SizedBox(width: 10),
                      Expanded(flex:3, child: _buildPodiumItem(_topPlayers[2], 3, Icons.workspace_premium_outlined, Color(0xFFCD7F32))), // Bronze
                    ],
                  ),
                ),

              // Divisor sutil
              if (!_isLoading && _topPlayers.length > 3)
                FadeTransition(
                  opacity: _listController, // Anima com a lista
                  child: Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),

              // Conteúdo da Leaderboard
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white.withOpacity(0.7)))
                    : _topPlayers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.white.withOpacity(0.5)),
                      SizedBox(height: 16),
                      Text(
                        'O Hall da Fama aguarda heróis!',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: _topPlayers.length > 3 ? 0 : 20, bottom: 20), // Espaçamento
                  // Começa a lista do 4º jogador se houver pódio
                  itemCount: _topPlayers.length - (_topPlayers.length >=3 ? 3 : 0),
                  itemBuilder: (context, index) {
                    final playerIndex = index + (_topPlayers.length >=3 ? 3 : 0);
                    final player = _topPlayers[playerIndex];
                    return _buildAnimatedListItem(player, playerIndex, _listController);
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
  Widget _buildAnimatedListItem(Map<String, dynamic> player, int index, AnimationController animController) {
    // Animação individual para cada item da lista
    final itemAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animController,
        // Efeito cascata na animação da lista
        curve: Interval(
          (0.2 * (index / _topPlayers.length)).clamp(0.0, 1.0), // Início escalonado
          (0.5 + (0.2 * (index / _topPlayers.length))).clamp(0.0, 1.0), // Fim escalonado
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: itemAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - itemAnimation.value)), // Efeito de "subir"
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7), // Margens ajustadas
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding interno
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08), // Mais sutil
          borderRadius: BorderRadius.circular(18), // Bordas mais suaves
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Row( // Usar Row para mais controle
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient( // Gradiente sutil no número
                  colors: [
                    _getLeaderboardColor(index).withOpacity(0.7),
                    _getLeaderboardColor(index).withOpacity(0.4)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                player['username'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 17, // Ajuste de tamanho
                ),
                overflow: TextOverflow.ellipsis, // Evita quebra de linha feia
              ),
            ),
            SizedBox(width: 10),
            Row( // Para ícone de ponto
              children: [
                Icon(Icons.star_border_purple500_outlined, color: Color(0xFFFFD700).withOpacity(0.8), size: 18),
                SizedBox(width: 5),
                Text(
                  '${player['points']}', // Apenas o número, "pts" implícito
                  style: TextStyle(
                    color: Color(0xFFFFD700).withOpacity(0.9), // Amarelo mais vibrante
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para definir cores diferenciadas
  Color _getLeaderboardColor(int index) {
    // Cores mais "cyber" ou "gamer"
    if (index == 0) return Color(0xFFFFD700); // Ouro
    if (index == 1) return Color(0xFFC0C0C0); // Prata
    if (index == 2) return Color(0xFFCD7F32); // Bronze

    // Cores para o restante da lista, podem variar ou ser uma cor base
    // Uma paleta de roxos/azuis pode funcionar bem com o gradiente de fundo
    List<Color> palette = [
      Colors.purple.shade300,
      Colors.indigo.shade300,
      Colors.blue.shade300,
    ];
    return palette[index % palette.length].withOpacity(0.8); // Adiciona opacidade
  }
}