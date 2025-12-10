/**
 * router/index.ts
 *
 * Automatic routes for `./src/pages/*.vue`
 */

import { setupLayouts } from 'virtual:generated-layouts'
// Composables
import { createRouter, createWebHistory } from 'vue-router/auto'
import { routes } from 'vue-router/auto-routes'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: setupLayouts(routes),
})

// 路由守衛：保護管理頁面
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // 初始化認證狀態（如果尚未初始化）
  if (!authStore.user && !authStore.loading) {
    await authStore.initAuth()
  }

  // 檢查是否為管理頁面
  if (to.path.startsWith('/admin')) {
    // 公開頁面（不需要認證）
    const publicPages = [
      '/admin/login',
      '/admin/register',
      '/admin/forgot-password',
      '/admin/reset-password',
    ]

    if (publicPages.includes(to.path)) {
      // 如果已登入，導向管理首頁
      if (authStore.isAuthenticated) {
        next('/admin')
      } else {
        next()
      }
    } else {
      // 其他管理頁面需要認證
      if (!authStore.isAuthenticated) {
        next('/admin/login')
      } else {
        next()
      }
    }
  } else {
    // 非管理頁面，直接通過
    next()
  }
})

// Workaround for https://github.com/vitejs/vite/issues/11804
router.onError((err, to) => {
  if (err?.message?.includes?.('Failed to fetch dynamically imported module')) {
    if (localStorage.getItem('vuetify:dynamic-reload')) {
      console.error('Dynamic import error, reloading page did not fix it', err)
    } else {
      console.log('Reloading page to fix dynamic import error')
      localStorage.setItem('vuetify:dynamic-reload', 'true')
      location.assign(to.fullPath)
    }
  } else {
    console.error(err)
  }
})

router.isReady().then(() => {
  localStorage.removeItem('vuetify:dynamic-reload')
})

export default router
