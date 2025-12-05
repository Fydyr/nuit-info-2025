// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxt/image', '@nuxt/content', '@nuxt/ui', '@vueuse/nuxt'],
  build: {
    transpile: ['three']
  },
  nitro: {
    // This is critical: tells Nitro "Don't touch this, just let Node run it"
    externals: {
      external: ['node-llama-cpp'] 
    }
  }
})