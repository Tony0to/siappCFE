import 'package:flutter/material.dart';
import 'dart:math';

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
                      final activity = entry.value;
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
    final questions = widget.activity['theory']['questions'] as List<dynamic>;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final correctAnswer = question['correctAnswer'] as int;
      if (_selectedAnswers[i] == correctAnswer) {
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
    final questions = widget.activity['theory']['questions'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity['subtopic']),
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
              widget.activity['objective'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
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
    final options = question['options'] as List<dynamic>;

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
              question['question'],
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
                title: Text(option),
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

class HardwareSoftwareActivityScreen extends StatefulWidget {
  const HardwareSoftwareActivityScreen({Key? key}) : super(key: key);

  @override
  _HardwareSoftwareActivityScreenState createState() => _HardwareSoftwareActivityScreenState();
}

class _HardwareSoftwareActivityScreenState extends State<HardwareSoftwareActivityScreen> {
  int _currentImageIndex = 0;
  final Map<int, String?> _userAnswers = {};
  bool _answersChecked = false;
  final Map<int, bool> _correctAnswers = {};

  final List<Map<String, dynamic>> _images = [
    {
      'url': 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Hardware', // CPU
      'description': 'Procesador (CPU)'
    },
    {
      'url': 'https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Hardware', // Microchip
      'description': 'Microchip'
    },
    {
      'url': 'https://images.unsplash.com/photo-1591488320449-011701bb6704?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Hardware', // Componentes de computadora
      'description': 'Componentes de computadora'
    },
    {
      'url': 'https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Software', // Pantalla con código
      'description': 'Interfaz de software'
    },
    {
      'url': 'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Software', // Escritorio con aplicaciones
      'description': 'Aplicaciones en escritorio'
    },
    {
      'url': 'https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Hardware', // Disco duro
      'description': 'Disco duro'
    },
    {
      'url': 'https://images.unsplash.com/photo-1547088886-8d8c7a9e5f6e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Software', // Editor de código
      'description': 'Editor de código'
    },
    {
      'url': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Software', // Interfaz de software en laptop
      'description': 'Interfaz de software en laptop'
    },
    {
      'url': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Hardware', // Teclado
      'description': 'Teclado'
    },
    {
      'url': 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'correctAnswer': 'Software', // Sistema operativo
      'description': 'Sistema operativo'
    },
  ];

  void _selectAnswer(String answer) {
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
    for (int i = 0; i < _images.length; i++) {
      _correctAnswers[i] = _userAnswers[i] == _images[i]['correctAnswer'];
    }
    setState(() {
      _answersChecked = true;
    });
  }

  void _resetActivity() {
    setState(() {
      _currentImageIndex = 0;
      _userAnswers.clear();
      _correctAnswers.clear();
      _answersChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificar Hardware o Software'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿Es Hardware o Software?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            if (!_answersChecked) ...[
              Text(
                'Imagen ${_currentImageIndex + 1} de ${_images.length}',
                style: const TextStyle(fontSize: 16),
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
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _images[_currentImageIndex]['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _selectAnswer('Hardware');
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
                      'Hardware',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectAnswer('Software');
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
                      'Software',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
            if (_answersChecked) ...[
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ..._images.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
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
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Tu respuesta: ${_userAnswers[index] ?? "No respondido"}',
                              style: const TextStyle(fontSize: 14),
                            ),
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
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _resetActivity();
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class OrderStepsActivityScreen extends StatefulWidget {
  const OrderStepsActivityScreen({Key? key}) : super(key: key);

  @override
  _OrderStepsActivityScreenState createState() => _OrderStepsActivityScreenState();
}

class _OrderStepsActivityScreenState extends State<OrderStepsActivityScreen> {
  int _currentActivityIndex = 0;
  bool _answersChecked = false;
  final Map<int, List<String>> _userOrderedSteps = {};
  final Map<int, List<bool>> _correctOrders = {};

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Hacer una reserva en un restaurante',
      'steps': [
        'Elegir el restaurante donde deseas hacer la reserva.',
        'Verificar disponibilidad de mesas en la fecha y hora deseadas.',
        'Contactar al restaurante (por teléfono, en persona o a través de su plataforma en línea).',
        'Proporcionar la información necesaria (nombre, número de personas, fecha y hora).',
        'Confirmar los detalles de la reserva y cualquier requerimiento especial.',
        'Guardar o anotar la confirmación de la reserva.',
        'Asistir al restaurante en la fecha y hora establecidas.',
      ],
    },
    {
      'title': 'Enviar un paquete por correo',
      'steps': [
        'Preparar el paquete asegurándose de que esté bien embalado.',
        'Escribir la dirección del destinatario correctamente en la caja o etiqueta.',
        'Elegir un servicio de mensajería o empresa de correos.',
        'Ir a la oficina de correos o solicitar una recogida a domicilio.',
        'Pagar el costo del envío y obtener el comprobante.',
        'Guardar el número de rastreo para dar seguimiento al paquete.',
        'Confirmar la entrega con el destinatario.',
      ],
    },
    {
      'title': 'Registrarse en una plataforma en línea',
      'steps': [
        'Ingresar al sitio web o aplicación de la plataforma.',
        'Hacer clic en el botón de "Registro" o "Crear cuenta".',
        'Completar el formulario con la información requerida (nombre, correo electrónico, contraseña).',
        'Aceptar los términos y condiciones de uso.',
        'Verificar la cuenta a través de un código enviado por correo electrónico o SMS.',
        'Iniciar sesión con las credenciales creadas.',
        'Configurar el perfil agregando información adicional si es necesario.',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Desordenar los pasos de cada actividad al inicio
    for (int i = 0; i < _activities.length; i++) {
      final steps = List<String>.from(_activities[i]['steps']);
      steps.shuffle(Random());
      _userOrderedSteps[i] = steps;
    }
  }

  void _checkAnswers() {
    for (int i = 0; i < _activities.length; i++) {
      final correctSteps = _activities[i]['steps'] as List<String>;
      final userSteps = _userOrderedSteps[i]!;
      _correctOrders[i] = List<bool>.generate(userSteps.length, (index) => userSteps[index] == correctSteps[index]);
    }
    setState(() {
      _answersChecked = true;
    });
  }

  void _resetActivity() {
    setState(() {
      _currentActivityIndex = 0;
      _answersChecked = false;
      _correctOrders.clear();
      for (int i = 0; i < _activities.length; i++) {
        final steps = List<String>.from(_activities[i]['steps']);
        steps.shuffle(Random());
        _userOrderedSteps[i] = steps;
      }
    });
  }

  void _nextActivity() {
    if (_currentActivityIndex < _activities.length - 1) {
      setState(() {
        _currentActivityIndex++;
      });
    } else {
      _checkAnswers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenar Pasos de Actividades'),
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
            const Text(
              'Ordena los Pasos Correctamente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            if (!_answersChecked) ...[
              Text(
                'Actividad ${_currentActivityIndex + 1} de ${_activities.length}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                _activities[_currentActivityIndex]['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final step = _userOrderedSteps[_currentActivityIndex]!.removeAt(oldIndex);
                    _userOrderedSteps[_currentActivityIndex]!.insert(newIndex, step);
                  });
                },
                children: _userOrderedSteps[_currentActivityIndex]!
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Card(
                        key: ValueKey('$index-$step'),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.drag_handle),
                          title: Text(
                            step,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _nextActivity();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentActivityIndex < _activities.length - 1
                        ? 'Siguiente Actividad'
                        : 'Verificar Orden',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
            if (_answersChecked) ...[
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ..._activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._userOrderedSteps[index]!.asMap().entries.map((stepEntry) {
                      final stepIndex = stepEntry.key;
                      final step = stepEntry.value;
                      final isCorrect = _correctOrders[index]![stepIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isCorrect ? Colors.black : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _resetActivity();
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
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}