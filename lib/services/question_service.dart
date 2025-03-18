import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/question.dart';

class QuestionService {
  // Método para carregar todas as perguntas do JSON
  Future<Map<String, List<Question>>> loadAllQuestions() async {
    // Carrega o arquivo JSON
    final String response = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> data = await json.decode(response);

    // Cria um mapa para armazenar as perguntas por categoria
    Map<String, List<Question>> questionsByCategory = {};

    // Para cada categoria no JSON
    data.forEach((category, questionsJson) {
      // Converte cada item do JSON em um objeto Question
      List<Question> questions = (questionsJson as List)
          .map((item) => Question.fromJson(item))
          .toList();

      // Adiciona a lista de perguntas dessa categoria ao mapa
      questionsByCategory[category] = questions;
    });

    return questionsByCategory;
  }

  // Método para carregar perguntas de uma categoria específica
  Future<List<Question>> loadQuestionsByCategory(String category) async {
    // Carrega o arquivo JSON
    final String response = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> data = await json.decode(response);

    // Verifica se a categoria existe
    if (!data.containsKey(category)) {
      return [];
    }

    // Converte os itens do JSON em objetos Question
    List<Question> questions = (data[category] as List)
        .map((item) => Question.fromJson(item))
        .toList();

    return questions;
  }
}