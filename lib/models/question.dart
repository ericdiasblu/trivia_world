class Question {
  final String questionText;
  final List<String> answers;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswerIndex,
  });
}

final List<Question> geralQuestions = [
  Question(
    questionText: "Qual é o país com a maior população do mundo?",
    answers: ["Indonésia", "China", "Estados Unidos", "Índia"],
    correctAnswerIndex: 1, // Índice 1 = "China" (ou 3 se considerar "Índia" a correta)
  ),
  Question(
    questionText: "Qual é a capital do Brasil?",
    answers: ["Brasília", "São Paulo", "Rio de Janeiro", "Salvador"],
    correctAnswerIndex: 0,
  ),
  // Adicione mais perguntas aqui...
];

