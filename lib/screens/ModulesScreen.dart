import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siapp/screens/login_screen.dart';
import 'package:siapp/screens/progress_screen.dart';
import 'module1.dart';
import 'module2.dart';
import 'module3.dart';

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
      'id': 'module1',
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Algoritmos',
      'activities': 3,
      'id': 'module2',
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Introducción a Java',
      'activities': 4,
      'id': 'module3',
    },
  ];

  Future<void> addModuleDetailsAndNavigate(BuildContext context, Map<String, dynamic> module) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    final String? userEmail = user.email;
    if (userEmail == null || userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El correo del usuario no está disponible.")),
      );
      return;
    }

    final QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El documento del usuario no existe en Firestore.")),
      );
      return;
    }

    final DocumentSnapshot userDoc = userQuery.docs.first;
    final data = userDoc.data() as Map<String, dynamic>?;

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Los datos del usuario son nulos.")),
      );
      return;
    }

    final String ncontrol = data['ncontrol']?.toString() ?? '';
    if (ncontrol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El número de control no está configurado.")),
      );
      return;
    }

    final DocumentReference progressRef =
        FirebaseFirestore.instance.collection('progress').doc(ncontrol);

    final DocumentSnapshot progressSnapshot =
        await progressRef.collection('module_details').doc(module['id']).get();

    if (!progressSnapshot.exists) {
      await progressRef.collection('module_details').doc(module['id']).set({
        'porcentaje': 0,
        'quiz_completed': false,
        'topics_completed': [],
      }, SetOptions(merge: true));
    }

    // Redireccionar directamente al módulo correspondiente
    switch (module['id']) {
      case 'module1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Module1IntroScreen(module: module)),
        );
        break;
      case 'module2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Module2Screen(module: module)),
        );
        break;
      case 'module3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Module3Screen(module: module)),
        );
        break;
    }
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
            onTap: () => addModuleDetailsAndNavigate(context, modules[index]),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Cuenta'),
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
