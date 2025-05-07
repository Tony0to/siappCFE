import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siapp/screens/loading_screen.dart';

// Extension to add a key to a widget after animation
extension KeyedWidget on Widget {
  Widget withKey(Key key) {
    return KeyedSubtree(
      key: key,
      child: this,
    );
  }
}

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> actividadesData;

  const ActividadesScreen({super.key, required this.actividadesData});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> exercises;
  late Map<String, dynamic> gradingInfo;
  int currentExerciseIndex = 0;
  late List<List<dynamic>> userAnswers;
  late List<List<bool>> answeredQuestions;
  late List<bool> exerciseCompleted;
  Map<String, dynamic>? _contentData;
  String? _errorMessage;
  late AnimationController _controller;
  late ConfettiController _confettiController;
  int _remainingAttempts = 3; // Default value before Firestore load
  bool _isAttemptsExhausted = false;
  // Track available code blocks for each question in exercise id == 2
  late List<List<List<int>>> availableCodeBlocks;
  late Future<void> _loadContentFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    debugPrint('ActividadesScreen initState: actividadesData = ${widget.actividadesData}');
    // Initialize the future for loading content and attempts
    _loadContentFuture = _loadContentWithDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadContentWithDelay() async {
    try {
      await Future.wait([
        _loadJsonContent(),
        _loadAttemptsFromFirestore(),
        Future.delayed(const Duration(seconds: 1)), // Ensure minimum 1-second delay
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el contenido: $e';
      });
      rethrow;
    }
  }

  Future<void> _loadAttemptsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module4')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(widget.actividadesData['id'] ?? 'module4')
            .set({
              'intentos': 3,
              'last_updated': FieldValue.serverTimestamp(),
              'module_id': widget.actividadesData['id'] ?? 'module4',
              'module_title': widget.actividadesData['module_title'] ?? 'Módulo 4',
            }, SetOptions(merge: true));

        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
        });
      }
    } catch (e) {
      throw Exception('Error al cargar los intentos: $e');
    }
  }

  Future<void> _decrementAttempts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttempts - 1;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module4')
          .set({
            'intentos': newAttempts,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los intentos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveFinalGrade(int percentage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final quizCompleted = percentage >= 70;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module4')
          .set({
            'calf': percentage,
            'quiz_completed': quizCompleted,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (percentage < 70) {
        await _decrementAttempts();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la calificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadJsonContent() async {
    debugPrint('Starting _loadJsonContent');
    try {
      debugPrint('Loading assets/data/module4/actividades.json');
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/module4/actividades.json');
      if (jsonString.isEmpty) {
        throw Exception('El archivo actividades.json está vacío');
      }
      debugPrint('JSON loaded: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
      debugPrint('JSON length: ${jsonString.length}');
      
      debugPrint('Parsing JSON');
      final data = json.decode(jsonString);
      debugPrint('Parsed data type: ${data.runtimeType}, keys: ${data.keys}');
      
      if (data['activities'] == null) {
        throw Exception('JSON does not contain "activities" key');
      }
      
      final activities = data['activities'] as Map<String, dynamic>;
      debugPrint('Activities keys: ${activities.keys}');
      
      setState(() {
        _contentData = activities;
        _errorMessage = null;
        debugPrint('JSON loaded successfully: ${_contentData?.keys}');
        _initializeData();
      });
    } catch (e, stackTrace) {
      final error = 'Error loading JSON: $e\nStackTrace: $stackTrace';
      debugPrint(error);
      throw Exception('Error al cargar el contenido: $e\nVerifica assets/data/module4/actividades.json y pubspec.yaml.');
    }
  }

  void _initializeData() {
    debugPrint('Initializing data');
    final activitiesData = _contentData ?? {};
    exercises = List<Map<String, dynamic>>.from(activitiesData['exercises'] ?? []);
    gradingInfo = Map<String, dynamic>.from(activitiesData['grading'] ?? {});
    debugPrint('Exercises count: ${exercises.length}');
    
    userAnswers = List<List<dynamic>>.generate(
      exercises.length,
      (i) {
        final quizLength = (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0;
        debugPrint('Exercise $i quiz length: $quizLength');
        if (exercises[i]['id'] == 2) {
          return List<List<int?>>.generate(quizLength, (j) {
            final questionText = exercises[i]['quiz'][j]['question'] as String;
            final lines = questionText.split('\n').where((line) => line.trim().startsWith(RegExp(r'\d+\.'))).toList();
            final codeLinesCount = lines.length;
            return List<int?>.filled(codeLinesCount, null);
          });
        }
        return List<int?>.filled(quizLength, null);
      },
    );

    answeredQuestions = List<List<bool>>.generate(
      exercises.length,
      (i) {
        final quizLength = (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0;
        return List<bool>.filled(quizLength, false);
      },
    );

    availableCodeBlocks = List<List<List<int>>>.generate(
      exercises.length,
      (i) {
        final quizLength = (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0;
        return List<List<int>>.generate(quizLength, (j) {
          if (exercises[i]['id'] != 2) {
            return [];
          }
          final questionText = exercises[i]['quiz'][j]['question'] as String;
          final lines = questionText.split('\n').where((line) => line.trim().startsWith(RegExp(r'\d+\.'))).toList();
          final codeLinesCount = lines.length;
          List<int> indices = List.generate(codeLinesCount, (index) => index)..shuffle();
          return indices;
        });
      },
    );

    exerciseCompleted = List<bool>.filled(exercises.length, false);
    debugPrint('Initialized data: ${exercises.length} exercises, grading: ${gradingInfo.keys}, userAnswers: $userAnswers, answeredQuestions: $answeredQuestions, availableCodeBlocks: $availableCodeBlocks');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadContentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingScreen(
              message: 'Cargando actividades...',
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _errorMessage ?? 'Error desconocido al cargar las actividades.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedButton(
                      text: 'Reintentar',
                      onPressed: () {
                        setState(() {
                          _loadContentFuture = _loadContentWithDelay();
                        });
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      ),
                    ).animate()
                      .scale(
                        delay: 300.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (exercises.isEmpty) {
          debugPrint('No exercises found');
          return _buildNoExercisesScreen();
        }

        final currentExercise = exercises[currentExerciseIndex];
        debugPrint('Rendering exercise ${currentExercise['id']}');

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressHeader().animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
                        const SizedBox(height: 20),
                        _buildAttemptsIndicator().animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 20),
                        _buildExerciseTitle(currentExercise).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 20),
                        Text(
                          _contentData?['sectionDescription']?.toString() ?? 'Descripción no disponible',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white.withAlpha(70),
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                        const SizedBox(height: 20),
                        Text(
                          currentExercise['description']?.toString() ?? 'Descripción no disponible',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white.withAlpha(70),
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                        const SizedBox(height: 20),
                        _buildQuizQuestions(currentExercise).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 20),
                        _buildRelatedTopics(currentExercise).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 30),
                        _buildNavigationControls().animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: _showGradingInfo,
                      backgroundColor: const Color(0xFF3B82F6),
                      child: const Icon(Icons.score, color: Colors.white),
                    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoExercisesScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              'No hay ejercicios disponibles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicio ${currentExerciseIndex + 1} de ${exercises.length}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              LinearProgressIndicator(
                value: (currentExerciseIndex + 1) / exercises.length,
                minHeight: 8,
                backgroundColor: Colors.white.withAlpha(24),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ).animate().fadeIn(duration: 600.ms),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withAlpha((0.5 * 255).round()),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsIndicator() {
    return GlassmorphicCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Intentos restantes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withAlpha((0.9 * 255).round()),
            ),
          ),
          Text(
            '$_remainingAttempts',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _remainingAttempts > 0 ? Colors.white : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTitle(Map<String, dynamic> exercise) {
    return GlassmorphicCard(
      child: Text(
        exercise['title']?.toString() ?? 'Ejercicio sin título',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuizQuestions(Map<String, dynamic> exercise) {
    final quiz = List<Map<String, dynamic>>.from(exercise['quiz'] ?? []);
    debugPrint('Rendering quiz for exercise ${exercise['id']}, questions: ${quiz.length}');

    if (quiz.isEmpty) {
      debugPrint('No quiz questions found for exercise ${exercise['id']}');
      return GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Color(0xFF93C5FD), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Evaluación de conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay preguntas disponibles',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withAlpha(70)),
            ),
          ],
        ),
      );
    }

    if (_isAttemptsExhausted) {
      return GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Color(0xFF93C5FD), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Evaluación de conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Has agotado todos tus intentos. No puedes responder más preguntas.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.redAccent),
            ),
          ],
        ),
      );
    }

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Evaluación de conocimiento',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...quiz.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;
            final isAnswered = answeredQuestions[currentExerciseIndex][questionIndex];

            if (exercise['id'] == 2) {
              final questionText = question['question'] as String;
              final lines = questionText.split('\n').where((line) => line.trim().startsWith(RegExp(r'\d+\.'))).toList();
              final correctAnswer = List<int>.from(question['correctAnswer'] ?? []);
              final slots = List<int?>.from(userAnswers[currentExerciseIndex][questionIndex] as List<int?>);
              final availableBlocks = List<int>.from(availableCodeBlocks[currentExerciseIndex][questionIndex]);

              final questionTitle = questionText.split('\n').firstWhere((line) => !line.trim().startsWith(RegExp(r'\d+\.')));

              debugPrint('Question $questionIndex: lines=$lines, slots=$slots, availableBlocks=$availableBlocks, correctAnswer=$correctAnswer');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: (100 * questionIndex).ms),
                  const SizedBox(height: 12),
                  ...slots.asMap().entries.map((slotEntry) {
                    final slotIndex = slotEntry.key;
                    final int? codeLineIndex = slotEntry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          final droppedIndex = details.data;
                          if (isAnswered || _isAttemptsExhausted) return;

                          setState(() {
                            slots[slotIndex] = droppedIndex;
                            userAnswers[currentExerciseIndex][questionIndex] = slots;
                            availableBlocks.remove(droppedIndex);
                            availableCodeBlocks[currentExerciseIndex][questionIndex] = availableBlocks;
                            debugPrint('Dropped code line $droppedIndex into slot $slotIndex');
                            debugPrint('Updated slots: $slots');
                            debugPrint('Updated availableBlocks: $availableBlocks');
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          if (codeLineIndex == null) {
                            return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: candidateData.isNotEmpty
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withAlpha((0.2 * 255).round()),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Arrastra una línea aquí',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withAlpha((0.5 * 255).round()),
                                  ),
                                ),
                              ),
                            ).animate().scale(
                                  delay: (100 * slotIndex).ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                );
                          } else {
                            final codeLineText = lines[codeLineIndex];
                            return GestureDetector(
                              onDoubleTap: () {
                                if (isAnswered || _isAttemptsExhausted) return;

                                setState(() {
                                  if (codeLineIndex != null) {
                                    availableBlocks.add(codeLineIndex);
                                    availableBlocks.sort();
                                    availableCodeBlocks[currentExerciseIndex][questionIndex] = availableBlocks;
                                    slots[slotIndex] = null;
                                    userAnswers[currentExerciseIndex][questionIndex] = slots;
                                    debugPrint('Removed code line $codeLineIndex from slot $slotIndex');
                                    debugPrint('Updated slots: $slots');
                                    debugPrint('Updated availableBlocks: $availableBlocks');
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(((isAnswered ? 0.05 : 0.1) * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAnswered
                                        ? (slots.toString() == correctAnswer.toString()
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444))
                                        : const Color(0xFF3B82F6).withAlpha((0.5 * 255).round()),
                                  ),
                                  boxShadow: [
                                    if (!isAnswered)
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6).withAlpha((0.3 * 255).round()),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.code,
                                      color: isAnswered
                                          ? (slots.toString() == correctAnswer.toString()
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444))
                                          : Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        codeLineText,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.white.withAlpha((0.5 * 255).round()),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ).animate().scale(
                                    delay: (100 * slotIndex).ms,
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            );
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  if (availableBlocks.isNotEmpty) ...[
                    Text(
                      'Líneas de código disponibles:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableBlocks.map((codeLineIndex) {
                        final codeLineText = lines[codeLineIndex];
                        return Draggable<int>(
                          data: codeLineIndex,
                          feedback: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                codeLineText,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.05 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                              ),
                            ),
                            child: Text(
                              codeLineText,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withAlpha((0.3 * 255).round()),
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withAlpha((0.5 * 255).round()),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withAlpha((0.3 * 255).round()),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.code,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  codeLineText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().scale(
                              delay: (100 * codeLineIndex).ms,
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!isAnswered)
                    _buildAnimatedButton(
                      text: 'Verificar orden',
                      onPressed: slots.any((slot) => slot == null)
                          ? null
                          : () {
                              setState(() {
                                answeredQuestions[currentExerciseIndex][questionIndex] = true;
                                exerciseCompleted[currentExerciseIndex] =
                                    answeredQuestions[currentExerciseIndex].every((answered) => answered);
                                debugPrint('Verified order for question $questionIndex: $slots');
                                debugPrint('Exercise $currentExerciseIndex completed: ${exerciseCompleted[currentExerciseIndex]}');

                                final isCorrect = slots.toString() == correctAnswer.toString();
                                final correctOrderText = correctAnswer.map((index) => lines[index]).join('\n');
                                final snackBar = SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        isCorrect ? Icons.check_circle : Icons.error,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isCorrect
                                              ? '¡Correcto! El orden es el adecuado.'
                                              : 'Incorrecto, el orden correcto es:\n$correctOrderText',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 5),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              });
                            },
                      gradient: LinearGradient(
                        colors: slots.any((slot) => slot == null)
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
                      ),
                    ).animate().scale(
                          delay: (100 * slots.length).ms,
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                ],
              );
            } else {
              final options = List<String>.from(question['options'] ?? []);
              final correctAnswer = question['correctAnswer'] as int?;
              final isIncomplete = userAnswers[currentExerciseIndex][questionIndex] == null;
              final isAnswered = answeredQuestions[currentExerciseIndex][questionIndex];

              debugPrint('Rendering question $questionIndex: ${question['question']}, options: $options, correctAnswer: $correctAnswer, isAnswered: $isAnswered');

              if (options.isEmpty || correctAnswer == null) {
                debugPrint('Invalid question data for question $questionIndex');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Error: Pregunta inválida',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.redAccent),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question']?.toString() ?? 'Pregunta no disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: (100 * questionIndex).ms),
                  const SizedBox(height: 12),
                  ...options.asMap().entries.map((optionEntry) {
                    final optionIndex = optionEntry.key;
                    final optionText = optionEntry.value;
                    final isSelected = userAnswers[currentExerciseIndex][questionIndex] == optionIndex;
                    final isCorrect = optionIndex == correctAnswer;

                    Color textColor = Colors.white;
                    Color borderColor = const Color(0xFF3B82F6).withAlpha((0.5 * 255).round());
                    Color bgColor = Colors.white.withAlpha((0.05 * 255).round());

                    if (isSelected) {
                      borderColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                      bgColor = isCorrect ? const Color(0xFF10B981).withAlpha((0.2 * 255).round()) : const Color(0xFFEF4444).withAlpha((0.2 * 255).round());
                      textColor = Colors.white;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: (isAnswered || _isAttemptsExhausted)
                            ? null
                            : () {
                                debugPrint('Selected option $optionIndex for question $questionIndex, locking answer');
                                setState(() {
                                  userAnswers[currentExerciseIndex][questionIndex] = optionIndex;
                                  answeredQuestions[currentExerciseIndex][questionIndex] = true;
                                  exerciseCompleted[currentExerciseIndex] =
                                      userAnswers[currentExerciseIndex].every((answer) => answer != null);
                                  debugPrint('Updated userAnswers[$currentExerciseIndex]: ${userAnswers[currentExerciseIndex]}');
                                  debugPrint('Updated answeredQuestions[$currentExerciseIndex]: ${answeredQuestions[currentExerciseIndex]}');
                                  debugPrint('Exercise $currentExerciseIndex completed: ${exerciseCompleted[currentExerciseIndex]}');

                                  final snackBar = SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          isCorrect ? Icons.check_circle : Icons.error,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isCorrect
                                                ? '¡Correcto!'
                                                : 'Incorrecto, la respuesta correcta es ${options[correctAnswer]}',
                                            style: GoogleFonts.poppins(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              if (isIncomplete && !isAnswered)
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withAlpha((0.3 * 255).round()),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                  color: isSelected ? borderColor : Colors.transparent,
                                ),
                                child: isSelected
                                    ? Icon(
                                        isCorrect ? Icons.check : Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: textColor,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scale(delay: (100 * optionIndex).ms, duration: 400.ms, curve: Curves.easeOutBack),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedTopics(Map<String, dynamic> exercise) {
    final topics = List<String>.from(exercise['relatedTopics'] ?? []);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Temas relacionados',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            Text(
              'No se especificaron temas',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withAlpha(70)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final topic = entry.value;
                return Chip(
                  label: Text(
                    topic,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                  ),
                  backgroundColor: const Color(0xFF93C5FD),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAnimatedButton(
          text: 'Anterior',
          onPressed: currentExerciseIndex > 0 ? _previousExercise : null,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
        _buildAnimatedButton(
          text: currentExerciseIndex < exercises.length - 1 ? 'Siguiente' : 'Finalizar',
          onPressed: _isCurrentExerciseComplete() ? _nextExercise : null,
          gradient: LinearGradient(
            colors: _isCurrentExerciseComplete()
                ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                : [Colors.grey.shade600, Colors.grey.shade400],
          ),
        ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback? onPressed,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }

  void _previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
      });
    }
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  bool _isCurrentExerciseComplete() {
    return answeredQuestions[currentExerciseIndex].every((answered) => answered);
  }

  void _showCompletionDialog() {
    final correctAnswers = _calculateCorrectAnswers();
    final totalQuestions = _getTotalQuestions();
    final percentage = totalQuestions > 0 ? (correctAnswers * 100 ~/ totalQuestions) : 0;
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('Showing completion dialog: screenWidth=$screenWidth, correctAnswers=$correctAnswers, totalQuestions=$totalQuestions');

    _saveFinalGrade(percentage);

    if (percentage >= 90) {
      _confettiController.play();
    }

    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              minWidth: 280,
            ),
            child: AlertDialog(
              backgroundColor: Colors.white.withAlpha((0.95 * 255).round()),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.celebration, color: Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Evaluación completada',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        'Respuestas correctas: $correctAnswers/$totalQuestions',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Stack(
                        children: [
                          LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
                          ).animate().fadeIn(duration: 600.ms),
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: _getScoreColor(percentage).withAlpha((0.5 * 255).round()),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        'Puntuación: $percentage%',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        'Nivel: ${_getGradeLevel(percentage)}',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    if (percentage < 70)
                      Flexible(
                        child: Text(
                          'Se ha descontado 1 intento porque tu puntuación es menor a 70%. Intentos restantes: $_remainingAttempts',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.redAccent),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Revisar',
                    style: GoogleFonts.poppins(color: const Color(0xFF3B82F6)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.poppins(color: const Color(0xFF3B82F6)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 50,
              minBlastForce: 10,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFFFFD700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      if (exercise.containsKey('quiz')) {
        final quiz = List<Map<String, dynamic>>.from(exercise['quiz'] ?? []);
        for (var j = 0; j < quiz.length; j++) {
          if (exercise['id'] == 2) {
            final correctAnswer = List<int>.from(quiz[j]['correctAnswer'] ?? []);
            final userSlots = userAnswers[i][j] as List<int?>;
            final userOrder = userSlots.map((slot) => slot ?? -1).toList();
            if (userOrder.toString() == correctAnswer.toString()) {
              correct++;
            }
          } else {
            final correctAnswer = quiz[j]['correctAnswer'];
            if (userAnswers[i][j] == correctAnswer) {
              correct++;
            }
          }
        }
      }
    }
    return correct;
  }

  int _getTotalQuestions() {
    return exercises
        .where((e) => e.containsKey('quiz'))
        .fold<int>(0, (total, e) => total + (e['quiz'] as List<dynamic>).length);
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 90) return const Color(0xFF10B981);
    if (percentage >= 70) return const Color(0xFF3B82F6);
    if (percentage >= 50) return Colors.orange;
    return const Color(0xFFEF4444);
  }

  String _getGradeLevel(int percentage) {
    final conversion = List<Map<String, dynamic>>.from(gradingInfo['scoreConversion'] ?? []);
    for (final grade in conversion) {
      final range = grade['range']?.toString() ?? '';
      if (range.contains('-')) {
        final parts = range.split('-');
        final min = int.tryParse(parts[0]) ?? 0;
        final max = int.tryParse(parts[1]) ?? 0;
        if (percentage >= min && percentage <= max) {
          return grade['grade']?.toString() ?? 'No evaluado';
        }
      }
    }
    return 'No evaluado';
  }

  void _showGradingInfo() {
    final criteria = List<Map<String, dynamic>>.from(gradingInfo['criteria'] ?? []);
    final conversion = List<Map<String, dynamic>>.from(gradingInfo['scoreConversion'] ?? []);
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('Showing grading info: screenWidth=$screenWidth, criteria=$criteria, conversion=$conversion');

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          minWidth: 280,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white.withAlpha((0.95 * 255).round()),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Criterios de Evaluación',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Criterios',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 12),
                if (criteria.isEmpty)
                  Text(
                    'No se especificaron criterios',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ).animate().fadeIn(delay: 200.ms)
                else
                  ...criteria.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final criterion = entry.value;
                    final aspectText = '${criterion['aspect']}: ${(criterion['weight'] * 100).toInt()}%';
                    debugPrint('Rendering criterion $index: $aspectText, length=${aspectText.length}');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 12, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              aspectText,
                              style: GoogleFonts.poppins(fontSize: 14),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
                  }),
                const SizedBox(height: 20),
                Text(
                  'Escala de calificaciones',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                if (conversion.isEmpty)
                  Text(
                    'No se especificó escala',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ).animate().fadeIn(delay: 400.ms)
                else
                  ...conversion.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final grade = entry.value;
                    final gradeText = '${grade['range']}: ${grade['grade']}';
                    debugPrint('Rendering conversion $index: $gradeText, length=${gradeText.length}');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 12, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              gradeText,
                              style: GoogleFonts.poppins(fontSize: 14),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (100 * index + 400).ms, duration: 400.ms);
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(color: const Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}