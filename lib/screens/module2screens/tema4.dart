import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  State<Tema4> createState() => Tema4State();
}

class Tema4State extends State<Tema4> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic>? _contentData;
  YoutubePlayerController? _youtubeController;
  bool _videoError = false;
  bool _showVideo = false;
  final _scrollController = ScrollController();
  final _pageController = PageController();
  int _currentPage = 0;
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
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );
    _loadContentData();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController?.pause();
    _youtubeController?.dispose();
    _scrollController.dispose();
    _pageController.dispose();
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

  void initializeVideo() {
    setState(() {
      _showVideo = true;
      try {
        _youtubeController = YoutubePlayerController(
          initialVideoId: _contentData?['video']?['id']?.toString() ?? 'walAu_skXHA',
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
            disableDragSeek: false,
            loop: false,
            enableCaption: true,
            hideThumbnail: false,
          ),
        )..addListener(() {
            if (_youtubeController!.value.hasError && !_videoError) {
              setState(() {
                _videoError = true;
              });
            }
          });
      } catch (e) {
        debugPrint('Error initializing video: $e');
        setState(() {
          _videoError = true;
        });
      }
    });
  }

  Widget buildSectionImage() {
    final imageUrl = _contentData?['sectionImage']?.toString() ??
        'https://img.freepik.com/free-vector/programming-concept-illustration_114360-1351.jpg';
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

  Widget buildVideoPlayer() {
    if (!_showVideo) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: initializeVideo,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
            ),
          ),
        ),
      );
    }

    if (_videoError) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'No se pudo cargar el video',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Por favor, intenta de nuevo más tarde.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: initializeVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blue,
            progressColors: ProgressBarColors(
              playedColor: Colors.blue,
              handleColor: Colors.blue,
              bufferedColor: Colors.blue.withValues(alpha: 0.3),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
            ),
            onReady: () {
              _youtubeController!.unMute();
            },
            onEnded: (metaData) {
              _youtubeController!.pause();
            },
          ),
        ),
      ),
    );
  }

  List<Widget> formatContent(String content) {
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
        final code = trimmed.substring(1, trimmed.length - 1);
        textWidget = buildCodeBox(
          code,
          language: 'dart',
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

  Widget buildHighlightBox(Map<String, dynamic> highlight) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: getHighlightColor(highlight['color'] as String?),
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
          ...formatContent(highlight['text'] as String),
        ],
      ),
    );
  }

  Widget buildCodeBox(String code, {String language = 'plaintext'}) {
    if (code.isEmpty) {
      return const Text(
        'Código no disponible',
        style: TextStyle(color: Colors.white70),
      );
    }

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
        color: const Color(0xFF0A2463).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3E92CC).withValues(alpha: 0.4)),
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

  Color getHighlightColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'blue':
        return Colors.blue.withValues(alpha: 0.2);
      case 'green':
        return Colors.green.withValues(alpha: 0.2);
      case 'lightgreen':
        return Colors.lightGreen.withValues(alpha: 0.2);
      case 'orange':
        return Colors.orange.withValues(alpha: 0.2);
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  Widget buildQuiz(Map<String, dynamic> quiz, int quizIndex) {
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

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withValues(alpha: 0.1),
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
                initiallyExpanded: true,
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
                      child: buildCodeBox(
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
                  onChanged: showFeedback
                      ? null
                      : (value) {
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
                onChanged: showFeedback
                    ? null
                    : (value) {
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
                onChanged: showFeedback
                    ? null
                    : (value) {
                        setState(() {
                          _selectedAnswers[quizIndex] = value;
                          _showFeedback[quizIndex] = false;
                        });
                      },
              ),
            ],
            const SizedBox(height: 12),
            if (selectedAnswer != null && !showFeedback)
              ElevatedButton(
                onPressed: () {
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
            if (showFeedback)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  selectedAnswer == respuestaCorrecta ? '¡Correcto!' : 'Incorrecto',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedAnswer == respuestaCorrecta ? Colors.green : Colors.red,
                  ),
                ),
              ),
            if (showFeedback && explicacion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: buildHighlightBox({
                  'text': explicacion,
                  'color': 'green',
                  'title': 'Explicación',
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSubtemaPage(int index, int totalPages) {
    final introduccion = _contentData!['introduccion'] as Map<String, dynamic>? ?? {};
    final subtema1 = _contentData!['subtema1'] as Map<String, dynamic>? ?? {};
    final subtema2 = _contentData!['subtema2'] as Map<String, dynamic>? ?? {};
    final subtema3 = _contentData!['subtema3'] as Map<String, dynamic>? ?? {};
    final quizzes = (subtema3['quizzes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Introducción',
        'content': [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    introduccion['titulo']?.toString() ?? 'Introducción',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...formatContent(introduccion['contenido']?.toString() ?? ''),
                ],
              ),
            ),
          ),
        ],
      },
      {
        'title': 'Patrones Numéricos',
        'content': [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white.withValues(alpha: 0.1),
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
                  ...formatContent(subtema1['contenido']?.toString() ?? ''),
                  if (subtema1['nota'] != null)
                    buildHighlightBox({
                      'text': subtema1['nota']['contenido']?.toString() ?? '',
                      'color': subtema1['nota']['color']?.toString() ?? 'blue',
                    }),
                ],
              ),
            ),
          ),
        ],
      },
      {
        'title': 'Validación de Entrada',
        'content': [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white.withValues(alpha: 0.1),
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
                  ...formatContent(subtema2['contenido']?.toString() ?? ''),
                  if (subtema2['nota'] != null)
                    buildHighlightBox({
                      'text': subtema2['nota']['contenido']?.toString() ?? '',
                      'color': subtema2['nota']['color']?.toString() ?? 'blue',
                    }),
                ],
              ),
            ),
          ),
        ],
      },
      {
        'title': 'Procesamiento de Cadenas',
        'content': [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white.withValues(alpha: 0.1),
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
                  ...formatContent(subtema3['contenido']?.toString() ?? ''),
                  if (subtema3['nota'] != null)
                    buildHighlightBox({
                      'text': subtema3['nota']['contenido']?.toString() ?? '',
                      'color': subtema3['nota']['color']?.toString() ?? 'blue',
                    }),
                ],
              ),
            ),
          ),
        ],
      },
      {
        'title': 'Ejercicios Prácticos',
        'content': [
          if (quizzes.isNotEmpty) ...[
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
            ...quizzes.asMap().entries.map((entry) => buildQuiz(entry.value, entry.key)),
          ],
        ],
      },
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) ...[
              SlideTransition(
                position: _slideAnimation,
                child: buildSectionImage(),
              ),
              const SizedBox(height: 16),
            ],
            ...pages[index]['content'],
            if (index == totalPages - 1) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Video Explicativo',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _contentData?['video']?['description']?.toString() ?? 'Aprende más con este video tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              buildVideoPlayer(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void navigateNext() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete(widget.sectionIndex);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Module2IntroScreen(
            module: widget.moduleData,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Future<bool> navigateBack() async {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Module2IntroScreen(
            module: widget.moduleData,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      return true;
    }
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

    const totalPages = 5; // Introduccion, Subtema1, Subtema2, Subtema3, Quizzes

    return WillPopScope(
      onWillPop: navigateBack,
      child: Scaffold(
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
          onPressed: navigateNext,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[900],
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            _currentPage < totalPages - 1 ? 'Continuar' : 'Completar módulo',
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
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _selectedAnswers.clear();
                  _showFeedback.clear();
                });
              },
              itemCount: totalPages,
              itemBuilder: (context, index) {
                return buildSubtemaPage(index, totalPages);
              },
            ),
          ),
        ),
      ),
    );
  }
}