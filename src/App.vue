<template>
  <v-app>
    <router-view />
  </v-app>
</template>

<script setup>
  import { onMounted } from 'vue'
  import { useAuthStore } from '@/stores/auth'

  const authStore = useAuthStore()

  // 應用啟動時初始化認證狀態
  onMounted(async () => {
    await authStore.initAuth()
  })
</script>
