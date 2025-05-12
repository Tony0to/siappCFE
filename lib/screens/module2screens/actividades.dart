import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:siapp/screens/loading_screen.dart';
import 'package:siapp/screens/module2.dart';
import 'package:siapp/theme/app_colors.dart';
import 'dart:math';

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> actividadesData;

  const ActividadesScreen({super.key, required this.actividadesData});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  late List<Map<String, dynamic>> exercises;
  late Map<String, dynamic> gradingInfo;
  Map<String, dynamic>? _contentData;
  String? _errorMessage;
  bool _isLoading = true;
  Map<String, dynamic>? selectedExercise;
  int? selectedExerciseIndex;
  late List<List<int?>> userAnswers;
  late List<List<bool>> answeredQuestions;
  late List<bool> exerciseCompleted;
  late Map<int, int> sectionScores;
  late ConfettiController _confettiController;
  late ScrollController _scrollController;
  int _remainingAttempts = 3;
  bool _isAttemptsExhausted = false;
  bool _isFinalGradeSubmitted = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _scrollController = ScrollController();
    sectionScores = {};
    _isFinalGradeSubmitted = false;
    debugPrint(
        'ActividadesScreen initState: actividadesData = ${widget.actividadesData}');
    _loadContentWithDelay();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContentWithDelay() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadJsonContent(),
        _loadAttemptsFromFirestore(),
        Future.delayed(const Duration(seconds: 1)),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el contenido: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadJsonContent() async {
    debugPrint('Starting _loadJsonContent');
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/data/module2/actividades.json');
      final data = json.decode(jsonString);
      if (data['activities'] == null) {
        throw Exception('JSON does not contain "activities" key');
      }

      final activities = data['activities'] as Map<String, dynamic>;
      setState(() {
        _contentData = activities;
        exercises =
            List<Map<String, dynamic>>.from(activities['exercises'] ?? []);
        gradingInfo = Map<String, dynamic>.from(activities['grading'] ?? {});
        _initializeData();
        _errorMessage = null;
        debugPrint('JSON loaded successfully: ${_contentData?.keys}');
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading JSON: $e\nStackTrace: $stackTrace');
      setState(() {
        _contentData = null;
        _errorMessage = 'Error al cargar el contenido: $e';
      });
    }
  }

  void _initializeData() {
    userAnswers = List<List<int?>>.generate(
      exercises.length,
      (i) => List<int?>.filled(
          (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, null),
    );
    answeredQuestions = List<List<bool>>.generate(
      exercises.length,
      (i) => List<bool>.filled(
          (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, false),
    );
    exerciseCompleted = List<bool>.filled(exercises.length, false);
  }

  void _resetLocalState() {
    setState(() {
      userAnswers = List<List<int?>>.generate(
        exercises.length,
        (i) => List<int?>.filled(
            (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, null),
      );
      answeredQuestions = List<List<bool>>.generate(
        exercises.length,
        (i) => List<bool>.filled(
            (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, false),
      );
      exerciseCompleted = List<bool>.filled(exercises.length, false);
      sectionScores = {};
      _isFinalGradeSubmitted = false;
    });
  }

  Future<void> _loadAttemptsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado.';
        });
        return;
      }

      final moduleDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc('module2')
          .get();

      if (moduleDoc.exists) {
        final data = moduleDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        final grade = (data?['calf'] as num?)?.toInt() ?? 0;
        final quizCompleted = data?['quiz_completed'] as bool? ?? false;

        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0;
          debugPrint(
              'Loaded module2 data: intentos=$attempts, calf=$grade, quiz_completed=$quizCompleted');
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc('module2')
            .set({
          'intentos': 3,
          'calf': 0,
          'quiz_completed': false,
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': 'module2',
          'module_title':
              widget.actividadesData['module_title'] ?? 'Módulo 2: Lógica de Programación',
        }, SetOptions(merge: true));

        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
          debugPrint('Initialized module2 document with default values');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los intentos: $e';
      });
      debugPrint('Error loading attempts: $e');
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
          .doc('module2')
          .set({
        'intentos': newAttempts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
        debugPrint('Decremented attempts to $newAttempts');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar los intentos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      debugPrint('Error decrementing attempts: $e');
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
          .doc('module2')
          .set({
        'calf': percentage,
        'quiz_completed': quizCompleted,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (percentage < 70) {
        await _decrementAttempts();
      }
      debugPrint(
          'Saved final grade: percentage=$percentage, quiz_completed=$quizCompleted');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la calificación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      debugPrint('Error saving final grade: $e');
    }
  }

  void _initializeExerciseData() {
    setState(() {
      exerciseCompleted[selectedExerciseIndex!] = false;
    });
  }

  Widget _buildLoadingScreen({String message = 'Cargando actividades...'}) {
    return LoadingScreen(message: message);
  }

  Widget _buildCodeBox(String code,
      {String language = 'plaintext', bool selectable = false}) {
    if (code.isEmpty) {
      return Text(
        'Código no disponible',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    String highlightLanguage;
    switch (language.toLowerCase()) {
      case 'c':
        highlightLanguage = 'c';
        break;
      case 'python':
        highlightLanguage = 'python';
        break;
      case 'javascript':
        highlightLanguage = 'javascript';
        break;
      case 'pseudocode':
      case 'plaintext':
        highlightLanguage = 'plaintext';
        break;
      default:
        highlightLanguage = 'plaintext';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.codeBoxBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.codeBoxBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.codeBoxLabel,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              language.toLowerCase() == 'pseudocode'
                  ? 'Pseudocódigo'
                  : 'Código',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: selectable
                    ? SelectableText.rich(
                        TextSpan(
                          text: code,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      )
                    : HighlightView(
                        code,
                        language: highlightLanguage,
                        theme: githubTheme,
                        padding: const EdgeInsets.all(10),
                        textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _formatQuestion(String question) {
    final codeBlockRegExp = RegExp(r'```(\w+)?\n([\s\S]*?)\n```');
    final matches = codeBlockRegExp.allMatches(question);
    final widgets = <Widget>[];
    int lastEnd = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final language = match.group(1) ?? 'plaintext';
      final code = kDelimiter + match.group(2)! + kDelimiter;

      if (lastEnd < start) {
        final text = question.substring(lastEnd, start).trim();
        if (text.isNotEmpty) {
          widgets.add(
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }
      }

      widgets.add(
        _buildCodeBox(
          code,
          language: language,
        ),
      );

      lastEnd = end;
    }

    if (lastEnd < question.length) {
      final text = question.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        widgets.add(
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Text(
          question.trim(),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return widgets;
  }

  static const kDelimiter = '<DELIMITER>';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: _buildLoadingScreen(
            message: _errorMessage ?? 'Cargando actividades...'),
      );
    }

    if (exercises.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Center(
            child: Text(
              'No hay ejercicios disponibles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.easeOut),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (selectedExercise != null && !exerciseCompleted[selectedExerciseIndex!]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Debes completar todas las preguntas antes de salir.',
                style: GoogleFonts.poppins(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: selectedExercise == null
              ? _buildMainMenu()
              : _buildExerciseDetail(),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    final allCompleted = exerciseCompleted.every((completed) => completed);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividades Prácticas del Módulo 2',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 12),
                Text(
                  'En estas actividades podrás poner a prueba tus conocimientos aprendidos hasta ahora, así como fortalecerlos y agregar más.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAttemptsIndicator().animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1.25,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseButton(
                  title:
                      exercise['title']?.toString() ?? 'Ejercicio ${index + 1}',
                  isCompleted: exerciseCompleted[index],
                  onPressed: () {
                    setState(() {
                      selectedExercise = exercise;
                      selectedExerciseIndex = index;
                      _initializeExerciseData();
                    });
                  },
                ).animate().scale(
                    delay: (100 * index).ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack);
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: _buildAnimatedButton(
              text: 'Completar',
              onPressed:
                  allCompleted && !_isAttemptsExhausted && !_isFinalGradeSubmitted
                      ? _showFinalCompletionDialog
                      : null,
              gradient: LinearGradient(
                colors: allCompleted &&
                        !_isAttemptsExhausted &&
                        !_isFinalGradeSubmitted
                    ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                    : [Colors.grey.shade600, Colors.grey.shade400],
              ),
            ).animate().scale(
                delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExerciseButton(
      {required String title,
      required bool isCompleted,
      required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glassmorphicBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassmorphicBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetail() {
    final currentExercise = selectedExercise!;
    final isDiagramExercise = currentExercise.containsKey('diagram');

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader().animate().slideY(
              begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 30),
          _buildExerciseTitle(currentExercise)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 25),
          Text(
            currentExercise['description']?.toString() ??
                'Descripción no disponible',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 25),
          if (isDiagramExercise) ...[
            _buildFlowChartSection(currentExercise)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 25),
            _buildPseudocodeSection(currentExercise)
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 25),
          ],
          _buildRequirementsSection(currentExercise)
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 25),
          if (!isDiagramExercise) ...[
            _buildExamplesSection(currentExercise)
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 25),
          ],
          _buildQuizQuestions(currentExercise)
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 25),
          _buildRelatedTopics(currentExercise)
              .animate()
              .fadeIn(delay: 900.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 30),
          _buildNavigationControls()
              .animate()
              .fadeIn(delay: 1000.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return GlassmorphicCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ejercicio ${selectedExerciseIndex! + 1} de ${exercises.length}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$_remainingAttempts',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _remainingAttempts > 0
                  ? AppColors.textPrimary
                  : AppColors.error,
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFlowChartSection(Map<String, dynamic> exercise) {
    final diagramPath = exercise['diagram']?.toString() ?? '';
    final diagramDescription = exercise['explanation']?.toString() ??
        exercise['logic']?.toString() ??
        'Descripción no disponible';

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Diagrama de Flujo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            diagramDescription,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 600.0,
            decoration: BoxDecoration(
              color: AppColors.neutralCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassmorphicBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 2.0,
                child: Center(
                  child: diagramPath.isNotEmpty
                      ? Image.asset(
                          diagramPath,
                          fit: BoxFit.contain,
                          width: 500.0,
                          height: 600.0,
                          errorBuilder: (context, error, stackTrace) => Text(
                            'Error: No se pudo cargar el diagrama',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        )
                      : Text(
                          'Error: Diagrama no disponible',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pellizca para hacer zoom • Desliza para mover',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPseudocodeSection(Map<String, dynamic> exercise) {
    final pseudocode = exercise['logic']?.toString() ??
        exercise['pseudocodigo']?.toString() ??
        'Pseudocódigo no disponible';

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Pseudocódigo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCodeBox(
            pseudocode,
            language: 'pseudocode',
            selectable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(Map<String, dynamic> exercise) {
    final requirements = List<String>.from(exercise['requirements'] ?? []);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Requisitos',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (requirements.isEmpty)
            Text(
              'No se especificaron requisitos',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
            )
          else
            ...requirements.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final req = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fiber_manual_record,
                        size: 10, color: AppColors.chipTopic),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
            }),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(Map<String, dynamic> exercise) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Ejemplo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Entrada: ${exercise['exampleInput']?.toString() ?? 'No especificado'}',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Salida: ${exercise['exampleOutput']?.toString() ?? 'No especificado'}',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizQuestions(Map<String, dynamic> exercise) {
    final quiz = List<Map<String, dynamic>>.from(exercise['quiz'] ?? []);
    final exerciseIndex = selectedExerciseIndex!;

    if (quiz.isEmpty) {
      return GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: AppColors.chipTopic, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Evaluación de conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'No hay preguntas disponibles',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
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
                Icon(Icons.quiz, color: AppColors.chipTopic, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Evaluación de conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Has agotado todos tus intentos. No puedes responder más preguntas.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.error),
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
              Icon(Icons.quiz, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Evaluación de conocimiento',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...quiz.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;
            final options = List<String>.from(question['options'] ?? []);
            final correctAnswer = question['correctAnswer'] as int?;
            final isIncomplete =
                userAnswers[exerciseIndex][questionIndex] == null;
            final isAnswered = answeredQuestions[exerciseIndex][questionIndex];

            if (options.isEmpty || correctAnswer == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Error: Pregunta inválida',
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: AppColors.error),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._formatQuestion(question['question']?.toString() ??
                        'Pregunta no disponible')
                    .map((widget) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: widget,
                        )),
                const SizedBox(height: 12),
                ...options.asMap().entries.map((optionEntry) {
                  final optionIndex = optionEntry.key;
                  final optionText = optionEntry.value;
                  final isSelected =
                      userAnswers[exerciseIndex][questionIndex] == optionIndex;
                  final isCorrect = optionIndex == correctAnswer;

                  Color textColor = AppColors.textPrimary;
                  Color borderColor = AppColors.progressActive.withOpacity(0.5);
                  Color bgColor = AppColors.glassmorphicBackground;

                  if (isSelected) {
                    borderColor =
                        isCorrect ? AppColors.success : AppColors.error;
                    bgColor = isCorrect
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2);
                    textColor = AppColors.textPrimary;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: (isAnswered || _isAttemptsExhausted)
                          ? null
                          : () {
                              setState(() {
                                userAnswers[exerciseIndex][questionIndex] =
                                    optionIndex;
                                answeredQuestions[exerciseIndex]
                                    [questionIndex] = true;
                                exerciseCompleted[exerciseIndex] =
                                    userAnswers[exerciseIndex]
                                        .every((answer) => answer != null);

                                final snackBar = SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: AppColors.textPrimary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isCorrect
                                              ? '¡Correcto!'
                                              : 'Incorrecto, la respuesta correcta es: "${options[correctAnswer]}"',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            if (isIncomplete && !isAnswered)
                              BoxShadow(
                                color:
                                    AppColors.progressActive.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor),
                                color: isSelected
                                    ? borderColor
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      size: 14,
                                      color: AppColors.textPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                optionText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(
                        delay: (100 * optionIndex).ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack),
                  );
                }),
                const SizedBox(height: 14),
              ],
            );
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
              Icon(Icons.tag, color: AppColors.chipTopic, size: 22),
              const SizedBox(width: 8),
              Text(
                'Temas relacionados',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            Text(
              'No se especificaron temas',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
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
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textPrimary),
                  ),
                  backgroundColor: AppColors.chipTopic,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Center(
      child: _buildAnimatedButton(
        text: 'Finalizar',
        onPressed: exerciseCompleted[selectedExerciseIndex!]
            ? _showCompletionDialog
            : null,
        gradient: LinearGradient(
          colors: exerciseCompleted[selectedExerciseIndex!]
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [Colors.grey.shade600, Colors.grey.shade400],
        ),
      ).animate().scale(
          delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback? onPressed,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }

  void _showCompletionDialog() {
    final exerciseIndex = selectedExerciseIndex!;
    final correctAnswers = _calculateCorrectAnswersForSection(exerciseIndex);
    final totalQuestions =
        (exercises[exerciseIndex]['quiz'] as List<dynamic>?)?.length ?? 0;
    final percentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;
    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      sectionScores[exerciseIndex] = correctAnswers;
    });

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          minWidth: 280,
        ),
        child: AlertDialog(
          backgroundColor: AppColors.glassmorphicBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Icon(Icons.celebration,
                  color: AppColors.progressActive, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sección completada',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
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
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: AppColors.textPrimary),
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
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(percentage)),
                      ).animate().fadeIn(duration: 600.ms),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: _getScoreColor(percentage).withOpacity(0.5),
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
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: AppColors.textPrimary),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    'Nivel: ${_getGradeLevel(percentage)}',
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: AppColors.textPrimary),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Revisar',
                style: GoogleFonts.poppins(color: AppColors.progressActive),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedExercise = null;
                  selectedExerciseIndex = null;
                });
              },
              child: Text(
                'Continuar',
                style: GoogleFonts.poppins(color: AppColors.progressActive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalCompletionDialog() {
    final correctAnswers = _calculateTotalCorrectAnswers();
    final totalQuestions = _getTotalQuestions();
    final percentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;
    final screenWidth = MediaQuery.of(context).size.width;

    if (!_isFinalGradeSubmitted) {
      _saveFinalGrade(percentage);
      setState(() {
        _isFinalGradeSubmitted = true;
      });
    }

    _resetLocalState();

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
              backgroundColor: AppColors.glassmorphicBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  Icon(Icons.celebration,
                      color: AppColors.progressActive, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Evaluación completada',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
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
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: AppColors.textPrimary),
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
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(percentage)),
                          ).animate().fadeIn(duration: 600.ms),
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: _getScoreColor(percentage)
                                      .withOpacity(0.5),
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
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: AppColors.textPrimary),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        'Nivel: ${_getGradeLevel(percentage)}',
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: AppColors.textPrimary),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    if (percentage < 70)
                      Flexible(
                        child: Text(
                          'Se ha descontado 1 intento porque tu puntuación es menor a 70%. Intentos restantes: $_remainingAttempts',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.error),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Module2IntroScreen(
                              module: widget.actividadesData)),
                    );
                  },
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(color: AppColors.progressActive),
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
              colors: [
                AppColors.progressActive,
                AppColors.success,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCorrectAnswersForSection(int exerciseIndex) {
    int correct = 0;
    final quiz =
        List<Map<String, dynamic>>.from(exercises[exerciseIndex]['quiz'] ?? []);
    for (var j = 0; j < quiz.length; j++) {
      final correctAnswer = quiz[j]['correctAnswer'];
      if (userAnswers[exerciseIndex][j] == correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  int _calculateTotalCorrectAnswers() {
    return sectionScores.values.fold(0, (total, score) => total + score);
  }

  int _getTotalQuestions() {
    return exercises
        .where((e) => e.containsKey('quiz'))
        .fold(0, (total, e) => total + (e['quiz'] as List<dynamic>).length);
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 70) return AppColors.progressActive;
    if (percentage >= 50) return Colors.orange;
    return AppColors.error;
  }

  String _getGradeLevel(int percentage) {
    final conversion =
        List<Map<String, dynamic>>.from(gradingInfo['scoreConversion'] ?? []);
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
    final criteria =
        List<Map<String, dynamic>>.from(gradingInfo['criteria'] ?? []);
    final conversion =
        List<Map<String, dynamic>>.from(gradingInfo['scoreConversion'] ?? []);
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          minWidth: 280,
        ),
        child: AlertDialog(
          backgroundColor: AppColors.glassmorphicBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Icon(Icons.info, color: AppColors.progressActive, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Criterios de Evaluación',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
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
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 12),
                if (criteria.isEmpty)
                  Text(
                    'No se especificaron criterios',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                  ).animate().fadeIn(delay: 200.ms)
                else
                  ...criteria.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final criterion = entry.value;
                    final aspectText =
                        '${criterion['aspect']}: ${(criterion['weight'] * 100).toInt()}%';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.fiber_manual_record,
                              size: 10, color: AppColors.progressActive),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              aspectText,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.textSecondary),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (100 * index).ms, duration: 400.ms);
                  }),
                const SizedBox(height: 18),
                Text(
                  'Escala de calificaciones',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                if (conversion.isEmpty)
                  Text(
                    'No se especificó escala',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                  ).animate().fadeIn(delay: 400.ms)
                else
                  ...conversion.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final grade = entry.value;
                    final gradeText = '${grade['range']}: ${grade['grade']}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.fiber_manual_record,
                              size: 10, color: AppColors.progressActive),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              gradeText,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.textSecondary),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (100 * index).ms, duration: 400.ms);
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(color: AppColors.progressActive),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}