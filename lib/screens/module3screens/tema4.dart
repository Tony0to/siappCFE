import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module3screens/contenido_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  YoutubePlayerController? _youtubeController;
  bool _videoError = false;
  bool _showVideo = false;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;
  String? _errorMessage;
  final _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> _activities = [];
  Map<int, String?> _selectedAnswers = {};
  Map<int, bool> _quizAnsweredMap = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadJsonContent();
  }

  Future<void> _loadJsonContent() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/module3.json')
          .timeout(const Duration(seconds: 5));
      final data = json.decode(jsonString);
      final sectionData = data['content']['section_4'] as Map<String, dynamic>?;
      if (sectionData == null) {
        throw Exception('No se encontró section_4 en el JSON');
      }
      setState(() {
        _contentData = {
          'sectionTitle': sectionData['title'],
          'sectionImage': sectionData['sectionImage'],
          'welcomeText': sectionData['welcomeText'],
          'introText1': data['welcome']['details'],
          'introText2': data['motivation']['text'],
          'subsections': sectionData['subsections'],
          'video': {
            'title': 'Conceptos clave del tema',
            'description': 'Este video explica los conceptos esenciales del tema.',
            'videoId': 'sQLn2asTefo', // Placeholder; replace with Module 3 Tema 4-specific video ID
          },
        };
        _activities = (data['activities'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        debugPrint('Loaded welcomeText: ${_contentData?['welcomeText']}');
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      setState(() {
        _errorMessage = 'No se pudo cargar el contenido: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el contenido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeVideo() {
    setState(() {
      _showVideo = true;
      try {
        final videoId = _contentData?['video']?['videoId']?.toString() ?? 'sQLn2asTefo';
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
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
        setState(() {
          _videoError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController?.pause();
    _youtubeController?.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildSectionImage() {
    final imageUrl = _contentData?['sectionImage'];
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1E40AF),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1E40AF),
                  child: Center(
                    child: Text(
                      'Error al cargar la imagen',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              color: const Color(0xFF1E40AF),
              height: 220,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Imagen no disponible',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(30, 64, 175, 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contentData?['sectionTitle']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
                Text(
                  'Tema ${widget.sectionIndex + 1} de ${widget.totalSections}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> formatContent(String? content, List<Map<String, dynamic>>? styles, {bool isIntro = false}) {
    if (content == null || content.isEmpty) return [const SizedBox.shrink()];
    
    final paragraphs = content.split('\n');
    final styleMap = <String, Map<String, dynamic>>{};
    if (styles != null) {
      for (var style in styles) {
        styleMap[style['text']] = style;
      }
    }

    List<Widget> formattedWidgets = [];
    for (var paragraph in paragraphs) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) {
        formattedWidgets.add(const SizedBox(height: 12));
        continue;
      }

      final style = styleMap[trimmed] ?? {};
      final fontSize = (style['fontSize']?.toDouble() ?? (isIntro ? 16.0 : 15.0));
      final fontWeight = style['fontWeight'] == 'w700'
          ? FontWeight.w700
          : style['fontWeight'] == 'w500'
              ? FontWeight.w500
              : isIntro ? FontWeight.w500 : FontWeight.normal;
      final fontStyle = style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal;

      formattedWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            trimmed,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              color: isIntro ? Colors.white : Color.fromRGBO(255, 255, 255, 0.9),
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              height: 1.5,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }
    return formattedWidgets;
  }

  Widget buildContentContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 58, 138, 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Color.fromRGBO(255, 255, 255, 0.2),
        thickness: 1,
      ),
    );
  }

  Widget buildNoteCard(String? content, {Color? color, String? title, String? icon}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    final iconWidget = icon != null
        ? Icon(
            _getIcon(icon),
            color: Color.fromRGBO(255, 255, 255, 0.7),
            size: 24,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(30, 64, 175, 0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty || iconWidget != null)
              Row(
                children: [
                  if (iconWidget != null) ...[
                    iconWidget,
                    const SizedBox(width: 8),
                  ],
                  if (title != null && title.isNotEmpty)
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                ],
              ),
            if (title != null && title.isNotEmpty || iconWidget != null)
              const SizedBox(height: 8),
            ...formatContent(content, null, isIntro: true),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'list':
        return Icons.list;
      case 'visibility':
        return Icons.visibility;
      case 'build':
        return Icons.build;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Widget buildNoteCardFromJson(Map<String, dynamic>? note) {
    if (note == null) return const SizedBox.shrink();

    final colorString = note['color']?.toString();
    final color = colorString != null && colorString.isNotEmpty
        ? Color(int.parse(colorString.replaceAll('#', '0xFF')))
        : const Color(0xFF1E40AF);
    
    final opacity = (note['opacity']?.toDouble() ?? 0.3).clamp(0.0, 1.0);

    return buildNoteCard(
      note['content']?.toString(),
      color: Color.fromRGBO(
        color.red,
        color.green,
        color.blue,
        opacity,
      ),
      title: note['title']?.toString(),
      icon: note['icon']?.toString(),
    );
  }

  Widget buildExampleCard(Map<String, dynamic>? example) {
    if (example == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 64, 175, 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example['title'] != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        example['title']?.toString() ?? 'Ejemplo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
            if (example['problem'] != null) ...[
              const SizedBox(height: 10),
              Text(
                example['problem']?.toString() ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ],
            const SizedBox(height: 10),
            ...formatContent(example['logic']?.toString(), null),
            if (example['image'] != null && example['image'].isNotEmpty) ...[
              const SizedBox(height: 10),
              buildDiagramImage(example['image']?.toString()),
            ],
            const SizedBox(height: 10),
            ...formatContent(example['explanation']?.toString(), null),
          ],
        ),
      ),
    );
  }

  Widget buildDiagramImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Diagrama no disponible',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        height: 350,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Error al cargar el diagrama: $imagePath',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

Widget buildQuiz(Map<String, dynamic>? question, int questionIndex) {
  if (question == null) return const SizedBox.shrink();

  final selectedAnswer = _selectedAnswers[questionIndex];
  final quizAnswered = _quizAnsweredMap[questionIndex] ?? false;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color.fromRGBO(30, 64, 175, 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz, color: Color(0xFF93C5FD), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Evaluación de conocimiento',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(30, 58, 138, 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            question['logic']?.toString() ?? 'Responde la siguiente pregunta:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFFBFDBFE),
              fontStyle: FontStyle.italic,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          question['question']?.toString() ?? '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 12),
        if (selectedAnswer != null) ...[
          Text(
            selectedAnswer == question['correct']
                ? '¡Correcto!'
                : 'Incorrecto, la respuesta correcta es ${question['correct']}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: selectedAnswer == question['correct']
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.w600,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 12),
        ],
        ...(question['options'] as List<dynamic>? ?? []).map((option) {
          final optionText = option?.toString() ?? '';
          final isSelected = selectedAnswer == optionText;
          final isCorrect = optionText == question['correct']?.toString();
          Color textColor = Colors.white;
          Color borderColor = Color.fromRGBO(59, 130, 246, 0.5);
          Color bgColor = Color.fromRGBO(30, 64, 175, 0.2);

          if (selectedAnswer != null) {
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
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: quizAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswers[questionIndex] = optionText;
                        _quizAnsweredMap[questionIndex] = true;
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
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
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
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
  );
}

  Widget buildVideoPlayer() {
    if (!_showVideo) {
      return GestureDetector(
        onTap: _initializeVideo,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
          ),
        ),
      );
    }

    if (_videoError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(30, 64, 175, 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
              style: GoogleFonts.poppins(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.7)),
              textAlign: TextAlign.center,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
    );
  }

  void navigateNext() {
    widget.onComplete(widget.sectionIndex);
    Navigator.pop(context);
  }

  Future<bool> navigateBack() async {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  Widget buildSectionHeader(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            height: 2,
            width: 40,
            color: const Color(0xFF93C5FD),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubsectionPage(Map<String, dynamic>? sectionData, int index, int totalPages) {
    if (sectionData == null) {
      return Center(
        child: Text(
          'No hay datos disponibles para esta sección',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
      );
    }

    final examples = sectionData['examples'] as List<dynamic>? ?? [];
    final notes = sectionData['notes'] as List<dynamic>? ?? [];
    final styles = sectionData['style'] as List<dynamic>? ?? [];
    final finalNote = sectionData['finalNote'] as Map<String, dynamic>?;

    final activity = _activities.firstWhere(
      (act) => act['subtopic'] == widget.sectionTitle,
      orElse: () => {},
    );
    final quizQuestions = (activity['theory']?['questions'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0) ...[
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
              ),
              child: buildSectionImage(),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4)),
              ),
              child: buildNoteCard(
                _contentData?['welcomeText']?.toString() ?? 'Contenido no disponible',
                color: Color.fromRGBO(30, 64, 175, 0.3),
                icon: 'lightbulb',
              ),
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText1']?.toString(),
              color: Color.fromRGBO(30, 64, 175, 0.3),
              icon: 'school',
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText2']?.toString(),
              color: const Color(0xFF065F46).withOpacity(0.3),
              icon: 'lightbulb',
            ),
          ],
          buildSectionHeader(sectionData['title']?.toString()),
          buildContentContainer(
            formatContent(sectionData['content']?.toString(), styles?.cast<Map<String, dynamic>>()),
          ),
          if (sectionData['image'] != null && sectionData['image'].isNotEmpty) ...[
            const SizedBox(height: 16),
            buildDiagramImage(sectionData['image']?.toString()),
          ],
          buildDivider(),
          ...notes.map((note) {
            return buildNoteCardFromJson(note as Map<String, dynamic>?);
          }),
          ...examples.map((example) {
            final exampleData = example as Map<String, dynamic>?;
            if (exampleData == null) return const SizedBox.shrink();
            return buildExampleCard(exampleData);
          }),
          if (index == totalPages - 1) ...[
            buildDivider(),
            ...quizQuestions.asMap().entries.map((entry) {
              final questionIndex = entry.key;
              final question = entry.value as Map<String, dynamic>;
              return buildQuiz({
                'question': question['question'],
                'options': question['options'],
                'correct': question['options'][question['correctAnswer']],
                'logic': 'Pregunta ${questionIndex + 1}: Evalúa tu comprensión',
              }, questionIndex);
            }),
          ],
          if (finalNote != null)
            buildNoteCardFromJson(finalNote),
          if (index == totalPages - 1 && _contentData?['video'] != null) ...[
            buildDivider(),
            buildSectionHeader(_contentData?['video']?['title']?.toString()),
            Text(
              _contentData?['video']?['description']?.toString() ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color.fromRGBO(255, 255, 255, 0.9),
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 12),
            buildVideoPlayer(),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

void _handleContinue() {
  if (_currentPage < (_contentData?['subsections']?.length ?? 0) - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    navigateNext();
  }
}

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E40AF),
                ),
                child: Text(
                  'Volver',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_contentData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E40AF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final subsections = _contentData?['subsections'] as List<dynamic>? ?? [];
    final totalPages = subsections.length;

    return WillPopScope(
      onWillPop: navigateBack,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            widget.sectionTitle,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await navigateBack();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${widget.sectionIndex + 1}/${widget.totalSections}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.9)),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleContinue,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E40AF),
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            _currentPage < totalPages - 1 ? 'Continuar' : 'Completar módulo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _selectedAnswers.clear();
                _quizAnsweredMap.clear();
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              final sectionData = subsections[index] as Map<String, dynamic>?;
              return buildSubsectionPage(sectionData, index, totalPages);
            },
          ),
        ),
      ),
    );
  }
}