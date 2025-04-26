import { defineConfig } from 'wxt';

// See https://wxt.dev/api/config.html
export default defineConfig({
  modules: ['@wxt-dev/module-react'],
  manifest: {
    "extension_pages": "script-src 'self' 'wasm-unsafe-eval' http://localhost:3000 https://accounts.google.com; object-src 'self'"
  },
});

