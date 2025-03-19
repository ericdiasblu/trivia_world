import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../models/question.dart';

class QuestionService {
  // Cache para armazenar todas as perguntas carregadas do JSON
  static Map<String, List<Question>>? _allQuestionsCache;

  // Lista atual de perguntas para a categoria ativa
  static List<Question>? _currentQuestions;

  // Método para carregar todas as perguntas do JSON
  Future<Map<String, List<Question>>> loadAllQuestions({int limitPerCategory = 10}) async {
    try {
      // Carrega o arquivo JSON apenas uma vez e armazena no cache
      if (_allQuestionsCache == null) {
        developer.log('Carregando todas as perguntas do JSON...');
        final String response = await rootBundle.loadString('assets/questions.json');
        final Map<String, dynamic> data = await json.decode(response);

        // Cria um mapa para armazenar todas as perguntas por categoria
        _allQuestionsCache = {};

        // Para cada categoria no JSON
        data.forEach((category, questionsJson) {
          // Converte cada item do JSON em um objeto Question
          List<Question> questions = (questionsJson as List)
              .map((item) => Question.fromJson(item))
              .toList();

          // Normalize a category name to lowercase for consistent lookup
          String normalizedCategory = category.toLowerCase();

          // Armazena todas as perguntas no cache
          _allQuestionsCache![normalizedCategory] = questions;
          developer.log('Categoria $normalizedCategory: ${questions.length} perguntas carregadas');
        });
      }

      // Cria um novo mapa para retornar as perguntas randomizadas
      Map<String, List<Question>> randomizedQuestions = {};

      // Para cada categoria, copia as perguntas, randomiza e limita
      _allQuestionsCache!.forEach((category, allQuestions) {
        // Faz uma cópia das perguntas para não modificar o cache original
        List<Question> questionsCopy = List.from(allQuestions);

        // Randomiza a ordem das perguntas
        questionsCopy.shuffle();

        // Limita para o número especificado de perguntas por categoria
        if (questionsCopy.length > limitPerCategory) {
          questionsCopy = questionsCopy.sublist(0, limitPerCategory);
        }

        // Adiciona a lista randomizada ao mapa de retorno
        randomizedQuestions[category] = questionsCopy;
      });

      return randomizedQuestions;
    } catch (e) {
      developer.log('Erro ao carregar perguntas: $e');
      throw Exception('Erro ao carregar perguntas: $e');
    }
  }

  // Método para carregar e randomizar perguntas de uma categoria específica
  Future<List<Question>> loadQuestionsByCategory(String category, {int limit = 10}) async {
    try {
      // Normalize the category name to lowercase for consistent lookup
      String normalizedCategory = category.toLowerCase();
      developer.log('Carregando perguntas para categoria: $normalizedCategory');

      // Se o cache ainda não está carregado, carrega o JSON
      if (_allQuestionsCache == null) {
        developer.log('Cache não encontrado, carregando todas as perguntas...');
        await loadAllQuestions(limitPerCategory: limit);
      }

      // Log disponible categories
      developer.log('Categorias disponíveis: ${_allQuestionsCache!.keys.join(", ")}');

      // Verifica se a categoria existe
      if (!_allQuestionsCache!.containsKey(normalizedCategory)) {
        developer.log('Categoria $normalizedCategory não encontrada!');

        // Fallback to first available category if the requested one doesn't exist
        if (_allQuestionsCache!.isNotEmpty) {
          String fallbackCategory = _allQuestionsCache!.keys.first;
          developer.log('Usando categoria fallback: $fallbackCategory');
          normalizedCategory = fallbackCategory;
        } else {
          throw Exception("Nenhuma categoria de perguntas disponível");
        }
      }

      // Faz uma cópia das perguntas dessa categoria
      List<Question> questionsCopy = List.from(_allQuestionsCache![normalizedCategory]!);
      developer.log('Total de perguntas na categoria: ${questionsCopy.length}');

      // Randomiza a ordem das perguntas
      questionsCopy.shuffle();
      developer.log('Perguntas randomizadas');

      // Limita para o número especificado pelo parâmetro limit
      if (questionsCopy.length > limit) {
        questionsCopy = questionsCopy.sublist(0, limit);
        developer.log('Perguntas limitadas para $limit');
      }

      // Store current questions for this session
      _currentQuestions = questionsCopy;

      return questionsCopy;
    } catch (e) {
      developer.log('Erro ao carregar perguntas para categoria $category: $e');
      throw Exception('Erro ao carregar perguntas: $e');
    }
  }

  // Getter for current questions
  List<Question>? getCurrentQuestions() {
    return _currentQuestions;
  }
}