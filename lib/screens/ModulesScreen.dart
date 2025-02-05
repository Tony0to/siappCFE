import 'package:flutter/material.dart';
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
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Algoritmos',
      'activities': 3,
      'introText':
          'En este módulo aprenderás sobre algoritmos, su importancia y cómo diseñarlos eficientemente.',
    },
    {
      'image': 'assets/siaapp.png',
      'title': 'Introducción a Java',
      'activities': 4,
      'introText':
          'Este módulo te introducirá al lenguaje de programación Java, sus características y cómo empezar a desarrollar aplicaciones con él.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Circular Logo
            _CircularLogo(),

            // Grid of Modules
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                childAspectRatio:
                    MediaQuery.of(context).size.width > 600 ? 1.5 : 2,
              ),
              itemCount: modules.length,
              itemBuilder: (BuildContext context, int index) {
                return _ModuleCard(
                  module: modules[index],
                );
              },
            ),
          ],
        ),
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
              MaterialPageRoute(builder: (context) => AccountScreen()),
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

class _CircularLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 20),
      child: Center(
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade100,
            image: DecorationImage(
              image: AssetImage('assets/siaapp.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final Map<String, dynamic> module;

  _ModuleCard({required this.module});

  @override
  __ModuleCardState createState() => __ModuleCardState();
}

class __ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ModuleScreen(module: widget.module)),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
          child: Card(
            elevation: _isHovered ? 12 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Imagen más grande hacia abajo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    widget.module['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),
                // Sombreado completo sobre la imagen
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Contenido de texto
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.module['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${widget.module['activities']} actividades',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            // Imagen relacionada al tema
            Image.asset(
              module['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
            // Texto introductorio
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
            // Botón "Comenzar a estudiar"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla correspondiente según el módulo
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
                      // Manejar el caso por defecto si es necesario
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

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuenta '),
      ),
      body: Center(
        child: Text('Pantalla de Cuenta'),
      ),
    );
  }
}
