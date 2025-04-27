import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siapp/screens/module2screens/tema4.dart'; // Adjust import as needed
import 'dart:convert';
import 'package:flutter/services.dart';

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
  _Tema3State createState() => _Tema3State();
}

class _Tema3State extends State<Tema3> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? _contentData;
  Map<int, dynamic> _userAnswers = {};
  Map<int, bool> _showResults = {};

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
    _loadContentData();
    _controller.forward();
  }

  Future<void> _loadContentData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/module2/tema3.json');
      final jsonData = json.decode(jsonString);
      setState(() {
        _contentData = jsonData;
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String content, {Color? color, String? title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF3E92CC).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? const Color(0xFF3E92CC)).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: (color ?? const Color(0xFF3E92CC)).withOpacity(0.9),
                ),
              ),
            ),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontStyle: title != null ? FontStyle.italic : null,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(String code, String language) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<dynamic> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fiber_manual_record, size: 10, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<Widget> _formatContent(String content) {
    return content.split('\n').map((paragraph) {
      if (paragraph.trim().isEmpty) return const SizedBox(height: 12);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          paragraph,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white,
            height: 1.6,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQuizSection() {
    if (_contentData?['quiz'] == null) return const SizedBox.shrink();

    final quiz = _contentData!['quiz'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quiz['titulo'],
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          quiz['descripcion'],
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        ...quiz['preguntas'].asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final pregunta = entry.value;
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pregunta ${index + 1}: ${pregunta['pregunta']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (pregunta['tipo'] == 'multiple_choice')
                    ...pregunta['opciones'].asMap().map((i, opcion) {
                      return MapEntry(
                        i,
                        RadioListTile<String>(
                          title: Text(
                            opcion,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          value: opcion,
                          groupValue: _userAnswers[index],
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[index] = value;
                            });
                          },
                        ),
                      );
                    }).values.toList()
                  else if (pregunta['tipo'] == 'true_false')
                    Column(
                      children: [
                        RadioListTile<bool>(
                          title: Text(
                            'Verdadero',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          value: true,
                          groupValue: _userAnswers[index],
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[index] = value;
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            'Falso',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          value: false,
                          groupValue: _userAnswers[index],
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[index] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _userAnswers[index] == null
                        ? null
                        : () {
                            setState(() {
                              _showResults[index] = true;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Verificar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_showResults[index] == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      _userAnswers[index] == pregunta['respuesta_correcta']
                          ? '¡Correcto!'
                          : 'Incorrecto',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _userAnswers[index] == pregunta['respuesta_correcta']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explicación: ${pregunta['explicacion']}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 80),
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
        pageBuilder: (context, animation, secondaryAnimation) => Tema4(
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

  @override
  Widget build(BuildContext context) {
    if (_contentData == null) {
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Cargando contenido...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
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
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateNext,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          'Siguiente',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2463), Color(0xFF3E92CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSectionImage(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Introducción
                if (_contentData?['introduccion'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._formatContent(_contentData!['introduccion']['contenido']),
                      const SizedBox(height: 16),
                      _buildHighlightBox(
                        _contentData!['introduccion']['highlight']['text'],
                        color: Colors.green.withOpacity(0.2),
                        title: "Importante",
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                
                // Características
                if (_contentData?['caracteristicas'] != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _contentData!['caracteristicas']['titulo'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBulletList(_contentData!['caracteristicas']['items']),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Subtema 1: Secuenciales
                if (_contentData?['subtema1'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _contentData!['subtema1']['titulo'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._formatContent(_contentData!['subtema1']['contenido']),
                      const SizedBox(height: 16),
                      
                      // Ejemplo de código
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.blue.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _contentData!['subtema1']['ejemplo']['titulo'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _contentData!['subtema1']['ejemplo']['descripcion'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildCodeBox(
                                _contentData!['subtema1']['ejemplo']['codigo'],
                                "JavaScript",
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _contentData!['subtema1']['conclusion'],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                
                // Subtema 2: Condicionales
                if (_contentData?['subtema2'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _contentData!['subtema2']['titulo'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._formatContent(_contentData!['subtema2']['contenido']),
                      const SizedBox(height: 16),
                      
                      // Lista de condicionales
                      ..._contentData!['subtema2']['condicionales'].map<Widget>((condicional) {
                        Color color;
                        switch (condicional['color']) {
                          case 'blue': color = Colors.blue; break;
                          case 'purple': color = Colors.purple; break;
                          case 'indigo': color = Colors.indigo; break;
                          case 'teal': color = Colors.teal; break;
                          case 'cyan': color = Colors.cyan; break;
                          default: color = Colors.blue;
                        }
                        
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: color.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Condicional ${condicional['tipo']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  condicional['descripcion'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildCodeBox(
                                  condicional['ejemplo'],
                                  condicional['tipo'] == 'switch' || condicional['tipo'] == 'switch sin break' 
                                    ? "JavaScript" 
                                    : "Ejemplo genérico",
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      
                      // Nota importante
                      _buildHighlightBox(
                        _contentData!['subtema2']['nota_importante']['text'],
                        color: Colors.green.withOpacity(0.2),
                        title: "Importante",
                      ),
                      const SizedBox(height: 16),
                      
                      // Cuándo usar switch
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.green.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _contentData!['subtema2']['cuando_usar_switch']['titulo'],
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildBulletList(_contentData!['subtema2']['cuando_usar_switch']['items']),
                              const SizedBox(height: 12),
                              Text(
                                _contentData!['subtema2']['cuando_usar_switch']['conclusion'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                
                // Subtema 3: Bucles
                if (_contentData?['subtema3'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _contentData!['subtema3']['titulo'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._formatContent(_contentData!['subtema3']['contenido']),
                      const SizedBox(height: 16),
                      
                      // Lista de bucles
                      ..._contentData!['subtema3']['bucles'].map<Widget>((bucle) {
                        Color color;
                        switch (bucle['color']) {
                          case 'orange': color = Colors.orange; break;
                          case 'purple': color = Colors.purple; break;
                          case 'indigo': color = Colors.indigo; break;
                          default: color = Colors.orange;
                        }
                        
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: color.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bucle ${bucle['tipo']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bucle['descripcion'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "¿Qué es?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bucle['definicion'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  bucle['explicacion'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Estructura",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bucle['estructura'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Ejemplos de código
                                Column(
                                  children: bucle['ejemplos'].map<Widget>((ejemplo) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCodeBox(
                                        ejemplo['codigo'],
                                        "${ejemplo['lenguaje']}",
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                const SizedBox(height: 12),
                                Text(
                                  "¿Cuándo utilizarlo?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildBulletList(bucle['cuando_usar']),
                                const SizedBox(height: 12),
                                Text(
                                  bucle['conclusion'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      
                      // Nota importante final
                      _buildHighlightBox(
                        _contentData!['subtema3']['nota_importante']['text'],
                        color: Colors.green.withOpacity(0.2),
                        title: "Importante",
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                
                // Quiz Section
                _buildQuizSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}