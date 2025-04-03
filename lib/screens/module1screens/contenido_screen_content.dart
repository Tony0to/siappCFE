import 'package:flutter/material.dart';

class ContenidoScreenContent {
  // URLs de imágenes de Unsplash
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

  static void scrollToSection(int index, Map<String, dynamic> content, Map<String, GlobalKey> sectionKeys) {
    final sectionKey = content.keys.elementAt(index);
    final context = sectionKeys[sectionKey]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuint,
      );
    }
  }

  static String _getImageForSection(String title) {
    if (title.toLowerCase().contains('lenguaje')) return _sectionImages['lenguaje_programacion']!;
    if (title.toLowerCase().contains('hardware') || title.toLowerCase().contains('software')) return _sectionImages['hardware_software']!;
    if (title.toLowerCase().contains('nivel')) return _sectionImages['bajo_alto_nivel']!;
    if (title.toLowerCase().contains('pensamiento')) return _sectionImages['pensamiento_logico']!;
    if (title.toLowerCase().contains('diagrama')) return _sectionImages['diagramas_flujo']!;
    return _sectionImages['lenguaje_programacion']!;
  }

  static Widget buildSection(Map<String, dynamic> section, {GlobalKey? key, required Animation<double> fadeAnimation}) {
    final imageUrl = _getImageForSection(section['title']);

    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.deepPurple.withOpacity(0.4), BlendMode.darken),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (key?.currentContext != null) {
                      Scrollable.ensureVisible(
                        key!.currentContext!,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      section['title'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._buildSubsections(section['subsections'] ?? []),
          const SizedBox(height: 40),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static List<Widget> _buildSubsections(List<dynamic> subsections) {
    return subsections.map<Widget>((subsection) {
      final additionalContent = subsection['additional_content'] != null ? _formatContent(subsection['additional_content']) : <Widget>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subsection['title'].toLowerCase().contains('hardware'))
            _buildNetworkImageWithCaption(_sectionImages['hardware_components']!, 'Componentes principales del hardware'),
          if (subsection['title'].toLowerCase().contains('software'))
            _buildNetworkImageWithCaption(_sectionImages['software_types']!, 'Diferentes tipos de software'),
          if (subsection['title'].toLowerCase().contains('bajo nivel'))
            _buildNetworkImageWithCaption(_sectionImages['low_level']!, 'Lenguajes de bajo nivel interactuando con hardware'),
          if (subsection['title'].toLowerCase().contains('diagrama'))
            _buildNetworkImageWithCaption(_sectionImages['flowchart_example']!, 'Ejemplo práctico de diagrama de flujo'),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.deepPurpleAccent, width: 4)),
            ),
            child: Text(
              subsection['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
          ),
          const SizedBox(height: 12),
          ..._formatContent(subsection['content']),
          if (subsection['highlight'] != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: subsection['highlight']['color'] == 'blue' ? Colors.blue[50] : Colors.green[50],
                border: Border(left: BorderSide(color: subsection['highlight']['color'] == 'blue' ? Colors.blue : Colors.green, width: 4)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(2, 2))],
              ),
              child: Column(
                children: [
                  if (subsection['highlight']['text'].toLowerCase().contains('sistema operativo'))
                    _buildNetworkImageWithCaption(_sectionImages['os_layers']!, 'Capas de un sistema operativo', height: 180),
                  const SizedBox(height: 12),
                  Text(subsection['highlight']['text'], style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ...additionalContent,
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  static Widget _buildNetworkImageWithCaption(String imageUrl, String caption, {double height = 220}) {
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

  static List<Widget> _formatContent(String content) {
    return content.split('\n').map((paragraph) {
      if (paragraph.trim().isEmpty) return const SizedBox(height: 12);
      if (paragraph.startsWith('•') || paragraph.startsWith('1.'))
        return Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 8, color: Colors.deepPurple.withOpacity(0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  paragraph.substring(1).trim(),
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      if (paragraph.startsWith('[') && paragraph.endsWith(']'))
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 2))],
          ),
          child: Text(
            paragraph,
            style: const TextStyle(fontSize: 15, fontFamily: 'monospace', color: Colors.deepPurple),
          ),
        );
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
}