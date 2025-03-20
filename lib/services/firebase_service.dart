// firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar um novo usuário
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {

      // Criar usuário com email e senha
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Importante: espere um momento para garantir que o token de autenticação esteja disponível
      await Future.delayed(const Duration(milliseconds: 500));

      await userCredential.user?.getIdToken(true);

      // Verificar se o username já existe
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Nome de usuário já está em uso.'
        };
      }

      // Criar documento do usuário no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este email já está em uso.';
          break;
        case 'weak-password':
          message = 'A senha é muito fraca.';
          break;
        case 'invalid-email':
          message = 'Email inválido.';
          break;
        default:
          message = 'Ocorreu um erro: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ocorreu um erro: $e',
      };
    }
  }

  // Método para fazer login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'invalid-email':
          message = 'Email inválido.';
          break;
        case 'user-disabled':
          message = 'Este usuário está desativado.';
          break;
        default:
          message = 'Ocorreu um erro: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ocorreu um erro: $e',
      };
    }
  }

  // Método para fazer logout
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Método para obter usuário atual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Método para obter os dados do usuário atual
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = user.uid;
      return data;
    }

    return null;
  }

  // Método para adicionar pontos ao usuário após completar um quiz
  Future<Map<String, dynamic>> updateUserPoints(int pointsToAdd) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return {
        'success': false,
        'message': 'Usuário não autenticado.',
      };
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(pointsToAdd),
      });

      return {
        'success': true,
        'message': 'Pontos atualizados com sucesso!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao atualizar pontos: $e',
      };
    }
  }

  // Método para verificar o estado da autenticação (stream)
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}