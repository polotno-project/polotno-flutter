# Polotno Flutter Demo

Flutter app that embeds the Polotno editor (React + Vite) in a `webview_flutter` WebView. The app passes design JSON to the editor, receives the saved design and a PNG preview back, and exports PNG and PDF to the system share sheet.

## Prerequisites

- Flutter 3.22+
- Xcode with an iOS simulator, or Android Studio with an emulator
- Node.js 20+ and npm (for building the web editor)

## Project layout

| Path                       | Role                                                            |
| -------------------------- | --------------------------------------------------------------- |
| `lib/main.dart`            | Home screen with the last saved preview and **Open Editor**      |
| `lib/editor_screen.dart`   | App bar (PNG, PDF, Save), the WebView, the `PolotnoFlutter` channel, the Android file picker |
| `lib/storage.dart`         | Latest design and preview in app storage, export files          |
| `assets/sample_design.json`| Design the editor opens before the first save                   |
| `web-editor/`              | Vite React app that hosts the Polotno editor                     |

## Building the embedded editor

```bash
cd web-editor
npm install
npm run build:flutter
```

`build:flutter` runs `vite build` with `vite-plugin-singlefile` and copies the one-file editor to `assets/editor/index.html`. Run it again after changing anything in `web-editor/`.

> **Note:** Set your Polotno API key before building. Create one at [polotno.com/cabinet](https://polotno.com/cabinet), then add `VITE_POLOTNO_KEY=your-key` to `web-editor/.env.local`. In the cabinet, add `localhost` to the key's allowed domains: the app loads the editor with `baseUrl: 'http://localhost/'`, so that is the origin it runs on. Change `editorOrigin` in `lib/editor_screen.dart` to use your own domain instead.

## Running the app

```bash
flutter pub get
flutter run
```

Tap **Open Editor**. **Save** posts `{ docJson, previewBase64 }` to Dart; the home screen shows the returned PNG and the next session starts from the saved design. **PNG** and **PDF** export the current design and open the share sheet.

## How it works

- **Bundled editor.** Dart reads the asset with `rootBundle.loadString()` and loads it with `loadHtmlString(html, baseUrl: editorOrigin)`. Nothing is fetched to start the editor, and `baseUrl` gives the page a regular `http` origin for the license check.
- **Dart → editor.** `controller.runJavaScript('window.polotnoNative.save()')`.
- **Editor → Dart.** `addJavaScriptChannel('PolotnoFlutter', …)` creates `window.PolotnoFlutter` in the page; the editor calls `window.PolotnoFlutter.postMessage(JSON.stringify(message))`.
- **Handshake.** The editor posts `{ type: "ready" }` once `window.polotnoNative` exists. Dart answers with `load(<design JSON>)`.
- **Exports.** The editor's toolbar download button is hidden in the app, because a browser download does nothing in a WebView. Exports cross the channel as base64; the app writes them to the temp directory and opens them with `share_plus`.

## Image uploads

Polotno's Upload panel uses `<input type="file">`. iOS opens the system picker on its own. On Android the WebView ignores the input until the app supplies the files: `lib/editor_screen.dart` registers `AndroidWebViewController.setOnShowFileSelector()` and picks images with `image_picker`.

Docs: https://polotno.com/docs/flutter
