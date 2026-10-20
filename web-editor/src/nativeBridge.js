// Bridge to the Flutter app. Dart registers the `PolotnoFlutter` JavaScript
// channel and calls `window.polotnoNative.*` with runJavaScript().
// Messages to Dart: { type: 'ready' | 'save' | 'export' | 'error', ... }

// Channel messages are strings, so they travel as JSON.
const post = (message) => window.PolotnoFlutter?.postMessage(JSON.stringify(message));

const base64Of = (dataUrl) => dataUrl.split(',')[1];

// The app waits for a reply to every request, so failures are reported too.
const replying = (task) => async (...args) => {
  try {
    await task(...args);
  } catch (error) {
    console.error('[polotnoNative]', error);
    post({ type: 'error', message: String(error?.message || error) });
  }
};

export const connectNativeBridge = (store) => {
  window.polotnoNative = {
    load: (json) => store.loadJSON(json),

    save: replying(async () => {
      const preview = await store.toDataURL({ pixelRatio: 0.5 });
      post({
        type: 'save',
        docJson: JSON.stringify(store.toJSON()),
        previewBase64: base64Of(preview),
      });
    }),

    export: replying(async (format) => {
      const dataUrl =
        format === 'pdf'
          ? await store.toPDFDataURL()
          : await store.toDataURL({ pageId: store.activePage?.id });
      post({ type: 'export', format, base64: base64Of(dataUrl) });
    }),
  };

  // Ask Dart for the initial design now that `load` exists.
  post({ type: 'ready' });
};
