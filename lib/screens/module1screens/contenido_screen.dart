import 'package:flutter/material.dart';

class ContenidoScreen extends StatefulWidget {
final Map<String, dynamic> moduleData;

const ContenidoScreen({Key? key, required this.moduleData}) : super(key: key);

@override
_ContenidoScreenState createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends State<ContenidoScreen> with SingleTickerProviderStateMixin {
late AnimationController _animationController;
late Animation<double> _fadeAnimation;
double _progress = 0.0;

@override
void initState() {
super.initState();
_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 500),
);
_fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
);
_animationController.forward();
}

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

void _updateProgress(int completedSections, int totalSections) {
setState(() {
_progress = completedSections / totalSections;
});
}

@override
Widget build(BuildContext context) {
final content = widget.moduleData['content'] as Map<String, dynamic>? ?? {};

return Scaffold(
appBar: AppBar(
title: Text(
widget.moduleData['module_title'] ?? 'Contenido del Módulo',
style: const TextStyle(fontWeight: FontWeight.bold),
),
backgroundColor: Colors.deepPurple,
),
body: FadeTransition(
opacity: _fadeAnimation,
child: content.isEmpty
? const Center(
child: Text(
'No hay contenido disponible',
style: TextStyle(fontSize: 18, color: Colors.grey),
),
)
: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Text(
'Selecciona una sección:',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
const SizedBox(height: 20),
...content.keys.map((sectionKey) {
final section = content[sectionKey];
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: ElevatedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => SectionDetailScreen(
section: section,
sectionTitle: section['title'],
sectionIndex: content.keys.toList().indexOf(sectionKey),
totalSections: content.length,
content: content,
moduleData: widget.moduleData,
onComplete: (index) {
_updateProgress(index + 1, content.length);
},
),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: Text(
section['title'],
style: const TextStyle(fontSize: 18),
),
),
);
}).toList(),
const Spacer(),
Padding(
padding: const EdgeInsets.symmetric(vertical: 16.0),
child: Column(
children: [
Text(
'Progreso: ${(_progress * 100).toStringAsFixed(0)}%',
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
LinearProgressIndicator(
value: _progress,
backgroundColor: Colors.grey[300],
valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
minHeight: 8,
),
],
),
),
],
),
),
),
);
}
}

class SectionDetailScreen extends StatelessWidget {
final Map<String, dynamic> section;
final String sectionTitle;
final int sectionIndex;
final int totalSections;
final Map<String, dynamic> content;
final Map<String, dynamic> moduleData;
final Function(int) onComplete;

const SectionDetailScreen({
Key? key,
required this.section,
required this.sectionTitle,
required this.sectionIndex,
required this.totalSections,
required this.content,
required this.moduleData,
required this.onComplete,
}) : super(key: key);

static final Map<String, String> _sectionImages = {
'lenguaje_programacion': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'hardware_software': 'https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'bajo_alto_nivel': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'pensamiento_logico': 'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'diagramas_flujo': 'https://images.unsplash.com/photo-1547658719-da2b51169166?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'hardware_components': 'https://images.unsplash.com/photo-1591488320449-011701bb6704?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'software_types': 'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'low_level': 'https://images.unsplash.com/photo-1563986768609-322da13575f3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'flowchart_example': 'https://images.unsplash.com/photo-1614680376573-df3480f0c6ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
'os_layers': 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
};

String _getImageForSection(String title) {
if (title.toLowerCase().contains('lenguaje')) return _sectionImages['lenguaje_programacion']!;
if (title.toLowerCase().contains('hardware') || title.toLowerCase().contains('software')) return _sectionImages['hardware_software']!;
if (title.toLowerCase().contains('nivel')) return _sectionImages['bajo_alto_nivel']!;
if (title.toLowerCase().contains('pensamiento')) return _sectionImages['pensamiento_logico']!;
if (title.toLowerCase().contains('diagrama')) return _sectionImages['diagramas_flujo']!;
return _sectionImages['lenguaje_programacion']!;
}

Widget _buildNetworkImageWithCaption(String imageUrl, String caption, {double height = 220}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 16),
child: Column(
children: [
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: Image.network(
imageUrl,
height: height,
width: double.infinity,
fit: BoxFit.cover,
loadingBuilder: (context, child, loadingProgress) {
if (loadingProgress == null) return child;
return Container(
height: height,
color: Colors.grey[200],
child: Center(
child: CircularProgressIndicator(
value: loadingProgress.expectedTotalBytes != null
? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
: null,
),
),
);
},
errorBuilder: (context, error, stackTrace) {
return Container(
height: height,
color: Colors.grey[200],
child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
);
},
),
),
const SizedBox(height: 8),
Text(
caption,
style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
textAlign: TextAlign.center,
),
],
),
);
}

List<Widget> _formatContent(String content) {
return content.split('\n').map((paragraph) {
if (paragraph.trim().isEmpty) return const SizedBox(height: 12);
if (paragraph.startsWith('•') || paragraph.startsWith('1.')) {
return Padding(
padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.circle, size: 8, color: Colors.deepPurple.withOpacity(0.7)),
const SizedBox(width: 12),
Expanded(
child: Text(
paragraph.substring(paragraph.startsWith('•') ? 1 : 2).trim(),
style: const TextStyle(fontSize: 16, height: 1.6),
textAlign: TextAlign.justify,
),
),
],
),
);
}
if (paragraph.startsWith('[') && paragraph.endsWith(']')) {
return Container(
margin: const EdgeInsets.symmetric(vertical: 12),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.grey[100],
borderRadius: BorderRadius.circular(8),
border: Border.all(color: Colors.grey[300]!),
),
child: Text(
paragraph.substring(1, paragraph.length - 1),
style: const TextStyle(fontSize: 15, fontFamily: 'monospace', color: Colors.deepPurple),
),
);
}
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8),
child: Text(
paragraph,
style: const TextStyle(fontSize: 16, height: 1.6),
textAlign: TextAlign.justify,
),
);
}).toList();
}

@override
Widget build(BuildContext context) {
final subsections = section['subsections'] as List<dynamic>? ?? [];

return WillPopScope(
onWillPop: () async {
// When the back button is pressed, reload ContenidoScreen
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => ContenidoScreen(moduleData: moduleData),
),
);
return false; // Prevent default back behavior since we handled it
},
child: Scaffold(
appBar: AppBar(
title: Text(
sectionTitle,
style: const TextStyle(fontWeight: FontWeight.bold),
),
backgroundColor: Colors.deepPurple,
leading: IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () {
// When the AppBar back button is pressed, reload ContenidoScreen
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => ContenidoScreen(moduleData: moduleData),
),
);
},
),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildNetworkImageWithCaption(
_getImageForSection(sectionTitle),
sectionTitle,
height: 200,
),
const SizedBox(height: 20),
...subsections.expand((subsection) {
final title = subsection['title'] as String;
final content = subsection['content'] as String;
final highlight = subsection['highlight'] as Map<String, dynamic>?;
final additionalContent = subsection['additional_content'] as String?;

List<Widget> widgets = [
Padding(
padding: const EdgeInsets.symmetric(vertical: 12),
child: Text(
title,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
),
..._formatContent(content),
];

if (title.toLowerCase().contains('hardware')) {
widgets.insert(
0,
_buildNetworkImageWithCaption(
_sectionImages['hardware_components']!,
'Componentes principales del hardware',
),
);
} else if (title.toLowerCase().contains('software')) {
widgets.insert(
0,
_buildNetworkImageWithCaption(
_sectionImages['software_types']!,
'Diferentes tipos de software',
),
);
} else if (title.toLowerCase().contains('bajo nivel')) {
widgets.insert(
0,
_buildNetworkImageWithCaption(
_sectionImages['low_level']!,
'Lenguajes de bajo nivel interactuando con hardware',
),
);
} else if (title.toLowerCase().contains('diagrama')) {
widgets.insert(
0,
_buildNetworkImageWithCaption(
_sectionImages['flowchart_example']!,
'Ejemplo práctico de diagrama de flujo',
),
);
}

if (highlight != null) {
widgets.add(
Container(
margin: const EdgeInsets.symmetric(vertical: 16),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: highlight['color'] == 'blue' ? Colors.blue[50] : Colors.green[50],
border: Border(
left: BorderSide(
color: highlight['color'] == 'blue' ? Colors.blue : Colors.green,
width: 4,
),
),
borderRadius: BorderRadius.circular(8),
),
child: Column(
children: [
if (highlight['text'].toLowerCase().contains('sistema operativo'))
_buildNetworkImageWithCaption(
_sectionImages['os_layers']!,
'Capas de un sistema operativo',
height: 180,
),
Text(
highlight['text'],
style: const TextStyle(fontSize: 16),
),
],
),
),
);
}

if (additionalContent != null) {
widgets.addAll(_formatContent(additionalContent));
}

return widgets;
}).toList(),
const SizedBox(height: 30),
Center(
child: ElevatedButton(
onPressed: () {
onComplete(sectionIndex);
if (sectionIndex < totalSections - 1) {
final nextSectionIndex = sectionIndex + 1;
final nextSectionKey = content.keys.elementAt(nextSectionIndex);
final nextSectionData = content[nextSectionKey];
// Replace the current screen with the next section
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => SectionDetailScreen(
section: nextSectionData,
sectionTitle: nextSectionData['title'],
sectionIndex: nextSectionIndex,
totalSections: totalSections,
content: content,
moduleData: moduleData,
onComplete: onComplete,
),
),
);
} else {
// When "Volver al Inicio" is pressed, reload ContenidoScreen
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => ContenidoScreen(moduleData: moduleData),
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: Text(
sectionIndex < totalSections - 1 ? 'Siguiente Sección' : 'Volver al Inicio',
style: const TextStyle(fontSize: 18),
),
),
),
],
),
),
),
);
}
}