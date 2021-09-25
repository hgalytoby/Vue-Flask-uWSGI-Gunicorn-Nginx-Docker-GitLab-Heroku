import {defineConfig} from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    plugins: [vue()],
    server: {
        proxy: {
            '/api1': {
                target: 'http://localhost:5000/',
                changeOrigin: true,
                rewrite: path => path.replace(/^\/api1/, 'api1/')
            },
            '/api2': {
                target: 'http://localhost:5001/',
                changeOrigin: true,
                rewrite: path => path.replace(/^\/api2/, 'api2/')
            },
        }
    }
})