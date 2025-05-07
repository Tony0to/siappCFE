import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siapp/screens/module3screens/contenido_screen.dart';
import 'module3screens/actividades.dart';
import 'package:siapp/screens/module3screens/actividades.dart';
import 'package:siapp/screens/ModulesScreen.dart';
import 'package:siapp/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Module3Content {
  static Map<String, dynamic>? _content;
  static bool _isLoaded = false;

  static Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/module3.json');
      _content = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Error al cargar el contenido del módulo: $e');
    }
  }

  static Map<String, dynamic> get content {
    if (_content == null) {
      throw Exception('Contenido del módulo no cargado. Llama a Module3Content.initialize() primero');
    }
    return _content!;
  }
}

class Module3IntroScreen extends StatefulWidget {
  final Map<String, dynamic> module;

  const Module3IntroScreen({Key? key, required this.module}) : super(key: key);

  @override
  State<Module3IntroScreen> createState() => _Module3IntroScreenState();
}

class _Module3IntroScreenState extends State<Module3IntroScreen>
    with SingleTickerProviderStateMixin {
  late Future<void> _loadContentFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // URL de la imagen para el Módulo 3
  final String moduleImageUrl =
      'https://images.unsplash.com/photo-1508313880080-c4bef0730395?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80';

  @override
  void initState() {
    super.initState();
    _loadContentFuture = Module3Content.initialize();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadContentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundDynamic,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.progressActive,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando módulo...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundDynamic,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error.toString()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.error,
                        textStyle: const TextStyle(height: 1.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadContentFuture = Module3Content.initialize();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.buttonText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        'Reintentar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final moduleContent = Module3Content.content;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Scaffold(
              floatingActionButton: ScaleTransition(
                scale: _scaleAnimation,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: AppColors.buttonText,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const ModulesScreen()),
                      (route) => route.isFirst || route.settings.name == '/modules',
                    );
                  },
                  child: Icon(Icons.arrow_back, color: AppColors.buttonText),
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundDynamic,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 70, bottom: 20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            moduleContent['module_title'] ?? 'Módulo 3',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          height: 220,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: moduleImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.cardBackground,
                                    child: Center(
                                      child: CircularProgressIndicator(color: AppColors.progressActive),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColors.cardBackground,
                                    child: Icon(Icons.image_not_supported, size: 50, color: AppColors.textSecondary),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.headerSection,
                                  ),
                                ),
                                Center(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      moduleContent['welcome']?['title'] ?? '¡Bienvenido al Módulo 3!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-0.5, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _controller,
                                  curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                                )),
                                child: Text(
                                  moduleContent['welcome']?['details'] ??
                                      'Exploraremos los conceptos fundamentales de los algoritmos y estudiaremos técnicas clave como la búsqueda, el ordenamiento y la recursividad.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: AppColors.cardBackground,
                                shadowColor: AppColors.shadowColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.glassmorphicBorder),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.list_alt,
                                              color: AppColors.progressBrightBlue,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              moduleContent['syllabus']?['title'] ?? 'Temario',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        ...List<Map<String, dynamic>>.from(
                                                moduleContent['syllabus']?['sections'] ?? [])
                                            .map((section) => _buildSyllabusSection(section))
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                moduleContent['learning_points']?['title'] ?? 'Lo que aprenderás',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ...List<Map<String, dynamic>>.from(
                                    moduleContent['learning_points']?['points'] ?? [])
                                .map((point) => _buildLearningPoint(
                                      icon: _getIcon(point['icon'] ?? ''),
                                      title: point['title'] ?? 'Sin título',
                                      description: point['description'] ?? 'Sin descripción',
                                    ))
                                .toList(),
                            const SizedBox(height: 30),
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Card(
                                elevation: 8,
                                color: AppColors.cardBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.glassmorphicBorder),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _getIcon(moduleContent['motivation']?['icon'] ?? 'emoji_objects'),
                                          size: 50,
                                          color: AppColors.progressBrightBlue,
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          moduleContent['motivation']?['text'] ??
                                              '¡Transforma problemas en soluciones elegantes y eficientes!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: AppColors.primaryGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.shadowColor,
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  ContenidoScreen(moduleData: moduleContent),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: const Duration(milliseconds: 300),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: AppColors.buttonText,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.play_arrow, color: AppColors.buttonText, size: 24),
                                            const SizedBox(width: 10),
                                            Text(
                                              moduleContent['button_text'] ?? 'Comenzar Módulo',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.buttonText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.glassmorphicBorder,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.shadowColor,
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  Module3ActividadesScreen(moduleData: moduleContent),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: const Duration(milliseconds: 300),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.cardBackground,
                                          foregroundColor: AppColors.textPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.assignment, color: AppColors.progressBrightBlue, size: 24),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Actividades Prácticas',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSyllabusSection(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section['title'] ?? 'Sección sin título',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...List<String>.from(section['items'] ?? [])
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.progressBrightBlue,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildLearningPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassmorphicBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.progressBrightBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.progressBrightBlue, width: 1.5),
                  ),
                  child: Icon(icon, size: 24, color: AppColors.progressBrightBlue),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'algorithm':
        return Icons.functions;
      case 'search':
        return Icons.search;
      case 'recursive':
        return Icons.loop;
      case 'real_world':
        return Icons.public;
      case 'emoji_objects':
        return Icons.emoji_objects;
      case 'list_alt':
        return Icons.list_alt;
      case 'assignment':
        return Icons.assignment;
      default:
        return Icons.help_outline;
    }
  }
}