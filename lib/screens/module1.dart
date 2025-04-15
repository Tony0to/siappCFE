import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:siapp/screens/module1screens/contenido_screen.dart'; // Actualizamos la importación
import 'package:siapp/screens/module1screens/actividades.dart';

class Module1Content {
  static Map<String, dynamic>? _content;
  static bool _isLoaded = false;

  static Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/module1.json');
      _content = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Error al cargar el contenido del módulo: $e');
    }
  }

  static Map<String, dynamic> get content {
    if (_content == null) {
      throw Exception('Contenido del módulo no cargado. Llama a Module1Content.initialize() primero');
    }
    return _content!;
  }
}

class Module1IntroScreen extends StatefulWidget {
  final Map<String, dynamic> module;

  const Module1IntroScreen({Key? key, required this.module}) : super(key: key);

  @override
  State<Module1IntroScreen> createState() => _Module1IntroScreenState();
}

class _Module1IntroScreenState extends State<Module1IntroScreen> {
  late Future<void> _loadContentFuture;

  @override
  void initState() {
    super.initState();
    _loadContentFuture = Module1Content.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadContentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

        final moduleContent = Module1Content.content;

        return Scaffold(
          appBar: AppBar(
            title: Text(moduleContent['module_title'] ?? 'Módulo 1'),
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moduleContent['welcome']?['title'] ?? 'Bienvenido',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        moduleContent['welcome']?['description'] ?? 'Descripción no disponible',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        moduleContent['syllabus']?['title'] ?? 'Temario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Colors.deepPurple[50],
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final section in List<Map<String, dynamic>>.from(
                                  moduleContent['syllabus']?['sections'] ?? []))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        section['title'] ?? 'Sección sin título',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      ...List<String>.from(section['items'] ?? [])
                                          .map((item) => Text('• $item'))
                                          .toList(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        moduleContent['learning_points']?['title'] ?? 'Puntos de Aprendizaje',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800],
                        ),
                      ),
                      const SizedBox(height: 15),
                      for (var point in moduleContent['learning_points']?['points'] ?? [])
                        _buildLearningPoint(
                          icon: _getIcon(point['icon'] ?? ''),
                          title: point['title'] ?? 'Sin título',
                          description: point['description'] ?? 'Sin descripción',
                        ),
                      const SizedBox(height: 30),
                      Card(
                        color: Colors.deepPurple[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                _getIcon(moduleContent['motivation']?['icon'] ?? ''),
                                size: 40,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                moduleContent['motivation']?['text'] ?? '¡Sigue adelante!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContenidoScreen(moduleData: moduleContent), // Actualizamos a ContenidoScreen
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            moduleContent['button_text'] ?? 'Comenzar',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActividadesScreen(moduleData: moduleContent),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Actividades Complementarias',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
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
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildLearningPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.deepPurple),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}