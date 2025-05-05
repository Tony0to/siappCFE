import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2screens/contenido_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

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
      case 'ejemplo genérico':
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
              'Ejemplo de Código',
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

    // Handle question['tipo'] being a list or string
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
        'title': 'Introducción y Estructuras secuenciales',
        'content': [
          if (_contentData?['introduccion'] != null)
            buildContentCard(
              _contentData!['introduccion']['titulo']?.toString() ?? 'Introducción',
              [
                ...formatContent(_contentData!['introduccion']['contenido']?.toString() ?? ''),
                const SizedBox(height: 16),
                buildHighlightBox(
                  _contentData!['introduccion']['highlight']['text']?.toString() ?? '',
                  color: const Color(0xFF10B981),
                  title: 'Importante',
                ),
              ],
              color: Color.fromRGBO(62, 146, 204, 0.15),
            ),
          if (_contentData?['caracteristicas'] != null)
            buildContentCard(
              _contentData!['caracteristicas']['titulo']?.toString() ?? '',
              [
                buildBulletList(_contentData!['caracteristicas']['items'] ?? []),
              ],
              color: Color.fromRGBO(16, 185, 129, 0.15),
            ),
        ],
      },
      {
        'title': 'Secuenciales',
        'content': [
          if (_contentData?['subtema1'] != null)
            buildContentCard(
              _contentData!['subtema1']['titulo']?.toString() ?? '',
              [
                ...formatContent(_contentData!['subtema1']['contenido']?.toString() ?? ''),
                const SizedBox(height: 16),
                buildContentCard(
                  _contentData!['subtema1']['ejemplo']['titulo']?.toString() ?? '',
                  [
                    Text(
                      _contentData!['subtema1']['ejemplo']['descripcion']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildCodeBox(
                      _contentData!['subtema1']['ejemplo']['codigo']?.toString() ?? '',
                      'JavaScript',
                    ),
                  ],
                  color: Color.fromRGBO(30, 64, 175, 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  _contentData!['subtema1']['conclusion']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
                ),
              ],
              color: Color.fromRGBO(16, 185, 129, 0.15),
            ),
        ],
      },
      {
        'title': 'Estructuras condicionales',
        'content': [
          if (_contentData?['subtema2'] != null)
            buildContentCard(
              _contentData!['subtema2']['titulo']?.toString() ?? '',
              [
                ...formatContent(_contentData!['subtema2']['contenido']?.toString() ?? ''),
                const SizedBox(height: 16),
                ...(_contentData!['subtema2']['condicionales'] as List<dynamic>? ?? []).map<Widget>((condicional) {
                  Color color;
                  switch (condicional['color']?.toString()) {
                    case 'blue':
                      color = Colors.blue;
                      break;
                    case 'purple':
                      color = Colors.purple;
                      break;
                    case 'indigo':
                      color = Colors.indigo;
                      break;
                    case 'teal':
                      color = Colors.teal;
                      break;
                    case 'cyan':
                      color = Colors.cyan;
                      break;
                    default:
                      color = Colors.blue;
                  }
                  return buildContentCard(
                    'Condicional ${condicional['tipo']?.toString() ?? ''}',
                    [
                      Text(
                        condicional['descripcion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildCodeBox(
                        condicional['ejemplo']?.toString() ?? '',
                        condicional['tipo'] == 'switch' || condicional['tipo'] == 'switch sin break'
                            ? 'JavaScript'
                            : 'Ejemplo genérico',
                      ),
                    ],
                    color: color.withOpacity(0.2),
                  );
                }),
                const SizedBox(height: 16),
                buildHighlightBox(
                  _contentData!['subtema2']['nota_importante']['text']?.toString() ?? '',
                  color: const Color(0xFF10B981),
                  title: 'Importante',
                ),
                const SizedBox(height: 16),
                buildContentCard(
                  _contentData!['subtema2']['cuando_usar_switch']['titulo']?.toString() ?? '',
                  [
                    buildBulletList(_contentData!['subtema2']['cuando_usar_switch']['items'] ?? []),
                    const SizedBox(height: 12),
                    Text(
                      _contentData!['subtema2']['cuando_usar_switch']['conclusion']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  color: Color.fromRGBO(6, 95, 70, 0.2),
                ),
              ],
              color: Color.fromRGBO(139, 92, 246, 0.15),
            ),
        ],
      },
      {
        'title': 'Estructuras cíclicas',
        'content': [
          if (_contentData?['subtema3'] != null)
            buildContentCard(
              _contentData!['subtema3']['titulo']?.toString() ?? '',
              [
                ...formatContent(_contentData!['subtema3']['contenido']?.toString() ?? ''),
                const SizedBox(height: 16),
                ...(_contentData!['subtema3']['bucles'] as List<dynamic>? ?? []).map<Widget>((bucle) {
                  Color color;
                  switch (bucle['color']?.toString()) {
                    case 'orange':
                      color = Colors.orange;
                      break;
                    case 'purple':
                      color = Colors.purple;
                      break;
                    case 'indigo':
                      color = Colors.indigo;
                      break;
                    default:
                      color = Colors.orange;
                  }
                  return buildContentCard(
                    'Bucle ${bucle['tipo']?.toString() ?? ''}',
                    [
                      Text(
                        bucle['descripcion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '¿Qué es?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bucle['definicion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bucle['explicacion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Estructura',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bucle['estructura']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...?(bucle['ejemplos'] as List<dynamic>?)?.map<Widget>((ejemplo) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: buildCodeBox(
                              ejemplo['codigo']?.toString() ?? '',
                              ejemplo['lenguaje']?.toString() ?? 'text',
                            ),
                          )),
                      const SizedBox(height: 12),
                      Text(
                        '¿Cuándo utilizarlo?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildBulletList(bucle['cuando_usar'] ?? []),
                      const SizedBox(height: 12),
                      Text(
                        bucle['conclusion']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                    ],
                    color: color.withOpacity(0.2),
                  );
                }),
                const SizedBox(height: 16),
                buildHighlightBox(
                  _contentData!['subtema3']['nota_importante']['text']?.toString() ?? '',
                  color: const Color(0xFF10B981),
                  title: 'Importante',
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

    const totalPages = 5; // Introduction, Subtema1, Subtema2, Subtema3, Quiz

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