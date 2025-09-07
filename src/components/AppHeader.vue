<template>
  <v-app-bar
    color="primary"
    dark
    elevation="0"
    height="80"
  >
    <v-container class="d-flex align-center">
      <!-- Logo -->
      <v-toolbar-title class="text-h4 font-weight-bold">
        古蹟介紹
      </v-toolbar-title>

      <!-- Navigation Links -->
      <v-spacer />
      <v-toolbar-items class="d-none d-md-flex">
        <v-btn
          v-for="item in navItems"
          :key="item.name"
          :to="item.to"
          variant="text"
          class="text-white mx-2"
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
          <v-list-item-title>{{ item.name }}</v-list-item-title>
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

