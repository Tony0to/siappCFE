import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart';

class FlowchartActivityScreen extends StatefulWidget {
  const FlowchartActivityScreen({Key? key}) : super(key: key);

  @override
  _FlowchartActivityScreenState createState() => _FlowchartActivityScreenState();
}

class _FlowchartActivityScreenState extends State<FlowchartActivityScreen> {
  late Dashboard _dashboard;
  bool _isVerified = false;
  bool _isCorrect = false;

  // Definición de los elementos esperados en el diagrama de referencia
  final List<Map<String, dynamic>> _referenceFlowchart = [
    {'text': 'Inicio', 'kind': ElementKind.oval},
    {'text': 'Solicitar dos números al usuario', 'kind': ElementKind.rectangle},
    {'text': 'Sumar ambos números', 'kind': ElementKind.rectangle},
    {'text': 'Si el resultado es mayor a 10', 'kind': ElementKind.diamond},
    {'text': 'Mostrar "El resultado es alto"', 'kind': ElementKind.rectangle},
    {'text': 'Si el resultado es menor o igual a 10', 'kind': ElementKind.diamond},
    {'text': 'Mostrar "El resultado es bajo"', 'kind': ElementKind.rectangle},
    {'text': 'Fin', 'kind': ElementKind.oval},
  ];

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(
      blockDefaultZoomGestures: false,
      minimumZoomFactor: 1.25,
      defaultArrowStyle: ArrowStyle.curve,
    );

    // Agregar elementos iniciales al dashboard
    _addInitialElements();
  }

  void _addInitialElements() {
    for (int i = 0; i < _referenceFlowchart.length; i++) {
      final element = FlowElement(
        position: Offset(50.0 + (i * 150), 50.0),
        size: const Size(150, 100),
        text: _referenceFlowchart[i]['text'],
        kind: _referenceFlowchart[i]['kind'],
        handlers: [
          Handler.topCenter,
          Handler.bottomCenter,
          Handler.leftCenter,
          Handler.rightCenter,
        ],
        backgroundColor: Colors.white,
        borderColor: Colors.black,
        borderThickness: 2.0,
      );
      _dashboard.addElement(element);
    }

    // Conectar elementos según el flujo (ejemplo básico)
    _dashboard.addNextById(
      _dashboard.elements[0], // Inicio
      _dashboard.elements[1].id, // Solicitar números
      ArrowParams(thickness: 1.5, color: Colors.black),
    );
    _dashboard.addNextById(
      _dashboard.elements[1], // Solicitar números
      _dashboard.elements[2].id, // Sumar números
      ArrowParams(thickness: 1.5, color: Colors.black),
    );
    _dashboard.addNextById(
      _dashboard.elements[2], // Sumar números
      _dashboard.elements[3].id, // Decisión mayor a 10
      ArrowParams(thickness: 1.5, color: Colors.black),
    );
    // Agrega más conexiones según el diagrama (por simplicidad, solo un camino inicial)
  }

  void _verifyFlowchart() {
    final userElements = _dashboard.elements.map((e) => {
          'text': e.text,
          'kind': e.kind,
          'position': e.position,
        }).toList();

    // Verificación simplificada: comparar texto y tipo de forma
    bool correctOrder = true;
    bool correctTypes = true;
    for (int i = 0; i < _referenceFlowchart.length; i++) {
      if (userElements.length <= i ||
          userElements[i]['text'] != _referenceFlowchart[i]['text'] ||
          userElements[i]['kind'] != _referenceFlowchart[i]['kind']) {
        correctOrder = false;
        break;
      }
    }

    // Verificación de conexiones (básica, puede expandirse)
    bool correctConnections = true;
    // Aquí podrías agregar lógica para verificar conexiones específicas
    // Por ahora, asumimos que el orden implica conexiones correctas

    setState(() {
      _isVerified = true;
      _isCorrect = correctOrder && correctTypes && correctConnections;
    });
  }

  void _resetFlowchart() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/FLOWCHART.json');
    if (await file.exists()) {
      await file.delete();
    }
    setState(() {
      _dashboard = Dashboard(
        blockDefaultZoomGestures: false,
        minimumZoomFactor: 1.25,
        defaultArrowStyle: ArrowStyle.curve,
      );
      _addInitialElements();
      _isVerified = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseñar Diagrama de Flujo'),
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
              'Actividad Práctica',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instrucciones: Arrastra y conecta los elementos para representar el diagrama de flujo basado en los pasos:\n'
              '• Inicio\n'
              '• Solicitar dos números al usuario\n'
              '• Sumar ambos números\n'
              '• Si el resultado es mayor a 10, mostrar "El resultado es alto"\n'
              '• Si el resultado es menor o igual a 10, mostrar "El resultado es bajo"\n'
              '• Fin',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              child: FlowChart(
                dashboard: _dashboard,
                onDashboardTapped: (context, position) {},
                onElementPressed: (context, element, position) {
                  // Acción al presionar un elemento (por ejemplo, mostrar información)
                  print('Elemento presionado: ${element.toString()} en $position');
                },
                onHandlerPressed: (context, position, handler, element) {
                  // Permitir conexiones manuales
                  if (handler == Handler.rightCenter) {
                    _dashboard.addNextById(
                      element,
                      _dashboard.elements.firstWhere((e) => e.id != element.id).id,
                      ArrowParams(thickness: 1.5, color: Colors.black),
                    );
                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isVerified
                        ? null
                        : () {
                            _verifyFlowchart();
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
                      'Verificar Diagrama',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isVerified)
                    Text(
                      _isCorrect
                          ? '¡Correcto!'
                          : 'Incorrecto, revisa el orden y las formas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_isVerified)
                    ElevatedButton(
                      onPressed: () {
                        _resetFlowchart();
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}