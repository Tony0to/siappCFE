import 'package:flutter/material.dart';

class FlowCharts {
  static Widget getFlowChart(String id) {
    switch (id) {
      case 'rectangulo':
        return const StaticFlowChart(type: FlowChartType.rectangulo);
      case 'par_impar':
        return const StaticFlowChart(type: FlowChartType.parImpar);
      case 'bucle':
        return const StaticFlowChart(type: FlowChartType.bucle);
      case 'condicional_multiple':
        return const StaticFlowChart(type: FlowChartType.condicionalMultiple);
      case 'rango_numeros':
        return const StaticFlowChart(type: FlowChartType.rangoNumeros);
      case 'aprobacion_estudiante':
        return const StaticFlowChart(type: FlowChartType.aprobacionEstudiante);
      default:
        return const StaticFlowChart(type: FlowChartType.defaultChart);
    }
  }
}

enum FlowChartType {
  rectangulo,
  parImpar,
  bucle,
  condicionalMultiple,
  rangoNumeros,
  aprobacionEstudiante,
  defaultChart,
}

class StaticFlowChart extends StatelessWidget {
  final FlowChartType type;

  const StaticFlowChart({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FlowChartPainter(type: type),
      size: _getSize(type),
    );
  }

  Size _getSize(FlowChartType type) {
    switch (type) {
      case FlowChartType.rectangulo:
        return const Size(400, 600);
      case FlowChartType.parImpar:
        return const Size(500, 600);
      case FlowChartType.bucle:
        return const Size(400, 600);
      case FlowChartType.condicionalMultiple:
        return const Size(600, 700);
      case FlowChartType.rangoNumeros:
        return const Size(500, 600);
      case FlowChartType.aprobacionEstudiante:
        return const Size(500, 650);
      case FlowChartType.defaultChart:
        return const Size(400, 200);
    }
  }
}

class FlowChartPainter extends CustomPainter {
  final FlowChartType type;

  FlowChartPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = 140.0;
    final nodeHeight = 80.0;
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    switch (type) {
      case FlowChartType.rectangulo:
        _drawRectangulo(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.parImpar:
        _drawParImpar(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.bucle:
        _drawBucle(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.condicionalMultiple:
        _drawCondicionalMultiple(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.rangoNumeros:
        _drawRangoNumeros(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.aprobacionEstudiante:
        _drawAprobacionEstudiante(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.defaultChart:
        _drawDefault(canvas, size, nodeWidth, nodeHeight, textStyle);
        break;
    }
  }

  void _drawRectangulo(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'Leer base', 'kind': 'rectangle', 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Leer altura', 'kind': 'rectangle', 'y': 220.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Área = base * altura', 'kind': 'rectangle', 'y': 320.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Mostrar área', 'kind': 'rectangle', 'y': 420.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'y': 520.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      _drawNode(canvas, Offset(centerX, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
      if (i < nodes.length - 1) {
        _drawArrow(canvas, Offset(centerX, (node['y'] as double) + nodeHeight / 2), Offset(centerX, (nodes[i + 1]['y'] as double) - nodeHeight / 2), arrowPaint);
      }
    }
  }

  void _drawParImpar(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'x': centerX, 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'Leer número', 'kind': 'rectangle', 'x': centerX, 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿Número % 2 == 0?', 'kind': 'diamond', 'x': centerX, 'y': 220.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar "Par"', 'kind': 'rectangle', 'x': centerX - 150, 'y': 340.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Mostrar "Impar"', 'kind': 'rectangle', 'x': centerX + 150, 'y': 340.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'x': centerX, 'y': 460.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Arrows
    _drawArrow(canvas, Offset(centerX, 20 + nodeHeight / 2), Offset(centerX, 120 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 120 + nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX - 150, 340 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX + 150, 340 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX - 150, 340 + nodeHeight / 2), Offset(centerX, 460 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 340 + nodeHeight / 2), Offset(centerX, 460 - nodeHeight / 2), arrowPaint);
  }

  void _drawBucle(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'x': centerX, 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'i = 1', 'kind': 'rectangle', 'x': centerX, 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿i <= 5?', 'kind': 'diamond', 'x': centerX, 'y': 220.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar i', 'kind': 'rectangle', 'x': centerX, 'y': 320.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'i = i + 1', 'kind': 'rectangle', 'x': centerX, 'y': 420.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'x': centerX - 150, 'y': 320.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Arrows
    _drawArrow(canvas, Offset(centerX, 20 + nodeHeight / 2), Offset(centerX, 120 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 120 + nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX, 320 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX - 150, 320 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 320 + nodeHeight / 2), Offset(centerX, 420 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 420 + nodeHeight / 2), Offset(centerX + 100, 420 + nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 100, 420 + nodeHeight / 2), Offset(centerX + 100, 220 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 100, 220 - nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
  }

  void _drawCondicionalMultiple(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'x': centerX, 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'Leer número', 'kind': 'rectangle', 'x': centerX, 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿Número > 0?', 'kind': 'diamond', 'x': centerX, 'y': 220.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar "Positivo"', 'kind': 'rectangle', 'x': centerX - 200, 'y': 340.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿Número < 0?', 'kind': 'diamond', 'x': centerX + 150, 'y': 340.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar "Negativo"', 'kind': 'rectangle', 'x': centerX + 50, 'y': 460.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Mostrar "Cero"', 'kind': 'rectangle', 'x': centerX + 250, 'y': 460.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'x': centerX, 'y': 580.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Arrows
    _drawArrow(canvas, Offset(centerX, 20 + nodeHeight / 2), Offset(centerX, 120 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 120 + nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX - 200, 340 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX + 150, 340 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX + 150, 340 + nodeHeight / 2), Offset(centerX + 50, 460 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX + 150, 340 + nodeHeight / 2), Offset(centerX + 250, 460 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX - 200, 340 + nodeHeight / 2), Offset(centerX, 580 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 50, 460 + nodeHeight / 2), Offset(centerX, 580 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 250, 460 + nodeHeight / 2), Offset(centerX, 580 - nodeHeight / 2), arrowPaint);
  }

  void _drawRangoNumeros(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'x': centerX, 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'Leer número', 'kind': 'rectangle', 'x': centerX, 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿Número >= 10\nY\nNúmero <= 20?', 'kind': 'diamond', 'x': centerX, 'y': 220.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar\n"Número dentro\ndel rango"', 'kind': 'rectangle', 'x': centerX - 150, 'y': 360.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Mostrar\n"Número fuera\ndel rango"', 'kind': 'rectangle', 'x': centerX + 150, 'y': 360.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'x': centerX, 'y': 480.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Arrows
    _drawArrow(canvas, Offset(centerX, 20 + nodeHeight / 2), Offset(centerX, 120 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 120 + nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX - 150, 360 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX + 150, 360 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX - 150, 360 + nodeHeight / 2), Offset(centerX, 480 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 360 + nodeHeight / 2), Offset(centerX, 480 - nodeHeight / 2), arrowPaint);
  }

  void _drawAprobacionEstudiante(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'Inicio', 'kind': 'oval', 'x': centerX, 'y': 20.0, 'color': const Color(0xFF1E40AF)},
      {'text': 'Leer calificación', 'kind': 'rectangle', 'x': centerX, 'y': 120.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Leer asistencia', 'kind': 'rectangle', 'x': centerX, 'y': 220.0, 'color': const Color(0xFF3B82F6)},
      {'text': '¿Calificación >= 6\nY\nAsistencia > 80%?', 'kind': 'diamond', 'x': centerX, 'y': 320.0, 'color': const Color(0xFFFFA500)},
      {'text': 'Mostrar\n"Aprobado"', 'kind': 'rectangle', 'x': centerX - 150, 'y': 450.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Mostrar\n"Reprobado"', 'kind': 'rectangle', 'x': centerX + 150, 'y': 450.0, 'color': const Color(0xFF3B82F6)},
      {'text': 'Fin', 'kind': 'oval', 'x': centerX, 'y': 570.0, 'color': const Color(0xFF1E40AF)},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Arrows
    _drawArrow(canvas, Offset(centerX, 20 + nodeHeight / 2), Offset(centerX, 120 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 120 + nodeHeight / 2), Offset(centerX, 220 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 220 + nodeHeight / 2), Offset(centerX, 320 - nodeHeight / 2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 320 + nodeHeight / 2), Offset(centerX - 150, 450 - nodeHeight / 2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 320 + nodeHeight / 2), Offset(centerX + 150, 450 - nodeHeight / 2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX - 150, 450 + nodeHeight / 2), Offset(centerX, 570 - nodeHeight / 2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 450 + nodeHeight / 2), Offset(centerX, 570 - nodeHeight / 2), arrowPaint);
  }

  void _drawDefault(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle) {
    _drawNode(canvas, Offset(size.width / 2, size.height / 2), nodeWidth, nodeHeight, 'Diagrama no disponible', 'rectangle', Colors.red, textStyle);
  }

  void _drawNode(Canvas canvas, Offset center, double width, double height, String text, String kind, Color color, TextStyle textStyle) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (kind == 'oval') {
      canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), paint);
      canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), borderPaint);
    } else if (kind == 'diamond') {
      final path = Path()
        ..moveTo(center.dx, center.dy - height / 2)
        ..lineTo(center.dx + width / 2, center.dy)
        ..lineTo(center.dx, center.dy + height / 2)
        ..lineTo(center.dx - width / 2, center.dy)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else {
      canvas.drawRect(Rect.fromCenter(center: center, width: width, height: height), paint);
      canvas.drawRect(Rect.fromCenter(center: center, width: width, height: height), borderPaint);
    }

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 10);
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, start, end, paint);
  }

  void _drawArrowWithLabel(Canvas canvas, Offset start, Offset end, Paint paint, String label, TextStyle textStyle) {
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, start, end, paint);

    final midPoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final textSpan = TextSpan(text: label, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(midPoint.dx - textPainter.width / 2, midPoint.dy - textPainter.height / 2 - 10));
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 10.0;
    final direction = (end - start).direction;
    final p1 = end;
    final p2 = p1 - Offset.fromDirection(direction + 3.14 / 6, arrowSize);
    final p3 = p1 - Offset.fromDirection(direction - 3.14 / 6, arrowSize);
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}