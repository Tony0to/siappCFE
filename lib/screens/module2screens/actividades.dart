import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'flowcharts3.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

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
  late List<List<int?>> userAnswers;
  late List<List<bool>> answeredQuestions;
  late List<bool> exerciseCompleted;
  Map<String, dynamic>? _contentData;
  String? _errorMessage;
  late AnimationController _controller;
  late ConfettiController _confettiController;
  late ScrollController _scrollController;
  int _remainingAttempts = 3;
  bool _isAttemptsLoading = true;
  bool _isAttemptsExhausted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scrollController = ScrollController();
    debugPrint('ActividadesScreen initState: actividadesData = ${widget.actividadesData}');
    _loadAttemptsFromFirestore();
    _loadJsonContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAttemptsFromFirestore() async {
    setState(() {
      _isAttemptsLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado.';
          _isAttemptsLoading = false;
        });
        return;
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module2')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0;
          _isAttemptsLoading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(widget.actividadesData['id'] ?? 'module2')
            .set({
              'intentos': 3,
              'last_updated': FieldValue.serverTimestamp(),
              'module_id': widget.actividadesData['id'] ?? 'module2',
              'module_title': widget.actividadesData['module_title'] ?? 'Módulo',
            }, SetOptions(merge: true));

        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
          _isAttemptsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los intentos: $e';
        _isAttemptsLoading = false;
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
          .doc(widget.actividadesData['id'] ?? 'module2')
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

      final quizCompleted = percentage > 70;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module2')
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

  Future<void> _loadJsonContent() async {
    debugPrint('Starting _loadJsonContent');
    try {
      debugPrint('Loading assets/data/module2/actividades.json');
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/module2/actividades.json');
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
      setState(() {
        _contentData = null;
        _errorMessage = 'Error al cargar el contenido: $e\nVerifica assets/data/module2/actividades.json y pubspec.yaml.';
      });
    }
  }

  void _initializeData() {
    debugPrint('Initializing data');
    final activitiesData = _contentData ?? {};
    exercises = List<Map<String, dynamic>>.from(activitiesData['exercises'] ?? []);
    gradingInfo = Map<String, dynamic>.from(activitiesData['grading'] ?? {});
    debugPrint('Exercises count: ${exercises.length}');
    
    userAnswers = List<List<int?>>.generate(
      exercises.length,
      (i) {
        final quizLength = (exercises[i]['quiz'] as List<dynamic>?)?.length ?? 0;
        debugPrint('Exercise $i quiz length: $quizLength');
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
    exerciseCompleted = List<bool>.filled(exercises.length, false);
    debugPrint('Initialized data: ${exercises.length} exercises, grading: ${gradingInfo.keys}, userAnswers: $userAnswers, answeredQuestions: $answeredQuestions');
  }

  Widget _buildCodeBox(String code, {String language = 'plaintext', bool selectable = false}) {
    if (code.isEmpty) {
      return const Text(
        'Código no disponible',
        style: TextStyle(color: Colors.white70),
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
        color: const Color(0xFF0A2463).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3E92CC).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  color: Colors.black.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    debugPrint('Building ActividadesScreen, _contentData: ${_contentData != null}, _isAttemptsLoading: $_isAttemptsLoading');
    if (_contentData == null || _isAttemptsLoading) {
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
                Lottie.asset(
                  'assets/animations/loading.json',
                  width: 100,
                  height: 100,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..repeat();
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _errorMessage ?? 'Cargando actividades...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 500.ms),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Reintentar',
                    onPressed: () {
                      _loadAttemptsFromFirestore();
                      _loadJsonContent();
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
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
    final isDiagramExercise = currentExercise.containsKey('flowchart');
    debugPrint('Rendering exercise ${currentExercise['id']}, isDiagram: $isDiagramExercise');

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
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 20),
                    Text(
                      currentExercise['description']?.toString() ?? 'Descripción no disponible',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white70,
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
                backgroundColor: Colors.white.withOpacity(0.24),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ).animate().fadeIn(duration: 600.ms),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.9),
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

  Widget _buildFlowChartSection(Map<String, dynamic> exercise) {
    final flowchart = exercise['flowchart'] as Map<String, dynamic>;
    final flowchartId = flowchart['flowchartId'].toString();
    debugPrint('Rendering flowchart: $flowchartId');

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
              color: Colors.white70,
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
                  color: Colors.black.withOpacity(0.1),
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
              color: Colors.white70,
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
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Salida: ${exercise['exampleOutput']?.toString() ?? 'No especificado'}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  static const kDelimiter = '<DELIMITER>';
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
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
                ..._formatQuestion(question['question']?.toString() ?? 'Pregunta no disponible')
                    .map((widget) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: widget,
                        )),
                const SizedBox(height: 12),
                ...options.asMap().entries.map((optionEntry) {
                  final optionIndex = optionEntry.key;
                  final optionText = optionEntry.value;
                  final isSelected = userAnswers[currentExerciseIndex][questionIndex] == optionIndex;
                  final isCorrect = optionIndex == correctAnswer;

                  Color textColor = Colors.white;
                  Color borderColor = const Color(0xFF3B82F6).withOpacity(0.5);
                  Color bgColor = Colors.white.withOpacity(0.05);

                  if (isSelected) {
                    borderColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                    bgColor = isCorrect ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2);
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
                                exerciseCompleted[currentExerciseIndex] = userAnswers[currentExerciseIndex].every((answer) => answer != null);
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
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
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
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
              color: Colors.black.withOpacity(0.2),
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
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      _showCompletionDialog();
    }
  }

  bool _isCurrentExerciseComplete() {
    return userAnswers[currentExerciseIndex].every((answer) => answer != null);
  }

  void _showCompletionDialog() {
    final correctAnswers = _calculateCorrectAnswers();
    final totalQuestions = _getTotalQuestions();
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
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
              backgroundColor: Colors.white.withOpacity(0.95),
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
          final correctAnswer = quiz[j]['correctAnswer'];
          if (userAnswers[i][j] == correctAnswer) {
            correct++;
          }
        }
      }
    }
    return correct;
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
    debugPrint('Showing grading info: screenWidth=$screenWidth, criteria=$criteria, conversion=$conversion');

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          minWidth: 280,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}