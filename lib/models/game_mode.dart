// lib/models/game_mode.dart
import 'package:flutter/material.dart';

enum GameModeType {
  classic,
  // Adicione outros tipos de modo aqui no futuro, ex: timeAttack, survival
}

class GameMode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final GameModeType type;

  GameMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
  });
}

// Lista de modos de jogo disponíveis
// No futuro, isso poderia vir de uma configuração remota ou ser mais dinâmico
List<GameMode> availableGameModes = [
  GameMode(
    id: 'classic',
    name: 'Clássico',
    description: 'Responda perguntas por tema no seu ritmo.',
    icon: Icons.style_outlined, // Ou outro ícone que represente clássico
    color: Color(0xFF4CAF50),   // Exemplo de cor
    type: GameModeType.classic,
  ),
  // Exemplo de como você adicionaria outro modo no futuro:
  /*
  GameMode(
    id: 'time_attack',
    name: 'Contra o Tempo',
    description: 'Acerte o máximo em tempo limitado!',
    icon: Icons.timer_outlined,
    color: Color(0xFFF44336),
    type: GameModeType.timeAttack,
  ),
  */
];