import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  double progress = 0.0;
  int completedModules = 0;
  int totalModules = 3;

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Introducción a la programación',
      'id': 'module1',
    },
    {
      'title': 'Algoritmos',
      'id': 'module2',
    },
    {
      'title': 'Introducción a Java',
      'id': 'module3',
    },
  ];

  @override
  void initState() {
    super.initState();
    cargarProgreso();
  }

  Future<void> cargarProgreso() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No hay usuario autenticado");
      return;
    }

    // Obtener el correo del usuario autenticado
    final String? userEmail = user.email;
    if (userEmail == null || userEmail.isEmpty) {
      print("El correo del usuario no está disponible.");
      return;
    }

    try {
      // Buscar el documento del usuario en la colección 'users' usando el correo
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        print("El documento del usuario no existe en Firestore.");
        return;
      }

      // Obtener el documento del usuario
      final DocumentSnapshot userDoc = userQuery.docs.first;
      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null) {
        print("Los datos del usuario son nulos.");
        return;
      }

      final String ncontrol = data['ncontrol']?.toString() ?? '';
      if (ncontrol.isEmpty) {
        print("El número de control (ncontrol) no está configurado.");
        return;
      }

      // Referencia al documento en la colección 'progress'
      final DocumentSnapshot progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(ncontrol)
          .get();

      if (!progressDoc.exists) {
        print("No hay progreso registrado para el usuario.");
        return;
      }

      final progressData = progressDoc.data() as Map<String, dynamic>?;

      int modulosCompletados = 0;
      if (progressData != null && progressData.containsKey('mcompleto')) {
        final moduleDetails = await FirebaseFirestore.instance
            .collection('progress')
            .doc(ncontrol)
            .collection('module_details')
            .get();

        for (var module in moduleDetails.docs) {
          if (module['porcentaje'] == 100) {
            modulosCompletados++;
          }
        }

        setState(() {
          completedModules = modulosCompletados;
          progress = (completedModules / totalModules) * 100;
        });
      }
    } catch (e) {
      print("Error al cargar el progreso: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificaciones y progreso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Módulos completados: $completedModules / $totalModules',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(modules[index]['title']),
                    trailing: Icon(
                      Icons.check_circle,
                      color: index < completedModules ? Colors.green : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
