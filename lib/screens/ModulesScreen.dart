import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siapp/screens/home_screen.dart';
import 'package:siapp/screens/login_screen.dart';
import 'package:siapp/screens/progress_screen.dart';
import '../theme/app_colors.dart'; // Import AppColors
import 'module1.dart';
import 'module2.dart';
import 'module3.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({Key? key}) : super(key: key);

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _controller;
  late Animation<Color?> _gradientAnimation;

  final List<Map<String, dynamic>> _modules = [
    {
      'image':
          'https://cecytebcs.edu.mx/wp-content/uploads/2022/02/programacion.jpeg',
      'title': 'Módulo 1: Introducción a la Programación',
      'subtitle': 'Conceptos básicos de programación',
      'activities': 4,
      'id': 'module1',
      'summary':
          'Aprende los fundamentos de la programación, variables y estructuras de control para comenzar tu viaje en el desarrollo de software.',
    },
    {
      'image':
          'https://adrianvegaonline.wordpress.com/wp-content/uploads/2020/06/3964906.jpg',
      'title': 'Módulo 2: Lógica de programación',
      'subtitle': 'Fundamentos de lógica para programar',
      'activities': 4,
      'id': 'module2',
      'summary':
          'Domina el pensamiento lógico y las habilidades de resolución de problemas esenciales para escribir código eficiente.',
    },
    {
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqHwUGEftbslnEMbKfZ8s7CyTkNUq7Ij1qHw&s',
      'title': 'Módulo 3: Algoritmos',
      'subtitle': 'Diseño y análisis de algoritmos',
      'activities': 4,
      'id': 'module3',
      'summary':
          'Explora técnicas de diseño de algoritmos y analiza su eficiencia para aplicaciones en el mundo real.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _gradientAnimation = ColorTween(
      begin: AppColors.backgroundGradientTop,
      end: AppColors.backgroundGradientBottom,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addModuleDetailsAndNavigate(
      BuildContext context, Map<String, dynamic> module) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showSnackBar(context, "No se encontraron datos del usuario");
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final progressRef = FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(module['id']);

        final progressDoc = await transaction.get(progressRef);

        if (!progressDoc.exists) {
          transaction.set(progressRef, {
            'porcentaje': 0,
            'quiz_completed': false,
            'topics_completed': [],
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      });

      _navigateToModule(context, module);
    } catch (e) {
      _showSnackBar(context, "Error al acceder a los datos: ${e.toString()}");
      debugPrint("Error detallado: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToModule(BuildContext context, Map<String, dynamic> module) {
    final routes = {
      'module1': (ctx) => Module1IntroScreen(module: module),
      'module2': (ctx) => Module2IntroScreen(module: module),
      'module3': (ctx) => Module3IntroScreen(module: module),
    };

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            routes[module['id']]!(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundDynamic,
            ),
            child: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.textPrimary),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.glassmorphicBorder,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowColor,
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/siaap.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.school,
                                  size: 50,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Módulos de Estudio',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final module = _modules[index];
                          return ModuleCard(
                            key: ValueKey(module['id']),
                            module: module,
                            onNavigate: () =>
                                _addModuleDetailsAndNavigate(context, module),
                          );
                        },
                        childCount: _modules.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    if (index == 1) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProgressScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                        ),
                      );
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppColors.textPrimary,
                  unselectedItemColor: AppColors.textSecondary,
                  selectedIconTheme: const IconThemeData(size: 28),
                  unselectedIconTheme: const IconThemeData(size: 24),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart),
                      label: 'Progreso',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ModuleCard extends StatefulWidget {
  final Map<String, dynamic> module;
  final VoidCallback onNavigate;

  const ModuleCard({
    required Key key,
    required this.module,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<double>(begin: 120, end: 340).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedBuilder(
        animation: _expandController,
        builder: (context, child) {
          return Material(
            color: AppColors.glassmorphicBackground,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'module-image-${widget.module['id']}',
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.glassmorphicBorder,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: widget.module['image'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.progressActive),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.menu_book,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.module['title'],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.module['subtitle'],
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.module['activities']} actividades',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _expandController,
                      axisAlignment: 1.0,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.module['image'],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.neutralCard,
                                    height: 120,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.progressActive),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.neutralCard,
                                    height: 120,
                                    child: const Icon(
                                      Icons.menu_book,
                                      size: 50,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.module['summary'],
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: widget.onNavigate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryButton,
                                    foregroundColor: AppColors.buttonText,
                                  ),
                                  child: const Text('Iniciar Módulo'),
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
            ),
          );
        },
      ),
    );
  }
}
