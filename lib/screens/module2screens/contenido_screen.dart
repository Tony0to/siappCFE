import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siapp/screens/loading_screen.dart';
import 'package:siapp/screens/module2screens/tema1.dart';
import 'package:siapp/screens/module2screens/tema2.dart';
import 'package:siapp/screens/module2screens/tema3.dart';
import 'package:siapp/screens/module2screens/tema4.dart';
import 'package:siapp/theme/app_colors.dart';

class ContenidoScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const ContenidoScreen({super.key, required this.moduleData});

  @override
  ContenidoScreenState createState() => ContenidoScreenState();
}

class ContenidoScreenState extends State<ContenidoScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  final List<AnimationController> _progressControllers = [];
  double _progress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _completedSections = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _loadContentWithDelay();
  }

  @override
  void dispose() {
    _animationController.stop(); // Detener la animación antes de desechar
    _animationController.dispose();
    for (var controller in _progressControllers) {
      controller.stop();
      controller.dispose();
    }
    _progressControllers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContentWithDelay() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadModuleProgress(),
        Future.delayed(const Duration(seconds: 1)),
      ]);

      setState(() {
        _isLoading = false;
      });

      _progressAnimation = Tween<double>(begin: 0, end: _progress).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuart,
        ),
      );
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el contenido: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadModuleProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData['id'] ?? 'module2')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final savedProgress = (data?['porcentaje'] as num?)?.toDouble() ?? 0.0;
        final completedSectionsData = data?['completed_sections'];

        setState(() {
          _progress = savedProgress / 100;
          if (completedSectionsData is Map) {
            completedSectionsData.forEach((key, value) {
              final sectionIndex = int.tryParse(key) ?? -1;
              if (sectionIndex >= 0) {
                _completedSections[sectionIndex] = value as bool? ?? false;
              }
            });
          } else if (completedSectionsData is List) {
            for (var i = 0; i < completedSectionsData.length; i++) {
              _completedSections[i] = completedSectionsData[i] as bool? ?? false;
            }
          }
        });
      } else {
        setState(() {
          _progress = 0.0;
        });
      }
    } catch (e) {
      throw Exception('Error al cargar el progreso: $e');
    }
  }

  Future<void> _updateModuleProgress(int sectionIndex) async {
    if (_completedSections[sectionIndex] == true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      _completedSections[sectionIndex] = true;
      final completedSections =
          _completedSections.values.where((completed) => completed).length;
      final newProgress = (completedSections * 25.0) / 100.0; // 25% por sección

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData['id'] ?? 'module2')
          .set({
        'porcentaje': newProgress * 100,
        'last_updated': FieldValue.serverTimestamp(),
        'module_id': widget.moduleData['id'] ?? 'module2',
        'module_title': widget.moduleData['module_title'] ?? 'Módulo',
        'completed': newProgress >= 1.0,
        'completed_sections': _completedSections.map((key, value) => MapEntry(key.toString(), value)),
      }, SetOptions(merge: true));

      final progressController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );

      _progressControllers.add(progressController);

      setState(() {
        _progress = newProgress;
        _progressAnimation =
            Tween<double>(begin: _progressAnimation.value, end: newProgress)
                .animate(CurvedAnimation(
          parent: progressController,
          curve: Curves.easeOutQuart,
        ));
      });

      progressController.forward();

      progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _progressControllers.remove(progressController);
          progressController.dispose();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el progreso: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Método para manejar el comportamiento del botón "Atrás" del dispositivo
  Future<bool> _onPopInvoked() async {
    debugPrint('Botón Atrás del dispositivo presionado');
    // Detener todas las animaciones para evitar parpadeos
    _animationController.stop();
    for (var controller in _progressControllers) {
      controller.stop();
    }
    debugPrint('Animaciones detenidas, ejecutando Navigator.pop');
    Navigator.pop(context);
    return true; // Permitir el pop
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: true, // Permitir pop por defecto
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onPopInvoked();
        }
      },
      child: Builder(
        builder: (context) {
          if (_isLoading || _errorMessage != null) {
            return Scaffold(
              body: LoadingScreen(
                message: _errorMessage ?? 'Cargando contenido...',
              ),
            );
          }

          final content = widget.moduleData['content'] as Map<String, dynamic>? ?? {};
          final syllabusSections =
              (widget.moduleData['syllabus']?['sections'] as List<dynamic>?) ?? [];
          final moduleImage = widget.moduleData['image'] as String? ??
              'https://img.freepik.com/free-vector/hand-drawn-web-developers_23-2148819604.jpg';

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.moduleData['module_title'] ?? 'Contenido',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        shadows: [
                          Shadow(
                            color: AppColors.shadowColor,
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: AppColors.buttonText),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () async {
                      debugPrint('IconButton Atrás presionado');
                      await _onPopInvoked();
                    },
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadContentWithDelay,
                        tooltip: 'Actualizar progreso',
                      ),
                    ),
                  ],
                ),
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundDynamic,
                  ),
                  child: content.isEmpty
                      ? _buildEmptyContent()
                      : CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const SizedBox(height: 80),
                                  _buildModuleHeader(moduleImage),
                                  const SizedBox(height: 20),
                                  _buildProgressIndicator(),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final sectionKey = content.keys.elementAt(index);
                                    final section = content[sectionKey];
                                    final syllabusTitle =
                                        syllabusSections[index]['title'] as String;
                                    final cleanedTitle = syllabusTitle.replaceFirst(
                                        RegExp(r'^[IVXLC]+\.\s'), '');
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: SectionCard(
                                        index: index,
                                        title: cleanedTitle,
                                        description: section['description'] ?? '',
                                        onTap: () {
                                          if (!mounted) return;
                                          Widget targetScreen;
                                          switch (index) {
                                            case 0:
                                              targetScreen = Tema1(
                                                section: section,
                                                sectionTitle: cleanedTitle,
                                                sectionIndex: index,
                                                totalSections: content.length,
                                                content: content,
                                                moduleData: widget.moduleData,
                                                onComplete: (index) {
                                                  _updateModuleProgress(index);
                                                },
                                              );
                                              break;
                                            case 1:
                                              targetScreen = Tema2(
                                                section: section,
                                                sectionTitle: cleanedTitle,
                                                sectionIndex: index,
                                                totalSections: content.length,
                                                content: content,
                                                moduleData: widget.moduleData,
                                                onComplete: (index) {
                                                  _updateModuleProgress(index);
                                                },
                                              );
                                              break;
                                            case 2:
                                              targetScreen = Tema3(
                                                section: section,
                                                sectionTitle: cleanedTitle,
                                                sectionIndex: index,
                                                totalSections: content.length,
                                                content: content,
                                                moduleData: widget.moduleData,
                                                onComplete: (index) {
                                                  _updateModuleProgress(index);
                                                },
                                              );
                                              break;
                                            case 3:
                                              targetScreen = Tema4(
                                                section: section,
                                                sectionTitle: cleanedTitle,
                                                sectionIndex: index,
                                                totalSections: content.length,
                                                content: content,
                                                moduleData: widget.moduleData,
                                                onComplete: (index) {
                                                  _updateModuleProgress(index);
                                                },
                                              );
                                              break;
                                            default:
                                              return;
                                          }
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  targetScreen,
                                              transitionsBuilder: (context, animation,
                                                  secondaryAnimation, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(milliseconds: 300),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  childCount: content.length,
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 30),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModuleHeader(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Hero(
        tag: 'module-image-${widget.moduleData['id']}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.cardBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.progressActive),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.cardBackground,
                      child: Icon(Icons.menu_book,
                          size: 50, color: AppColors.textSecondary),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.headerSection,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.moduleData['module_title'] ?? 'Módulo',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.moduleData['subtitle'] != null)
                          Text(
                            widget.moduleData['subtitle'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tu progreso',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(_progressAnimation.value * 100).toStringAsFixed(0)}% completado',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.progressInactive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuart,
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: AppColors.progressBar,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.progressShadow,
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 60,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay contenido disponible',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _onPopInvoked();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                'Volver',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatefulWidget {
  final int index;
  final String title;
  final String description;
  final VoidCallback onTap;

  const SectionCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _isPressed
                ? AppColors.glassmorphicBackground
                : AppColors.cardBackground,
            border: Border.all(color: AppColors.glassmorphicBorder),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.progressBrightBlue
                            .withAlpha(51), // 0.2 opacity
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.progressBrightBlue,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${widget.index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (widget.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}