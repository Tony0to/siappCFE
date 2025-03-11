import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siapp/screens/progress_screen.dart';
import 'module1.dart'; // Importar pantalla del módulo 1
import 'module2.dart'; // Importar pantalla del módulo 2
import 'module3.dart'; // Importar pantalla del módulo 3

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Módulos de Estudio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ModulesScreen(),
    );
  }
}

class ModulesScreen extends StatefulWidget {
  @override
  _ModulesScreenState createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> modules = [
    {
      'image': 'assets/siaapp.png',
      'title': 'Introducción a la programación',
      'activities': 5,
      'introText':
          'Bienvenido al módulo de introducción a la programación. Aquí aprenderás los conceptos básicos de la programación y cómo aplicarlos en diferentes lenguajes.',
      'id': 'module1',
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Algoritmos',
      'activities': 3,
      'introText':
          'En este módulo aprenderás sobre algoritmos, su importancia y cómo diseñarlos eficientemente.',
      'id': 'module2',
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Introducción a Java',
      'activities': 4,
      'introText':
          'Este módulo te introducirá al lenguaje de programación Java, sus características y cómo empezar a desarrollar aplicaciones con él.',
      'id': 'module3',
    },
  ];

  Future<void> addModuleDetails(String moduleId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No hay usuario autenticado");
      return;
    }

    final String? userEmail = user.email;
    if (userEmail == null || userEmail.isEmpty) {
      print("El correo del usuario no está disponible.");
      return;
    }

    final QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isEmpty) {
      print("El documento del usuario no existe en Firestore.");
      return;
    }

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

    final DocumentReference progressRef =
        FirebaseFirestore.instance.collection('progress').doc(ncontrol);

    await progressRef.collection('module_details').doc(moduleId).set({
      'porcentaje': 0,
      'quiz_completed': false,
      'topics_completed': [],
    }, SetOptions(merge: true));

    print("Subdocumento module_details actualizado correctamente");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Detalles del módulo actualizados correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escoge un tema")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (BuildContext context, int index) {
          return _ModuleCard(
            module: modules[index],
            onTap: () async {
              await addModuleDetails(modules[index]['id']); // Guardar detalles en Firestore
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuleScreen(module: modules[index]),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProgressScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final VoidCallback onTap;

  _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Comienza',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    child: Text('Start'),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                module['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleScreen extends StatelessWidget {
  final Map<String, dynamic> module;

  ModuleScreen({required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(module['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              module['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                module['introText'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  switch (module['title']) {
                    case 'Introducción a la programación':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Module1Screen(module: module),
                        ),
                      );
                      break;
                    case 'Algoritmos':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Module2Screen(module: module),
                        ),
                      );
                      break;
                    case 'Introducción a Java':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Module3Screen(module: module),
                        ),
                      );
                      break;
                    default:
                      break;
                  }
                },
                child: Text('Comenzar a estudiar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
