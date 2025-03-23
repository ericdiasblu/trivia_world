import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsManager {
  static const String _pointsKey = 'user_points';
  static int _points = 0;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controller to notify point changes
  static final StreamController<int> _pointsController = StreamController<int>.broadcast();

  // Getter to access the stream
  static Stream<int> get pointsStream => _pointsController.stream;

  // Get current points
  static Future<int> getUserPoints() async {
    // Get the current authenticated user
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Try to get points from Firestore for logged-in user
        DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(user.uid).get();

        if (documentSnapshot.exists) {
          _points = documentSnapshot.get('points') ?? 0;
          _pointsController.add(_points);
          return _points;
        } else {
          print("User document not found!");
          _points = 0;
          _pointsController.add(_points);
          return 0;
        }
      } catch (e) {
        print("Error fetching points: $e");
        _points = 0;
        _pointsController.add(_points);
        return 0;
      }
    } else {
      // If not logged in, use 0 as default
      print("User not authenticated!");
      _points = 0;
      _pointsController.add(_points);
      return 0;
    }
  }

  // Add points and return new total
  static Future<int> addPoints(int points) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Get current points from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        int currentPoints = 0;

        if (doc.exists) {
          currentPoints = doc.get('points') ?? 0;
        }

        // Calculate new total
        int newTotal = currentPoints + points;

        // Update points in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'points': newTotal
        });

        // Update local points variable and notify listeners
        _points = newTotal;
        _pointsController.add(newTotal);

        return newTotal;
      } catch (e) {
        print("Error adding points: $e");
        return _points;
      }
    } else {
      // If not logged in, don't add points
      print("Cannot add points - user not logged in");
      return 0;
    }
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

  // Reset points (for logout or testing)
  static Future<void> resetPoints() async {
    _points = 0;
    _pointsController.add(0);

    // No need to save to shared preferences since we're using Firebase
    // Instead, we should consider clearing any local caches if needed
  }

  // Dispose of controller when the app is closed
  static void dispose() {
    _pointsController.close();
  }
}