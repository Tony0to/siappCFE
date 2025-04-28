import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siapp/screens/module3screens/actividades.dart';
import 'package:siapp/screens/module3screens/contenido_screen.dart';
import 'package:siapp/screens/ModulesScreen.dart';

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

  // Colores
  static const Color darkBlue = Color(0xFF00171F);
  static const Color navyBlue = Color(0xFF003459);
  static const Color mediumBlue = Color(0xFF007EA7);
  static const Color brightCyan = Color(0xFF00A8E8);
  static const Color lightCyan = Color(0xFF4FC3F7); // Color para el temario
  static const Color white = Color(0xFFFFFFFF);

  // URL de la imagen
  final String moduleImageUrl =
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80';

  @override
  void initState() {
    super.initState();
    _loadContentFuture = Module3Content.initialize();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
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
            backgroundColor: darkBlue,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(brightCyan),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: darkBlue,
            body: Center(
              child: Text(
                'Error: ${snapshot.error.toString()}',
                style: TextStyle(fontSize: 16, color: brightCyan),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final moduleContent = Module3Content.content;

        return Scaffold(
          floatingActionButton: _buildFloatingActionButton(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  navyBlue,
                  navyBlue.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _buildContent(moduleContent),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: navyBlue.withOpacity(0.8),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ModulesScreen()),
          (route) => route.isFirst || route.settings.name == '/modules',
        );
      },
      child: const Icon(Icons.arrow_back, color: white),
    );
  }

  Widget _buildContent(Map<String, dynamic> moduleContent) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 70, bottom: 20),
            child: Text(
              moduleContent['module_title'] ?? 'Módulo 3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: white,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _buildHeroImage(moduleContent);
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                moduleContent['welcome']?['description'] ??
                    'Explora el fascinante mundo de los algoritmos y aprende a resolver problemas de manera lógica y eficiente.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 30),
              _buildSyllabusSection(moduleContent),
              const SizedBox(height: 30),
              _buildLearningPointsSection(moduleContent),
              const SizedBox(height: 30),
              _buildMotivationCard(moduleContent),
              const SizedBox(height: 40),
              _buildActionButtons(moduleContent),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(Map<String, dynamic> moduleContent) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: 220,
          child: CachedNetworkImage(
            imageUrl: moduleImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: darkBlue.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: brightCyan)),
            ),
            errorWidget: (context, url, error) => Container(
              color: darkBlue,
              child: Icon(Icons.error, color: brightCyan),
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      darkBlue.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    moduleContent['welcome']?['title'] ?? '¡Bienvenido al Módulo 3!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: darkBlue,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyllabusSection(Map<String, dynamic> moduleContent) {
    final sections = List<Map<String, dynamic>>.from(
        moduleContent['syllabus']?['sections'] ?? []);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: lightCyan.withOpacity(0.4),
      shadowColor: brightCyan.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: brightCyan,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  moduleContent['syllabus']?['title'] ?? 'Temario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                return _buildSyllabusItem(sections[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllabusItem(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section['title'] ?? 'Sección sin título',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: white,
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
                          color: brightCyan,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: white.withOpacity(0.8),
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

  Widget _buildLearningPointsSection(Map<String, dynamic> moduleContent) {
    final points = List<Map<String, dynamic>>.from(
        moduleContent['learning_points']?['points'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lo que aprenderás',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          itemBuilder: (context, index) {
            final point = points[index];
            return _buildLearningPoint(
              icon: _getIcon(point['icon'] ?? ''),
              title: point['title'] ?? 'Sin título',
              description: point['description'] ?? 'Sin descripción',
            );
          },
        ),
      ],
    );
  }

  Widget _buildMotivationCard(Map<String, dynamic> moduleContent) {
    return Card(
      elevation: 6,
      color: mediumBlue.withOpacity(0.4),
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
              color: brightCyan,
            ),
            const SizedBox(height: 15),
            Text(
              moduleContent['motivation']?['text'] ??
                  '¡Domina los algoritmos y resuelve problemas con lógica y precisión!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> moduleContent) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  brightCyan,
                  mediumBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Module3ContenidoScreen(moduleData: moduleContent),
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
                  Icon(Icons.play_arrow, color: white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    moduleContent['button_text'] ?? 'Comenzar Módulo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: brightCyan.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Module3ActividadesScreen(moduleData: moduleContent),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, color: white.withOpacity(0.9), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Actividades Prácticas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        color: navyBlue.withOpacity(0.3),
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
                  color: brightCyan.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: brightCyan),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: white.withOpacity(0.8),
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
      case 'algorithm':
        return Icons.account_tree;
      case 'search':
        return Icons.search;
      case 'recursive':
        return Icons.loop;
      case 'real_world':
        return Icons.public;
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