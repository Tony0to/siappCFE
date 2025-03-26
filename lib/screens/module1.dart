import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Preguntas externas según el documento
final List<Map<String, dynamic>> module1Activities = [
  {
    "subtopic": "Conceptos clave antes de escribir código",
    "theory": {
      "question": "¿Qué diferencia hay entre software y hardware?",
      "options": [
        "El software es el conjunto de piezas físicas, y el hardware es el conjunto de programas.",
        "El software se refiere a programas y aplicaciones, el hardware a componentes físicos.",
        "Software y hardware son lo mismo.",
        "Ninguna de las anteriores."
      ],
      "correctAnswer": 1,
    },
    "reflection":
        "¿Cómo puede el entendimiento de software y hardware mejorar tu capacidad para desarrollar aplicaciones eficientes?",
    "practice": {
      "question": "Clasifica los siguientes elementos en Software o Hardware.",
      "elements": [
        "Teclado",
        "Monitor",
        "Procesador",
        "Windows",
        "Antivirus",
        "Sistema operativo"
      ],
      "answers": {
        "Hardware": ["Teclado", "Monitor", "Procesador"],
        "Software": ["Windows", "Antivirus", "Sistema operativo"]
      }
    }
  },
  {
    "subtopic": "Pensamiento lógico y resolución de problemas",
    "theory": {
      "question":
          "¿Cuál opción describe mejor la diferencia entre lenguajes de bajo y alto nivel?",
      "options": [
        "Bajo nivel más fácil para humanos, alto nivel solo para computadoras.",
        "Bajo nivel más cercano al hardware, alto nivel más comprensible para programadores.",
        "Alto nivel no requiere compilación, bajo nivel siempre necesita traductor.",
        "No hay diferencias."
      ],
      "correctAnswer": 1,
    },
    "reflection":
        "¿Cómo elegirías entre un lenguaje de bajo o alto nivel según el proyecto?",
    "practice": {
      "question":
          "Observa fragmentos en lenguajes bajo y alto nivel. ¿Cuál es más fácil y por qué?",
      "details": "Explica considerando abstracción y facilidad de comprensión."
    }
  }
];

class Module1Screen extends StatelessWidget {
  final Map<String, dynamic> module;

  Module1Screen({required this.module});

  Future<void> completeActivity(BuildContext context, int activityIndex) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debes iniciar sesión primero.")),
      );
      return;
    }

    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario no encontrado en la base de datos.")),
      );
      return;
    }

    final String ncontrol = userQuery.docs.first.data()['ncontrol'].toString();

    // Mostrar preguntas
    var theoryQuestion = module1Activities[activityIndex]["theory"];
    var reflectionQuestion = module1Activities[activityIndex]["reflection"];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(theoryQuestion["question"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            theoryQuestion["options"].length,
            (index) => ElevatedButton(
              onPressed: () => Navigator.pop(context, index.toString()),
              child: Text(theoryQuestion["options"][index]),
            ),
          ),
        ),
      ),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reflexión"),
        content: Text(reflectionQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, "Respondido"),
            child: Text("Continuar"),
          ),
        ],
      ),
    );

    // Guardar progreso usando ncontrol correctamente
    await FirebaseFirestore.instance
        .collection('progress')
        .doc(ncontrol)
        .collection('module_details')
        .doc(module['id'])
        .set({
      'topics_completed': FieldValue.arrayUnion(
          [module1Activities[activityIndex]["subtopic"]]),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Actividad completada y progreso guardado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Módulo 1: ${module['title']}')),
      body: ListView.builder(
        itemCount: module1Activities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(module1Activities[index]["subtopic"]),
            subtitle: Text("Realiza la actividad"),
            trailing: ElevatedButton(
              onPressed: () => completeActivity(context, index),
              child: Text("Iniciar"),
            ),
          );
        },
      ),
    );
  }
}