// Copies the single-file build into the Flutter assets.
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const htmlPath = join(__dirname, '..', 'dist', 'index.html');
const assetDir = join(__dirname, '..', '..', 'assets', 'editor');

if (!existsSync(htmlPath)) {
  console.error('Missing dist/index.html. Run `npm run build` first.');
  process.exit(1);
}

mkdirSync(assetDir, { recursive: true });
// Inlined scripts don't need CORS mode; drop the attribute Vite adds.
const html = readFileSync(htmlPath, 'utf8').replaceAll(' crossorigin', '');
writeFileSync(join(assetDir, 'index.html'), html, 'utf8');
console.log(`Copied ${htmlPath} -> ${assetDir}/index.html`);
