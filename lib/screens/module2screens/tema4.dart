import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2.dart';
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
          minScale: 0.1,
          maxScale: 6.0,
          child: Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
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
  YoutubePlayerController? _youtubeControllerSubtema3;
  bool _videoError = false;
  bool _videoErrorSubtema3 = false;
  bool _showVideo = false;
  bool _showVideoSubtema3 = false;
  final _scrollController = ScrollController();
  final _pageController = PageController();
  int _currentPage = 0;
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool?> _answerResults = {};
  final Map<int, bool> _showExplanations = {};
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
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );
    _loadContentData();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController?.pause();
    _youtubeController?.dispose();
    _youtubeControllerSubtema3?.pause();
    _youtubeControllerSubtema3?.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContentData() async {
    try {
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/data/module2/tema4.json');
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
          initialVideoId:
              _contentData?['video']?['id']?.toString() ?? 'walAu_skXHA',
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

  void initializeVideoSubtema3() {
    setState(() {
      _showVideoSubtema3 = true;
      try {
        _youtubeControllerSubtema3 = YoutubePlayerController(
          initialVideoId:
              _contentData?['subtema3']?['video']?['id']?.toString() ??
                  'cShOfUMT5iA',
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
            disableDragSeek: false,
            loop: false,
            enableCaption: true,
            hideThumbnail: false,
          ),
        )..addListener(() {
            if (_youtubeControllerSubtema3!.value.hasError &&
                !_videoErrorSubtema3) {
              setState(() {
                _videoErrorSubtema3 = true;
              });
            }
          });
      } catch (e) {
        debugPrint('Error initializing subtema3 video: $e');
        setState(() {
          _videoErrorSubtema3 = true;
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
              color: AppColors.glassmorphicBackground,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.glassmorphicBackground,
              child: const Icon(Icons.image_not_supported,
                  size: 50, color: AppColors.textPrimary),
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: AppColors.headerSection,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoPlayer({bool isSubtema3 = false}) {
    final showVideo = isSubtema3 ? _showVideoSubtema3 : _showVideo;
    final videoError = isSubtema3 ? _videoErrorSubtema3 : _videoError;
    final initializeFunction =
        isSubtema3 ? initializeVideoSubtema3 : initializeVideo;

    if (!showVideo) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: initializeFunction,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.play_arrow,
                  color: AppColors.textPrimary, size: 50),
            ),
          ),
        ),
      );
    }

    if (videoError) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassmorphicBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'No se pudo cargar el video',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: initializeFunction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.codeBoxLabel,
                  foregroundColor: AppColors.textPrimary,
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
                color: AppColors.shadowColor,
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: YoutubePlayer(
            controller:
                isSubtema3 ? _youtubeControllerSubtema3! : _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.progressActive,
            progressColors: ProgressBarColors(
              playedColor: AppColors.progressActive,
              handleColor: AppColors.progressActive,
              bufferedColor: AppColors.glassmorphicBackground,
              backgroundColor: AppColors.glassmorphicBackground,
            ),
            onReady: () {
              if (isSubtema3) {
                _youtubeControllerSubtema3!.unMute();
              } else {
                _youtubeController!.unMute();
              }
            },
            onEnded: (metaData) {
              if (isSubtema3) {
                _youtubeControllerSubtema3!.pause();
              } else {
                _youtubeController!.pause();
              }
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
            const Icon(Icons.fiber_manual_record,
                size: 10, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trimmed.substring(1).trim(),
                style: GoogleFonts.poppins(
                    fontSize: 15, color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        final code = trimmed.substring(1, trimmed.length - 1);
        textWidget = buildCodeBox(
          code,
          language: 'pseudocode',
        );
      } else if (trimmed.startsWith('**') && trimmed.contains('**')) {
        final title = trimmed.replaceAll('**', '');
        textWidget = Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        );
      } else {
        textWidget = Text(
          trimmed,
          style:
              GoogleFonts.poppins(fontSize: 15, color: AppColors.textPrimary),
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
        border: Border.all(color: AppColors.glassmorphicBorder),
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
                color: AppColors.textPrimary,
              ),
            ),
          if (highlight['title'] != null) const SizedBox(height: 8),
          ...formatContent(highlight['text'] as String),
        ],
      ),
    );
  }

  Widget buildCodeBox(String code, {String language = 'pseudocode'}) {
    if (code.isEmpty) {
      return const Text(
        'Código no disponible',
        style: TextStyle(color: AppColors.textSecondary),
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
        color: AppColors.codeBoxBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.codeBoxBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
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

  Widget buildQuizQuestion(Map<String, dynamic> question, int questionIndex) {
    final bool isAnswered = _answerResults[questionIndex] != null;
    final bool isCorrect = _answerResults[questionIndex] == true;
    final bool showExplanation = _showExplanations[questionIndex] ?? false;

    final tipo = question['tipo'] is List
        ? question['tipo'].first.toString()
        : question['tipo']?.toString() ?? 'multiple_choice';

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
                  'Pregunta ${questionIndex + 1}: ${question['pregunta'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(question['opciones']?.toList() ??
                  (tipo == 'true_false' ? ['Verdadero', 'Falso'] : []))
              .asMap()
              .entries
              .map<Widget>((entry) {
                final option = entry.value;
                final optionText = option.toString();
                final isSelected = _selectedAnswers[questionIndex] == optionText;
                final isCorrectOption =
                    optionText == question['respuesta_correcta']?.toString();
                Color textColor = AppColors.textPrimary;
                Color borderColor = AppColors.glassmorphicBorder;
                Color bgColor = AppColors.glassmorphicBackground;

                if (isAnswered) {
                  if (isSelected && !isCorrectOption) {
                    borderColor = AppColors.error;
                    bgColor = Colors.red.withValues(alpha: 0.2);
                  } else if (isSelected && isCorrectOption) {
                    borderColor = AppColors.success;
                    bgColor = Colors.green.withValues(alpha: 0.2);
                  } else if (isCorrectOption) {
                    borderColor = AppColors.success;
                    bgColor = Colors.green.withValues(alpha: 0.2);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isAnswered
                        ? null
                        : () {
                            setState(() {
                              _selectedAnswers[questionIndex] = optionText;
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                                    isCorrectOption ? Icons.check : Icons.close,
                                    size: 16,
                                    color: isCorrectOption
                                        ? AppColors.success
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
              .toList(),
          if (_selectedAnswers[questionIndex] != null && !isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _answerResults[questionIndex] =
                        _selectedAnswers[questionIndex] ==
                            question['respuesta_correcta']?.toString();
                    _showExplanations[questionIndex] = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.codeBoxLabel,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enviar Respuesta',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                isCorrect ? '¡Correcto!' : 'Incorrecto',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          if (showExplanation && question['explicacion'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: buildHighlightBox({
                'text': question['explicacion'].toString(),
                'color': 'green',
                'title': 'Explicación',
              }),
            ),
        ],
      ),
    );
  }

  Widget buildQuiz(Map<String, dynamic> quiz, int quizIndex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.glassmorphicBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz['titulo']?.toString() ?? 'Cuestionario',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quiz['descripcion']?.toString() ??
                  'Responde las siguientes preguntas.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...(quiz['preguntas'] as List<dynamic>? ?? [])
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: buildQuizQuestion(
                          entry.value, quizIndex * 100 + entry.key),
                    ))
                .toList(),
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
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 6.0,
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
      ),
    );
  }

  Widget buildSubtemaPage(int index, int totalPages) {
    final introduccion =
        _contentData!['introduccion'] as Map<String, dynamic>? ?? {};
    final subtema1 = _contentData!['subtema1'] as Map<String, dynamic>? ?? {};
    final subtema2 = _contentData!['subtema2'] as Map<String, dynamic>? ?? {};
    final subtema3 = _contentData!['subtema3'] as Map<String, dynamic>? ?? {};
    final quizzes =
        (subtema3['quizzes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Introducción',
        'content': [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.glassmorphicBackground,
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
                      color: AppColors.textPrimary,
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
        'title': 'Planteamiento de problemas',
        'content': [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.glassmorphicBackground,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...formatContent(subtema1['contenido']?.toString() ?? ''),
                  if (subtema1['nota'] != null)
                    buildHighlightBox({
                      'text': subtema1['nota']['contenido']?.toString() ?? '',
                      'color': subtema1['nota']['color']?.toString() ?? 'blue',
                      'title': 'Consejo práctico',
                    }),
                ],
              ),
            ),
          ),
          if (subtema1['diagrama_flujo'] != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: AppColors.glassmorphicBackground,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ejemplo: Contar estudiantes aprobados',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (subtema1['diagrama_flujo']['pseudocodigo'] != null)
                      buildCodeBox(
                        subtema1['diagrama_flujo']['pseudocodigo'] as String,
                        language: 'pseudocode',
                      ),
                    const SizedBox(height: 12),
                    if (subtema1['diagrama_flujo']['image_path'] != null)
                      buildDiagramImage(
                          subtema1['diagrama_flujo']['image_path'] as String),
                    if (subtema1['diagrama_flujo']['descripcion'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: buildHighlightBox({
                          'text': subtema1['diagrama_flujo']['descripcion']
                              as String,
                          'color': 'blue',
                          'title': 'Descripción del diagrama',
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (subtema1['quiz'] != null) ...[
            const SizedBox(height: 16),
            buildQuiz(subtema1['quiz'], 1),
          ],
        ],
      },
      {
        'title': 'Algoritmos paso a paso',
        'content': [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.glassmorphicBackground,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...formatContent(subtema2['contenido']?.toString() ?? ''),
                  if (subtema2['nota'] != null)
                    buildHighlightBox({
                      'text': subtema2['nota']['contenido']?.toString() ?? '',
                      'color': subtema2['nota']['color']?.toString() ?? 'blue',
                      'title': 'Nota',
                    }),
                ],
              ),
            ),
          ),
          if (subtema2['quiz'] != null) ...[
            const SizedBox(height: 16),
            buildQuiz(subtema2['quiz'], 2),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.progressActive,
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
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _contentData?['video']?['description']?.toString() ??
                'Aprende más con este video tutorial',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          buildVideoPlayer(),
        ],
      },
      {
        'title': 'Ejercicios Prácticos',
        'content': [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.glassmorphicBackground,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...formatContent(subtema3['contenido']?.toString() ?? ''),
                  if (quizzes.isEmpty)
                    Text(
                      'No hay ejercicios disponibles en este momento.',
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: AppColors.textSecondary),
                    ),
                  if (quizzes.isNotEmpty) ...[
                    Text(
                      'Resuelve estos ejercicios para practicar lo aprendido:',
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ...quizzes
                        .asMap()
                        .entries
                        .map((entry) => buildQuiz(entry.value, 3 + entry.key))
                        .toList(),
                  ],
                ],
              ),
            ),
          ),
          if (subtema3['video'] != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.progressActive,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtema3['video']['description']?.toString() ??
                  'Explora ejercicios prácticos y análisis de soluciones en este video.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            buildVideoPlayer(isSubtema3: true),
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void navigateNext() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete(widget.sectionIndex);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Module2IntroScreen(
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
          pageBuilder: (context, animation, secondaryAnimation) =>
              Module2IntroScreen(
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
        backgroundColor: AppColors.backgroundDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    const totalPages = 4;

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
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateNext,
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.backgroundDark,
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            _currentPage < totalPages - 1 ? 'Continuar' : 'Completar módulo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                _answerResults.clear();
                _showExplanations.clear();
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              return buildSubtemaPage(index, totalPages);
            },
          ),
        ),
      ),
    );
  }
}