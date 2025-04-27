import 'package:flutter/material.dart';

class FlowCharts {
  static Widget getFlowChart(String id) {
    switch (id) {
      case 'triangulo_numerico':
        return const StaticFlowChart(type: FlowChartType.trianguloNumerico);
      case 'validador_password':
        return const StaticFlowChart(type: FlowChartType.validadorPassword);
      case 'contador_vocales':
        return const StaticFlowChart(type: FlowChartType.contadorVocales);
      default:
        return const StaticFlowChart(type: FlowChartType.defaultChart);
    }
  }
}

enum FlowChartType {
  trianguloNumerico,
  validadorPassword,
  contadorVocales,
  defaultChart,
}

class StaticFlowChart extends StatelessWidget {
  final FlowChartType type;

  const StaticFlowChart({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale the flowchart to fit within the available space
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final baseSize = _getBaseSize(type);
        final scale = [
          maxWidth / baseSize.width,
          maxHeight / baseSize.height,
          1.0
        ].reduce((a, b) => a < b ? a : b);

        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            painter: FlowChartPainter(type: type),
            size: Size(baseSize.width * scale, baseSize.height * scale),
          ),
        );
      },
    );
  }

  Size _getBaseSize(FlowChartType type) {
    switch (type) {
      case FlowChartType.trianguloNumerico:
        return const Size(400, 550);
      case FlowChartType.validadorPassword:
        return const Size(450, 650);
      case FlowChartType.contadorVocales:
        return const Size(400, 600);
      case FlowChartType.defaultChart:
        return const Size(300, 200);
    }
  }
}

class FlowChartPainter extends CustomPainter {
  final FlowChartType type;

  FlowChartPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = 140.0;
    final nodeHeight = 60.0;
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (type) {
      case FlowChartType.trianguloNumerico:
        _drawTrianguloNumerico(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.validadorPassword:
        _drawValidadorPassword(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.contadorVocales:
        _drawContadorVocales(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType.defaultChart:
        _drawDefault(canvas, size, nodeWidth, nodeHeight, textStyle);
        break;
    }
  }

  void _drawTrianguloNumerico(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'INICIO', 'kind': 'oval', 'x': centerX, 'y': 30.0, 'color': Colors.blue.shade800},
      {'text': 'Leer N', 'kind': 'rectangle', 'x': centerX, 'y': 100.0, 'color': Colors.blue.shade600},
      {'text': 'i = 1', 'kind': 'rectangle', 'x': centerX, 'y': 170.0, 'color': Colors.blue.shade600},
      {'text': '¿i <= N?', 'kind': 'diamond', 'x': centerX, 'y': 240.0, 'color': Colors.orange},
      {'text': 'j = 1', 'kind': 'rectangle', 'x': centerX - 100, 'y': 310.0, 'color': Colors.blue.shade600},
      {'text': '¿j <= i?', 'kind': 'diamond', 'x': centerX - 100, 'y': 380.0, 'color': Colors.orange},
      {'text': 'Imprimir j', 'kind': 'rectangle', 'x': centerX - 180, 'y': 450.0, 'color': Colors.green.shade600},
      {'text': 'j++', 'kind': 'rectangle', 'x': centerX - 100, 'y': 520.0, 'color': Colors.blue.shade600},
      {'text': 'Imprimir \\n', 'kind': 'rectangle', 'x': centerX + 100, 'y': 380.0, 'color': Colors.green.shade600},
      {'text': 'i++', 'kind': 'rectangle', 'x': centerX + 100, 'y': 240.0, 'color': Colors.blue.shade600},
      {'text': 'FIN', 'kind': 'oval', 'x': centerX, 'y': 310.0, 'color': Colors.blue.shade800},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Conexiones
    _drawArrow(canvas, Offset(centerX, 30 + nodeHeight/2), Offset(centerX, 100 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 100 + nodeHeight/2), Offset(centerX, 170 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 170 + nodeHeight/2), Offset(centerX, 240 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 240 + nodeHeight/2), Offset(centerX - 100, 310 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 100, 310 + nodeHeight/2), Offset(centerX - 100, 380 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX - 100, 380 + nodeHeight/2), Offset(centerX - 180, 450 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 180, 450 + nodeHeight/2), Offset(centerX - 100, 520 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX - 100, 520 + nodeHeight/2), Offset(centerX - 100, 380 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX - 100, 380 + nodeHeight/2), Offset(centerX + 100, 380 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX + 100, 380 + nodeHeight/2), Offset(centerX + 100, 240 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 240 + nodeHeight/2), Offset(centerX, 310 - nodeHeight/2), arrowPaint, 'No', textStyle);
  }

  void  _drawValidadorPassword(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'INICIO', 'kind': 'oval', 'x': centerX, 'y': 30.0, 'color': Colors.blue.shade800},
      {'text': 'Leer password', 'kind': 'rectangle', 'x': centerX, 'y': 100.0, 'color': Colors.blue.shade600},
      {'text': '¿longitud < 8?', 'kind': 'diamond', 'x': centerX, 'y': 170.0, 'color': Colors.orange},
      {'text': 'Mostrar "Inválida"', 'kind': 'rectangle', 'x': centerX - 150, 'y': 240.0, 'color': Colors.red.shade600},
      {'text': 'tieneMayus = falso\ntieneNum = falso', 'kind': 'rectangle', 'x': centerX, 'y': 240.0, 'color': Colors.blue.shade600},
      {'text': 'Para cada c en password', 'kind': 'rectangle', 'x': centerX, 'y': 310.0, 'color': Colors.purple.shade600},
      {'text': '¿c es mayúscula?', 'kind': 'diamond', 'x': centerX - 100, 'y': 380.0, 'color': Colors.orange},
      {'text': 'tieneMayus = verdadero', 'kind': 'rectangle', 'x': centerX - 180, 'y': 450.0, 'color': Colors.blue.shade600},
      {'text': '¿c es número?', 'kind': 'diamond', 'x': centerX + 100, 'y': 380.0, 'color': Colors.orange},
      {'text': 'tieneNum = verdadero', 'kind': 'rectangle', 'x': centerX + 180, 'y': 450.0, 'color': Colors.blue.shade600},
      {'text': '¿tieneMayus y tieneNum?', 'kind': 'diamond', 'x': centerX, 'y': 520.0, 'color': Colors.orange},
      {'text': 'Mostrar "Válida"', 'kind': 'rectangle', 'x': centerX - 150, 'y': 590.0, 'color': Colors.green.shade600},
      {'text': 'Mostrar "Inválida"', 'kind': 'rectangle', 'x': centerX + 150, 'y': 590.0, 'color': Colors.red.shade600},
      {'text': 'FIN', 'kind': 'oval', 'x': centerX, 'y': 660.0, 'color': Colors.blue.shade800},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    _drawArrow(canvas, Offset(centerX, 30 + nodeHeight/2), Offset(centerX, 100 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 100 + nodeHeight/2), Offset(centerX, 170 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 170 + nodeHeight/2), Offset(centerX - 150, 240 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 150, 240 + nodeHeight/2), Offset(centerX, 660 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 170 + nodeHeight/2), Offset(centerX, 240 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 240 + nodeHeight/2), Offset(centerX, 310 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 310 + nodeHeight/2), Offset(centerX - 100, 380 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX - 100, 380 + nodeHeight/2), Offset(centerX - 180, 450 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 180, 450 + nodeHeight/2), Offset(centerX + 100, 380 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX - 100, 380 + nodeHeight/2), Offset(centerX + 100, 380 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX + 100, 380 + nodeHeight/2), Offset(centerX + 180, 450 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX + 180, 450 + nodeHeight/2), Offset(centerX, 520 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX + 100, 380 + nodeHeight/2), Offset(centerX, 520 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 520 + nodeHeight/2), Offset(centerX - 150, 590 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 520 + nodeHeight/2), Offset(centerX + 150, 590 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX - 150, 590 + nodeHeight/2), Offset(centerX, 660 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 590 + nodeHeight/2), Offset(centerX, 660 - nodeHeight/2), arrowPaint);
  }

  void _drawContadorVocales(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'INICIO', 'kind': 'oval', 'x': centerX, 'y': 30.0, 'color': Colors.blue.shade800},
      {'text': 'Leer texto', 'kind': 'rectangle', 'x': centerX, 'y': 100.0, 'color': Colors.blue.shade600},
      {'text': 'texto = texto.toLowerCase()', 'kind': 'rectangle', 'x': centerX, 'y': 170.0, 'color': Colors.blue.shade600},
      {'text': 'contador = 0', 'kind': 'rectangle', 'x': centerX, 'y': 240.0, 'color': Colors.blue.shade600},
      {'text': 'Para cada c en texto', 'kind': 'rectangle', 'x': centerX, 'y': 310.0, 'color': Colors.purple.shade600},
      {'text': '¿c es vocal?', 'kind': 'diamond', 'x': centerX, 'y': 380.0, 'color': Colors.orange},
      {'text': 'contador++', 'kind': 'rectangle', 'x': centerX, 'y': 450.0, 'color': Colors.blue.shade600},
      {'text': 'Mostrar contador', 'kind': 'rectangle', 'x': centerX, 'y': 520.0, 'color': Colors.green.shade600},
      {'text': 'FIN', 'kind': 'oval', 'x': centerX, 'y': 590.0, 'color': Colors.blue.shade800},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    _drawArrow(canvas, Offset(centerX, 30 + nodeHeight/2), Offset(centerX, 100 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 100 + nodeHeight/2), Offset(centerX, 170 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 170 + nodeHeight/2), Offset(centerX, 240 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 240 + nodeHeight/2), Offset(centerX, 310 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 310 + nodeHeight/2), Offset(centerX, 380 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 380 + nodeHeight/2), Offset(centerX, 450 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX, 450 + nodeHeight/2), Offset(centerX, 520 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 380 + nodeHeight/2), Offset(centerX, 520 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 520 + nodeHeight/2), Offset(centerX, 590 - nodeHeight/2), arrowPaint);
  }

  void _drawDefault(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle) {
    _drawNode(canvas, Offset(size.width/2, size.height/2), nodeWidth, nodeHeight, 'Diagrama no disponible', 'rectangle', Colors.red, textStyle);
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
        ..moveTo(center.dx, center.dy - height/2)
        ..lineTo(center.dx + width/2, center.dy)
        ..lineTo(center.dx, center.dy + height/2)
        ..lineTo(center.dx - width/2, center.dy)
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
    textPainter.paint(canvas, Offset(center.dx - textPainter.width/2, center.dy - textPainter.height/2));
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, start, end, paint);
  }

  void _drawArrowWithLabel(Canvas canvas, Offset start, Offset end, Paint paint, String label, TextStyle textStyle) {
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, start, end, paint);

    final midPoint = Offset((start.dx + end.dx)/2, (start.dy + end.dy)/2);
    final textSpan = TextSpan(text: label, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(midPoint.dx - textPainter.width/2, midPoint.dy - textPainter.height/2 - 10));
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 8.0;
    final direction = (end - start).direction;
    final p1 = end;
    final p2 = p1 - Offset.fromDirection(direction + 3.14/6, arrowSize);
    final p3 = p1 - Offset.fromDirection(direction - 3.14/6, arrowSize);
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