import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart'; // Certifique-se que o model Question espera os tipos corretos

class QuestionService {
  static Map<String, List<Question>>? _allQuestionsCache;
  static List<Question>? _currentQuestions;

  Future<Map<String, List<Question>>> loadAllQuestions({int limitPerCategory = 10}) async {
    try {
      // Não recarregar se o cache já estiver populado e não vazio.
      // Se precisar de recarga forçada, adicione um parâmetro para isso.
      if (_allQuestionsCache != null && _allQuestionsCache!.isNotEmpty) {
        developer.log('Usando cache para todas as perguntas.');
        // Retorna uma cópia randomizada e limitada do cache
        return _getRandomizedAndLimitedQuestionsFromCache(limitPerCategory);
      }

      developer.log('Carregando todas as perguntas do Firestore...');
      _allQuestionsCache = {};

      final themesSnapshot = await FirebaseFirestore.instance.collection('questions').get();

      if (themesSnapshot.docs.isEmpty) {
        developer.log('Nenhum tema encontrado na coleção "questions".');
      }

      for (var themeDoc in themesSnapshot.docs) {
        String themeName = themeDoc.id.toLowerCase();
        developer.log('Carregando tema: $themeName (ID original: ${themeDoc.id})');

        final questionsSnapshot = await FirebaseFirestore.instance
            .collection('questions')
            .doc(themeDoc.id) // Use o ID original do documento do tema
            .collection('perguntas')
            .get();

        List<Question> questions = [];

        if (questionsSnapshot.docs.isEmpty) {
          developer.log('Nenhuma pergunta encontrada na subcoleção "perguntas" do tema: $themeName');
        }

        for (var questionDoc in questionsSnapshot.docs) {
          final data = questionDoc.data();

          // Adicionar log para ver os dados brutos de cada pergunta
          // developer.log('Dados brutos para pergunta ${questionDoc.id} no tema $themeName: $data');

          try {
            bool hasQuestionText = data.containsKey('questionText');
            bool hasAnswers = data.containsKey('answers');
            bool hasCorrectAnswerIndex = data.containsKey('correctAnswerIndex');

            if (hasQuestionText && hasAnswers && hasCorrectAnswerIndex) {
              // Validação adicional de tipo (opcional, mas bom para depuração)
              if (data['questionText'] is! String) {
                developer.log('Campo "questionText" não é String para ${questionDoc.id} no tema $themeName. Tipo: ${data['questionText'].runtimeType}');
                continue; // Pula esta pergunta
              }
              if (data['answers'] is! List || !(data['answers'] as List).every((item) => item is String)) {
                developer.log('Campo "answers" não é List<String> para ${questionDoc.id} no tema $themeName. Tipo: ${data['answers'].runtimeType}');
                continue; // Pula esta pergunta
              }
              if (data['correctAnswerIndex'] is! int) {
                developer.log('Campo "correctAnswerIndex" não é int para ${questionDoc.id} no tema $themeName. Tipo: ${data['correctAnswerIndex'].runtimeType}');
                // Tentar conversão se for double, por exemplo
                if (data['correctAnswerIndex'] is double) {
                  data['correctAnswerIndex'] = (data['correctAnswerIndex'] as double).toInt();
                } else {
                  continue; // Pula esta pergunta
                }
              }

              questions.add(Question(
                questionText: data['questionText'],
                answers: List<String>.from(data['answers']),
                correctAnswerIndex: data['correctAnswerIndex'],
              ));
            } else {
              String missingKeys = "";
              if (!hasQuestionText) missingKeys += "questionText ";
              if (!hasAnswers) missingKeys += "answers ";
              if (!hasCorrectAnswerIndex) missingKeys += "correctAnswerIndex ";
              developer.log('Documento ${questionDoc.id} no tema $themeName com estrutura inválida. Campos ausentes: ${missingKeys.trim()}. Dados: $data');
            }
          } catch (e, s) { // Adicionar stack trace (s)
            developer.log('Erro ao processar pergunta ${questionDoc.id} no tema $themeName: $e. Dados: $data. StackTrace: $s');
          }
        }

        _allQuestionsCache![themeName] = questions;
        developer.log('Tema $themeName: ${questions.length} perguntas carregadas.');
      }
      // Após carregar tudo, retorna a versão randomizada e limitada
      return _getRandomizedAndLimitedQuestionsFromCache(limitPerCategory);

    } catch (e, s) { // Adicionar stack trace (s)
      developer.log('Erro fatal ao carregar perguntas do Firestore: $e. StackTrace: $s');
      _allQuestionsCache = null; // Limpa o cache em caso de erro para tentar de novo depois
      throw Exception('Erro ao carregar perguntas: $e');
    }
  }

  // Função auxiliar para randomizar e limitar do cache
  Map<String, List<Question>> _getRandomizedAndLimitedQuestionsFromCache(int limitPerCategory) {
    if (_allQuestionsCache == null) return {}; // Se o cache for nulo

    Map<String, List<Question>> randomizedQuestions = {};
    _allQuestionsCache!.forEach((theme, questions) {
      List<Question> questionsCopy = List.from(questions)..shuffle();
      if (questionsCopy.length > limitPerCategory) {
        questionsCopy = questionsCopy.sublist(0, limitPerCategory);
      }
      randomizedQuestions[theme] = questionsCopy;
    });
    return randomizedQuestions;
  }


  Future<List<Question>> loadQuestionsByTheme(String theme, {int limit = 10}) async {
    try {
      String normalizedTheme = theme.toLowerCase();
      developer.log('Carregando perguntas para tema: $normalizedTheme (Solicitado: $theme)');

      // Sempre tenta carregar/recarregar se o cache estiver nulo ou vazio.
      // A lógica de `loadAllQuestions` já evita recarregar se o cache estiver populado.
      if (_allQuestionsCache == null || _allQuestionsCache!.isEmpty) {
        developer.log('Cache vazio ou nulo, chamando loadAllQuestions...');
        // Passa o limit aqui para que loadAllQuestions já limite por categoria
        // Isso pode ser redundante se loadAllQuestions já tiver sido chamado com outro limite.
        // Considere se o limitPerCategory de loadAllQuestions deve ser o mesmo que 'limit' aqui.
        await loadAllQuestions(limitPerCategory: limit);
      } else {
        developer.log('Cache já existe. Verificando tema...');
      }


      if (!_allQuestionsCache!.containsKey(normalizedTheme)) {
        developer.log('Tema "$normalizedTheme" não encontrado no cache após carregamento.');
        developer.log('Temas disponíveis no cache: ${_allQuestionsCache!.keys.join(', ')}');

        if (_allQuestionsCache!.isNotEmpty) {
          String fallbackTheme = _allQuestionsCache!.keys.first;
          developer.log('Usando tema fallback: "$fallbackTheme" pois "$normalizedTheme" não foi encontrado.');
          normalizedTheme = fallbackTheme; // Atenção: isso pode levar a um comportamento inesperado se o tema original realmente deveria existir.
        } else {
          developer.log('Nenhum tema disponível no cache. Retornando lista vazia.');
          _currentQuestions = [];
          return []; // Retorna lista vazia em vez de lançar exceção, QuizScreen lida com isso.
        }
      }

      // Para garantir que o 'limit' de loadQuestionsByTheme seja respeitado:
      List<Question> themeSpecificQuestions = List.from(_allQuestionsCache![normalizedTheme]!);
      themeSpecificQuestions.shuffle(); // Randomiza novamente para esta chamada específica

      if (themeSpecificQuestions.length > limit) {
        themeSpecificQuestions = themeSpecificQuestions.sublist(0, limit);
      }

      _currentQuestions = themeSpecificQuestions;
      developer.log('Perguntas para o tema "$normalizedTheme" (final): ${_currentQuestions!.length}');
      return _currentQuestions!;

    } catch (e, s) {
      developer.log('Erro ao carregar perguntas do tema "$theme": $e. StackTrace: $s');
      _currentQuestions = []; // Garante que não haja perguntas atuais em caso de erro
      throw Exception('Erro ao carregar perguntas para o tema $theme: $e'); // Lançar para que a UI possa tratar
    }
  }

  List<Question>? getCurrentQuestions() {
    return _currentQuestions;
  }
}