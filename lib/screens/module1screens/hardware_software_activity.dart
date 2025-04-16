import 'package:flutter/material.dart';

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