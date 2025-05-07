import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siapp/screens/module4screens/tema2.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

class Tema1 extends StatefulWidget {
  final Map<String, dynamic> section;
  final String sectionTitle;
  final int sectionIndex;
  final int totalSections;
  final Map<String, dynamic> content;
  final Map<String, dynamic> moduleData;
  final Function(int) onComplete;

  const Tema1({
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
  State<Tema1> createState() => Tema1State();
}

class Tema1State extends State<Tema1> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  YoutubePlayerController? _youtubeController;
  bool _videoError = false;
  bool _showVideo = false;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;

  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool> _showFeedback = {};
  final Map<String, bool> _explanationVisibility = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.8)),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );
    _loadJsonContent();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController?.pause();
    _youtubeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module4/tema1.json');
      final data = json.decode(jsonString);
      setState(() {
        _contentData = data;
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
          initialVideoId: _contentData?['video']?['id']?.toString() ?? 'hcuvB58hwlE',
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
                  color: Colors.blue[900],
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.blue[900],
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
                  Colors.blue[900]!.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
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
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tema ${widget.sectionIndex + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoPlayer() {
    if (!_showVideo) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: initializeVideo,
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(top: 24),
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
        ),
      );
    }

    if (_videoError) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
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
                  'No se pudo cargar el video',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, intenta de nuevo más tarde.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
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
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue[400]!),
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
                  const Icon(Icons.video_library, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _contentData?['video']?['title']?.toString() ?? 'Video Complementario',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_contentData?['video']?['description']?.toString() != null) ...[
                Text(
                  _contentData?['video']?['description']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 16),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                  ),
                  onReady: () {
                    _youtubeController!.unMute();
                  },
                  onEnded: (metaData) {
                    _youtubeController!.pause();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> formatContent(String? content, {bool isIntro = false}) {
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
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      );
    }).toList();
  }

  Widget buildSectionHeader(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExampleCard(Map<String, dynamic>? example, int sectionIndex, int exampleIndex) {
    if (example == null) return const SizedBox.shrink();

    String? language;
    String? sectionTitle;

    final subsections = _contentData?['subsections'] as List<dynamic>?;
    if (subsections != null && sectionIndex < subsections.length) {
      final sectionData = subsections[sectionIndex] as Map<String, dynamic>?;
      sectionTitle = sectionData?['title'] as String?;
    }

    if (sectionTitle != null) {
      if (sectionTitle.contains("Programación Imperativa")) {
        language = 'cpp';
      } else if (sectionTitle.contains("Programación Declarativa")) {
        language = 'sql';
      } else if (sectionTitle.contains("Programación Funcional")) {
        language = 'javascript';
      } else if (sectionTitle.contains("Programación Lógica")) {
        language = 'prolog';
      } else {
        language = 'dart';
      }
    } else {
      language = 'dart';
    }

    final explanationKey = '${sectionIndex}_$exampleIndex';
    final isExplanationVisible = _explanationVisibility[explanationKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: example['color'] != null
            ? Color(int.parse(example['color'].replaceFirst('#', '0xFF'))).withValues(alpha: example['opacity'] ?? 1.0)
            : Colors.blue[900]!.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[400]!),
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
                    color: Colors.blue[600],
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
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ...formatContent(item['text']?.toString()),
                      ],
                    ),
                  );
                })
              else if (example['content'] is String)
                ...formatContent(example['content']?.toString()),
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
                    backgroundColor: Colors.blue[600],
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
                  color: Colors.green[900]!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
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
                    ...formatContent(example['explanation']?.toString()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildNoteCard(String? content, {Color? color, String? title}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color ?? Colors.blue[900]!.withValues(alpha: 0.3),
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
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ...formatContent(content),
          ],
        ),
      ),
    );
  }

  Widget buildPracticeQuestions(List<dynamic>? questions, int sectionIndex) {
    if (questions == null || questions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[400]!),
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
              const Icon(Icons.quiz, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Práctica de Conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value as Map<String, dynamic>;
            final uniqueIndex = (sectionIndex * 100) + questionIndex;
            final selectedAnswer = _selectedAnswers[uniqueIndex];
            final showFeedback = _showFeedback[uniqueIndex] ?? false;
            final isCorrect = selectedAnswer == question['correct'].toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pregunta ${questionIndex + 1}: ${question['text']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 12),
                  ...(question['options'] as List<dynamic>).map((option) {
                    final optionText = option.toString();
                    final isSelected = selectedAnswer == optionText;
                    final isOptionCorrect = optionText == question['correct'].toString();
                    Color textColor = Colors.white;
                    Color borderColor = Colors.blue[400]!;
                    Color bgColor = Colors.blue[900]!.withValues(alpha: 0.2);

                    if (showFeedback) {
                      if (isSelected && !isOptionCorrect) {
                        textColor = Colors.white;
                        borderColor = Colors.red;
                        bgColor = Colors.red[900]!.withValues(alpha: 0.2);
                      } else if (isSelected && isOptionCorrect) {
                        textColor = Colors.white;
                        borderColor = Colors.green;
                        bgColor = Colors.green[900]!.withValues(alpha: 0.2);
                      } else if (isOptionCorrect) {
                        textColor = Colors.white;
                        borderColor = Colors.green;
                        bgColor = Colors.green[900]!.withValues(alpha: 0.2);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: showFeedback
                            ? null
                            : () {
                                setState(() {
                                  _selectedAnswers[uniqueIndex] = optionText;
                                  _showFeedback[uniqueIndex] = true;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                        isOptionCorrect ? Icons.check : Icons.close,
                                        size: 16,
                                        color: isOptionCorrect ? Colors.green : Colors.red,
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
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (showFeedback)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        isCorrect ? '¡Correcto!' : 'Incorrecto',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  if (showFeedback && question['explanation'] != null && question['explanation'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[900]!.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
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
                            ...formatContent(question['explanation'].toString()),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void navigateNext() {
    widget.onComplete(widget.sectionIndex);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Tema2(
          section: widget.section,
          sectionTitle: 'Tema 2',
          sectionIndex: widget.sectionIndex + 1,
          totalSections: widget.totalSections,
          content: widget.content,
          moduleData: widget.moduleData,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return Scaffold(
        backgroundColor: Colors.blue[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[900],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.sectionTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateNext,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          'Siguiente tema',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
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
                opacity: _fadeAnimation,
                child: buildSectionImage(),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnimation,
                child: buildNoteCard(
                  _contentData?['introText']?.toString(),
                  color: Colors.blue[900]!.withValues(alpha: 0.35),
                ),
              ),
              ...(_contentData?['subsections'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                final sectionIndex = entry.key;
                final sectionData = entry.value as Map<String, dynamic>?;
                if (sectionData == null) return const SizedBox.shrink();

                final examples = sectionData['examples'] as List<dynamic>? ?? [];
                final questions = sectionData['questions'] as List<dynamic>?;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: buildSectionHeader(sectionData['title']?.toString()),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: buildNoteCard(sectionData['content']?.toString()),
                    ),
                    const SizedBox(height: 12),
                    ...examples.asMap().entries.map((exampleEntry) {
                      final exampleIndex = exampleEntry.key;
                      final exampleData = exampleEntry.value as Map<String, dynamic>?;
                      if (exampleData == null) return const SizedBox.shrink();

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: buildExampleCard(exampleData, sectionIndex, exampleIndex),
                      );
                    }),
                    if (questions != null && questions.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: buildPracticeQuestions(
                          questions,
                          sectionIndex,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                );
              }),
              const SizedBox(height: 28),
              buildVideoPlayer(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}