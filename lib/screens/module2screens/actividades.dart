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
import 'flowcharts3.dart';
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scrollController = ScrollController();
    sectionScores = {};
    _isFinalGradeSubmitted = false;
    debugPrint('ActividadesScreen initState: actividadesData = ${widget.actividadesData}');
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
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/module2/actividades.json');
      final data = json.decode(jsonString);
      if (data['activities'] == null) {
        throw Exception('JSON does not contain "activities" key');
      }

      final activities = data['activities'] as Map<String, dynamic>;
      setState(() {
        _contentData = activities;
        exercises = List<Map<String, dynamic>>.from(activities['exercises'] ?? []);
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
      (i) => List<int?>.filled((exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, null),
    );
    answeredQuestions = List<List<bool>>.generate(
      exercises.length,
      (i) => List<bool>.filled((exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, false),
    );
    exerciseCompleted = List<bool>.filled(exercises.length, false);
  }

  void _resetLocalState() {
    setState(() {
      userAnswers = List<List<int?>>.generate(
        exercises.length,
        (i) => List<int?>.filled((exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, null),
      );
      answeredQuestions = List<List<bool>>.generate(
        exercises.length,
        (i) => List<bool>.filled((exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0, false),
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

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'])
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
            .doc(widget.actividadesData['id'])
            .set({
              'intentos': 3,
              'last_updated': FieldValue.serverTimestamp(),
              'module_id': widget.actividadesData['id'],
              'module_title': widget.actividadesData['module_title'] ?? 'Módulo',
            }, SetOptions(merge: true));

        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los intentos: $e';
      });
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
          .doc(widget.actividadesData['id'])
          .set({
            'intentos': newAttempts,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar los intentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          .doc(widget.actividadesData['id'])
          .set({
            'calf': percentage,
            'quiz_completed': quizCompleted,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (percentage < 70) {
        await _decrementAttempts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Widget _buildCodeBox(String code, {String language = 'plaintext', bool selectable = false}) {
    if (code.isEmpty) {
      return const Text(
        'Código no disponible',
        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(10, 36, 99, 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(62, 146, 204, 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3E92CC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              language.toLowerCase() == 'pseudocode' ? 'Pseudocódigo' : 'Código',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      )
                    : HighlightView(
                        code,
                        language: highlightLanguage,
                        theme: githubTheme,
                        padding: const EdgeInsets.all(12),
                        textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 14,
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    if (matches.isEmpty) {
      widgets.add(
        Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
        body: _buildLoadingScreen(message: _errorMessage ?? 'Cargando actividades...'),
      );
    }

    if (exercises.isEmpty) {
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
              selectedExercise == null ? _buildMainMenu() : _buildExerciseDetail(),
              if (selectedExercise != null) ...[
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: 'back_button',
                    onPressed: () {
                      setState(() {
                        selectedExercise = null;
                        selectedExerciseIndex = null;
                      });
                    },
                    backgroundColor: const Color(0xFF3B82F6),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'grading_button',
                    onPressed: _showGradingInfo,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: const Icon(Icons.score, color: Colors.white),
                  ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    final allCompleted = exerciseCompleted.every((completed) => completed);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _contentData?['sectionTitle']?.toString() ?? 'Actividades',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 10),
          Text(
            _contentData?['sectionDescription']?.toString() ?? 'Selecciona un ejercicio para continuar.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color.fromRGBO(255, 255, 255, 0.7),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseButton(
                  title: exercise['title']?.toString() ?? 'Ejercicio ${index + 1}',
                  isCompleted: exerciseCompleted[index],
                  onPressed: () {
                    setState(() {
                      selectedExercise = exercise;
                      selectedExerciseIndex = index;
                      _initializeExerciseData();
                    });
                  },
                ).animate().scale(delay: (100 * index).ms, duration: 400.ms, curve: Curves.easeOutBack);
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildAnimatedButton(
            text: 'Completar',
            onPressed: allCompleted && !_isAttemptsExhausted && !_isFinalGradeSubmitted ? _showFinalCompletionDialog : null,
            gradient: LinearGradient(
              colors: allCompleted && !_isAttemptsExhausted && !_isFinalGradeSubmitted
                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                  : [Colors.grey.shade600, Colors.grey.shade400],
            ),
          ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildExerciseButton({required String title, required bool isCompleted, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                  color: const Color(0xFF10B981),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetail() {
    final currentExercise = selectedExercise!;
    final isDiagramExercise = currentExercise.containsKey('flowchart');

    return SingleChildScrollView(
      controller: _scrollController,
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
              color: const Color.fromRGBO(255, 255, 255, 0.7),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 20),
          Text(
            currentExercise['description']?.toString() ?? 'Descripción no disponible',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color.fromRGBO(255, 255, 255, 0.7),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 20),
          if (isDiagramExercise) ...[
            _buildFlowChartSection(currentExercise).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
            _buildPseudocodeSection(currentExercise).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
          ],
          _buildRequirementsSection(currentExercise).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          if (!isDiagramExercise) ...[
            _buildExamplesSection(currentExercise).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
          ],
          _buildQuizQuestions(currentExercise).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          _buildRelatedTopics(currentExercise).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 30),
          _buildNavigationControls().animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicio ${selectedExerciseIndex! + 1} de ${exercises.length}',
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
                value: (selectedExerciseIndex! + 1) / exercises.length,
                minHeight: 8,
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.24),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ).animate().fadeIn(duration: 600.ms),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
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
              color: const Color.fromRGBO(255, 255, 255, 0.9),
            ),
          ),
          Text(
            '$_remainingAttempts',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _remainingAttempts > 0 ? const Color.fromRGBO(255, 255, 255, 0.9) : Colors.redAccent,
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

  Widget _buildFlowChartSection(Map<String, dynamic> exercise) {
    final flowchart = exercise['flowchart'] as Map<String, dynamic>;
    final flowchartId = flowchart['flowchartId'].toString();

    final flowchartConfig = {
      'identificador_primos': {'scale': 0.8, 'height': 600.0, 'width': 500.0},
      'conversor_temperaturas': {'scale': 0.8, 'height': 800.0, 'width': 600.0},
    };

    final config = flowchartConfig[flowchartId] ?? {'scale': 0.8, 'height': 600.0, 'width': 500.0};

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Diagrama de Flujo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            flowchart['description']?.toString() ?? 'Descripción no disponible',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color.fromRGBO(255, 255, 255, 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: config['height'] as double,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 2.0,
                child: Center(
                  child: SizedBox(
                    width: config['width'] as double,
                    height: config['height'] as double,
                    child: FlowCharts3.getFlowChart(flowchartId) ?? const Text('Error: Diagrama no disponible', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pellizca para hacer zoom • Desliza para mover',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color.fromRGBO(255, 255, 255, 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPseudocodeSection(Map<String, dynamic> exercise) {
    final pseudocode = exercise['pseudocode']?.toString() ?? 'Pseudocódigo no disponible';

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Pseudocódigo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
              const Icon(Icons.checklist, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Requisitos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (requirements.isEmpty)
            Text(
              'No se especificaron requisitos',
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
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
                    const Icon(Icons.fiber_manual_record, size: 12, color: Color(0xFF93C5FD)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
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
              const Icon(Icons.lightbulb, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              Text(
                'Ejemplo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Entrada: ${exercise['exampleInput']?.toString() ?? 'No especificado'}',
            style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'Salida: ${exercise['exampleOutput']?.toString() ?? 'No especificado'}',
            style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
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
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
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
            final options = List<String>.from(question['options'] ?? []);
            final correctAnswer = question['correctAnswer'] as int?;
            final isIncomplete = userAnswers[exerciseIndex][questionIndex] == null;
            final isAnswered = answeredQuestions[exerciseIndex][questionIndex];

            if (options.isEmpty || correctAnswer == null) {
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
                ..._formatQuestion(question['question']?.toString() ?? 'Pregunta no disponible')
                    .map((widget) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: widget,
                        )),
                const SizedBox(height: 12),
                ...options.asMap().entries.map((optionEntry) {
                  final optionIndex = optionEntry.key;
                  final optionText = optionEntry.value;
                  final isSelected = userAnswers[exerciseIndex][questionIndex] == optionIndex;
                  final isCorrect = optionIndex == correctAnswer;

                  Color textColor = Colors.white;
                  Color borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.5);
                  Color bgColor = const Color.fromRGBO(255, 255, 255, 0.05);

                  if (isSelected) {
                    borderColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                    bgColor = isCorrect ? const Color.fromRGBO(16, 185, 129, 0.2) : const Color.fromRGBO(239, 68, 68, 0.2);
                    textColor = const Color.fromRGBO(255, 255, 255, 0.9);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: (isAnswered || _isAttemptsExhausted)
                          ? null
                          : () {
                              setState(() {
                                userAnswers[exerciseIndex][questionIndex] = optionIndex;
                                answeredQuestions[exerciseIndex][questionIndex] = true;
                                exerciseCompleted[exerciseIndex] = userAnswers[exerciseIndex].every((answer) => answer != null);

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
                                              : 'Incorrecto, la respuesta correcta es: "${options[correctAnswer]}"',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
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
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
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
                                color: isSelected ? borderColor : const Color.fromRGBO(0, 0, 0, 0.5),
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
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromRGBO(255, 255, 255, 0.7)),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedButton(
          text: 'Finalizar',
          onPressed: exerciseCompleted[selectedExerciseIndex!] ? _showCompletionDialog : null,
          gradient: LinearGradient(
            colors: exerciseCompleted[selectedExerciseIndex!]
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
              color: Colors.black.withValues(alpha: 0.2),
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

  void _showCompletionDialog() {
    final exerciseIndex = selectedExerciseIndex!;
    final correctAnswers = _calculateCorrectAnswersForSection(exerciseIndex);
    final totalQuestions = (exercises[exerciseIndex]['quiz'] as List<dynamic>?)?.length ?? 0;
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
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
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.celebration, color: Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sección completada',
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
                              color: _getScoreColor(percentage).withValues(alpha: 0.5),
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
                setState(() {
                  selectedExercise = null;
                  selectedExerciseIndex = null;
                });
              },
              child: Text(
                'Continuar',
                style: GoogleFonts.poppins(color: const Color(0xFF3B82F6)),
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
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
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
              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.95),
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
                                  color: Color.fromRGBO(
                                    _getScoreColor(percentage).r.toInt(),
                                    _getScoreColor(percentage).g.toInt(),
                                    _getScoreColor(percentage).b.toInt(),
                                    0.5,
                                  ),
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
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Module2IntroScreen(module: widget.actividadesData)),
                    );
                  },
                  child: Text(
                    'Cerrar',
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

  int _calculateCorrectAnswersForSection(int exerciseIndex) {
    int correct = 0;
    final quiz = List<Map<String, dynamic>>.from(exercises[exerciseIndex]['quiz'] ?? []);
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

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          minWidth: 280,
        ),
        child: AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.95),
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
                    ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}