<script setup>
  import { computed, ref } from 'vue'
  import { useRouter, useRoute } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import { getRoleDisplayText } from '@/utils/roleHelper'

  const router = useRouter()
  const route = useRoute()
  const authStore = useAuthStore()

  const drawer = ref(false)

  // 所有導航選單項目
  const allNavItems = [
    {
      title: '儀表板',
      icon: 'mdi-view-dashboard',
      to: '/admin',
      exact: true,
      roles: ['admin', 'user'], // 所有角色都可以訪問儀表板
    },
    {
      title: '公告管理',
      icon: 'mdi-bullhorn',
      to: '/admin/announcements',
      roles: ['admin', 'user'],
    },
    {
      title: '歷史沿革管理',
      icon: 'mdi-history',
      to: '/admin/history',
      roles: ['admin', 'user'],
    },
    {
      title: '委員會管理',
      icon: 'mdi-account-tie',
      to: '/admin/directors',
      roles: ['admin', 'user'],
    },
    {
      title: '組織架構管理',
      icon: 'mdi-office-building',
      to: '/admin/organization',
      roles: ['admin', 'user'],
    },
    {
      title: '公務資訊管理',
      icon: 'mdi-file-document-multiple',
      to: '/admin/public-affairs',
      roles: ['admin', 'user'],
    },
    {
      title: '用戶管理',
      icon: 'mdi-account-group',
      to: '/admin/user',
      roles: ['admin'], // 只有管理員可以訪問
    },
    {
      title: '系統設定',
      icon: 'mdi-cog',
      to: '/admin/settings',
      roles: ['admin'], // 只有管理員可以訪問
    },
  ]

  // 根據用戶角色過濾顯示的導航選單項目
  const navItems = computed(() => {
    const userRole = authStore.userMetaInfo?.role || 'user'
    return allNavItems.filter(item => item.roles.includes(userRole))
  })

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
  const userName = computed(() => authStore.userName)
  const userRole = computed(() => {
    if (!authStore.userMetaInfo) return ''
    return getRoleDisplayText(authStore.userMetaInfo.role)
  })
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
            <div v-if="userRole" class="mt-1">
              <v-chip
                :color="authStore.userMetaInfo?.role === 'admin' ? 'error' : 'primary'"
                size="small"
                variant="tonal"
              >
                {{ userRole }}
              </v-chip>
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
            <v-list-item-subtitle v-if="userRole" class="text-caption mt-1">
              <v-chip
                :color="authStore.userMetaInfo?.role === 'admin' ? 'error' : 'primary'"
                size="x-small"
                variant="tonal"
              >
                {{ userRole }}
              </v-chip>
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

