import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (directory.existsSync()) {
    directory.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        final newContent = content.replaceAll(
          'package:flutter_supabase_order_app_mobile/',
          'package:numero_shastra/',
        );
        if (content != newContent) {
          entity.writeAsStringSync(newContent);
          print('Updated: ${entity.path}');
        }
      }
    });
  }
  
  final testDir = Directory('test');
  if (testDir.existsSync()) {
    testDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        final newContent = content.replaceAll(
          'package:flutter_supabase_order_app_mobile/',
          'package:numero_shastra/',
        );
        if (content != newContent) {
          entity.writeAsStringSync(newContent);
          print('Updated: ${entity.path}');
        }
      }
    });
  }
}
