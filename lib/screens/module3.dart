import 'package:flutter/material.dart';

class Module3Screen extends StatelessWidget {
  final Map<String, dynamic> module;

  Module3Screen({required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Módulo 3: ${module['title']}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contenido del módulo: ${module['title']}',
              style: TextStyle(fontSize: 20),
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
