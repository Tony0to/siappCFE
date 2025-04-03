import 'package:flutter/material.dart';
import 'actividades.dart';
import 'contenido_screen_content.dart';

class ContenidoScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const ContenidoScreen({Key? key, required this.moduleData}) : super(key: key);

  @override
  _ContenidoScreenState createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends State<ContenidoScreen> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentSectionIndex = 0; // Índice de la sección actual
  int _sectionsPassed = 0; // Número de secciones que has pasado

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
    
    if (widget.moduleData['content'] != null) {
      final content = widget.moduleData['content'] as Map<String, dynamic>;
      content.forEach((key, value) {
        _sectionKeys[key] = GlobalKey();
      });
    }

    _scrollController.addListener(() {
      _updateCurrentSection();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index, Map<String, dynamic> content) {
    ContenidoScreenContent.scrollToSection(index, content, _sectionKeys);
  }

  Widget _buildSection(Map<String, dynamic> section, {GlobalKey? key}) {
    return ContenidoScreenContent.buildSection(section, key: key, fadeAnimation: _fadeAnimation);
  }

  // Actualizar la sección actual y cuántas secciones has pasado
  void _updateCurrentSection() {
    if (_scrollController.hasClients && _sectionKeys.isNotEmpty) {
      final content = widget.moduleData['content'] as Map<String, dynamic>;
      double scrollOffset = _scrollController.offset;

      int newSectionIndex = 0;
      int sectionsPassed = 0;

      for (int i = 0; i < content.length; i++) {
        final sectionKey = content.keys.elementAt(i);
        final RenderBox? box = _sectionKeys[sectionKey]?.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final sectionPosition = box.localToGlobal(Offset.zero).dy;

          // Determinar la sección actual (la última sección cuyo título está arriba del scroll)
          if (sectionPosition <= scrollOffset + 100) { // 100 píxeles de tolerancia desde la parte superior
            newSectionIndex = i;
          }

          // Contar secciones pasadas (si el título de la sección está completamente arriba del scroll)
          if (sectionPosition + box.size.height < scrollOffset) {
            sectionsPassed = i + 1;
          }
        }
      }

      setState(() {
        _currentSectionIndex = newSectionIndex;
        _sectionsPassed = sectionsPassed;
      });
    }
  }

  // Widget para las barras de progreso verticales
  Widget _buildProgressBars(Map<String, dynamic> content) {
    final int totalSections = content.length;

    return Container(
      width: 20, // Ancho fijo para todas las barras
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSections, (index) {
          bool isCurrent = index == _currentSectionIndex;
          bool isRead = index < _sectionsPassed;

          return GestureDetector(
            onTap: () {
              print('Tocando barra $index'); // Para depurar
              _scrollToSection(index, content);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 8, // Ancho fijo
              height: isCurrent ? 40 : 20, // La barra actual es más alta
              decoration: BoxDecoration(
                color: isRead || isCurrent ? Colors.green : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = widget.moduleData['content'] as Map<String, dynamic>? ?? {};
    print('Contenido recibido en ContenidoScreen: $content'); // Para depurar

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.moduleData['module_title'] ?? 'Contenido del Módulo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 8,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutQuint,
            ),
          ),
        ],
      ),
      body: content.isEmpty
          ? const Center(
              child: Text(
                'No hay contenido disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProgressBars(content), // Barras de progreso verticales
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...content.keys.map((sectionKey) {
                                  return _buildSection(content[sectionKey], key: _sectionKeys[sectionKey]);
                                }).toList(),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: content.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Ir al final'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 6,
              onPressed: () => _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutQuint,
              ),
            ),
      bottomNavigationBar: content.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text('Realizar actividades complementarias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActividadesScreen(moduleData: widget.moduleData),
                    ),
                  );
                },
              ),
            ),
    );
  }
}