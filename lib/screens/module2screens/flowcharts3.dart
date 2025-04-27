import 'package:flutter/material.dart';

class FlowCharts3 {
  static Widget getFlowChart(String id) {
    debugPrint('FlowCharts3.getFlowChart called with id: $id');
    switch (id) {
      case 'identificador_primos':
        return const StaticFlowChart3(type: FlowChartType3.identificadorPrimos);
      case 'conversor_temperaturas':
        return const StaticFlowChart3(type: FlowChartType3.conversorTemperaturas);
      default:
        debugPrint('Unknown flowchart ID: $id');
        return const StaticFlowChart3(type: FlowChartType3.defaultChart);
    }
  }
}

enum FlowChartType3 {
  identificadorPrimos,
  conversorTemperaturas,
  defaultChart,
}

class StaticFlowChart3 extends StatelessWidget {
  final FlowChartType3 type;

  const StaticFlowChart3({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final baseSize = _getBaseSize(type);
        final scale = [
          maxWidth / baseSize.width,
          maxHeight / baseSize.height,
          1.0
        ].reduce((a, b) => a < b ? a : b);

        debugPrint('StaticFlowChart3: type=$type, scale=$scale, size=${baseSize.width * scale}x${baseSize.height * scale}');
        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            painter: FlowChartPainter3(type: type),
            size: Size(baseSize.width, baseSize.height),
          ),
        );
      },
    );
  }

  Size _getBaseSize(FlowChartType3 type) {
    switch (type) {
      case FlowChartType3.identificadorPrimos:
        return const Size(600, 800);
      case FlowChartType3.conversorTemperaturas:
        return const Size(800, 1000);
      case FlowChartType3.defaultChart:
        return const Size(300, 200);
    }
  }
}

class FlowChartPainter3 extends CustomPainter {
  final FlowChartType3 type;

  FlowChartPainter3({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = 160.0;
    final nodeHeight = 70.0;
    final textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    debugPrint('FlowChartPainter3: Painting $type on canvas size ${size.width}x${size.height}');
    switch (type) {
      case FlowChartType3.identificadorPrimos:
        _drawIdentificadorPrimos(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType3.conversorTemperaturas:
        _drawConversorTemperaturas(canvas, size, nodeWidth, nodeHeight, textStyle, arrowPaint);
        break;
      case FlowChartType3.defaultChart:
        _drawDefault(canvas, size, nodeWidth, nodeHeight, textStyle);
        break;
    }
  }

  void _drawIdentificadorPrimos(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'INICIO', 'kind': 'oval', 'x': centerX, 'y': 50.0, 'color': Colors.blue.shade800},
      {'text': 'Leer num', 'kind': 'rectangle', 'x': centerX, 'y': 150.0, 'color': Colors.blue.shade600},
      {'text': '¿num < 2?', 'kind': 'diamond', 'x': centerX, 'y': 250.0, 'color': Colors.orange},
      {'text': 'Mostrar "No primo"', 'kind': 'rectangle', 'x': centerX - 200, 'y': 350.0, 'color': Colors.red.shade600},
      {'text': 'divisor = 2', 'kind': 'rectangle', 'x': centerX, 'y': 350.0, 'color': Colors.blue.shade600},
      {'text': '¿divisor*divisor <= num?', 'kind': 'diamond', 'x': centerX, 'y': 450.0, 'color': Colors.orange},
      {'text': '¿num % divisor == 0?', 'kind': 'diamond', 'x': centerX, 'y': 550.0, 'color': Colors.orange},
      {'text': 'Mostrar "No primo"', 'kind': 'rectangle', 'x': centerX - 200, 'y': 650.0, 'color': Colors.red.shade600},
      {'text': 'divisor++', 'kind': 'rectangle', 'x': centerX + 200, 'y': 550.0, 'color': Colors.blue.shade600},
      {'text': 'Mostrar "Primo"', 'kind': 'rectangle', 'x': centerX, 'y': 650.0, 'color': Colors.green.shade600},
      {'text': 'FIN', 'kind': 'oval', 'x': centerX, 'y': 750.0, 'color': Colors.blue.shade800},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Conexiones
    _drawArrow(canvas, Offset(centerX, 50 + nodeHeight/2), Offset(centerX, 150 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 150 + nodeHeight/2), Offset(centerX, 250 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 250 + nodeHeight/2), Offset(centerX - 200, 350 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 200, 350 + nodeHeight/2), Offset(centerX, 750 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 250 + nodeHeight/2), Offset(centerX, 350 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 350 + nodeHeight/2), Offset(centerX, 450 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 450 + nodeHeight/2), Offset(centerX, 550 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX - 200, 650 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrow(canvas, Offset(centerX - 200, 650 + nodeHeight/2), Offset(centerX, 750 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX + 200, 550 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX + 200, 550 + nodeHeight/2), Offset(centerX, 450 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 450 + nodeHeight/2), Offset(centerX, 650 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 650 + nodeHeight/2), Offset(centerX, 750 - nodeHeight/2), arrowPaint);
  }

  void _drawConversorTemperaturas(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle, Paint arrowPaint) {
    final centerX = size.width / 2;
    final nodes = [
      {'text': 'INICIO', 'kind': 'oval', 'x': centerX, 'y': 50.0, 'color': Colors.blue.shade800},
      {'text': 'Mostrar menú de opciones', 'kind': 'rectangle', 'x': centerX, 'y': 150.0, 'color': Colors.purple.shade600},
      {'text': 'Leer opcion', 'kind': 'rectangle', 'x': centerX, 'y': 250.0, 'color': Colors.blue.shade600},
      {'text': '¿opcion válida?', 'kind': 'diamond', 'x': centerX, 'y': 350.0, 'color': Colors.orange},
      {'text': 'Leer temperatura', 'kind': 'rectangle', 'x': centerX, 'y': 450.0, 'color': Colors.blue.shade600},
      {'text': 'SEGUN opcion', 'kind': 'diamond', 'x': centerX, 'y': 550.0, 'color': Colors.purple.shade400},
      {'text': 'C→F: (t*9/5)+32', 'kind': 'rectangle', 'x': centerX - 300, 'y': 650.0, 'color': Colors.blue.shade600},
      {'text': 'F→C: (t-32)*5/9', 'kind': 'rectangle', 'x': centerX - 150, 'y': 650.0, 'color': Colors.blue.shade600},
      {'text': 'C→K: t+273.15', 'kind': 'rectangle', 'x': centerX, 'y': 650.0, 'color': Colors.blue.shade600},
      {'text': 'K→C: t-273.15', 'kind': 'rectangle', 'x': centerX + 150, 'y': 650.0, 'color': Colors.blue.shade600},
      {'text': 'F→K: (t-32)*5/9+273.15', 'kind': 'rectangle', 'x': centerX - 300, 'y': 750.0, 'color': Colors.blue.shade600},
      {'text': 'K→F: (t-273.15)*9/5+32', 'kind': 'rectangle', 'x': centerX + 150, 'y': 750.0, 'color': Colors.blue.shade600},
      {'text': 'Mostrar resultado', 'kind': 'rectangle', 'x': centerX, 'y': 850.0, 'color': Colors.green.shade600},
      {'text': 'FIN', 'kind': 'oval', 'x': centerX, 'y': 950.0, 'color': Colors.blue.shade800},
    ];

    for (final node in nodes) {
      _drawNode(canvas, Offset(node['x'] as double, node['y'] as double), nodeWidth, nodeHeight, node['text'] as String, node['kind'] as String, node['color'] as Color, textStyle);
    }

    // Conexiones
    _drawArrow(canvas, Offset(centerX, 50 + nodeHeight/2), Offset(centerX, 150 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 150 + nodeHeight/2), Offset(centerX, 250 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 250 + nodeHeight/2), Offset(centerX, 350 - nodeHeight/2), arrowPaint);
    _drawArrowWithLabel(canvas, Offset(centerX, 350 + nodeHeight/2), Offset(centerX, 450 - nodeHeight/2), arrowPaint, 'Sí', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 350 + nodeHeight/2), Offset(centerX, 150 - nodeHeight/2), arrowPaint, 'No', textStyle);
    _drawArrow(canvas, Offset(centerX, 450 + nodeHeight/2), Offset(centerX, 550 - nodeHeight/2), arrowPaint);
    
    // Conexiones para el switch-case
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX - 300, 650 - nodeHeight/2), arrowPaint, '1', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX - 150, 650 - nodeHeight/2), arrowPaint, '2', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX, 650 - nodeHeight/2), arrowPaint, '3', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX + 150, 650 - nodeHeight/2), arrowPaint, '4', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX - 300, 750 - nodeHeight/2), arrowPaint, '5', textStyle);
    _drawArrowWithLabel(canvas, Offset(centerX, 550 + nodeHeight/2), Offset(centerX + 150, 750 - nodeHeight/2), arrowPaint, '6', textStyle);
    
    // Conexiones desde las operaciones al resultado
    _drawArrow(canvas, Offset(centerX - 300, 650 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX - 150, 650 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX, 650 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 650 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX - 300, 750 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    _drawArrow(canvas, Offset(centerX + 150, 750 + nodeHeight/2), Offset(centerX, 850 - nodeHeight/2), arrowPaint);
    
    _drawArrow(canvas, Offset(centerX, 850 + nodeHeight/2), Offset(centerX, 950 - nodeHeight/2), arrowPaint);
  }

  void _drawDefault(Canvas canvas, Size size, double nodeWidth, double nodeHeight, TextStyle textStyle) {
    _drawNode(canvas, Offset(size.width/2, size.height/2), nodeWidth, nodeHeight, 'Diagrama no disponible', 'rectangle', Colors.red, textStyle);
  }

  void _drawNode(Canvas canvas, Offset center, double width, double height, String text, String kind, Color color, TextStyle textStyle) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

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