import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:siapp/screens/module2screens/tema2.dart';
import 'package:siapp/screens/module2screens/flowcharts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  String? _correctAnswer;
  late YoutubePlayerController _youtubeController;
  bool _videoError = false;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _loadJsonContent();

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

  Future<void> _loadJsonContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module2/tema1.json');
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
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionImage() {
    final imageUrl = _contentData?['sectionImage'] as String?;
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
                  color: const Color(0xFF1E40AF),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1E40AF),
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
                  Color.fromRGBO(30, 64, 175, 0.8),
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
                  _contentData?['sectionTitle']?.toString() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tema ${widget.sectionIndex + 1} de ${widget.totalSections}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
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
            color: isIntro ? Colors.white : Colors.white.withOpacity(0.9),
            fontWeight: isIntro ? FontWeight.w500 : FontWeight.normal,
            height: 1.5,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFlowchart(String? flowchartId) {
    if (flowchartId == null) return const SizedBox.shrink();

    final flowchartConfig = {
      'rectangulo': {'scale': 0.65, 'height': 350.0},
      'par_impar': {'scale': 0.6, 'height': 400.0},
      'bucle': {'scale': 0.6, 'height': 400.0},
      'condicional_multiple': {'scale': 0.5, 'height': 450.0},
      'rango_numeros': {'scale': 0.6, 'height': 400.0},
      'aprobacion_estudiante': {'scale': 0.6, 'height': 450.0},
    };

    final config = flowchartConfig[flowchartId] ?? {'scale': 0.7, 'height': 350.0};

    return Container(
      height: (config['height'] as double?) ?? 350.0,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Diagrama de Flujo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.1,
              maxScale: 4.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Transform.scale(
                    scale: (config['scale'] as double?) ?? 0.7,
                    alignment: Alignment.topCenter,
                    child: FlowCharts.getFlowChart(flowchartId),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pellizca para hacer zoom • Desliza para mover',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(Map<String, dynamic>? question) {
    if (question == null) return const SizedBox.shrink();

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
              Text(
                'Evaluación de conocimiento',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
              question['logic']?.toString() ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFFBFDBFE),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question['text']?.toString() ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...(question['options'] as List<dynamic>? ?? []).map((option) {
            final optionText = option?.toString() ?? '';
            final isSelected = _selectedAnswer == optionText;
            final isCorrect = optionText == question['correct']?.toString();
            Color textColor = Colors.white;
            Color borderColor = Color.fromRGBO(59, 130, 246, 0.5);
            Color bgColor = Color.fromRGBO(30, 64, 175, 0.2);

            if (_selectedAnswer != null) {
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
                onTap: () {
                  setState(() {
                    _selectedAnswer = optionText;
                    _correctAnswer = question['correct']?.toString();
                    if (optionText == _correctAnswer) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Correcto!', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Incorrecto, la respuesta correcta es ${question['correct']}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

  Widget _buildVideoPlayer() {
    if (_videoError) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(30, 64, 175, 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  'No se pudo cargar el video. Por favor, intenta de nuevo más tarde.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
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
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        progressColors: const ProgressBarColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
        ),
        onReady: () {
          _youtubeController.unMute();
        },
        onEnded: (metaData) {
          _youtubeController.pause();
        },
      ),
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
        pageBuilder: (context, animation, secondaryAnimation) => Tema2(
          section: nextSection,
          sectionTitle: nextSection['title'] ?? 'Sección ${nextIndex + 1}',
          sectionIndex: nextIndex,
          totalSections: widget.totalSections,
          content: widget.content,
          moduleData: widget.moduleData,
          onComplete: widget.onComplete,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildSectionHeader(String? title) {
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
    );
  }

  Widget _buildExampleCard(Map<String, dynamic>? example) {
    if (example == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 64, 175, 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example['title'] != null)
              Row(
                children: [
                  Container(
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
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ..._formatContent(example['logic']?.toString()),
            const SizedBox(height: 10),
            if (example['flowchartId'] != null)
              _buildFlowchart(example['flowchartId']?.toString()),
            const SizedBox(height: 10),
            ..._formatContent(example['explanation']?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String? content, {Color? color, String? title}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? Color.fromRGBO(30, 64, 175, 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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

  Widget _buildNoteCardFromJson(Map<String, dynamic>? note) {
    if (note == null) return const SizedBox.shrink();

    final colorString = note['color']?.toString();
    final color = colorString != null && colorString.isNotEmpty
      ? Color(int.parse(colorString.replaceAll('#', '0xFF')))
      : const Color(0xFF1E40AF);
    
    final opacity = note['opacity']?.toDouble() ?? 0.3;

    return _buildNoteCard(
      note['content']?.toString(),
      color: Color.fromRGBO(
        color.red,
        color.green,
        color.blue,
        opacity,
      ),
      title: note['title']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E40AF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.sectionTitle,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${widget.sectionIndex + 1}/${widget.totalSections}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateNext,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E40AF),
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          'Siguiente tema',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
                ),
                child: _buildSectionImage(),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4)),
                ),
                child: _buildNoteCard(
                  _contentData?['introText']?.toString(),
                  color: Color.fromRGBO(30, 64, 175, 0.3),
                ),
              ),
              
              // Construir cada subsección del JSON
              ...(_contentData?['subsections'] as List<dynamic>? ?? []).map((section) {
                final sectionData = section as Map<String, dynamic>?;
                if (sectionData == null) return const SizedBox.shrink();

                final examples = sectionData['examples'] as List<dynamic>? ?? [];
                final notes = sectionData['notes'] as List<dynamic>? ?? [];
                final finalNote = sectionData['finalNote'] as Map<String, dynamic>?;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionHeader(sectionData['title']?.toString()),
                    _buildNoteCard(sectionData['content']?.toString()),
                    const SizedBox(height: 8),
                    
                    // Construir ejemplos
                    ...examples.map((example) {
                      final exampleData = example as Map<String, dynamic>?;
                      if (exampleData == null) return const SizedBox.shrink();

                      return Column(
                        children: [
                          _buildExampleCard(exampleData),
                          
                          // Mostrar quiz si existe
                          if (exampleData['quiz'] != null)
                            _buildQuiz(exampleData['quiz'] as Map<String, dynamic>?),
                          
                          // Mostrar notas si existen
                          ...(exampleData['notes'] as List<dynamic>? ?? []).map((note) {
                            return _buildNoteCardFromJson(note as Map<String, dynamic>?);
                          }),
                        ],
                      );
                    }),
                    
                    // Mostrar nota final si existe
                    if (finalNote != null)
                      _buildNoteCardFromJson(finalNote),
                  ],
                );
              }),
              
              // Video explicativo
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(_contentData?['video']?['title']?.toString()),
                  Text(
                    _contentData?['video']?['description']?.toString() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildVideoPlayer(),
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