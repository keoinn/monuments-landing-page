<script setup>
  import { computed, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import { getRoleDisplayText } from '@/utils/roleHelper'

  const router = useRouter()
  const authStore = useAuthStore()

  const drawer = ref(false)
  const userMenu = ref(false)

  // 讀取環境變數中的 baseURL
  const baseURL = '/'

  const navItems = [
    { name: '首頁', to: '/' },
    { name: '沿革', to: '/history' },
    { name: '組織', to: '/organization' },
    { name: '委員會', to: '/directors' },
    { name: '公務', to: '/public-affairs' },
    { name: '公告', to: '/announcements' },
  ]

  // 用戶資訊
  const userEmail = computed(() => authStore.user?.email || '')
  const userName = computed(() => authStore.userName)
  const userRole = computed(() => {
    if (!authStore.userMetaInfo) return ''
    return getRoleDisplayText(authStore.userMetaInfo.role)
  })

  // 登出處理
  async function handleLogout () {
    await authStore.signOut()
    userMenu.value = false
    router.push('/')
  }

  // 前往管理後台
  function goToAdmin () {
    userMenu.value = false
    router.push('/admin')
  }

  // 前往登入頁面
  function goToLogin () {
    router.push('/admin/login')
  }
</script>

<template>
  <v-app-bar
    color="primary"
    elevation="0"
    height="80"
    style="z-index: 1000;"
  >
    <v-container class="d-flex align-center" style="min-width: 0; flex-wrap: nowrap;">
      <!-- Logo -->
      <v-toolbar-title class="text-h3 font-weight-black header-title" style="white-space: nowrap; overflow: visible; padding-right: 20px;">
        <router-link class="header-logo-link" :to="baseURL">
          青錢萬選
        </router-link>
      </v-toolbar-title>

      <!-- Navigation Links -->
      <v-spacer />
      <v-toolbar-items class="d-none d-md-flex">
        <v-btn
          v-for="item in navItems"
          :key="item.name"
          class="mx-1 header-menu"
          size="large"
          :to="item.to"
          variant="text"
        >
          {{ item.name }}
        </v-btn>
      </v-toolbar-items>

      <!-- User Button (Desktop) -->
      <div class="d-none d-md-flex align-center ml-4">
        <!-- 未登入：顯示登入按鈕 -->
        <v-btn
          v-if="!authStore.isAuthenticated"
          class="header-menu"
          color="white"
          size="large"
          variant="outlined"
          @click="goToLogin"
        >
          <v-icon class="mr-2" icon="mdi-login" />
          登入
        </v-btn>

        <!-- 已登入：顯示用戶選單 -->
        <v-menu
          v-else
          v-model="userMenu"
          location="bottom end"
        >
          <template #activator="{ props }">
            <v-btn
              class="header-menu"
              color="white"
              size="large"
              variant="text"
              v-bind="props"
            >
              <v-avatar
                class="mr-2"
                size="32"
              >
                <v-icon icon="mdi-account" />
              </v-avatar>
              {{ userName }}
              <v-icon class="ml-2" icon="mdi-chevron-down" />
            </v-btn>
          </template>

          <v-list>
            <v-list-item>
              <v-list-item-title class="text-body-2 font-weight-bold">
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
              prepend-icon="mdi-view-dashboard"
              title="管理後台"
              @click="goToAdmin"
            />
            <v-list-item
              prepend-icon="mdi-logout"
              title="登出"
              @click="handleLogout"
            />
          </v-list>
        </v-menu>
      </div>

      <!-- Mobile Menu Button -->
      <v-btn
        class="d-md-none"
        icon
        @click="drawer = !drawer"
      >
        <v-icon icon="mdi-menu" />
      </v-btn>
    </v-container>

    <!-- Mobile Navigation Drawer -->
    <v-navigation-drawer
      v-model="drawer"
      location="right"
      style="z-index: 1005 !important; height: 100vh !important;"
      temporary
      width="300"
    >
      <v-list class="pa-0" style="height: 100%;">
        <v-list-item
          v-for="item in navItems"
          :key="item.name"
          class="py-4"
          :to="item.to"
          @click="drawer = false"
        >
          <v-list-item-title class="header-menu-mobile">{{ item.name }}</v-list-item-title>
        </v-list-item>

        <!-- Mobile User Section -->
        <v-divider class="my-4" />

        <!-- 未登入：顯示登入按鈕 -->
        <v-list-item
          v-if="!authStore.isAuthenticated"
          class="py-4"
          @click="goToLogin(); drawer = false"
        >
          <template #prepend>
            <v-icon icon="mdi-login" />
          </template>
          <v-list-item-title class="header-menu-mobile">登入</v-list-item-title>
        </v-list-item>

        <!-- 已登入：顯示用戶資訊和選項 -->
        <template v-else>
          <v-list-item class="py-4">
            <template #prepend>
              <v-avatar size="40">
                <v-icon icon="mdi-account" />
              </v-avatar>
            </template>
            <v-list-item-title class="header-menu-mobile font-weight-bold">
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
          <v-list-item
            class="py-4"
            @click="goToAdmin(); drawer = false"
          >
            <template #prepend>
              <v-icon icon="mdi-view-dashboard" />
            </template>
            <v-list-item-title class="header-menu-mobile">管理後台</v-list-item-title>
          </v-list-item>
          <v-list-item
            class="py-4"
            @click="handleLogout(); drawer = false"
          >
            <template #prepend>
              <v-icon icon="mdi-logout" />
            </template>
            <v-list-item-title class="header-menu-mobile">登出</v-list-item-title>
          </v-list-item>
        </template>
      </v-list>
    </v-navigation-drawer>
  </v-app-bar>
</template>

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

/* Logo 連結樣式 */
.header-logo-link {
  color: inherit !important;
  text-decoration: none !important;
  transition: opacity 0.3s ease;
}

.header-logo-link:hover {
  opacity: 0.8;
  text-decoration: none !important;
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

/* 確保手機版選單正確顯示 */
.v-navigation-drawer--mobile {
  height: 100vh !important;
  min-height: 100vh !important;
}

.v-navigation-drawer__content {
  height: 100% !important;
  min-height: 100% !important;
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
