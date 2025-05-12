import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siapp/theme/app_colors.dart';

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
  String? _statusMessage;
  bool _isCompleted = false;
  bool _isLocked = false;
  double _score = 0.0;
  List<int> _wrongIndices = [];
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (_isLocked) return;

    setState(() {
      _userAnswers[_currentImageIndex] = answer;
      if (_currentImageIndex < _images.length - 1) {
        _currentImageIndex++;
      } else {
        _verifyAnswers();
      }
    });
  }

  void _verifyAnswers() {
    _wrongIndices.clear();
    int correctCount = 0;

    for (int i = 0; i < _images.length; i++) {
      final isCorrect = _userAnswers[i] == _images[i]['correctAnswer'];
      _correctAnswers[i] = isCorrect;
      if (isCorrect) {
        correctCount++;
      } else {
        _wrongIndices.add(i);
      }
    }

    _score = (correctCount / _images.length) * 100;
    final passed = _score >= 70;

    setState(() {
      _answersChecked = true;
      _isCompleted = passed;
      _isLocked = passed;
      _statusMessage =
          'Calificación: ${_score.toStringAsFixed(1)}% ${passed ? "✅" : "❌"} Incorrectos: ${_wrongIndices.length}';
    });

    _showResultDialog(passed);
  }

  void _resetActivity() {
    if (_isLocked) return;

    setState(() {
      _currentImageIndex = 0;
      _userAnswers.clear();
      _correctAnswers.clear();
      _answersChecked = false;
      _statusMessage = null;
      _isCompleted = false;
      _isLocked = false;
      _score = 0.0;
      _wrongIndices.clear();
    });
  }

  void _completeActivity() {
    Navigator.pop(context, {'score': _score, 'passed': _isCompleted});
  }

  Future<void> _showResultDialog(bool passed) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.error,
              color: passed ? AppColors.success : AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              passed ? '¡Actividad Completada!' : 'Actividad No Aprobada',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calificación: ${_score.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_wrongIndices.isNotEmpty && !passed) ...[
                Text(
                  'Respuestas incorrectas:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                ..._wrongIndices.map((index) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        '• ${_images[index]['description']} (Respondido: ${_userAnswers[index]})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )),
              ],
              if (passed)
                Text(
                  '¡Felicidades! Has completado la actividad.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (passed) _completeActivity();
            },
            child: Text(
              'Aceptar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
      ),
    );
  }

  void _showGradingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Criterios de Evaluación',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para aprobar esta actividad, debes clasificar correctamente al menos el 70% de las imágenes como Hardware o Software.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Cada imagen debe clasificarse según su descripción.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• La calificación se calcula como el porcentaje de respuestas correctas.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Se aprueba con una calificación de 70% o más.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            heroTag: null,
            backgroundColor: AppColors.glassmorphicBackground,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showGradingInfo,
            heroTag: null,
            backgroundColor: AppColors.glassmorphicBackground,
            child: const Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                child: Text(
                  'Clasificar Hardware o Software',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 20),
              if (_statusMessage != null)
                GlassmorphicCard(
                  child: Text(
                    _statusMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: _isCompleted ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Text(
                  'Instrucciones: Clasifica cada imagen como Hardware o Software.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
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
                                color: AppColors.glassmorphicBackground.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.progressActive,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: AppColors.glassmorphicBackground.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.error_outline, color: AppColors.error, size: 40),
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
                          color: AppColors.textPrimary,
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
                      onPressed: _isLocked ? null : () => _selectAnswer('Hardware'),
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    _buildAnimatedButton(
                      text: 'Software',
                      onPressed: _isLocked ? null : () => _selectAnswer('Software'),
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
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
                          color: AppColors.progressActive,
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: _wrongIndices.contains(index) && !_isCompleted
                                          ? Border.all(color: AppColors.error, width: 2)
                                          : null,
                                    ),
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
                                            color: AppColors.glassmorphicBackground.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(child: CircularProgressIndicator(color: AppColors.progressActive)),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.glassmorphicBackground.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(child: Icon(Icons.error_outline, color: AppColors.error)),
                                        );
                                      },
                                    ),
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
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Tu respuesta: ${_userAnswers[index] ?? "No respondido"}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _correctAnswers[index]! ? 'Correcto' : 'Incorrecto',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _correctAnswers[index]! ? AppColors.success : AppColors.error,
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
                  onPressed: _isLocked ? null : _resetActivity,
                  gradient: LinearGradient(
                    colors: _isLocked
                        ? [Colors.grey.shade600, Colors.grey.shade400]
                        : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                  ),
                ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
              ],
              const SizedBox(height: 40),
            ],
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
            color: AppColors.textPrimary,
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
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}