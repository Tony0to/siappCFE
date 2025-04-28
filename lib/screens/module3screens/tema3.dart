import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tema4.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Module3Tema3Screen extends StatefulWidget {
  final Map<String, dynamic> section;
  final Map<String, dynamic> moduleData;
  final int sectionIndex;
  final int totalSections;
  final Function(int) onComplete;

  const Module3Tema3Screen({
    Key? key,
    required this.section,
    required this.moduleData,
    required this.sectionIndex,
    required this.totalSections,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<Module3Tema3Screen> createState() => _Module3Tema3ScreenState();
}

class _Module3Tema3ScreenState extends State<Module3Tema3Screen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final _scrollController = ScrollController();
  Map<String, dynamic>? _contentData;
  List<dynamic>? _quizQuestions;
  String? _errorMessage;
  bool _isLoading = true;

  Map<int, String?> _selectedAnswers = {};
  Map<int, bool> _isCorrect = {};
  bool _showResults = false;
  Set<String> _shownImages = {}; // Conjunto para rastrear imágenes ya mostradas

  static final Map<String, String> _sectionImages = {
    // Tema 3: Algoritmos de ordenamiento
    'algoritmos_ordenamiento': 'https://images.unsplash.com/photo-1610563166150-b34df4f3bcd6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1527&q=80', // Imagen para portada
    'ordenamiento_basico': 'https://images.unsplash.com/photo-1610563166150-b34df4f3bcd6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1527&q=80', // Elementos reorganizándose visualmente
    'ordenamiento_avanzado': 'https://images.unsplash.com/photo-1547658719-da2b51169166?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1528&q=80', // Diagrama de fusión/partición
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _shownImages = {}; // Inicializar el conjunto de imágenes mostradas
    _loadJsonContent();
  }

  Future<void> _loadJsonContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String jsonString = await rootBundle.loadString('assets/data/module3.json');
      final data = json.decode(jsonString);

      final sectionContent = data['content']['section_3'];

      final activities = data['activities'] as List<dynamic>;
      final tema3Activity = activities.firstWhere(
        (activity) => activity['subtopic'] == 'Algoritmos de búsqueda y ordenamiento',
        orElse: () => null,
      );

      if (tema3Activity == null) {
        throw Exception('No se encontró la actividad para el tema 3');
      }

      setState(() {
        _contentData = {
          ...sectionContent,
          'objective': tema3Activity['objective'],
          'theory': tema3Activity['theory'],
          'reflection': tema3Activity['reflection'],
          'practice': tema3Activity['practice'],
        };
        _quizQuestions = tema3Activity['theory']['questions'];
        _selectedAnswers = {for (var i = 0; i < _quizQuestions!.length; i++) i: null};
        _isCorrect = {for (var i = 0; i < _quizQuestions!.length; i++) i: false};
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error al cargar el JSON: $e\n$stackTrace');
      setState(() {
        _errorMessage = 'Error al cargar el contenido: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionImage() {
    final imageUrl = _sectionImages['algoritmos_ordenamiento']!;
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
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 40,
                  ),
                  child: Text(
                    _contentData?['title']?.toString() ?? widget.section['title'] ?? 'Algoritmos de ordenamiento',
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
      if (trimmed.startsWith('•') || trimmed.startsWith('1.')) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 8, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trimmed.substring(trimmed.startsWith('•') ? 1 : 2).trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(30, 64, 175, 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color.fromRGBO(59, 130, 246, 0.5)),
          ),
          child: Text(
            trimmed.substring(1, trimmed.length - 1),
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        );
      }
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
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }

  Widget _buildQuiz(Map<String, dynamic>? question, int questionIndex) {
    if (question == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
              Flexible(
                child: Text(
                  'Pregunta ${questionIndex + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['question']?.toString() ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ...(question['options'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final optionText = entry.value?.toString() ?? '';
            final isSelected = _selectedAnswers[questionIndex] == optionText;
            final isCorrect = index == question['correctAnswer'];
            Color textColor = Colors.white;
            Color borderColor = Color.fromRGBO(59, 130, 246, 0.5);
            Color bgColor = Color.fromRGBO(30, 64, 175, 0.2);

            if (_showResults) {
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
                    _selectedAnswers[questionIndex] = optionText;
                    _isCorrect[questionIndex] = isCorrect;
                  });
                },
                child: Container(
                  width: double.infinity,
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
                        child: isSelected && _showResults
                            ? Icon(
                                isCorrect ? Icons.check : Icons.close,
                                size: 16,
                                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              )
                            : isSelected
                                ? const Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Colors.white,
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
                          softWrap: true,
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

  Widget _buildNoteCard(String? content, {Color? color, String? title}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
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

  Widget _buildHighlightCard(Map<String, dynamic>? highlight) {
    if (highlight == null || highlight['text'] == null) return const SizedBox.shrink();

    final colorString = highlight['color']?.toString();
    Color color;
    switch (colorString?.toLowerCase()) {
      case 'blue':
        color = const Color(0xFF1E40AF);
        break;
      case 'green':
        color = const Color(0xFF065F46);
        break;
      default:
        color = const Color(0xFF1E40AF);
    }

    return _buildNoteCard(
      highlight['text']?.toString(),
      color: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
      title: 'Nota Importante',
    );
  }

  Widget _buildNetworkImageWithCaption(String imageUrl, String caption, {double height = 220}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: height,
                color: const Color(0xFF1E40AF),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: height,
                color: const Color(0xFF1E40AF),
                child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, String>? _getImageForSubsection(String title) {
    final lowerTitle = title.toLowerCase();
    debugPrint('Procesando título de subsección: $title');

    if (lowerTitle.contains('recursividad') || lowerTitle.contains('insercion') || 
        lowerTitle.contains('selección') || lowerTitle.contains('seleccion')) {
      debugPrint('Asignando imagen: ordenamiento_basico');
      return {'key': 'ordenamiento_basico', 'caption': 'Ordenamiento básico'};
    }
    if (lowerTitle.contains('iterativos') || lowerTitle.contains('quicksort') || lowerTitle.contains('o(n log n)')) {
      debugPrint('Asignando imagen: ordenamiento_avanzado');
      return {'key': 'ordenamiento_avanzado', 'caption': 'Ordenamiento avanzado'};
    }
    debugPrint('No se asignó ninguna imagen para: $title');
    return null; // No mostrar imagen si no hay coincidencia
  }

  void _navigateNext() {
    widget.onComplete(widget.sectionIndex);
    if (widget.sectionIndex + 1 < widget.totalSections) {
      final nextIndex = widget.sectionIndex + 1;
      final nextSectionKey = widget.moduleData['content'].keys.elementAt(nextIndex);
      final nextSection = widget.moduleData['content'][nextSectionKey];
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Module3Tema4Screen(
            section: nextSection,
            moduleData: widget.moduleData,
            sectionIndex: nextIndex,
            totalSections: widget.totalSections,
            onComplete: widget.onComplete,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _navigateBack() {
    widget.onComplete(widget.sectionIndex);
    Navigator.pop(context);
  }

  void _verifyAnswers() {
    setState(() {
      _showResults = true;
    });

    int correctCount = _isCorrect.values.where((isCorrect) => isCorrect).length;
    int totalQuestions = _quizQuestions!.length;
    String message;
    if (correctCount == totalQuestions) {
      message = '¡Excelente! Todas las respuestas son correctas.';
    } else if (correctCount > 0) {
      message = 'Bien, acertaste $correctCount de $totalQuestions preguntas.';
    } else {
      message = 'Lo siento, ninguna respuesta es correcta.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: correctCount == totalQuestions ? Colors.green : correctCount > 0 ? Colors.orange : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadJsonContent,
                  child: Text('Reintentar', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E40AF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final subsections = _contentData?['subsections'] as List<dynamic>? ?? [];

    return WillPopScope(
      onWillPop: () async {
        widget.onComplete(widget.sectionIndex); // Guardar progreso antes de salir
        return true; // Permitir la salida
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            widget.section['title'] ?? 'Algoritmos de ordenamiento',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack, // Usar el método que guarda progreso
          ),
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
                if (_contentData?['objective'] != null)
                  _buildNoteCard(
                    _contentData?['objective'],
                    color: Color.fromRGBO(30, 64, 175, 0.3),
                    title: 'Objetivo',
                  ),
                ...subsections.expand((subsection) {
                  final title = subsection['title'] as String;
                  final content = subsection['content'] as String;
                  final highlight = subsection['highlight'] as Map<String, dynamic>?;
                  final additionalContent = subsection['additional_content'] as String?;

                  List<Widget> widgets = [
                    _buildSectionHeader(title),
                    _buildNoteCard(content),
                  ];

                  // Obtener la imagen para la subsección y verificar si ya fue mostrada
                  final imageInfo = _getImageForSubsection(title);
                  if (imageInfo != null && !_shownImages.contains(imageInfo['key'])) {
                    debugPrint('Mostrando imagen: ${imageInfo['key']} para título: $title');
                    widgets.insert(
                      0,
                      _buildNetworkImageWithCaption(
                        _sectionImages[imageInfo['key']]!,
                        imageInfo['caption']!,
                      ),
                    );
                    _shownImages.add(imageInfo['key']!); // Registrar la imagen como mostrada
                    debugPrint('Imágenes mostradas hasta ahora: $_shownImages');
                  } else if (imageInfo != null) {
                    debugPrint('Imagen omitida (ya mostrada): ${imageInfo['key']} para título: $title');
                  } else {
                    debugPrint('No se muestra ninguna imagen para: $title');
                  }

                  if (highlight != null) {
                    widgets.add(
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildHighlightCard(highlight),
                      ),
                    );
                  }

                  if (additionalContent != null) {
                    widgets.add(_buildNoteCard(additionalContent));
                  }

                  return widgets;
                }).toList(),
                if (_quizQuestions != null && _quizQuestions!.isNotEmpty) ...[
                  _buildSectionHeader('Evaluación de conocimiento'),
                  ..._quizQuestions!.asMap().entries.map((entry) {
                    return _buildQuiz(entry.value, entry.key);
                  }).toList(),
                  if (!_showResults)
                    Center(
                      child: ElevatedButton(
                        onPressed: (_selectedAnswers.values.every((answer) => answer != null))
                            ? _verifyAnswers
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E40AF),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Verificar Respuestas',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
                if (_contentData?['reflection'] != null) ...[
                  _buildSectionHeader('Reflexión'),
                  _buildNoteCard(_contentData?['reflection']),
                ],
                if (_contentData?['practice'] != null) ...[
                  _buildSectionHeader('Práctica'),
                  _buildNoteCard(
                    _contentData?['practice']?['question'],
                    color: Color.fromRGBO(6, 95, 70, 0.3),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}