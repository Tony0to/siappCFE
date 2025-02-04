import 'package:flutter/material.dart';

class ModulesScreen extends StatefulWidget {
  @override
  _ModulesScreenState createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> modules = [
    {
      'image': 'assets/module1.png',
      'title': 'Módulo 1',
      'activities': 5,
    },
    {
      'image': 'assets/module2.png',
      'title': 'Módulo 2',
      'activities': 3,
    },
    {
      'image': 'assets/module3.png',
      'title': 'Módulo 3',
      'activities': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: modules.length,
        itemBuilder: (BuildContext context, int index) {
          return _ModuleCard(
            module: modules[index],
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
          // Navegación según el índice seleccionado
          if (index == 0) {
            // Estás en Home
          } else if (index == 1) {
            // Navega a la pantalla de cuenta
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

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;

  _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Image.asset(
            module['image'],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  module['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${module['activities']} actividades',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de cuenta (como ejemplo)
class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Pantalla de Cuenta'),
      ),
    );
  }
}
