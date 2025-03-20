import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../services/question_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String tema;

  const QuizScreen({
    Key? key,
    required this.questions,
    required this.tema,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  int selectedAnswerIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late List<Question> _questions;


  // Adicionar variáveis para o temporizador
  late Timer _timer;
  double _timeLeft = 15; // 15 segundos para cada pergunta
  double _timerProgress = 1.0;

  @override
  void initState() {
    super.initState();

    // Garantir que estamos usando as perguntas randomizadas
    _questions = widget.questions;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    // Iniciar o temporizador
    startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel(); // Cancelar o temporizador ao sair da tela
    super.dispose();
  }

  // Função para iniciar o temporizador
  void startTimer() {
    _timeLeft = 15; // Reiniciar para 15 segundos
    _timerProgress = 1.0;

    // Definir um temporizador que dispara a cada 1 segundo
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_timeLeft <= 0) {
        // Se o tempo acabou, passar para a próxima pergunta
        _timer.cancel();
        if (!answered) {
          // Só avança se ainda não tiver respondido
          nextQuestion();
        }
      } else {
        setState(() {
          // Decrementar o tempo e atualizar o progresso
          _timeLeft -= 0.1;
          _timerProgress = _timeLeft / 15; // Cálculo do progresso (0.0 a 1.0)
        });
      }
    });
  }

  void checkAnswer(int index) {
    setState(() {
      answered = true;
      selectedAnswerIndex = index;
      if (index == widget.questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
    });

    // Cancelar o temporizador quando o usuário responde
    _timer.cancel();

    Timer(Duration(milliseconds: 1500), () {
      if (mounted) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    // Cancelar o temporizador atual
    _timer.cancel();

    if (currentQuestionIndex >= _questions.length - 1) {
      showResultScreen();
    } else {
      setState(() {
        answered = false;
        selectedAnswerIndex = -1;
        currentQuestionIndex++;
        _animationController.reset();
        _animationController.forward();
      });

      // Iniciar um novo temporizador para a próxima pergunta
      startTimer();
    }
  }

  void showResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: _questions.length,
          tema: widget.tema,
          onPlayAgain: () async {
            // Carregar novas questões randomizadas
            final newQuestions = await QuestionService().loadQuestionsByCategory(widget.tema.toLowerCase());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
                  questions: newQuestions,
                  tema: widget.tema,
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF000066),
                Color(0xFF990099),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhuma pergunta disponível',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.arrow_back),
                  label: Text('Voltar ao Menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA4045F),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF000066),
              Color(0xFF990099),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header with title and theme
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trivia World',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.tema,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFA4045F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Progress bar
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFA4045F),
                                Color(0xFFE6526E),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFA4045F).withOpacity(0.5),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pergunta ${currentQuestionIndex + 1}/${widget.questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      // Timer indicator
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: _timeLeft < 5 ? Colors.red : Colors.white.withOpacity(0.8),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${_timeLeft.toInt()}s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _timeLeft < 5 ? Colors.red : Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Timer progress bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: _timerProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _timeLeft < 5
                                  ? [Colors.red.shade700, Colors.red.shade400]
                                  : [Colors.green.shade600, Colors.green.shade400],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Question card with animation
                Expanded(
                  child: FadeTransition(
                    opacity: _animation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question number badge
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF330066),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "#${currentQuestionIndex + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Question text
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                question.questionText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF330066),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 24),

                            // Answer options
                            Expanded(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: question.answers.length,
                                itemBuilder: (context, index) {
                                  final answerText = question.answers[index];

                                  // Define button styles based on answer status
                                  Color backgroundColor;
                                  Color borderColor;
                                  Color textColor = Color(0xFF330066);
                                  IconData? icon;

                                  if (answered) {
                                    if (index == question.correctAnswerIndex) {
                                      backgroundColor = Colors.green.withOpacity(0.2);
                                      borderColor = Colors.green;
                                      textColor = Colors.green.shade800;
                                      icon = Icons.check_circle;
                                    } else if (index == selectedAnswerIndex) {
                                      backgroundColor = Colors.red.withOpacity(0.2);
                                      borderColor = Colors.red;
                                      textColor = Colors.red.shade800;
                                      icon = Icons.cancel;
                                    } else {
                                      backgroundColor = Colors.white;
                                      borderColor = Colors.grey.withOpacity(0.5);
                                    }
                                  } else {
                                    backgroundColor = Colors.white;
                                    borderColor = Color(0xFFA4045F).withOpacity(0.3);
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Material(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        onTap: answered ? null : () => checkAnswer(index),
                                        borderRadius: BorderRadius.circular(12),
                                        splashColor: Color(0xFFA4045F).withOpacity(0.1),
                                        highlightColor: Color(0xFFA4045F).withOpacity(0.05),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: borderColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: answered ? borderColor : Color(0xFFA4045F).withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: icon != null
                                                      ? Icon(
                                                    icon,
                                                    color: Colors.white,
                                                    size: 16,
                                                  )
                                                      : Text(
                                                    String.fromCharCode(65 + index),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: answered ? Colors.white : Color(0xFFA4045F),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  answerText,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Bottom navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.arrow_back,color: Colors.white,),
                        label: Text('Voltar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _timer.cancel(); // Cancelar o temporizador ao sair
                          Navigator.of(context).pushNamed('/home');
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.skip_next,color: answered ? null : Colors.white,),
                        label: Text('Pular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA4045F),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: answered ? null : nextQuestion,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}