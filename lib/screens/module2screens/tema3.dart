import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2screens/contenido_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

// Pantalla para mostrar la imagen en pantalla completa con área maximizada
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              fit: BoxFit.contain, // Asegura que el diagrama sea completamente visible
              width: double.infinity,
              height: double.infinity, // Ocupa todo el espacio disponible
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
                child: Center(
                  child: Text(
                    'Error al cargar la imagen: $imagePath\n$error',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
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

class Tema3 extends StatefulWidget {
  final Map<String, dynamic> section;
  final String sectionTitle;
  final int sectionIndex;
  final int totalSections;
  final Map<String, dynamic> content;
  final Map<String, dynamic> moduleData;
  final Function(int) onComplete;

  const Tema3({
    Key? key,
    required this.section,
    required this.sectionTitle,
    required this.sectionIndex,
    required this.totalSections,
    required this.content,
    required this.moduleData,
    required this.onComplete,
  }) : super(key: key);

  @override
  Tema3State createState() => Tema3State();
}

class Tema3State extends State<Tema3> with TickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, dynamic>? _contentData;
  YoutubePlayerController? _youtubeController;
  bool _videoError = false;
  bool _showVideo = false;
  final _scrollController = ScrollController();
  final _pageController = PageController();
  int _currentPage = 0;
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool?> _answerResults = {};
  final Map<int, bool> _showExplanations = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadContentData();
  }

  Future<void> _loadContentData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module2/tema3.json');
      final jsonData = json.decode(jsonString);
      if (jsonData == null) {
        throw FlutterError('El archivo JSON está vacío');
      }
      setState(() {
        _contentData = jsonData;
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
    final imageUrl = _contentData?['sectionImage']?.toString() ??
        'https://img.freepik.com/free-vector/programming-concept-illustration_114360-1351.jpg';
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF0A2463),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF0A2463),
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
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
                  Color.fromRGBO(10, 36, 99, 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sectionTitle,
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
                ),
                Text(
                  'Tema ${widget.sectionIndex + 1} de ${widget.totalSections}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
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
      return GestureDetector(
        onTap: initializeVideo,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
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
          color: Color.fromRGBO(62, 146, 204, 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
              style: GoogleFonts.poppins(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: initializeVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E92CC),
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

  Widget buildContentCard(String title, List<Widget> content, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(10, 36, 99, 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Row(
                children: [
                  Container(
                    height: 2,
                    width: 40,
                    color: const Color(0xFF93C5FD),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget buildHighlightBox(String content, {Color? color, String? title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(62, 146, 204, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color != null
              ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.5)
              : Color.fromRGBO(62, 146, 204, 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: color != null
                        ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.8)
                        : Color.fromRGBO(62, 146, 204, 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Color.fromRGBO(255, 255, 255, 0.9),
              fontStyle: title != null ? FontStyle.italic : null,
              height: 1.6,
            ),
          ),
        ],
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
        color: Color.fromRGBO(10, 36, 99, 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(62, 146, 204, 0.4)),
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
              'Pseudocódigo',
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

  Widget buildDiagramImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 350,
        color: const Color(0xFF1E3A8A),
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
            color: const Color(0xFF1E3A8A),
            child: Center(
              child: Text(
                'Error al cargar el diagrama: $imagePath\n$error',
                style: GoogleFonts.poppins(
                  color: Colors.white,
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

  Widget buildBulletList(List<dynamic> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fiber_manual_record, size: 8, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<Widget> formatContent(String content) {
    return content.split('\n').map((paragraph) {
      if (paragraph.trim().isEmpty) return const SizedBox(height: 12);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          paragraph,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Color.fromRGBO(255, 255, 255, 0.9),
            height: 1.6,
          ),
        ),
      );
    }).toList();
  }

  Widget buildQuizQuestion(Map<String, dynamic> question, int questionIndex) {
    final bool isAnswered = _answerResults[questionIndex] != null;
    final bool isCorrect = _answerResults[questionIndex] == true;
    final bool showExplanation = _showExplanations[questionIndex] ?? false;

    final tipo = question['tipo'] is List ? question['tipo'].first.toString() : question['tipo']?.toString() ?? 'multiple_choice';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 64, 175, 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.5)),
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
                  'Pregunta ${questionIndex + 1}: ${question['pregunta'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(question['opciones']?.toList() ?? (tipo == 'true_false' ? ['Verdadero', 'Falso'] : [])).map<Widget>((option) {
            final optionText = option.toString();
            final isSelected = _selectedAnswers[questionIndex] == optionText;
            final isCorrectOption = optionText == question['respuesta_correcta']?.toString();
            Color textColor = Colors.white;
            Color borderColor = Color.fromRGBO(59, 130, 246, 0.5);
            Color bgColor = Color.fromRGBO(30, 64, 175, 0.2);

            if (isAnswered) {
              if (isSelected && !isCorrectOption) {
                borderColor = const Color(0xFFEF4444);
                bgColor = Color.fromRGBO(153, 27, 27, 0.2);
              } else if (isSelected && isCorrectOption) {
                borderColor = const Color(0xFF10B981);
                bgColor = Color.fromRGBO(6, 95, 70, 0.2);
              } else if (isCorrectOption) {
                borderColor = const Color(0xFF10B981);
                bgColor = Color.fromRGBO(6, 95, 70, 0.2);
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
                                isCorrectOption ? Icons.check : Icons.close,
                                size: 16,
                                color: isCorrectOption ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
          }),
          if (_selectedAnswers[questionIndex] != null && !isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _answerResults[questionIndex] =
                        _selectedAnswers[questionIndex] == question['respuesta_correcta']?.toString();
                    _showExplanations[questionIndex] = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E92CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enviar Respuesta',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
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
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ),
          if (showExplanation && question['explicacion'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: buildHighlightBox(
                question['explicacion'].toString(),
                color: const Color(0xFF10B981),
                title: 'Explicación',
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSubtemaPage(int index, int totalPages) {
    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Introducción',
        'content': [
          buildContentCard(
            'III. Estructuras de datos y de control',
            [
              buildHighlightBox(
                _contentData!['introduccion']['highlight1']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildHighlightBox(
                _contentData!['introduccion']['highlight2']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
            ],
            color: Color.fromRGBO(62, 146, 204, 0.15),
          ),
        ],
      },
      {
        'title': 'Arreglos, matrices, listas, etc.',
        'content': [
          buildContentCard(
            'Arreglos, matrices, listas, etc.',
            [
              buildHighlightBox(
                _contentData!['subtema1']['highlight1']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              ...formatContent(_contentData!['subtema1']['contenido']?.toString() ?? ''),
              const SizedBox(height: 16),
              buildHighlightBox(
                _contentData!['subtema1']['highlight2']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildContentCard(
                'Arreglos',
                [
                  buildHighlightBox(
                    _contentData!['subtema1']['arreglos']['definicion']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                    title: 'Definición',
                  ),
                  const SizedBox(height: 16),
                  ...formatContent(_contentData!['subtema1']['arreglos']['contenido']?.toString() ?? ''),
                  const SizedBox(height: 16),
                  buildContentCard(
                    _contentData!['subtema1']['arreglos']['ejemplo']['titulo']?.toString() ?? '',
                    [
                      Text(
                        _contentData!['subtema1']['arreglos']['ejemplo']['descripcion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildCodeBox(
                        _contentData!['subtema1']['arreglos']['ejemplo']['pseudocodigo']?.toString() ?? '',
                        'pseudocode',
                      ),
                      const SizedBox(height: 12),
                      buildDiagramImage('assets/module2photos/diag16.png'),
                      const SizedBox(height: 12),
                      Text(
                        _contentData!['subtema1']['arreglos']['ejemplo']['conclusion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildHighlightBox(
                        _contentData!['subtema1']['arreglos']['usos']['text']?.toString() ?? '',
                        color: const Color(0xFF3E92CC),
                        title: 'Usos de los arreglos',
                      ),
                    ],
                    color: Color.fromRGBO(30, 64, 175, 0.2),
                  ),
                ],
                color: Color.fromRGBO(16, 185, 129, 0.15),
              ),
            ],
            color: Color.fromRGBO(16, 185, 129, 0.15),
          ),
        ],
      },
      {
        'title': 'Matrices',
        'content': [
          buildContentCard(
            'Matrices',
            [
              buildHighlightBox(
                _contentData!['subtema2']['highlight1']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildContentCard(
                _contentData!['subtema2']['ejemplo']['titulo']?.toString() ?? '',
                [
                  Text(
                    _contentData!['subtema2']['ejemplo']['descripcion']?.toString() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildCodeBox(
                    _contentData!['subtema2']['ejemplo']['pseudocodigo']?.toString() ?? '',
                    'pseudocode',
                  ),
                  const SizedBox(height: 12),
                  buildDiagramImage('assets/module2photos/diag17.png'),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema2']['operaciones']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                    title: 'Operaciones comunes',
                  ),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema2']['definicion']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                ],
                color: Color.fromRGBO(30, 64, 175, 0.2),
              ),
            ],
            color: Color.fromRGBO(139, 92, 246, 0.15),
          ),
        ],
      },
      {
        'title': 'Listas',
        'content': [
          buildContentCard(
            'Listas',
            [
              buildHighlightBox(
                _contentData!['subtema3']['highlight1']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildContentCard(
                'Características',
                [
                  buildBulletList(_contentData!['subtema3']['caracteristicas']['items'] ?? []),
                ],
                color: Color.fromRGBO(30, 64, 175, 0.2),
              ),
              const SizedBox(height: 16),
              buildContentCard(
                _contentData!['subtema3']['ejemplo']['titulo']?.toString() ?? '',
                [
                  Text(
                    _contentData!['subtema3']['ejemplo']['descripcion']?.toString() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildCodeBox(
                    _contentData!['subtema3']['ejemplo']['pseudocodigo']?.toString() ?? '',
                    'pseudocode',
                  ),
                  const SizedBox(height: 12),
                  buildDiagramImage('assets/module2photos/diag18.png'),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema3']['comparacion']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema3']['usos']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                ],
                color: Color.fromRGBO(30, 64, 175, 0.2),
              ),
            ],
            color: Color.fromRGBO(255, 214, 10, 0.15),
          ),
        ],
      },
      {
        'title': 'Aplicación en estructuras de control',
        'content': [
          buildContentCard(
            '¿Cómo aplicarlo en estructuras de control?',
            [
              buildHighlightBox(
                _contentData!['subtema4']['highlight1']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildHighlightBox(
                _contentData!['subtema4']['importancia']['text']?.toString() ?? '',
                color: const Color(0xFF10B981),
                title: '¿Por qué es importante esta combinación?',
              ),
              const SizedBox(height: 16),
              buildHighlightBox(
                _contentData!['subtema4']['acceso']['text']?.toString() ?? '',
                color: const Color(0xFF3E92CC),
              ),
              const SizedBox(height: 16),
              buildContentCard(
                _contentData!['subtema4']['ejemplo1']['titulo']?.toString() ?? '',
                [
                  Text(
                    _contentData!['subtema4']['ejemplo1']['descripcion']?.toString() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildCodeBox(
                    _contentData!['subtema4']['ejemplo1']['pseudocodigo']?.toString() ?? '',
                    'pseudocode',
                  ),
                  const SizedBox(height: 12),
                  buildDiagramImage('assets/module2photos/diag19.png'),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema4']['listas']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                  const SizedBox(height: 16),
                  buildContentCard(
                    _contentData!['subtema4']['ejemplo2']['titulo']?.toString() ?? '',
                    [
                      Text(
                        _contentData!['subtema4']['ejemplo2']['descripcion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildCodeBox(
                        _contentData!['subtema4']['ejemplo2']['pseudocodigo']?.toString() ?? '',
                        'pseudocode',
                      ),
                      const SizedBox(height: 12),
                      buildDiagramImage('assets/module2photos/diag20.png'),
                    ],
                    color: Color.fromRGBO(30, 64, 175, 0.2),
                  ),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema4']['matrices']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                  const SizedBox(height: 16),
                  buildContentCard(
                    _contentData!['subtema4']['ejemplo3']['titulo']?.toString() ?? '',
                    [
                      Text(
                        _contentData!['subtema4']['ejemplo3']['descripcion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildCodeBox(
                        _contentData!['subtema4']['ejemplo3']['pseudocodigo']?.toString() ?? '',
                        'pseudocode',
                      ),
                      const SizedBox(height: 12),
                      buildDiagramImage('assets/module2photos/diag21.png'),
                    ],
                    color: Color.fromRGBO(30, 64, 175, 0.2),
                  ),
                  const SizedBox(height: 16),
                  buildHighlightBox(
                    _contentData!['subtema4']['diccionarios']['text']?.toString() ?? '',
                    color: const Color(0xFF3E92CC),
                  ),
                ],
                color: Color.fromRGBO(16, 185, 129, 0.15),
              ),
            ],
            color: Color.fromRGBO(255, 214, 10, 0.15),
          ),
        ],
      },
      {
        'title': 'Cuestionario de Repaso',
        'content': [
          if (_contentData?['quiz'] != null)
            buildContentCard(
              _contentData!['quiz']['titulo']?.toString() ?? '',
              [
                Text(
                  _contentData!['quiz']['descripcion']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                ...(_contentData!['quiz']['preguntas'] as List<dynamic>? ?? [])
                    .asMap()
                    .entries
                    .map<Widget>((entry) => buildQuizQuestion(entry.value, entry.key))
                    .expand((widget) => [widget, const SizedBox(height: 16)]),
              ],
              color: Color.fromRGBO(255, 214, 10, 0.15),
            ),
        ],
      },
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) ...[
              buildSectionImage(),
              const SizedBox(height: 24),
            ],
            ...pages[index]['content'],
            if (index == totalPages - 1) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    height: 2,
                    width: 40,
                    color: const Color(0xFF93C5FD),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Video Explicativo',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _contentData?['video']?['description']?.toString() ?? 'Aprende con este video tutorial',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                ),
              ),
              const SizedBox(height: 12),
              buildVideoPlayer(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void navigateNext() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete(widget.sectionIndex);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ContenidoScreen(
            moduleData: widget.moduleData,
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
          pageBuilder: (context, animation, secondaryAnimation) => ContenidoScreen(
            moduleData: widget.moduleData,
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
      return const Scaffold(
        backgroundColor: Color(0xFF0A2463),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    const totalPages = 6; // Introduction, Arreglos, Matrices, Listas, Aplicación, Quiz

    return WillPopScope(
      onWillPop: navigateBack,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A2463),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            widget.sectionTitle,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateNext,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A2463),
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