import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siapp/screens/ModulesScreen.dart';
import 'package:siapp/screens/module1.dart';
import 'package:siapp/screens/module2.dart';
import 'package:siapp/screens/module3.dart';
import '../theme/app_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  double progress = 0.0;
  int completedModules = 0;
  int totalModules = 3;
  int _currentIndex = 1;
  String? _errorMessage;
  bool _isLoading = true;

  late final AnimationController _mainController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  late final AnimationController _cardsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late Animation<double> _progressAnimation;
  late Animation<Color?> _gradientAnimation;
  late Animation<double> _cardsScaleAnimation;
  late Animation<double> _cardsOpacityAnimation;

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Módulo 1: Introducción a la Programación',
      'id': 'module1',
      'image':
          'https://cecytebcs.edu.mx/wp-content/uploads/2022/02/programacion.jpeg',
      'summary': 'Conceptos básicos de programación',
    },
    {
      'title': 'Módulo 2: Lógica de programación',
      'id': 'module2',
      'image':
          'https://adrianvegaonline.wordpress.com/wp-content/uploads/2020/06/3964906.jpg',
      'summary': 'Fundamentos de lógica para programar',
    },
    {
      'title': 'Módulo 3: Algoritmos',
      'id': 'module3',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q\limits:ANd9GcQqHwUGEftbslnEMbKfZ8s7CyTkNUq7Ij1qHw&s',
      'summary': 'Diseño y análisis de algoritmos',
    },
  ];

  Map<String, double> moduleScores = {};
  Map<String, bool> moduleQuizCompleted = {};
  Map<String, double> modulePercentages = {};

  @override
  void initState() {
    super.initState();

    _gradientAnimation = ColorTween(
      begin: AppColors.backgroundGradientTop,
      end: AppColors.backgroundGradientBottom,
    ).animate(_mainController);

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOut,
      ),
    );

    _cardsScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: Curves.easeInOut,
      ),
    );

    _cardsOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: Curves.easeIn,
      ),
    );

    cargarProgreso();

    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  Future<void> cargarProgreso() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado. Por favor, inicia sesión.';
          _isLoading = false;
        });
        debugPrint('No user logged in');
        return;
      }

      final String userId = user.uid;
      debugPrint('Fetching progress for userId: $userId');

      final moduleDetails = await FirebaseFirestore.instance
          .collection('progress')
          .doc(userId)
          .collection('modules')
          .get();

      if (moduleDetails.docs.isEmpty) {
        setState(() {
          _errorMessage =
              'No se encontraron datos de progreso para este usuario.';
          _isLoading = false;
        });
        debugPrint('No progress data found for userId: $userId');
        return;
      }

      int modulosCompletados = 0;
      Map<String, double> tempScores = {};
      Map<String, bool> tempQuizCompleted = {};
      Map<String, double> tempPercentages = {};

      for (var module in moduleDetails.docs) {
        final data = module.data();
        debugPrint('Module ${module.id} data: $data');

        final porcentaje =
            (data.containsKey('porcentaje') && data['porcentaje'] != null)
                ? (data['porcentaje'] as num).toDouble()
                : 0.0;
        final quizCompleted = (data.containsKey('quiz_completed') &&
                data['quiz_completed'] != null)
            ? data['quiz_completed'] as bool
            : false;
        final grade = (data.containsKey('calf') && data['calf'] != null)
            ? (data['calf'] as num).toDouble()
            : 0.0;

        tempScores[module.id] = grade;
        tempQuizCompleted[module.id] = quizCompleted;
        tempPercentages[module.id] = porcentaje;

        debugPrint(
            'Module ${module.id}: porcentaje=$porcentaje, quiz_completed=$quizCompleted, grade=$grade');

        if (porcentaje == 100 && quizCompleted) {
          modulosCompletados++;
        }
      }

      setState(() {
        completedModules = modulosCompletados;
        progress = (completedModules / totalModules) * 100;
        moduleScores = tempScores;
        moduleQuizCompleted = tempQuizCompleted;
        modulePercentages = tempPercentages;
        _isLoading = false;
        debugPrint(
            'Updated state: completedModules=$completedModules, progress=$progress');
        debugPrint('moduleScores=$moduleScores');
        debugPrint('moduleQuizCompleted=$moduleQuizCompleted');
        debugPrint('modulePercentages=$modulePercentages');
      });

      _progressAnimation = Tween<double>(
        begin: 0,
        end: progress / 100,
      ).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: Curves.easeOut,
        ),
      );

      _mainController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el progreso: $e';
        _isLoading = false;
      });
      debugPrint("Error al cargar el progreso: $e");
    }
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

  Widget _buildModuleCard(Map<String, dynamic> module, bool isCompleted) {
    final moduleId = module['id'];
    final score = moduleScores[moduleId] ?? 0.0;
    final quizCompleted = moduleQuizCompleted[moduleId] ?? false;
    final percentage = modulePercentages[moduleId] ?? 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.glassmorphicBackground,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToModule(context, module),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Hero(
                tag: 'progress-image-${module['id']}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(module['image']),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module['summary'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progreso: ${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.progressActive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Calificación: ${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.progressActive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quiz: ${quizCompleted ? 'Completado' : 'No completado'}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            quizCompleted ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<bool>(isCompleted),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.textSecondary.withOpacity(0.2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                ),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundDynamic,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.progressActive),
                const SizedBox(height: 16),
                Text(
                  'Cargando progreso...',
                  style:
                      TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundDynamic,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 16, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: cargarProgreso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _cardsController]),
      builder: (context, child) {
        return Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundDynamic,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
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
                                    builder: (context) =>
                                        const ModulesScreen()),
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
                                Icons.bar_chart,
                                size: 50,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _cardsOpacityAnimation,
                          child: const Text(
                            'Tu Progreso',
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
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ScaleTransition(
                      scale: _cardsScaleAnimation,
                      child: FadeTransition(
                        opacity: _cardsOpacityAnimation,
                        child: Material(
                          color: AppColors.glassmorphicBackground,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Progreso General',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 160,
                                      height: 160,
                                      child: AnimatedBuilder(
                                        animation: _progressAnimation,
                                        builder: (context, child) {
                                          return CircularProgressIndicator(
                                            value: _progressAnimation.value,
                                            strokeWidth: 12,
                                            backgroundColor:
                                                AppColors.progressInactive,
                                            color: AppColors.progressActive,
                                          );
                                        },
                                      ),
                                    ),
                                    AnimatedBuilder(
                                      animation: _progressAnimation,
                                      builder: (context, child) {
                                        return Text(
                                          '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    'Módulos completados: $completedModules / $totalModules',
                                    key: ValueKey<int>(completedModules),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = modules[index];
                      final moduleId = module['id'];
                      final percentage = modulePercentages[moduleId] ?? 0.0;
                      final quizCompleted =
                          moduleQuizCompleted[moduleId] ?? false;
                      final isCompleted = percentage == 100 && quizCompleted;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.9,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _cardsController,
                              curve: Interval(
                                0.1 + (index * 0.1),
                                0.5 + (index * 0.1),
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(
                              CurvedAnimation(
                                parent: _cardsController,
                                curve: Interval(
                                  0.1 + (index * 0.1),
                                  0.5 + (index * 0.1),
                                  curve: Curves.easeIn,
                                ),
                              ),
                            ),
                            child: _buildModuleCard(module, isCompleted),
                          ),
                        ),
                      );
                    },
                    childCount: modules.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _cardsOpacityAnimation,
                          child: Text(
                            'Continúa aprendiendo para completar todos los módulos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events,
                                  color: AppColors.buttonText),
                              SizedBox(width: 10),
                              Text(
                                '¡Tú puedes!',
                                style: TextStyle(
                                  color: AppColors.buttonText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
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
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    if (index == 0) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ModulesScreen(),
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

  @override
  void dispose() {
    _mainController.dispose();
    _cardsController.dispose();
    super.dispose();
  }
}
