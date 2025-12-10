<script setup>
  import { computed, ref } from 'vue'
  import { useRouter, useRoute } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'

  const router = useRouter()
  const route = useRoute()
  const authStore = useAuthStore()

  const drawer = ref(false)

  // 導航選單
  const navItems = [
    {
      title: '儀表板',
      icon: 'mdi-view-dashboard',
      to: '/admin',
      exact: true,
    },
    {
      title: '公告管理',
      icon: 'mdi-bullhorn',
      to: '/admin/announcements',
    },
    {
      title: '用戶管理',
      icon: 'mdi-account-group',
      to: '/admin/users',
    },
    {
      title: '系統設定',
      icon: 'mdi-cog',
      to: '/admin/settings',
    },
  ]

  // 檢查當前路由是否為活動狀態
  const isActive = (item) => {
    if (item.exact) {
      return route.path === item.to
    }
    return route.path.startsWith(item.to)
  }

  // 登出處理
  async function handleLogout () {
    await authStore.signOut()
    router.push('/admin/login')
  }

  // 用戶資訊
  const userEmail = computed(() => authStore.user?.email || '')
  const userName = computed(() => authStore.user?.user_metadata?.name || userEmail.value)
</script>

<template>
  <v-app>
    <v-navigation-drawer
      v-model="drawer"
      :permanent="$vuetify.display.mdAndUp"
      location="left"
      width="280"
    >
      <div class="pa-4">
        <div class="d-flex align-center mb-4">
          <v-icon
            class="mr-2"
            color="primary"
            icon="mdi-shield-lock"
            size="32"
          />
          <h2 class="text-h6 font-weight-bold">
            管理後台
          </h2>
        </div>
      </div>

      <v-divider />

      <v-list density="compact" nav>
        <v-list-item
          v-for="item in navItems"
          :key="item.title"
          :active="isActive(item)"
          :prepend-icon="item.icon"
          :title="item.title"
          :to="item.to"
          @click="drawer = false"
        />
      </v-list>

      <template #append>
        <v-divider />
        <div class="pa-4">
          <div class="mb-2">
            <div class="text-caption text-medium-emphasis">
              登入為
            </div>
            <div class="text-body-2 font-weight-medium">
              {{ userName }}
            </div>
          </div>
          <v-btn
            block
            color="error"
            size="small"
            variant="outlined"
            @click="handleLogout"
          >
            <v-icon class="mr-2" icon="mdi-logout" />
            登出
          </v-btn>
        </div>
      </template>
    </v-navigation-drawer>

    <v-app-bar
      color="surface"
      elevation="1"
      height="64"
    >
      <v-app-bar-nav-icon
        v-if="$vuetify.display.smAndDown"
        @click="drawer = !drawer"
      />

      <v-toolbar-title class="text-h6 font-weight-bold">
        {{ route.meta?.title || '管理後台' }}
      </v-toolbar-title>

      <v-spacer />

      <v-menu>
        <template #activator="{ props }">
          <v-btn
            icon
            v-bind="props"
          >
            <v-avatar size="32">
              <v-icon icon="mdi-account" />
            </v-avatar>
          </v-btn>
        </template>

        <v-list>
          <v-list-item>
            <v-list-item-title class="text-body-2">
              {{ userName }}
            </v-list-item-title>
            <v-list-item-subtitle class="text-caption">
              {{ userEmail }}
            </v-list-item-subtitle>
          </v-list-item>
          <v-divider />
          <v-list-item
            prepend-icon="mdi-logout"
            title="登出"
            @click="handleLogout"
          />
        </v-list>
      </v-menu>
    </v-app-bar>

    <v-main>
      <v-container fluid class="pa-6">
        <router-view />
      </v-container>
    </v-main>
  </v-app>
</template>

<style scoped lang="scss">
// 管理後台樣式
</style>

