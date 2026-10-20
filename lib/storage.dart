import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the latest saved design and its preview in the app's documents directory.
class DesignStorage {
  static Future<File> _file(String name) async =>
      File('${(await getApplicationDocumentsDirectory()).path}/$name');

  static Future<String> loadDesign() async {
    final file = await _file('design.json');
    if (await file.exists()) return file.readAsString();
    return rootBundle.loadString('assets/sample_design.json');
  }

  static Future<void> save(String docJson, String previewBase64) async {
    await (await _file('design.json')).writeAsString(docJson);
    await (await _file('preview.png')).writeAsBytes(base64Decode(previewBase64));
  }

  static Future<File?> preview() async {
    final file = await _file('preview.png');
    return await file.exists() ? file : null;
  }

  /// Writes an export to the temp directory and returns its path.
  static Future<String> writeExport(String format, String base64) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/design-${DateTime.now().millisecondsSinceEpoch}.$format');
    await file.writeAsBytes(base64Decode(base64));
    return file.path;
  }
}
