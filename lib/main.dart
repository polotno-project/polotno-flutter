import 'dart:io';

import 'package:flutter/material.dart';

import 'editor_screen.dart';
import 'storage.dart';

void main() => runApp(const PolotnoApp());

class PolotnoApp extends StatelessWidget {
  const PolotnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polotno + Flutter',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _preview;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final file = await DesignStorage.preview();
    // Drop the cached image so a new save shows up.
    if (file != null) await FileImage(file).evict();
    if (mounted) setState(() => _preview = file);
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
    await _refreshPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polotno + Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _preview == null
                  ? const Center(child: Text('Open the editor and tap Save to see a preview here.'))
                  : Image.file(_preview!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _openEditor, child: const Text('Open Editor')),
          ],
        ),
      ),
    );
  }
}
