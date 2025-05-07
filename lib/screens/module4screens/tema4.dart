import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module4screens/contenido_screen.dart';
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
  late Animation<double> _scaleAnimation;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;
  YoutubePlayerController? _videoController;
  bool _videoError = false;
  bool _showVideo = false;

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
    _scrollController.dispose();
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadJsonContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module4/tema4.json');
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
        final videoId = _contentData?['video']?['youtubeId']?.toString() ?? 'xTLbG3_Rs_w';
        _videoController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
            enableCaption: true,
            loop: false,
            controlsVisibleAtStart: true,
          ),
        )..addListener(() {
            if (_videoController!.value.hasError && !_videoError) {
              setState(() {
                _videoError = true;
              });
              debugPrint('Error loading video ID: $videoId');
            }
          });
        _videoError = false;
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

  void navigateNext() {
    widget.onComplete(widget.sectionIndex);
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ContenidoScreen(
          moduleData: widget.moduleData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => route.isFirst,
    );
  }

  Widget buildSectionHeader(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      if (sectionTitle.contains("Programación funcional")) {
        language = 'haskell';
      } else if (sectionTitle.contains("Programación lógica")) {
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
            ? Color(int.parse(example['color'].replaceFirst('#', '0xFF')))
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
            if (example['table'] != null) ...[
              const SizedBox(height: 16),
              buildComparisonTable(example['table'] as List<dynamic>),
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

  Widget buildComparisonTable(List<dynamic> tableData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        dataRowMinHeight: 80,
        dataRowMaxHeight: 100,
        headingRowHeight: 56,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          verticalInside: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          left: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        columns: [
          DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                'Paradigma',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120),
              child: Text(
                'Cómo piensa el paradigma',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                'Está enfocado en...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                'Lenguajes comunes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                'Aplicaciones típicas',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
        rows: tableData.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value as Map<String, dynamic>;
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              return index % 2 == 0
                  ? Colors.blue[900]!.withValues(alpha: 0.4)
                  : Colors.blue[400]!.withValues(alpha: 0.2);
            }),
            cells: [
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    row['paradigma'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 120),
                  child: Text(
                    row['como_piensa'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    row['enfocado_en'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    row['lenguajes_comunes'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    row['aplicaciones_tipicas'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
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

  Widget buildVideoPlayer() {
    if (!_showVideo) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 24),
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
                    const Icon(Icons.video_library, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Video Complementario',
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
                GestureDetector(
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
              ],
            ),
          ),
        ),
      );
    }

    if (_videoError || _videoController == null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 24),
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
                    const Icon(Icons.video_library, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Video Complementario',
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[900]!.withValues(alpha: 0.3),
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
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por favor, intenta de nuevo más tarde.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
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
                  const Icon(Icons.video_library, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Video Complementario',
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: YoutubePlayer(
                  controller: _videoController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                  ),
                  onReady: () {
                    _videoController?.unMute();
                  },
                  onEnded: (metaData) {
                    _videoController?.pause();
                  },
                ),
              ),
            ],
          ),
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
        icon: const Icon(Icons.check),
        label: Text(
          'Completar módulo',
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