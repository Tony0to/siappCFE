import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:siapp/screens/module2screens/contenido_screen.dart';
import 'package:siapp/screens/module2screens/actividades.dart';
import 'package:siapp/screens/ModulesScreen.dart';

class Module2Content {
  static Map<String, dynamic>? _content;
  static bool _isLoaded = false;

  static Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/module2.json');
      _content = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Error al cargar el contenido del módulo: $e');
    }
  }

  static Map<String, dynamic> get content {
    if (_content == null) {
      throw Exception('Contenido del módulo no cargado. Llama a Module2Content.initialize() primero');
    }
    return _content!;
  }
}

class Module2IntroScreen extends StatefulWidget {
  final Map<String, dynamic> module;

  const Module2IntroScreen({Key? key, required this.module}) : super(key: key);

  @override
  State<Module2IntroScreen> createState() => _Module2IntroScreenState();
}

class _Module2IntroScreenState extends State<Module2IntroScreen> 
    with SingleTickerProviderStateMixin {
  late Future<void> _loadContentFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // URL de la imagen que puedes cambiar fácilmente
  final String moduleImageUrl = 'https://www.dongee.com/tutoriales/content/images/2024/04/image-47.png';

  @override
  void initState() {
    super.initState();
    _loadContentFuture = Module2Content.initialize();
    
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
      begin: Colors.blueAccent[400],
      end: Colors.lightBlue[700],
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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

        final moduleContent = Module2Content.content;

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
                          // Header Section (Integrated)
                          Container(
                            padding: const EdgeInsets.only(top: 70, bottom: 20),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                moduleContent['module_title'] ?? 'Módulo 2',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          // Hero Image with Animation
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
                                      Colors.blueAccent.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      moduleContent['welcome']?['title'] ?? 'Lógica de Programación',
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
                          
                          // Main Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome Section
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
                                      'Domina los fundamentos de la lógica de programación para resolver problemas complejos',
                                      style: const TextStyle(
                                        fontSize: 16, 
                                        height: 1.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 30),
                                
                                // Syllabus Section
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white.withOpacity(0.15),
                                    shadowColor: Colors.blueAccent.withOpacity(0.3),
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
                                
                                // Learning Points
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
                                
                                // Motivation Card
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
                                            _getIcon(moduleContent['motivation']?['icon'] ?? 'emoji_objects'),
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            moduleContent['motivation']?['text'] ?? 
                                            '¡Domina la lógica y abre un mundo de posibilidades en programación!',
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
                                
                                // Action Buttons
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Start Module Button
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blueAccent,
                                                Colors.lightBlue[700]!,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.4),
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
                                      
                                      // Activities Button
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
                                                color: Colors.blue.withOpacity(0.2),
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
                                              builder: (context) => ActividadesScreen(actividadesData: moduleContent),                                                ),
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
                                                const Text(
                                                  'Actividades Prácticas',
                                                  style: TextStyle(
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
      default:
        return Icons.help_outline;
    }
  }
}