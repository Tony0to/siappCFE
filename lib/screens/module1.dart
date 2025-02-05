import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Module1Screen extends StatelessWidget {
  final Map<String, dynamic> module;

  Module1Screen({required this.module});

  // Función para simular un juego (cuestionario)
  void _startQuiz(BuildContext context) async {
    // Preguntas y respuestas
    List<Map<String, dynamic>> questions = [
      {
        "question": "¿Cuál es la capital de Francia?",
        "options": ["Londres", "París", "Madrid", "Berlín"],
        "correctAnswer": 1,
      },
      {
        "question": "¿Cuál es el planeta más cercano al Sol?",
        "options": ["Tierra", "Marte", "Venus", "Mercurio"],
        "correctAnswer": 3,
      },
      {
        "question": "¿Quién escribió 'Cien años de soledad'?",
        "options": [
          "Gabriel García Márquez",
          "Pablo Neruda",
          "Mario Vargas Llosa",
          "Julio Cortázar"
        ],
        "correctAnswer": 0,
      },
    ];

    int score = 0;

    // Mostrar preguntas y calcular la calificación
    for (var i = 0; i < questions.length; i++) {
      String? answer = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(questions[i]["question"]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                questions[i]["options"].length,
                (index) => ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, index.toString());
                  },
                  child: Text(questions[i]["options"][index]),
                ),
              ),
            ),
          );
        },
      );

      if (answer != null &&
          int.parse(answer) == questions[i]["correctAnswer"]) {
        score++;
      }
    }

    // Calcular porcentaje
    double percentage = (score / questions.length) * 100;

    // Mostrar resultado
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Resultado"),
          content:
              Text("Tu calificación es: ${percentage.toStringAsFixed(2)}%"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    // Guardar en Firestore si la calificación es mayor a 70
    if (percentage > 70) {
      await FirebaseFirestore.instance
          .collection('progress')
          .doc('idprogress')
          .collection('module_details')
          .doc('QAMZWz2TE0WHgfyt5Elo')
          .update({
        'temascompletos': FieldValue.arrayUnion(["tema2"]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Módulo 1: ${module['title']}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contenido del móduloooooo: ${module['title']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startQuiz(context); // Iniciar el juego
              },
              child: Text('Jugar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Regresar al módulo anterior
              },
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
