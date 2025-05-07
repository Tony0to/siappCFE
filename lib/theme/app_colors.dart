import 'package:flutter/material.dart';

class AppColors {
  // === FONDOS GENERALES ===
  static const Color backgroundDark = Color(0xFF0A2540); // Fondo principal
  static const Color backgroundGradientTop = Color(0xFF0057B8);
  static const Color backgroundGradientBottom = Color(0xFF0057B8); // Añadido del segundo archivo

  // === TEXTO ===
  static const Color textPrimary = Color.fromARGB(255, 255, 255, 255); // Siempre sobre fondo oscuro
  static const Color textSecondary = Color.fromARGB(255, 240, 240, 240);

  // === CARDS Y CONTENEDORES ===
  static const Color cardBackground = Color.fromARGB(179, 60, 128, 205); // 70% opacidad
  static const Color neutralCard = Color.fromARGB(230, 43, 60, 112);     // Fondo gris 90%
  static const Color glassmorphicBackground = Color.fromRGBO(255, 255, 255, 0.1); // Contenedor translúcido para secciones
  static const Color glassmorphicBorder = Color.fromRGBO(255, 255, 255, 0.2);     // Delimita secciones

  // === BOTONES ===
  static const Color primaryButton = Color(0xFF00A8E8);     // Azul eléctrico
  static const Color primaryButtonHover = Color(0xFF007EA7);
  static const Color secondaryButton = Color(0xFF8B0000);   // Rojo quemado
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFA0A0A0);     // Gris

  // === PROGRESO Y BARRAS ===
  static const Color progressInactive = Color(0x33FFFFFF);  // Blanco 20%
  static const Color progressActive = Color(0xFF64B5F6);    // Azul claro
  static const Color progressShadow = Color(0x6600A8E8);    // Sombra azul
  static const Color progressBrightBlue = Color(0xFF3B82F6);                      // Progreso y títulos

  // === BADGES / ESTADOS ===
  static const Color badgeBackground = Color(0xFFFFC300);   // Dorado
  static const Color badgeText = Color(0xFF000000);
  static const Color success = Color(0xFF7FFF00);           // Verde lima
  static const Color confirm = Color(0xFF7FFF00);           // Verde lima
  static const Color error = Color(0xFFEF4444);             // Rojo claro
  static const Color validationError = Color(0xFFFF6F61);   // Coral
  static const Color warning = Color(0xFFFFC300);           // Amarillo
  static const Color exhaustedAttempts = Color(0xFFFF4D4F); // Texto en rojo fuerte (añadido del segundo archivo)

  // === ELEMENTOS DECORATIVOS ===
  static const Color accentAqua = Color(0xFF00FFFF);        // Cian llamativo
  static const Color chipTopic = Color(0xFF93C5FD);         // Chips temas relacionados

  // === CÓDIGO Y PSEUDOCÓDIGO ===
  static const Color codeBoxBackground = Color.fromRGBO(10, 36, 99, 0.7); // Fondo contenedor de código resaltado (corregido a formato RGBO del segundo archivo)
  static const Color codeBoxBorder = Color.fromRGBO(62, 146, 204, 0.4);   // Línea de borde en tarjetas de código
  static const Color codeBoxLabel = Color(0xFF3E92CC);      // Fondo para títulos como “Código”, “Pseudocódigo”

  // === EVALUACIÓN ===
  static const Color answerCorrect = Color(0xFF10B981);     // Icono de check y fondo al responder bien
  static const Color answerIncorrect = Color(0xFFEF4444);   // Icono de error y fondo rojo
  static const Color answerCorrectBg = Color.fromRGBO(16, 185, 129, 0.2); // Fondo al responder bien
  static const Color answerIncorrectBg = Color.fromRGBO(239, 68, 68, 0.2); // Fondo al responder mal

  // === GRADIENTES COMPLEMENTARIOS ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00A8E8), Color(0xFF007EA7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient loadingBackground = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === NUEVAS COMBINACIONES DE DEGRADADOS ===
  static const LinearGradient backgroundDynamic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0057B8), Color(0xFF0A2540)],
  );

  static const LinearGradient headerSection = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.7)],
  );

  static const LinearGradient progressBar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFFFFF), Color(0xFF64B5F6)],
  );

  // === COLORES DE CONFETTI ===
  static const List<Color> confettiColors = [
    Color(0xFF3B82F6), // Azul
    Color(0xFF10B981), // Verde
    Color(0xFFFFD700), // Oro
  ];

  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.1);
}