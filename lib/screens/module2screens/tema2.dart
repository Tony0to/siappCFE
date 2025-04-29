import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2screens/tema3.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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
  Tema2State createState() => Tema2State();
}

class Tema2State extends State<Tema2> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _contentAnimation;
  Map<String, dynamic>? _contentData;
  late YoutubePlayerController _youtubeController;
  bool _videoError = false;
  final _scrollController = ScrollController();
  final List<AnimationController> _cardAnimations = [];
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool?> _answerResults = {};
  final Map<int, bool> _showExplanations = {};
  final Map<String, bool> _codeExplanationVisibility = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );

    _contentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    _loadContentData();
    _controller.forward();

    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId('https://youtu.be/walAu_skXHA?si=ghIsgJCeE_dAmSzY') ?? '',
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
  }

  Future<void> _loadContentData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module2/tema2.json');
      final jsonData = json.decode(jsonString);
      if (jsonData == null) {
        throw FlutterError('El archivo JSON está vacío');
      }

      final subtema1Sections = (jsonData['subtema1']?['secciones']?.length ?? 0);
      final subtema2Sections = (jsonData['subtema2']?['secciones']?.length ?? 0);
      final quizQuestions = (jsonData['quiz']?['preguntas']?.length ?? 0);
      final totalSections = subtema1Sections + subtema2Sections + quizQuestions;

      for (int i = 0; i < totalSections; i++) {
        _cardAnimations.add(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        ));
      }

      setState(() {
        _contentData = jsonData;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        for (var anim in _cardAnimations) {
          anim.forward();
        }
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController.dispose();
    _scrollController.dispose();
    for (var anim in _cardAnimations) {
      anim.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionImage() {
    const imageUrl = 'https://img.freepik.com/free-vector/programming-concept-illustration_114360-1351.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFF0A2463),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF0A2463),
              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
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
            right: 20,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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

  Widget _buildVideoPlayer() {
    if (_videoError) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(62, 146, 204, 0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
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
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF3E92CC),
            progressColors: ProgressBarColors(
              playedColor: const Color(0xFF3E92CC),
              handleColor: const Color(0xFF3E92CC),
              bufferedColor: Color.fromRGBO(62, 146, 204, 0.3),
              backgroundColor: Color.fromRGBO(62, 146, 204, 0.1),
            ),
            onReady: () {
              _youtubeController.unMute();
            },
            onEnded: (metaData) {
              _youtubeController.pause();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(String title, List<Widget> content, {Color? color, int? animationIndex}) {
    final animation = animationIndex != null && animationIndex < _cardAnimations.length
        ? _cardAnimations[animationIndex]
        : _controller;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: color ?? Color.fromRGBO(10, 36, 99, 0.3),
            margin: const EdgeInsets.only(bottom: 20),
            shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color != null ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.5) : Color.fromRGBO(10, 36, 99, 0.2),
                    color != null ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.3) : Color.fromRGBO(62, 146, 204, 0.1),
                  ],
                ),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E92CC),
                                borderRadius: BorderRadius.circular(2),
                              ),
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...content,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightBox(String content, {Color? color, String? title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(62, 146, 204, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color != null ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.5) : Color.fromRGBO(62, 146, 204, 0.5),
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
                    color: color != null ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.8) : Color.fromRGBO(62, 146, 204, 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color != null ? Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.9) : Color.fromRGBO(62, 146, 204, 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCodeBox(String code, String? explanation, String sectionTitle, String exampleKey) {
    String language = 'text';
    if (sectionTitle == 'Datos primitivos' || sectionTitle == 'Datos no primitivos') {
      language = 'java';
    } else if (sectionTitle == 'Arreglos' || sectionTitle == 'Listas') {
      language = 'python';
    } else if (sectionTitle == 'Matrices') {
      language = code.contains('matriz_python') ? 'python' : 'java';
    }

    final isExplanationVisible = _codeExplanationVisibility[exampleKey] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(10, 36, 99, 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(62, 146, 204, 0.4)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
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
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
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
                  language: language,
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
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _codeExplanationVisibility[exampleKey] = !isExplanationVisible;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E92CC),
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
            if (isExplanationVisible) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(16, 185, 129, 0.2),
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
                    Text(
                      explanation,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Color.fromRGBO(62, 146, 204, 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color.fromRGBO(255, 255, 255, 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentList(dynamic content) {
    if (content is String) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Color.fromRGBO(255, 255, 255, 0.9),
              height: 1.6,
            ),
          ),
        )
      ];
    } else if (content is List) {
      return content.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            item.toString(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Color.fromRGBO(255, 255, 255, 0.9),
              height: 1.6,
            ),
          ),
        );
      }).toList();
    }
    return [];
  }

  List<Widget> _buildBulletList(List<dynamic> items) {
    return items.map((item) => _buildBulletPoint(item.toString())).toList();
  }

  Widget _buildSectionContent(Map<String, dynamic> section, int animationIndex) {
    final widgets = <Widget>[];
    final sectionTitle = section['titulo']?.toString() ?? '';

    if (section['contenido'] != null) {
      widgets.addAll(_buildContentList(section['contenido']));
      widgets.add(const SizedBox(height: 16));
    }

    if (section['items'] != null && section['items'] is List) {
      widgets.addAll(_buildBulletList(section['items']));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['tipo'] == 'highlight') {
      Color? color;
      switch (section['color']) {
        case 'green':
          color = const Color(0xFF10B981);
          break;
        case 'blue':
          color = const Color(0xFF3E92CC);
          break;
        case 'purple':
          color = const Color(0xFF8B5CF6);
          break;
      }

      final content = section['contenido'] is String ? section['contenido'] : '';
      widgets.add(_buildHighlightBox(
        content,
        color: color,
        title: section['titulo'] is String ? section['titulo'] : null,
      ));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['clasificacion'] != null && section['clasificacion'] is Map) {
      final clasificacion = section['clasificacion'] as Map<String, dynamic>;
      if (clasificacion['items'] != null && clasificacion['items'] is List) {
        widgets.add(_buildHighlightBox(
          (clasificacion['items'] as List).join('\n\n'),
          color: Color.fromRGBO(62, 146, 204, 0.2),
          title: clasificacion['titulo'] is String ? clasificacion['titulo'] : null,
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }

    if (section['ejemplos'] != null && section['ejemplos'] is List) {
      (section['ejemplos'] as List).asMap().forEach((index, example) {
        final code = example is String ? example : example['code']?.toString() ?? '';
        final explanation = example is Map ? example['explicacion']?.toString() : null;
        widgets.add(_buildCodeBox(
          code,
          explanation,
          sectionTitle,
          'example_$animationIndex$index',
        ));
        widgets.add(const SizedBox(height: 12));
      });
    } else if (section['ejemplo'] != null) {
      final code = section['ejemplo'] is String ? section['ejemplo'] : section['ejemplo']['code']?.toString() ?? '';
      final explanation = section['ejemplo'] is Map ? section['ejemplo']['explicacion']?.toString() : null;
      widgets.add(_buildCodeBox(
        code,
        explanation,
        sectionTitle,
        'example_$animationIndex',
      ));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['descripcion'] != null && section['descripcion'] is String) {
      widgets.add(Text(
        section['descripcion'],
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
          height: 1.6,
        ),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['definicion'] != null && section['definicion'] is String) {
      widgets.add(Text(
        section['definicion'],
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
          height: 1.6,
        ),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['usos'] != null && section['usos'] is List) {
      widgets.add(Text(
        'Usos:',
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(_buildBulletList(section['usos']));
      widgets.add(const SizedBox(height: 8));
    }

    if (section['operaciones'] != null && section['operaciones'] is List) {
      widgets.add(Text(
        'Operaciones comunes:',
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(_buildBulletList(section['operaciones']));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['caracteristicas'] != null && section['caracteristicas'] is List) {
      widgets.add(Text(
        'Características:',
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(_buildBulletList(section['caracteristicas']));
      widgets.add(const SizedBox(height: 12));
    }

    if (section['conclusion'] != null && section['conclusion'] is String) {
      widgets.add(Text(
        section['conclusion'],
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Color.fromRGBO(255, 255, 255, 0.9),
          height: 1.6,
        ),
      ));
    }

    return Column(children: widgets);
  }

  Widget _buildQuizQuestion(Map<String, dynamic> question, int questionIndex, int animationIndex) {
    final bool isAnswered = _answerResults[questionIndex] != null;
    final bool isCorrect = _answerResults[questionIndex] == true;
    final bool showExplanation = _showExplanations[questionIndex] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pregunta ${questionIndex + 1}: ${question['pregunta']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...question['opciones'].asMap().entries.map<Widget>((entry) {
          final option = entry.value;
          return RadioListTile<String>(
            title: Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color.fromRGBO(255, 255, 255, 0.9),
              ),
            ),
            value: option,
            groupValue: _selectedAnswers[questionIndex],
            onChanged: isAnswered
                ? null
                : (value) {
                    setState(() {
                      _selectedAnswers[questionIndex] = value;
                    });
                  },
            activeColor: const Color(0xFF3E92CC),
          );
        }).toList(),
        const SizedBox(height: 12),
        if (_selectedAnswers[questionIndex] != null)
          ElevatedButton(
            onPressed: isAnswered
                ? null
                : () {
                    setState(() {
                      _answerResults[questionIndex] =
                          _selectedAnswers[questionIndex] == question['respuesta_correcta'];
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
        if (showExplanation)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildHighlightBox(
              question['explicacion'],
              color: Color.fromRGBO(16, 185, 129, 0.2),
              title: 'Explicación',
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateNext() {
    widget.onComplete(widget.sectionIndex);
    final nextIndex = widget.sectionIndex + 1;
    final nextSectionKey = widget.content.keys.elementAt(nextIndex);
    final nextSection = widget.content[nextSectionKey];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Tema3(
          section: nextSection,
          sectionTitle: nextSection['title'] ?? 'Sección ${nextIndex + 1}',
          sectionIndex: nextIndex,
          totalSections: widget.totalSections,
          content: widget.content,
          moduleData: widget.moduleData,
          onComplete: widget.onComplete,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A2463),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E92CC)),
              ),
              const SizedBox(height: 20),
              Text(
                'Cargando contenido...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.sectionTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(10, 36, 99, 0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: _navigateNext,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A2463),
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            'Siguiente tema',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A2463),
              Color(0xFF1E3A8A),
              Color(0xFF3E92CC),
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionImage(),
                      const SizedBox(height: 24),

                      if (_contentData?['introduccion'] != null)
                        _buildContentCard(
                          _contentData!['introduccion']['titulo'] ?? '',
                          _buildContentList(_contentData!['introduccion']['contenido']),
                          color: Color.fromRGBO(62, 146, 204, 0.15),
                        ),

                      if (_contentData?['subtema1'] != null)
                        _buildContentCard(
                          _contentData!['subtema1']['titulo'] ?? '',
                          [
                            ..._buildContentList(_contentData!['subtema1']['contenido']),
                            if (_contentData!['subtema1']['secciones'] != null)
                              ...(_contentData!['subtema1']['secciones'] as List).asMap().entries.map<Widget>((entry) {
                                final index = entry.key;
                                final section = entry.value;
                                return _buildSectionContent(section, index);
                              }).expand((widget) => [widget, const SizedBox(height: 16)]),
                          ],
                          color: Color.fromRGBO(16, 185, 129, 0.15),
                        ),

                      const SizedBox(height: 24),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _contentAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3E92CC),
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
                                'Aprende sobre estructuras de datos con este video tutorial',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Color.fromRGBO(255, 255, 255, 0.9),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildVideoPlayer(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      if (_contentData?['subtema2'] != null)
                        _buildContentCard(
                          _contentData!['subtema2']['titulo'] ?? '',
                          [
                            ..._buildContentList(_contentData!['subtema2']['contenido']),
                            if (_contentData!['subtema2']['secciones'] != null)
                              ...(_contentData!['subtema2']['secciones'] as List).asMap().entries.map<Widget>((entry) {
                                final index = entry.key;
                                final section = entry.value;
                                final animationIndex = (_contentData!['subtema1']?['secciones']?.length ?? 0) + index;
                                return _buildSectionContent(section, animationIndex);
                              }).expand((widget) => [widget, const SizedBox(height: 16)]),
                          ],
                          color: Color.fromRGBO(139, 92, 246, 0.15),
                        ),

                      if (_contentData?['quiz'] != null)
                        _buildContentCard(
                          _contentData!['quiz']['titulo'] ?? '',
                          [
                            ..._buildContentList(_contentData!['quiz']['contenido']),
                            if (_contentData!['quiz']['preguntas'] != null)
                              ...(_contentData!['quiz']['preguntas'] as List).asMap().entries.map<Widget>((entry) {
                                final question = entry.value;
                                final animationIndex = (_contentData!['subtema1']?['secciones']?.length ?? 0) +
                                    (_contentData!['subtema2']?['secciones']?.length ?? 0) +
                                    entry.key;
                                return _buildQuizQuestion(question, entry.key, animationIndex);
                              }).expand((widget) => [widget, const SizedBox(height: 16)]),
                          ],
                          color: Color.fromRGBO(255, 214, 10, 0.15),
                        ),

                      const SizedBox(height: 100),
                    ],
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