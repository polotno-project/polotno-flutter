import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'storage.dart';

/// The page's origin. Add it to your API key's allowed domains in the Polotno cabinet.
const editorOrigin = 'http://localhost/';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final WebViewController _controller;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // The channel name becomes `window.PolotnoFlutter` in the page.
      ..addJavaScriptChannel('PolotnoFlutter', onMessageReceived: _onMessage);
    _loadEditor();
  }

  Future<void> _loadEditor() async {
    final html = await rootBundle.loadString('assets/editor/index.html');
    await _controller.loadHtmlString(html, baseUrl: editorOrigin);
  }

  Future<void> _onMessage(JavaScriptMessage message) async {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    try {
      switch (data['type']) {
        case 'ready':
          // A JSON document is a valid JavaScript object literal.
          final design = await DesignStorage.loadDesign();
          await _controller.runJavaScript('window.polotnoNative.load($design)');
        case 'save':
          await DesignStorage.save(data['docJson'] as String, data['previewBase64'] as String);
          if (mounted) Navigator.of(context).pop(true);
        case 'export':
          final format = data['format'] as String;
          final path = await DesignStorage.writeExport(format, data['base64'] as String);
          setState(() => _busy = null);
          await _share(path, format);
        case 'error':
          _fail(data['message'] as String);
      }
    } catch (error) {
      _fail('$error');
    }
  }

  Future<void> _share(String path, String format) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      files: [XFile(path, mimeType: format == 'pdf' ? 'application/pdf' : 'image/png')],
      // Required on iPad: where the share popover points.
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _busy = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _run(String label, String code) {
    setState(() => _busy = label);
    _controller.runJavaScript(code);
  }

  @override
  Widget build(BuildContext context) {
    final idle = _busy == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          if (!idle)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          TextButton(
            onPressed: idle ? () => _run('png', "window.polotnoNative.export('png')") : null,
            child: const Text('PNG'),
          ),
          TextButton(
            onPressed: idle ? () => _run('pdf', "window.polotnoNative.export('pdf')") : null,
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: idle ? () => _run('save', 'window.polotnoNative.save()') : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
