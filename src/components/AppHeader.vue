<template>
  <v-app-bar
    color="primary"
    elevation="0"
    height="80"
  >
    <v-container class="d-flex align-center" style="min-width: 0; flex-wrap: nowrap;">
      <!-- Logo -->
      <v-toolbar-title class="text-h3 font-weight-black header-title" style="white-space: nowrap; overflow: visible; padding-right: 20px;">
        青錢萬選
      </v-toolbar-title>

      <!-- Navigation Links -->
      <v-spacer />
      <v-toolbar-items class="d-none d-md-flex">
        <v-btn
          v-for="item in navItems"
          :key="item.name"
          :to="item.to"
          variant="text"
          class="mx-1 header-menu"
          size="large"
        >
          {{ item.name }}
        </v-btn>
      </v-toolbar-items>

      <!-- Mobile Menu Button -->
      <v-btn
        class="d-md-none"
        icon
        @click="drawer = !drawer"
      >
        <v-icon>mdi-menu</v-icon>
      </v-btn>
    </v-container>

    <!-- Mobile Navigation Drawer -->
    <v-navigation-drawer
      v-model="drawer"
      temporary
      location="right"
      width="300"
    >
      <v-list>
        <v-list-item
          v-for="item in navItems"
          :key="item.name"
          :to="item.to"
          @click="drawer = false"
        >
          <v-list-item-title class="header-menu-mobile">{{ item.name }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
  </v-app-bar>
</template>

<script setup>
import { ref } from 'vue'

const drawer = ref(false)

const navItems = [
  { name: '首頁', to: '/' },
  { name: '沿革', to: '/history' },
  { name: '組織', to: '/organization' },
  { name: '理事公', to: '/directors' },
  { name: '公務', to: '/public-affairs' },
  { name: '公告', to: '/announcements' }
]
</script>

<style scoped>
/* Header 字體樣式 - 與 hero-title 保持一致 */
.header-title {
  font-family: 'Noto Serif TC', serif !important;
  letter-spacing: 0.05em;
  white-space: nowrap !important;
  overflow: visible !important;
  min-width: fit-content !important;
  flex-shrink: 0 !important;
  padding-right: 30px !important;
  margin-right: 15px !important;
  font-size: 2.5rem !important;
  line-height: 1.2 !important;
  font-weight: 900 !important;
}

.header-menu {
  font-family: 'Noto Serif TC', serif !important;
  letter-spacing: 0.05em;
  font-weight: 700 !important;
  font-size: 1rem !important;
}

.header-menu-mobile {
  font-family: 'Noto Serif TC', serif !important;
  letter-spacing: 0.05em;
  font-weight: 700 !important;
  font-size: 1rem !important;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .header-title {
    font-size: 2rem !important;
    padding-right: 20px !important;
    margin-right: 10px !important;
  }
}

@media (max-width: 480px) {
  .header-title {
    font-size: 1.8rem !important;
    padding-right: 15px !important;
    margin-right: 8px !important;
  }
}
</style>

