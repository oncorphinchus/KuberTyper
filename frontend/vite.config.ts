import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  
  // Development server configuration
  server: {
    port: 3000,
    host: true, // Allow external connections
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
      '/socket.io': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        ws: true, // Enable WebSocket proxying
      },
    },
  },
  
  // Build configuration
  build: {
    target: 'esnext',
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['socket.io-client'],
        },
      },
    },
  },
  
  // Preview server (for production preview)
  preview: {
    port: 3000,
    host: true,
  },
  
  // Define global constants
  define: {
    __APP_VERSION__: JSON.stringify('1.0.0'),
  },
}) 