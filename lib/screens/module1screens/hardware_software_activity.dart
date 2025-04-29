import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HardwareSoftwareActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? moduleData;

  const HardwareSoftwareActivityScreen({Key? key, this.moduleData}) : super(key: key);

  @override
  _HardwareSoftwareActivityScreenState createState() => _HardwareSoftwareActivityScreenState();
}

class _HardwareSoftwareActivityScreenState extends State<HardwareSoftwareActivityScreen> with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  final Map<int, String?> _userAnswers = {};
  bool _answersChecked = false;
  final Map<int, bool> _correctAnswers = {};
  bool _isAttemptsLoading = true;
  int _remainingAttempts = 3;
  bool _isAttemptsExhausted = false;
  String? _errorMessage;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _images = [
  {
    'url': 'https://media.istockphoto.com/id/1196702694/photo/designers-drawing-website-ux-app-development.jpg?s=1024x1024&w=is&k=20&c=qHoUFxILcwXARVEhiLICF1exRIKwg4y-nd0kXJn_8nI=',
    'correctAnswer': 'Software',
    'description': 'Aplicación de diseño gráfico',
  },
  {
    'url': 'https://cdn.pixabay.com/photo/2015/06/24/15/45/code-820275_1280.jpg',
    'correctAnswer': 'Software',
    'description': 'Editor de código (VS Code)',
  },
  {
    'url': 'https://cdn.pixabay.com/photo/2014/08/26/21/27/service-428540_1280.jpg',
    'correctAnswer': 'Hardware',
    'description': 'Placa base',
  },
  {
    'url': 'https://cdn.pixabay.com/photo/2020/09/26/11/36/laptop-5603790_1280.jpg',
    'correctAnswer': 'Software',
    'description': 'Sistema operativo Windows',
  },
  {
    'url': 'https://media.istockphoto.com/id/1691499727/photo/hard-and-solid-disks-drives.jpg?s=1024x1024&w=is&k=20&c=2v6ULfheyObZf4SXjaRKXMWZLltCrtfJjve8eahRbU8=',
    'correctAnswer': 'Hardware',
    'description': 'Disco duro (HDD)',
  },
  {
    'url': 'https://images.unsplash.com/photo-1649180564403-db28d5673f48?q=80&w=2062&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'correctAnswer': 'Software',
    'description': 'Entorno de desarrollo (IDE)',
  },
  {
    'url': 'https://media.istockphoto.com/id/1279667350/es/foto/ingeniero-electr%C3%B3nico-de-tecnolog%C3%ADa-inform%C3%A1tica-actualizaci%C3%B3n-de-hardware-de-la-computadora-de.jpg?s=1024x1024&w=is&k=20&c=ZyeOk2NjzOZe3UTRW3ORuvi17fL-T3cGaeCi4JJWwao=',
    'correctAnswer': 'Hardware',
    'description': 'Memoria RAM',
  },
  {
    'url': 'https://media.istockphoto.com/id/1326283378/photo/programming-code-keyboard-colors-computer.jpg?s=1024x1024&w=is&k=20&c=6NiB410DZywlAgbU4zESoczAFvJU5SBCrEKFzhYjrtk=',
    'correctAnswer': 'Hardware',
    'description': 'Teclado',
  },
  {
    'url': 'https://cdn.pixabay.com/photo/2019/08/08/16/54/cpu-4393376_1280.jpg',
    'correctAnswer': 'Hardware',
    'description': 'Procesador (CPU)',
  },
  {
    'url': 'https://media.istockphoto.com/id/1195604855/photo/flow-chart-of-control-panel-of-a-web-site-relational-database-table.jpg?s=1024x1024&w=is&k=20&c=yRI26TGwLjz0N-F2ducLsfQRjIxgJAMG7TrCC9leul0=',
    'correctAnswer': 'Software',
    'description': 'Interfaz de base de datos',
  },
];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadAttemptsFromFirestore();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAttemptsFromFirestore() async {
    setState(() {
      _isAttemptsLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado.';
          _isAttemptsLoading = false;
        });
        return;
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        final completed = data?['completed_activities'] as Map<String, dynamic>? ?? {};
        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0 || (completed['hardware_software'] ?? false);
          _isAttemptsLoading = false;
        });
      } else {
        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
          _isAttemptsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los intentos: $e';
        _isAttemptsLoading = false;
      });
    }
  }

  Future<void> _decrementAttempts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttempts - 1;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .set({
        'intentos': newAttempts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los intentos: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _markActivityCompleted() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .set({
        'completed_activities': {'hardware_software': true},
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isAttemptsExhausted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la actividad: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _selectAnswer(String answer) {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes más intentos o la actividad ya está completada.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _userAnswers[_currentImageIndex] = answer;
      if (_currentImageIndex < _images.length - 1) {
        _currentImageIndex++;
      } else {
        _checkAnswers();
      }
    });
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (int i = 0; i < _images.length; i++) {
      _correctAnswers[i] = _userAnswers[i] == _images[i]['correctAnswer'];
      if (!_correctAnswers[i]!) {
        allCorrect = false;
      }
    }
    setState(() {
      _answersChecked = true;
    });

    if (allCorrect) {
      _markActivityCompleted();
      Navigator.pop(context, true); // Retorna true para indicar que la actividad fue completada
    } else {
      _decrementAttempts();
    }
  }

  void _resetActivity() {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes más intentos o la actividad ya está completada.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _currentImageIndex = 0;
      _userAnswers.clear();
      _correctAnswers.clear();
      _answersChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAttemptsLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003459), Color(0xFF00A8E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFFFFFF)),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Cargando progreso...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Reintentar',
                    onPressed: _loadAttemptsFromFirestore,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003459), Color(0xFF00A8E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Clasificar Hardware o Software',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFFFFF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intentos restantes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFFFFFFFF).withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '$_remainingAttempts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _remainingAttempts > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Instrucciones: Clasifica cada imagen como Hardware o Software.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFFFFFFFF).withOpacity(0.9),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                if (!_answersChecked) ...[
                  GlassmorphicCard(
                    child: Column(
                      children: [
                        Text(
                          'Imagen ${_currentImageIndex + 1} de ${_images.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFFFFFFFF).withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _images[_currentImageIndex]['url'],
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF00A8E8),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 40),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _images[_currentImageIndex]['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFFFFFFF).withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedButton(
                        text: 'Hardware',
                        onPressed: _isAttemptsExhausted ? null : () => _selectAnswer('Hardware'),
                        gradient: LinearGradient(
                          colors: _isAttemptsExhausted
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      _buildAnimatedButton(
                        text: 'Software',
                        onPressed: _isAttemptsExhausted ? null : () => _selectAnswer('Software'),
                        gradient: LinearGradient(
                          colors: _isAttemptsExhausted
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ],
                if (_answersChecked) ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultados',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4FC3F7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._images.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GlassmorphicCard(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      image['url'],
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(child: CircularProgressIndicator(color: Color(0xFF00A8E8))),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(child: Icon(Icons.error_outline, color: Color(0xFFEF4444))),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          image['description'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: const Color(0xFFFFFFFF).withOpacity(0.9),
                                          ),
                                        ),
                                        Text(
                                          'Tu respuesta: ${_userAnswers[index] ?? "No respondido"}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFFFFFFFF).withOpacity(0.9),
                                          ),
                                        ),
                                        Text(
                                          _correctAnswers[index]! ? 'Correcto' : 'Incorrecto',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _correctAnswers[index]! ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 30),
                  _buildAnimatedButton(
                    text: 'Reiniciar Actividad',
                    onPressed: _isAttemptsExhausted ? null : _resetActivity,
                    gradient: LinearGradient(
                      colors: _isAttemptsExhausted
                          ? [Colors.grey.shade600, Colors.grey.shade400]
                          : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Volver a Actividades',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback? onPressed,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}