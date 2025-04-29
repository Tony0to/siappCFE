import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siapp/screens/module2screens/flowcharts2.dart';
import 'package:siapp/screens/module2.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

class Tema4 extends StatefulWidget {
  final Map<String, dynamic> section;
  final String sectionTitle;
  final int sectionIndex;
  final int totalSections;
  final Map<String, dynamic> content;
  final Map<String, dynamic> moduleData;
  final Function(int) onComplete;

  const Tema4({
    super.key,
    required this.section,
    required this.sectionTitle,
    required this.sectionIndex,
    required this.totalSections,
    required this.content,
    required this.moduleData,
    required this.onComplete,
  });

  @override
  State<Tema4> createState() => _Tema4State();
}

class _Tema4State extends State<Tema4> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? _contentData;
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool> _showFeedback = {};
  final Map<int, TransformationController> _transformationControllers = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _loadContentData();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContentData() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/data/module2/tema4.json');
      final data = jsonDecode(response) as Map<String, dynamic>;
      setState(() {
        _contentData = data;
        final quizzes = (data['subtema3']?['quizzes'] as List<dynamic>? ?? []);
        for (int i = 0; i < quizzes.length; i++) {
          _transformationControllers[i] = TransformationController();
        }
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      setState(() {
        _contentData = {};
      });
    }
  }

  Widget _buildSectionImage() {
    const imageUrl = 'https://img.freepik.com/free-vector/programming-concept-illustration_114360-1351.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200]!.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200]!.withValues(alpha: 0.3),
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _formatContent(String content) {
    return content.split('\n').map((paragraph) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) return const SizedBox(height: 12);

      Widget textWidget;
      if (trimmed.startsWith('•')) {
        textWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fiber_manual_record, size: 10, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trimmed.substring(1).trim(),
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        );
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        // Handle inline code snippets
        final code = trimmed.substring(1, trimmed.length - 1);
        textWidget = _buildCodeBox(
          code,
          language: 'dart', // Adjust based on context; assuming Dart for examples
        );
      } else {
        textWidget = Text(
          trimmed,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: textWidget,
      );
    }).toList();
  }

  Widget _buildHighlightBox(Map<String, dynamic> highlight) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getHighlightColor(highlight['color'] as String?),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight['title'] != null)
            Text(
              highlight['title'] as String,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (highlight['title'] != null) const SizedBox(height: 8),
          ..._formatContent(highlight['text'] as String),
        ],
      ),
    );
  }

  Widget _buildCodeBox(String code, {String language = 'plaintext'}) {
    if (code.isEmpty) {
      return const Text(
        'Código no disponible',
        style: TextStyle(color: Colors.white70),
      );
    }

    // Map language to flutter_highlighter language IDs
    String highlightLanguage;
    switch (language.toLowerCase()) {
      case 'javascript':
        highlightLanguage = 'javascript';
        break;
      case 'python':
        highlightLanguage = 'python';
        break;
      case 'java':
        highlightLanguage = 'java';
        break;
      case 'c++':
        highlightLanguage = 'cpp';
        break;
      case 'dart':
        highlightLanguage = 'dart';
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
                child: HighlightView(
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

  Color _getHighlightColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'blue':
        return const Color(0x2127AE60);
      case 'green':
        return const Color(0x214CAF50);
      case 'lightgreen':
        return const Color(0x218BC34A);
      case 'orange':
        return const Color(0x21FF9800);
      default:
        return const Color(0x1AFFFFFF);
    }
  }

  Widget _buildQuiz(Map<String, dynamic> quiz, int quizIndex) {
    final tipo = quiz['tipo'] as String? ?? 'unknown';
    final pregunta = quiz['pregunta'] as Map<String, dynamic>? ?? {};
    final opciones = (pregunta['opciones'] as List<dynamic>?)?.cast<String>() ?? [];
    final respuestaCorrecta = pregunta['respuesta_correcta'] as String? ?? (tipo == 'true_false' ? 'true' : '');
    final explicacion = pregunta['explicacion'] as String? ?? 'Sin explicación disponible';
    final selectedAnswer = _selectedAnswers[quizIndex];
    final showFeedback = _showFeedback[quizIndex] ?? false;

    final controller = _transformationControllers[quizIndex] ?? TransformationController();
    final containerWidth = MediaQuery.of(context).size.width * 0.95;
    const containerHeight = 600.0;
    const initialScale = 0.6;

    void zoomIn() {
      final currentScale = controller.value.getMaxScaleOnAxis();
      final newScale = currentScale * 1.2;
      controller.value = Matrix4.identity()..scale(newScale);
    }

    void zoomOut() {
      final currentScale = controller.value.getMaxScaleOnAxis();
      final newScale = (currentScale / 1.2).clamp(0.3, 4.0);
      controller.value = Matrix4.identity()..scale(newScale);
    }

    void resetZoom() {
      controller.value = Matrix4.identity()..scale(initialScale);
    }

    // Debug pseudocode rendering
    if (quiz['diagrama_flujo']?['pseudocodigo'] != null) {
      debugPrint('Rendering pseudocode for quiz $quizIndex: ${quiz['diagrama_flujo']['pseudocodigo']}');
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0x1AFFFFFF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz['titulo']?.toString() ?? 'Quiz sin título',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quiz['enunciado']?.toString() ?? 'Sin enunciado',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
            ),
            if (tipo == 'flowchart') ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  'Algoritmo',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: (quiz['algoritmo'] as List<dynamic>? ?? [])
                          .map((step) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.arrow_right, size: 16, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        step.toString(),
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                initiallyExpanded: true, // Expand by default for visibility
                title: Text(
                  'Diagrama de Flujo',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ClipRect(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: containerWidth,
                                maxHeight: containerHeight,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InteractiveViewer(
                                  transformationController: controller,
                                  minScale: 0.3,
                                  maxScale: 4.0,
                                  boundaryMargin: const EdgeInsets.all(20),
                                  constrained: false,
                                  onInteractionStart: (_) {
                                    if (controller.value.getMaxScaleOnAxis() == 1.0) {
                                      controller.value = Matrix4.identity()..scale(initialScale);
                                    }
                                  },
                                  child: Center(
                                    child: (quiz['diagrama_flujo'] != null &&
                                            quiz['diagrama_flujo']['id'] != null)
                                        ? Builder(
                                            builder: (context) {
                                              try {
                                                return FlowCharts.getFlowChart(quiz['diagrama_flujo']['id'] as String);
                                              } catch (e) {
                                                return const Text(
                                                  'Error al cargar el diagrama',
                                                  style: TextStyle(color: Colors.white70),
                                                );
                                              }
                                            },
                                          )
                                        : const Text(
                                            'Diagrama no disponible',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.zoom_in, color: Colors.white),
                              onPressed: zoomIn,
                              tooltip: 'Acercar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_out, color: Colors.white),
                              onPressed: zoomOut,
                              tooltip: 'Alejar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: resetZoom,
                              tooltip: 'Restablecer',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (quiz['diagrama_flujo']?['descripcion'] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        quiz['diagrama_flujo']['descripcion'] as String,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                      ),
                    ),
                  if (quiz['diagrama_flujo']?['pseudocodigo'] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildCodeBox(
                        quiz['diagrama_flujo']['pseudocodigo'] as String,
                        language: quiz['diagrama_flujo']['lenguaje']?.toString() ?? 'pseudocode',
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Pseudocódigo no disponible',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Análisis',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      quiz['analisis']?.toString() ?? 'Sin análisis',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              pregunta['texto']?.toString() ?? 'Pregunta no disponible',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (tipo == 'multiple_choice' || tipo == 'flowchart') ...[
              ...opciones.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                  value: option,
                  groupValue: selectedAnswer,
                  activeColor: Colors.blue[300],
                  onChanged: (value) {
                    setState(() {
                      _selectedAnswers[quizIndex] = value;
                      _showFeedback[quizIndex] = false;
                    });
                  },
                );
              }),
            ] else if (tipo == 'true_false') ...[
              RadioListTile<String>(
                title: Text(
                  'Verdadero',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                value: 'true',
                groupValue: selectedAnswer,
                activeColor: Colors.blue[300],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[quizIndex] = value;
                    _showFeedback[quizIndex] = false;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text(
                  'Falso',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                value: 'false',
                groupValue: selectedAnswer,
                activeColor: Colors.blue[300],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[quizIndex] = value;
                    _showFeedback[quizIndex] = false;
                  });
                },
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: selectedAnswer == null
                  ? null
                  : () {
                      setState(() {
                        _showFeedback[quizIndex] = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Enviar Respuesta',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            if (showFeedback) ...[
              const SizedBox(height: 12),
              _buildHighlightBox({
                'text': selectedAnswer == respuestaCorrecta
                    ? '¡Correcto! $explicacion'
                    : 'Incorrecto. La respuesta correcta es: $respuestaCorrecta\n\n$explicacion',
                'color': selectedAnswer == respuestaCorrecta ? 'green' : 'orange',
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateNext() {
    widget.onComplete(widget.sectionIndex);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Module2IntroScreen(module: widget.moduleData)),
      (route) => route.settings.name == '/module2' || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final introduccion = _contentData!['introduccion'] as Map<String, dynamic>? ?? {};
    final subtema1 = _contentData!['subtema1'] as Map<String, dynamic>? ?? {};
    final subtema2 = _contentData!['subtema2'] as Map<String, dynamic>? ?? {};
    final subtema3 = _contentData!['subtema3'] as Map<String, dynamic>? ?? {};
    final quizzes = (subtema3['quizzes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.sectionTitle,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateNext,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        icon: const Icon(Icons.check),
        label: Text(
          'Completar Módulo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSectionImage(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  introduccion['titulo']?.toString() ?? 'Introducción',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ..._formatContent(introduccion['contenido']?.toString() ?? ''),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0x1AFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtema1['titulo']?.toString() ?? 'Subtema 1',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._formatContent(subtema1['contenido']?.toString() ?? ''),
                        if (subtema1['nota'] != null)
                          _buildHighlightBox({
                            'text': subtema1['nota']['contenido']?.toString() ?? '',
                            'color': subtema1['nota']['color']?.toString() ?? 'blue',
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0x1AFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtema2['titulo']?.toString() ?? 'Subtema 2',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._formatContent(subtema2['contenido']?.toString() ?? ''),
                        if (subtema2['nota'] != null)
                          _buildHighlightBox({
                            'text': subtema2['nota']['contenido']?.toString() ?? '',
                            'color': subtema2['nota']['color']?.toString() ?? 'blue',
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0x1AFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtema3['titulo']?.toString() ?? 'Subtema 3',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._formatContent(subtema3['contenido']?.toString() ?? ''),
                        if (subtema3['nota'] != null)
                          _buildHighlightBox({
                            'text': subtema3['nota']['contenido']?.toString() ?? '',
                            'color': subtema3['nota']['color']?.toString() ?? 'blue',
                          }),
                      ],
                    ),
                  ),
                ),
                if (quizzes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Ejercicios Prácticos',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Resuelve estos ejercicios para practicar lo aprendido:',
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ...quizzes.asMap().entries.map((entry) => _buildQuiz(entry.value, entry.key)),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}