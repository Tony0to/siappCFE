import 'package:flutter/material.dart';
import 'dart:math';

class OrderStepsActivityScreen extends StatefulWidget {
  const OrderStepsActivityScreen({Key? key}) : super(key: key);

  @override
  _OrderStepsActivityScreenState createState() => _OrderStepsActivityScreenState();
}

class _OrderStepsActivityScreenState extends State {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    SizedBox(
                      height: 400, // Altura fija para que el ReorderableListView sea desplazable si es necesario
                      child: ReorderableListView(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(), // Permitir desplazamiento dentro del ReorderableListView
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final step = _userOrderedSteps[_currentActivityIndex]!.removeAt(oldIndex);
                            _userOrderedSteps[_currentActivityIndex]!.insert(newIndex, step);
                            print('Reordenado: $oldIndex -> $newIndex'); // Depuración
                          });
                        },
                        children: _userOrderedSteps[_currentActivityIndex]!
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              return Card(
                                key: ValueKey('$index-$step-${_currentActivityIndex}'),
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  leading: Text(
                                    '${index + 1}', // Número basado en el índice
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  title: Text(
                                    step,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  trailing: ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(
                                      Icons.drag_handle, // Usamos un ícono más grande y claro
                                      color: Colors.grey,
                                      size: 40, // Aumentamos el tamaño para facilitar el agarre
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}