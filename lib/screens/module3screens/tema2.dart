import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siapp/theme/app_colors.dart';

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
  State<Tema2> createState() => _Tema2State();
}

class _Tema2State extends State<Tema2> with TickerProviderStateMixin {
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
      final sectionData = data['content']['section_2'] as Map<String, dynamic>?;
      if (sectionData == null) {
        throw Exception('No se encontró section_2 en el JSON');
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
            'title': 'Video introductorio',
            'description': 'Este video resume los conceptos clave del tema.',
            'videoId': '4nwl62oDnDg', // Placeholder; replace with Module 3 Tema 2-specific video ID
          },
        };
        _activities = (data['activities'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _initializeVideo() {
    setState(() {
      _showVideo = true;
      try {
        final videoId = _contentData?['video']?['videoId']?.toString() ?? '4nwl62oDnDg';
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

  List<TextSpan> _buildBoldSpans(String source, TextStyle base) {
    final exp = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    int last = 0;

    for (final m in exp.allMatches(source)) {
      if (m.start > last) {
        spans.add(TextSpan(text: source.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: base.copyWith(fontWeight: FontWeight.w700),
      ));
      last = m.end;
    }
    if (last < source.length) {
      spans.add(TextSpan(text: source.substring(last)));
    }
    return spans;
  }

  Widget buildSectionImage() {
    final imageUrl = _contentData?['sectionImage'];
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.2),
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
                  color: AppColors.backgroundDark,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.backgroundDark,
                  child: Center(
                    child: Text(
                      'Error al cargar la imagen',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              color: AppColors.backgroundDark,
              height: 220,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Imagen no disponible',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.headerSection,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contentData?['sectionTitle']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: AppColors.shadowColor.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tema ${widget.sectionIndex + 1} de ${widget.totalSections}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.left,
                  softWrap: true,
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

    return paragraphs.map((paragraph) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) return const SizedBox(height: 12);

      final style = styleMap[trimmed] ?? {};
      final fontSize = (style['fontSize']?.toDouble() ?? (isIntro ? 16.0 : 15.0));
      final baseWeight = style['fontWeight'] == 'w700'
          ? FontWeight.w700
          : style['fontWeight'] == 'w500'
              ? FontWeight.w500
              : isIntro ? FontWeight.w500 : FontWeight.normal;
      final fontStyle = style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal;

      final baseStyle = GoogleFonts.poppins(
        fontSize: fontSize,
        color: isIntro ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.9),
        fontWeight: baseWeight,
        fontStyle: fontStyle,
        height: 1.5,
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: RichText(
          text: TextSpan(
            style: baseStyle,
            children: _buildBoldSpans(trimmed, baseStyle),
          ),
          textAlign: TextAlign.justify,
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
      );
    }).toList();
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: AppColors.glassmorphicBorder,
        thickness: 1,
      ),
    );
  }

  Widget buildDiagramImage(String? imagePath, {bool enableZoom = true, double height = 350}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Diagrama no disponible',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
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

    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: imagePath,
              height: height,
              width: double.infinity,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundDark,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.backgroundDark,
                child: Center(
                  child: Text(
                    'Error al cargar la imagen',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.contain,
              height: height,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.backgroundDark,
                child: Center(
                  child: Text(
                    'Error al cargar el diagrama: $imagePath',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: enableZoom
          ? GestureDetector(
              onTap: () => _showFullScreenImage(context, imagePath, isNetworkImage),
              child: imageWidget,
            )
          : imageWidget,
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath, bool isNetworkImage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            'Error al cargar la imagen',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            'Error al cargar el diagrama: $imagePath',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
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
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTable(String? content, {Color? color, String? title, String? icon}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    final iconWidget = icon != null
        ? Icon(
            _getIcon(icon),
            color: AppColors.textPrimary.withOpacity(0.7),
            size: 24,
          )
        : null;

    final rows = content.split('\n').where((line) => line.contains('|')).map((line) {
      final cells = line.split('|').map((cell) => cell.trim()).toList();
      return cells.length >= 2 ? cells.sublist(1, cells.length - 1) : null;
    }).where((cells) => cells != null).cast<List<String>>().toList();

    if (rows.isEmpty) return const SizedBox.shrink();

    return _DynamicTable(
      stages: rows,
      title: title,
      iconWidget: iconWidget,
      color: color ?? AppColors.answerCorrect,
    );
  }

  Widget buildNoteCard(String? content, {Color? color, String? title, String? icon}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    final iconWidget = icon != null
        ? Icon(
            _getIcon(icon),
            color: AppColors.textPrimary.withOpacity(0.7),
            size: 24,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.progressActive.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
                          color: AppColors.textPrimary,
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

  Widget buildExampleCard(Map<String, dynamic>? example) {
    if (example == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
                        color: AppColors.primaryButton,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        example['title']?.toString() ?? 'Ejemplo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                  color: AppColors.textPrimary,
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
              buildDiagramImage(example['image']?.toString(), enableZoom: true, height: 200),
            ],
            const SizedBox(height: 10),
            ...formatContent(example['explanation']?.toString(), null),
          ],
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.progressActive.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
              const Icon(Icons.quiz, color: AppColors.chipTopic, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evaluación de conocimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
              color: AppColors.glassmorphicBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question['logic']?.toString() ?? 'Responde la siguiente pregunta:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.chipTopic,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.justify,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question['question']?.toString() ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textPrimary,
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
                    ? AppColors.answerCorrect
                    : AppColors.answerIncorrect,
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
            Color textColor = AppColors.textPrimary;
            Color borderColor = AppColors.progressActive.withOpacity(0.5);
            Color bgColor = AppColors.glassmorphicBackground;

            if (selectedAnswer != null) {
              if (isSelected && !isCorrect) {
                textColor = AppColors.textPrimary;
                borderColor = AppColors.answerIncorrect;
                bgColor = AppColors.answerIncorrectBg;
              } else if (isSelected && isCorrect) {
                textColor = AppColors.textPrimary;
                borderColor = AppColors.answerCorrect;
                bgColor = AppColors.answerCorrectBg;
              } else if (isCorrect) {
                textColor = AppColors.textPrimary;
                borderColor = AppColors.answerCorrect;
                bgColor = AppColors.answerCorrectBg;
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
                                color: isCorrect ? AppColors.answerCorrect : AppColors.answerIncorrect,
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
                          textAlign: TextAlign.justify,
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
                color: AppColors.shadowColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.play_arrow, color: AppColors.textPrimary, size: 50),
          ),
        ),
      );
    }

    if (_videoError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary.withOpacity(0.7)),
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

  Widget buildSectionHeader(String? title) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            height: 2,
            width: 40,
            color: AppColors.chipTopic,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContentContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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

  Widget buildNoteCardFromJson(Map<String, dynamic>? note) {
    if (note == null) return const SizedBox.shrink();

    final colorString = note['color']?.toString();
    final color = colorString != null && colorString.isNotEmpty
        ? Color(int.parse(colorString.replaceAll('#', '0xFF')))
        : AppColors.backgroundDark;

    final opacity = (note['opacity']?.toDouble() ?? 0.3).clamp(0.0, 1.0);

    if (note['content']?.toString().contains('|') ?? false) {
      return buildTable(
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

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'computer':
        return Icons.computer;
      case 'apps':
        return Icons.apps;
      case 'settings':
        return Icons.settings;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'trending_up':
        return Icons.trending_up;
      case 'compare_arrows':
        return Icons.compare_arrows;
      case 'speed':
        return Icons.speed;
      case 'book':
        return Icons.book;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'list':
        return Icons.list;
      case 'pattern':
        return Icons.pattern;
      case 'psychology':
        return Icons.psychology;
      case 'emoji_objects':
        return Icons.lightbulb;
      default:
        return Icons.info;
    }
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

  Widget buildSubsectionPage(Map<String, dynamic>? sectionData, int index, int totalPages) {
    if (sectionData == null) {
      return Center(
        child: Text(
          'No hay datos disponibles para esta sección',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
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
                _contentData?['welcomeText']?.toString(),
                color: AppColors.cardBackground,
                icon: 'psychology',
              ),
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText1']?.toString(),
              color: AppColors.cardBackground,
              icon: 'school',
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText2']?.toString(),
              color: AppColors.answerCorrect.withOpacity(0.3),
              icon: 'emoji_objects',
            ),
          ],
          buildSectionHeader(sectionData['title']?.toString()),
          buildContentContainer(
            formatContent(sectionData['content']?.toString(), styles.cast<Map<String, dynamic>>()),
          ),
          buildDivider(),
          ...examples.map((example) {
            final exampleData = example as Map<String, dynamic>?;
            if (exampleData == null) return const SizedBox.shrink();
            return buildExampleCard(exampleData);
          }),
          ...notes.map((note) {
            return buildNoteCardFromJson(note as Map<String, dynamic>?);
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
                color: AppColors.textPrimary.withOpacity(0.9),
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
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
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
                  backgroundColor: AppColors.moduleButton,
                  foregroundColor: AppColors.backgroundDark,
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
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final subsections = _contentData?['subsections'] as List<dynamic>? ?? [];
    final totalPages = subsections.length;

    return WillPopScope(
      onWillPop: navigateBack,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () async {
              await navigateBack();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'página ${_currentPage + 1} de $totalPages',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary.withOpacity(0.9)),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleContinue,
          backgroundColor: AppColors.moduleButton,
          foregroundColor: AppColors.backgroundDark,
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

class _DynamicTable extends StatefulWidget {
  final List<List<String>> stages;
  final String? title;
  final Widget? iconWidget;
  final Color color;

  const _DynamicTable({
    required this.stages,
    this.title,
    this.iconWidget,
    required this.color,
  });

  @override
  __DynamicTableState createState() => __DynamicTableState();
}

class __DynamicTableState extends State<_DynamicTable> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.progressActive.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null && widget.title!.isNotEmpty || widget.iconWidget != null)
              Row(
                children: [
                  if (widget.iconWidget != null) ...[
                    widget.iconWidget!,
                    const SizedBox(width: 8),
                  ],
                  if (widget.title != null && widget.title!.isNotEmpty)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                ],
              ),
            if (widget.title != null && widget.title!.isNotEmpty || widget.iconWidget != null)
              const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.stages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stage = entry.value[0];
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(isSelected ? 0.8 : 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.progressActive.withOpacity(0.5),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          stage,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.glassmorphicBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassmorphicBorder),
                ),
                child: Text(
                  widget.stages[_selectedIndex][1],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}