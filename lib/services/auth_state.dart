// auth_wrapper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; // Você precisará adicionar o provider ao pubspec.yaml
import 'package:trivia_world/screens/menu_screen.dart';
import 'package:trivia_world/screens/username_screen.dart';

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

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Configurar o GoogleSignIn para mostrar a caixa de seleção de conta
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      // Forçar a seleção de conta
      await googleSignIn.signOut(); // Logout primeiro para garantir a seleção de conta

      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Usuário cancelou o login
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        // Buscar dados do usuário no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Verificar se o usuário já existe e tem username
        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

          // Se o username já existir e não for vazio, não redireciona para UsernameScreen
          if (userData != null &&
              userData.containsKey('username') &&
              userData['username'] != null &&
              userData['username'].toString().trim().isNotEmpty) {
            // Já tem username, então pode ir direto para o MenuScreen
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
              return;
            }
          }
        }

        // Criar/atualizar documento do usuário se não tiver username
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': user.displayName ?? user.email?.split('@').first,
          'email': user.email,
          'points': 0, // Manter os pontos como estavam
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Carregar dados do usuário
        await refreshUserData();

        // Navegar para UsernameScreen para permitir edição do username
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UsernameScreen()),
          );
        }
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
      // Opcional: Mostrar uma mensagem de erro ao usuário
    }
  }


  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isLoggedIn) {
      return const MenuScreen();
    } else {
      return const LoginScreen();
    }
  }
}
