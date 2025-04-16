import 'package:flutter/material.dart';
import 'hardware_software_activity.dart';
import 'order_steps_activity.dart';
import 'flowchart_activity.dart';

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const ActividadesScreen({Key? key, required this.moduleData}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities = widget.moduleData['activities'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actividades - ${widget.moduleData['module_title'] ?? 'Módulo'}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actividades Complementarias',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Selecciona una actividad para comenzar:',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...activities.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value as Map<String, dynamic>;
                      return _buildActivityButton(index, activity);
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HardwareSoftwareActivityScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Clasificar Hardware o Software',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderStepsActivityScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ordenar Pasos de Actividades',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlowchartActivityScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Diseñar Diagrama de Flujo',
                          style: TextStyle(fontSize: 18),
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

  Widget _buildActivityButton(int index, Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(
                activity: activity,
                activityIndex: index,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          activity['subtopic'],
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ActivityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> activity;
  final int activityIndex;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.activityIndex,
  }) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final Map<int, int> _selectedAnswers = {};
  final Map<int, bool> _correctAnswers = {};
  bool _answersChecked = false;

  void _checkAnswers() {
    // Verificar que 'theory' y 'questions' existan en widget.activity
    if (widget.activity['theory'] == null || widget.activity['theory']['questions'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos de preguntas no disponibles')),
      );
      return;
    }

    final questions = widget.activity['theory']['questions'] as List<dynamic>;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as Map<String, dynamic>? ?? {};
      final correctAnswer = question['correctAnswer'] as int?;
      if (correctAnswer == null) {
        _correctAnswers[i] = false; // Asumimos incorrecto si no hay respuesta válida
      } else if (_selectedAnswers[i] == correctAnswer) {
        _correctAnswers[i] = true;
      } else {
        _correctAnswers[i] = false;
      }
    }
    setState(() {
      _answersChecked = true;
    });
  }

  void _resetAnswers() {
    setState(() {
      _selectedAnswers.clear();
      _correctAnswers.clear();
      _answersChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verificar que 'theory' y 'objective' existan en widget.activity
    final objective = widget.activity['objective'] ?? 'No hay objetivo definido';
    final questions = widget.activity['theory']?['questions'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity['subtopic'] ?? 'Actividad'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              objective,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value as Map<String, dynamic>? ?? {};
              return _buildQuestionCard(index, question);
            }).toList(),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _answersChecked
                        ? null
                        : () {
                            _checkAnswers();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Verificar Respuestas',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_answersChecked)
                    ElevatedButton(
                      onPressed: () {
                        _resetAnswers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reiniciar Actividad',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_answersChecked)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Volver a Actividades',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>? ?? [];
    final questionText = question['question'] ?? 'Pregunta no disponible';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              return RadioListTile<int>(
                title: Text(option.toString()),
                value: optionIndex,
                groupValue: _selectedAnswers[index],
                onChanged: _answersChecked
                    ? null
                    : (value) {
                        setState(() {
                          _selectedAnswers[index] = value!;
                        });
                      },
              );
            }).toList(),
            if (_correctAnswers.containsKey(index))
              Text(
                _correctAnswers[index]! ? 'Correcto' : 'Incorrecto',
                style: TextStyle(
                  color: _correctAnswers[index]! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}