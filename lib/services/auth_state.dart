// auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; // Você precisará adicionar o provider ao pubspec.yaml
import 'package:trivia_world/screens/menu_screen.dart';

// Tela principal após login/registro
import '../screens/login_screen.dart';
import 'firebase_service.dart';
// Estado de autenticação para uso com Provider
class AuthState with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  AuthState() {
    _initAuth();
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  int get userPoints => _userData != null ? _userData!['points'] ?? 0 : 0;
  String get username => _userData != null ? _userData!['username'] ?? '' : '';

  void _initAuth() {
    _firebaseService.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        _userData = await _firebaseService.getCurrentUserData();
      } else {
        _userData = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshUserData() async {
    if (_user != null) {
      _userData = await _firebaseService.getCurrentUserData();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _firebaseService.loginUser(
      email: email,
      password: password,
    );

    if (result['success']) {
      await refreshUserData();
    }

    return result;
  }

  // video utilizado: https://www.youtube.com/watch?v=VCrXSFqdsoA
  // minuto 2:35
  Future <void> signInWithGoogle() async {

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user?.displayName);
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final result = await _firebaseService.registerUser(
      username: username,
      email: email,
      password: password,
    );

    if (result['success']) {
      await refreshUserData();
    }

    return result;
  }

  Future<void> logout() async {
    await _firebaseService.logoutUser();
    // authStateChanges vai atualizar o estado
  }

  Future<Map<String, dynamic>> addPoints(int points) async {
    final result = await _firebaseService.updateUserPoints(points);

    if (result['success']) {
      await refreshUserData();
    }

    return result;
  }
}

// Widget que decide qual tela mostrar com base no estado de autenticação
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isLoggedIn) {
      return const MenuScreen();
    } else {
      return const LoginScreen();
    }
  }
}