import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2screens/contenido_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:siapp/theme/app_colors.dart';

// Pantalla para mostrar la imagen en pantalla completa con área maximizada
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.1, // Permite reducir más para diagramas largos
          maxScale: 6.0, // Mayor zoom para detalles
          child: Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit
                  .contain, // Asegura que el diagrama sea completamente visible
              width: double.infinity,
              height: double.infinity, // Ocupa todo el espacio disponible
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.backgroundDark,
                child: Center(
                  child: Text(
                    'Error al cargar la imagen: $imagePath\n$error',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  State<Tema1> createState() => _Tema1State();
}

class _Tema1State extends State<Tema1> with TickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedAnswer;
  YoutubePlayerController? _youtubeController;
  bool _videoError = false;
  bool _showVideo = false;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;
  String? _errorMessage;
  bool _quizAnswered = false;
  final _pageController = PageController();
  int _currentPage = 0;

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
          .loadString('assets/data/module2/tema1.json')
          .timeout(const Duration(seconds: 5));
      final data = json.decode(jsonString);
      setState(() {
        _contentData = data;
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
        _youtubeController = YoutubePlayerController(
          initialVideoId: 'u6fusP6JLgg',
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
                      maxLines: null,
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
                  maxLines: null,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contentData?['sectionTitle']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: AppColors.shadowColor,
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
                    color: AppColors.textSecondary,
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
            color: isIntro ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isIntro ? FontWeight.w500 : FontWeight.normal,
            height: 1.5,
          ),
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
      );
    }).toList();
  }

  Widget buildDiagramImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 350,
        color: AppColors.neutralCard,
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
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(imagePath: imagePath),
            ),
          );
        },
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          height: 350,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 350,
            color: AppColors.neutralCard,
            child: Center(
              child: Text(
                'Error al cargar el diagrama: $imagePath\n$error',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCodeBox(String code, String language) {
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
      case 'pseudocode':
        highlightLanguage = 'text';
        break;
      default:
        highlightLanguage = 'text';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.codeBoxBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.codeBoxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.codeBoxLabel,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Pseudocódigo',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                code,
                language: highlightLanguage,
                theme: githubTheme,
                padding: const EdgeInsets.all(12),
                textStyle: GoogleFonts.sourceCodePro(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuiz(Map<String, dynamic>? question) {
    if (question == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
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
              color: AppColors.neutralCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question['logic']?.toString() ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question['text']?.toString() ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 12),
          if (_selectedAnswer != null) ...[
            Text(
              _selectedAnswer == question['correct']
                  ? '¡Correcto!'
                  : 'Incorrecto, la respuesta correcta es ${question['correct']}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _selectedAnswer == question['correct']
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 12),
          ],
          ...(question['options'] as List<dynamic>? ?? []).map((option) {
            final optionText = option?.toString() ?? '';
            final isSelected = _selectedAnswer == optionText;
            final isCorrect = optionText == question['correct']?.toString();
            Color textColor = AppColors.textPrimary;
            Color borderColor = AppColors.glassmorphicBorder;
            Color bgColor = AppColors.glassmorphicBackground;

            if (_selectedAnswer != null) {
              if (isSelected && !isCorrect) {
                textColor = AppColors.textPrimary;
                borderColor = AppColors.error;
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
                onTap: _quizAnswered
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = optionText;
                          _quizAnswered = true;
                        });
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                color: isCorrect
                                    ? AppColors.answerCorrect
                                    : AppColors.error,
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
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child:
                Icon(Icons.play_arrow, color: AppColors.textPrimary, size: 50),
          ),
        ),
      );
    }

    if (_videoError) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassmorphicBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 40),
                const SizedBox(height: 8),
                Text(
                  'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.progressActive,
        progressColors: ProgressBarColors(
          playedColor: AppColors.progressActive,
          handleColor: AppColors.progressBrightBlue,
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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ContenidoScreen(
          moduleData: widget.moduleData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<bool> navigateBack() async {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false; // Prevent default pop
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ContenidoScreen(
            moduleData: widget.moduleData,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      return true; // Allow pop to proceed
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
            color: AppColors.chipTopic,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
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

  Widget buildExampleCard(Map<String, dynamic>? example) {
    if (example == null) return const SizedBox.shrink();

    final isLoopExample =
        example['title']?.toString().contains('Bucle') ?? false;
    final pseudocode = isLoopExample
        ? example['logic']?.toString().split('Lógica de solución:').last.trim()
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ],
            const SizedBox(height: 10),
            if (isLoopExample && pseudocode != null) ...[
              buildCodeBox(pseudocode, 'pseudocode'),
            ] else ...[
              ...formatContent(example['logic']?.toString()),
            ],
            if (example['diagram'] != null)
              buildDiagramImage(example['diagram']?.toString()),
            const SizedBox(height: 10),
            ...formatContent(example['explanation']?.toString()),
          ],
        ),
      ),
    );
  }

  Widget buildNoteCard(String? content, {Color? color, String? title}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ...formatContent(content),
          ],
        ),
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

    return buildNoteCard(
      note['content']?.toString(),
      color: Color.fromRGBO(
        color.r.toInt(),
        color.g.toInt(),
        color.b.toInt(),
        opacity,
      ),
      title: note['title']?.toString(),
    );
  }

  Widget buildSubsectionPage(
      Map<String, dynamic>? sectionData, int index, int totalPages) {
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
    final finalNote = sectionData['finalNote'] as Map<String, dynamic>?;

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
                CurvedAnimation(
                    parent: _controller, curve: const Interval(0, 0.3)),
              ),
              child: buildSectionImage(),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                    parent: _controller, curve: const Interval(0.1, 0.4)),
              ),
              child: buildNoteCard(
                _contentData?['welcomeText']?.toString(),
                color: AppColors.glassmorphicBackground,
              ),
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText1']?.toString(),
              color: AppColors.glassmorphicBackground,
            ),
            const SizedBox(height: 16),
            buildNoteCard(
              _contentData?['introText2']?.toString(),
              color: AppColors.answerCorrectBg,
            ),
          ],
          buildSectionHeader(sectionData['title']?.toString()),
          buildNoteCard(sectionData['content']?.toString()),
          const SizedBox(height: 8),
          ...examples.map((example) {
            final exampleData = example as Map<String, dynamic>?;
            if (exampleData == null) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildExampleCard(exampleData),
                if (exampleData['quiz'] != null)
                  buildQuiz(exampleData['quiz'] as Map<String, dynamic>?),
                ...(exampleData['notes'] as List<dynamic>? ?? []).map((note) {
                  return buildNoteCardFromJson(note as Map<String, dynamic>?);
                }),
              ],
            );
          }),
          if (finalNote != null) buildNoteCardFromJson(finalNote),
          if (index == totalPages - 1) ...[
            const SizedBox(height: 16),
            buildSectionHeader(_contentData?['video']?['title']?.toString()),
            Text(
              _contentData?['video']?['description']?.toString() ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
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
                  backgroundColor: AppColors.textPrimary,
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

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await navigateBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            widget.sectionTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
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
                  '${widget.sectionIndex + 1}/${widget.totalSections}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleContinue,
          backgroundColor: AppColors.textPrimary,
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
                _quizAnswered = false;
                _selectedAnswer = null;
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
