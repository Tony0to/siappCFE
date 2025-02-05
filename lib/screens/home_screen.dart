import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart'; // Pantalla de autenticación
import 'ModulesScreen.dart'; // Pantalla de módulos

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Función para crear o actualizar el progreso del usuario en Firestore.
  Future<void> createOrUpdateProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    // Obtener el 'ncontrol' del usuario autenticado
    final String? userEmail = user.email; // Usamos el correo para buscar el documento
    if (userEmail == null || userEmail.isEmpty) {
      throw Exception("El correo del usuario no está disponible.");
    }

    // Buscar el documento del usuario en la colección 'users' usando el correo
    final QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    // Verificar si se encontró el documento
    if (userQuery.docs.isEmpty) {
      throw Exception("El documento del usuario no existe en Firestore.");
    }

    // Obtener el primer documento (asumimos que el correo es único)
    final DocumentSnapshot userDoc = userQuery.docs.first;
    final data = userDoc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Los datos del usuario son nulos.");
    }

    // Obtener el campo 'ncontrol'
    final String ncontrol = data['ncontrol']?.toString() ?? '';
    if (ncontrol.isEmpty) {
      throw Exception("El número de control (ncontrol) no está configurado.");
    }

    // Referencia al documento en la colección 'progress' con el 'ncontrol' como ID
    final DocumentReference progressRef =
        FirebaseFirestore.instance.collection('progress').doc(ncontrol);

    // Crear o actualizar el documento en 'progress'
    await progressRef.set({
      'mcompleto': [], // Lista de módulos completados
      'ultimo_acceso': FieldValue.serverTimestamp(), // Fecha de último acceso
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          // Botón para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al cerrar sesión')),
                );
              }
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mensaje de bienvenida
              Text(
                '¡Bienvenido ${user?.email ?? 'Usuario'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Foto de perfil del usuario
              if (user != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              const SizedBox(height: 20),

              // Botón para ver los módulos
              ElevatedButton(
                onPressed: () async {
                  try {
                    await createOrUpdateProgress();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModulesScreen(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Ver módulos',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}