import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PointsManager {
  static const String _pointsKey = 'user_points';

  // Stream controller para notificar mudanças de pontos
  static final _pointsController = StreamController<int>.broadcast();

  // Getter para acessar o stream
  static Stream<int> get pointsStream => _pointsController.stream;

  // Get current points
  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  // Add points and return new total
  static Future<int> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt(_pointsKey) ?? 0;
    final newTotal = currentPoints + points;
    await prefs.setInt(_pointsKey, newTotal);

    // Notificar ouvintes sobre a mudança de pontos
    _pointsController.add(newTotal);

    return newTotal;
  }

  // Calculate points based on score and difficulty
  static int calculatePoints(int score, int totalQuestions, String tema) {
    // Base points for each correct answer
    int basePoints = 10;

    // Multiplier based on topic difficulty (can be adjusted)
    double multiplier = 1.0;
    switch (tema.toLowerCase()) {
      case 'geral':
        multiplier = 1.0;
        break;
      case 'filmes':
        multiplier = 1.2;
        break;
      case 'futebol':
        multiplier = 1.1;
        break;
    // Add more topics with different multipliers
      default:
        multiplier = 1.0;
    }

    // Calculate total points
    int totalPoints = (score * basePoints * multiplier).round();

    // Bonus for perfect score (all questions correct)
    if (score == totalQuestions) {
      totalPoints += 20;
    }

    return totalPoints;
  }

  // Reset points (for testing)
  static Future<void> resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, 0);

    // Notificar ouvintes que os pontos foram resetados
    _pointsController.add(0);
  }

  // Dispose do controller quando o app for fechado
  static void dispose() {
    _pointsController.close();
  }
}