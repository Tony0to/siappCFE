import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siapp/screens/module4screens/tema3.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

class Tema2 extends StatefulWidget {
  final Map<String, dynamic> section;
  final String sectionTitle;
  final int sectionIndex;
  final int totalSections;
  final Map<String, dynamic> content;
  final Map<String, dynamic> moduleData;
  final Function(int) onComplete;

  const Tema2({
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
  State<Tema2> createState() => Tema2State();
}

class Tema2State extends State<Tema2> with TickerProviderStateMixin {
  late AnimationController _controller;
  late YoutubePlayerController _youtubeController;
  late YoutubePlayerController _questionVideoController;
  bool _videoError = false;
  bool _questionVideoError = false;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;
  bool _isCompleted = false;

  // State for multiple-choice questions
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, String?> _correctAnswers = {};
  // Map to track visibility of explanations for each example
  final Map<String, bool> _explanationVisibility = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _loadJsonContent();

    // Initialize the main video controller
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: 'qfNCH9ajjOA',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: true,
          disableDragSeek: false,
          loop: false,
          enableCaption: true,
          hideThumbnail: false,
        ),
      )..addListener(() {
          if (_youtubeController.value.hasError && !_videoError) {
            setState(() {
              _videoError = true;
            });
          }
        });
    } catch (e) {
      setState(() {
        _videoError = true;
      });
    }

    // Initialize the question video controller
    try {
      _questionVideoController = YoutubePlayerController(
        initialVideoId: 'XRBvb0HqDwM',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: true,
          disableDragSeek: false,
          loop: false,
          enableCaption: true,
          hideThumbnail: false,
        ),
      )..addListener(() {
          if (_questionVideoController.value.hasError && !_questionVideoError) {
            setState(() {
              _questionVideoError = true;
            });
          }
        });
    } catch (e) {
      setState(() {
        _questionVideoError = true;
      });
    }
  }

  Future<void> _loadJsonContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module4/tema2.json');
      final data = json.decode(jsonString);
      setState(() {
        _contentData = data;
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController.dispose();
    _questionVideoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionImage() {
    final imageUrl = _contentData?['sectionImage'] as String?;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1E40AF),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1E40AF),
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                ),
              ),
            ),
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(30, 64, 175, 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contentData?['sectionTitle']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tema ${widget.sectionIndex + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _formatContent(String? content, {bool isIntro = false}) {
    if (content == null || content.isEmpty) return [const SizedBox.shrink()];
    
    return content.split('\n').map((paragraph) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) return const SizedBox(height: 12);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          trimmed,
          style: GoogleFonts.poppins(
            fontSize: isIntro ? 16 : 15,
            color: isIntro ? Colors.white : Colors.white.withValues(alpha: 0.9),
            fontWeight: isIntro ? FontWeight.w500 : FontWeight.normal,
            height: 1.6,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildVideoPlayer({bool isQuestionVideo = false}) {
    final bool errorState = isQuestionVideo ? _questionVideoError : _videoError;
    final YoutubePlayerController controller = isQuestionVideo ? _questionVideoController : _youtubeController;

    if (errorState) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromRGBO(30, 64, 175, 0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        progressColors: const ProgressBarColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
        ),
        onReady: () {
          controller.unMute();
        },
        onEnded: (metaData) {
          controller.pause();
        },
      ),
    );
  }

  void _navigateNext() {
    widget.onComplete(widget.sectionIndex);
    setState(() {
      _isCompleted = true;
    });

    // Navigate to Tema3
    if (widget.sectionIndex + 1 < widget.totalSections) {
      final nextSectionKey = widget.content.keys.elementAt(widget.sectionIndex + 1);
      final nextSection = widget.content[nextSectionKey];
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Tema3(
            section: nextSection,
            sectionTitle: "Programación orientada a objetos (POO)",
            sectionIndex: widget.sectionIndex + 1,
            totalSections: widget.totalSections,
            content: widget.content,
            moduleData: widget.moduleData,
            onComplete: widget.onComplete,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF93C5FD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(Map<String, dynamic>? example, int sectionIndex, int exampleIndex) {
    if (example == null) return const SizedBox.shrink();

    // Determinar el lenguaje según el título de la sección
    String? language;
    String? sectionTitle;

    final subsections = _contentData?['subsections'] as List<dynamic>?;
    if (subsections != null && sectionIndex < subsections.length) {
      final sectionData = subsections[sectionIndex] as Map<String, dynamic>?;
      sectionTitle = sectionData?['title'] as String?;
    }

    if (sectionTitle != null) {
      if (sectionTitle.contains("Programación Estructurada")) {
        language = 'cpp'; // Código en C
      } else if (sectionTitle.contains("Programación Modular")) {
        language = 'cpp'; // Código en C
      } else {
        language = 'dart'; // Por defecto, Dart
      }
    } else {
      language = 'dart'; // Si no se encuentra la sección, usar Dart por defecto
    }

    // Create a unique key for this example to track its explanation visibility
    final explanationKey = '${sectionIndex}_$exampleIndex';
    final isExplanationVisible = _explanationVisibility[explanationKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: example['color'] != null
            ? Color(int.parse(example['color'].replaceFirst('#', '0xFF'))).withValues(alpha: example['opacity'] ?? 1.0)
            : Color.fromRGBO(30, 64, 175, 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example['title'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    example['title']?.toString() ?? 'Ejemplo',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                  ),
                ),
              ),
            if (example['content'] != null) ...[
              const SizedBox(height: 16),
              if (example['content'] is List && (example['content'] as List).isNotEmpty)
                ...(example['content'] as List).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['subtitle'] != null)
                          Text(
                            item['subtitle'],
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ..._formatContent(item['text']?.toString()),
                      ],
                    ),
                  );
                })
              else if (example['content'] is String)
                ..._formatContent(example['content']?.toString()),
            ],
            if (example['code'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
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
                      example['code']?.toString() ?? '',
                      language: language,
                      theme: githubTheme,
                      padding: const EdgeInsets.all(8),
                      textStyle: GoogleFonts.sourceCodePro(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (example['explanation'] != null) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _explanationVisibility[explanationKey] = !isExplanationVisible;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isExplanationVisible ? 'Ocultar Explicación' : 'Ver Explicación',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            if (isExplanationVisible && example['explanation'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(6, 95, 70, 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explicación',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._formatContent(example['explanation']?.toString()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String? content, {Color? color, String? title}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(30, 64, 175, 0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ..._formatContent(content),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeQuestions(List<dynamic>? questions, int questionOffset) {
    if (questions == null || questions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 64, 175, 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: Color(0xFF93C5FD), size: 28),
              const SizedBox(width: 12),
              Text(
                'Práctica de Conocimiento',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...questions.asMap().entries.expand((entry) {
            final index = entry.key + questionOffset;
            final question = entry.value as Map<String, dynamic>;
            final questionText = question['text']?.toString() ?? '';

            final List<Widget> questionWidgets = [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta ${index + 1}: $questionText',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(question['options'] as List<dynamic>).map((option) {
                      final optionText = option.toString();
                      final isSelected = _selectedAnswers[index] == optionText;
                      final isCorrect = optionText == question['correct'].toString();
                      Color textColor = Colors.white;
                      Color borderColor = Color.fromRGBO(59, 130, 246, 0.5);
                      Color bgColor = Color.fromRGBO(30, 64, 175, 0.2);

                      if (_selectedAnswers[index] != null) {
                        if (isSelected && !isCorrect) {
                          textColor = Colors.white;
                          borderColor = const Color(0xFFEF4444);
                          bgColor = Color.fromRGBO(153, 27, 27, 0.2);
                        } else if (isSelected && isCorrect) {
                          textColor = Colors.white;
                          borderColor = const Color(0xFF10B981);
                          bgColor = Color.fromRGBO(6, 95, 70, 0.2);
                        } else if (isCorrect) {
                          textColor = Colors.white;
                          borderColor = const Color(0xFF10B981);
                          bgColor = Color.fromRGBO(6, 95, 70, 0.2);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedAnswers[index] = optionText;
                              _correctAnswers[index] = question['correct'].toString();
                              if (optionText == _correctAnswers[index]) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Correcto!',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Incorrecto, la respuesta correcta es ${question['correct']}',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: borderColor, width: 2),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          size: 16,
                                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ];

            // Add the video only after the specific question
            if (questionText == '¿Cuál de las siguientes es una estructura principal de la programación estructurada?') {
              questionWidgets.addAll([
                const SizedBox(height: 20),
                _buildVideoPlayer(isQuestionVideo: true),
              ]);
            }

            return questionWidgets;
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E40AF),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.sectionTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateNext,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E40AF),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          'Siguiente tema',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
                ),
                child: _buildSectionImage(),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4)),
                ),
                child: _buildNoteCard(
                  _contentData?['introText']?.toString(),
                  color: Color.fromRGBO(30, 64, 175, 0.35),
                ),
              ),
              ...(_contentData?['subsections'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                final sectionIndex = entry.key;
                final sectionData = entry.value as Map<String, dynamic>?;
                if (sectionData == null) return const SizedBox.shrink();

                final examples = sectionData['examples'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _buildSectionHeader(sectionData['title']?.toString()),
                    _buildNoteCard(sectionData['content']?.toString()),
                    const SizedBox(height: 12),
                    ...examples.asMap().entries.map((exampleEntry) {
                      final exampleIndex = exampleEntry.key;
                      final exampleData = exampleEntry.value as Map<String, dynamic>?;
                      if (exampleData == null) return const SizedBox.shrink();

                      return FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5)),
                        ),
                        child: _buildExampleCard(exampleData, sectionIndex, exampleIndex),
                      );
                    }),
                    if (sectionData['questions'] != null && (sectionData['questions'] as List).isNotEmpty) ...[
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)),
                        ),
                        child: _buildPracticeQuestions(sectionData['questions'], sectionIndex * 100),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(_contentData?['video']?['title']?.toString()),
                  Text(
                    _contentData?['video']?['description']?.toString() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _controller, curve: Interval(0.3, 0.6)),
                    ),
                    child: _buildVideoPlayer(),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}