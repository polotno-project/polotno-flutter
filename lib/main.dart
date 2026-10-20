import 'dart:typed_data';

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
  Uint8List? _preview;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    // Read the bytes each time: the file keeps its path, so a cached image would go stale.
    final bytes = await (await DesignStorage.preview())?.readAsBytes();
    if (mounted) setState(() => _preview = bytes);
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
                  : Image.memory(_preview!, fit: BoxFit.contain, gaplessPlayback: true),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _openEditor, child: const Text('Open Editor')),
          ],
        ),
      ),
    );
  }
}
