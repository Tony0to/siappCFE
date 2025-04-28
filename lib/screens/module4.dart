import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:siapp/screens/module4screens/actividades.dart';
import 'package:siapp/screens/module4screens/contenido_screen.dart';
import 'package:siapp/screens/ModulesScreen.dart';

class Module4Content {
  static Map<String, dynamic>? _content;
  static bool _isLoaded = false;

  static Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/module4.json');
      _content = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Error al cargar el contenido del módulo: $e');
    }
  }

  static Map<String, dynamic> get content {
    if (_content == null) {
      throw Exception('Contenido del módulo no cargado. Llama a Module4Content.initialize() primero');
    }
    return _content!;
  }
}

class Module4IntroScreen extends StatefulWidget {
  final Map<String, dynamic> module;

  const Module4IntroScreen({Key? key, required this.module}) : super(key: key);

  @override
  State<Module4IntroScreen> createState() => _Module4IntroScreenState();
}

class _Module4IntroScreenState extends State<Module4IntroScreen> 
    with SingleTickerProviderStateMixin {
  late Future<void> _loadContentFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  final String moduleImageUrl = 'https://cdn-icons-png.flaticon.com/512/2103/2103633.png';

  @override
  void initState() {
    super.initState();
    _loadContentFuture = Module4Content.initialize();
    
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
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF00171F),
      end: const Color(0xFF003459),
    ).animate(_controller);

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
            body: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007EA7)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error.toString()}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final moduleContent = Module4Content.content;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white.withOpacity(0.2),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ModulesScreen()),
                    (route) => route.isFirst || route.settings.name == '/modules',
                  );
                },
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation.value!,
                      _colorAnimation.value!.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 70, bottom: 20),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                moduleContent['module_title'] ?? 'Módulo 4',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(moduleImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color(0xFF003459).withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      moduleContent['welcome']?['title'] ?? 'Paradigmas de Programación',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10,
                                            color: Colors.black45,
                                            offset: Offset(2, 2),
                                          )],
                                      ),
                                    ),
                                  ),
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
                                      moduleContent['welcome']?['description'] ?? 
                                      'Explora los diferentes enfoques de programación y aprende a elegir el mejor para cada situación',
                                      style: const TextStyle(
                                        fontSize: 16, 
                                        height: 1.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white.withOpacity(0.15),
                                    shadowColor: const Color(0xFF007EA7).withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.list_alt,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                moduleContent['syllabus']?['title'] ?? 'Temario',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
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
                                const SizedBox(height: 30),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: const Text(
                                    'Lo que aprenderás',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                                    elevation: 6,
                                    color: Colors.white.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _getIcon(moduleContent['motivation']?['icon'] ?? 'auto_awesome'),
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            moduleContent['motivation']?['text'] ?? 
                                            '¡Domina múltiples paradigmas y conviértete en un programador más versátil!',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                                            borderRadius: BorderRadius.circular(30),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF007EA7),
                                                Color(0xFF00A8E8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF007EA7).withOpacity(0.4),
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
                                                MaterialPageRoute(
                                                  builder: (context) => ContenidoScreen(moduleData: moduleContent),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                                                const SizedBox(width: 10),
                                                Text(
                                                  moduleContent['button_text'] ?? 'Comenzar Módulo',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
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
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.5),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF007EA7).withOpacity(0.2),
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
                                                MaterialPageRoute(
                                                  builder: (context) => ActividadesScreen(actividadesData: moduleContent),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white.withOpacity(0.15),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.assignment, color: Colors.white.withOpacity(0.9), size: 24),
                                                const SizedBox(width: 10),
                                                Text(
                                                  moduleContent['practice_button_text'] ?? 'Actividades Prácticas',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
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
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ...List<String>.from(section['items'] ?? [])
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.white70,
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
        elevation: 3,
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
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
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'computer':
        return Icons.computer;
      case 'psychology':
        return Icons.psychology;
      case 'account_tree':
        return Icons.account_tree;
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'emoji_objects':
        return Icons.emoji_objects;
      case 'list_alt':
        return Icons.list_alt;
      case 'assignment':
        return Icons.assignment;
      case 'compare_arrows':
        return Icons.compare_arrows;
      case 'architecture':
        return Icons.architecture;
      case 'functions':
        return Icons.functions;
      case 'merge_type':
        return Icons.merge_type;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }
}