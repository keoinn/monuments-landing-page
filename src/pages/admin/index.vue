<script setup>
  import { computed, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // 所有管理功能配置
  const allMenuItems = [
    {
      id: 'announcements',
      title: '公告管理',
      description: '管理公告內容與附件',
      icon: 'mdi-bullhorn',
      color: 'primary',
      route: '/admin/announcements',
      roles: ['admin', 'user'], // 允許的角色
    },
    {
      id: 'history',
      title: '歷史沿革管理',
      description: '管理時間軸事件與歷史意義',
      icon: 'mdi-history',
      color: 'warning',
      route: '/admin/history',
      roles: ['admin', 'user'],
    },
    {
      id: 'directors',
      title: '委員會管理',
      description: '管理理事會成員、結構與會議行程',
      icon: 'mdi-account-tie',
      color: 'info',
      route: '/admin/directors',
      roles: ['admin', 'user'],
    },
    {
      id: 'organization',
      title: '組織架構管理',
      description: '管理部門資訊與組織架構圖',
      icon: 'mdi-office-building',
      color: 'purple',
      route: '/admin/organization',
      roles: ['admin', 'user'],
    },
    {
      id: 'public-affairs',
      title: '公務資訊管理',
      description: '管理表單文件與聯絡資訊',
      icon: 'mdi-file-document-multiple',
      color: 'teal',
      route: '/admin/public-affairs',
      roles: ['admin', 'user'],
    },
    {
      id: 'user',
      title: '用戶管理',
      description: '管理系統用戶與權限',
      icon: 'mdi-account-group',
      color: 'success',
      route: '/admin/user',
      roles: ['admin'], // 只有管理員可以訪問
    },
    {
      id: 'settings',
      title: '系統設定',
      description: '系統設定與配置',
      icon: 'mdi-cog',
      color: 'info',
      route: '/admin/settings',
      roles: ['admin'], // 只有管理員可以訪問
    },
  ]

  // 根據用戶角色過濾顯示的選單項目
  const visibleMenuItems = computed(() => {
    const userRole = authStore.userMetaInfo?.role || 'user'
    return allMenuItems.filter(item => item.roles.includes(userRole))
  })

  onMounted(async () => {
    // 初始化認證狀態
    await authStore.initAuth()

    // 如果未登入，導向登入頁面
    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
    }
  })
</script>

<template>
  <div>
    <v-container class="py-8">
      <v-row>
        <v-col cols="12">
          <h1 class="text-h3 font-weight-bold mb-4">管理後台</h1>
          <p class="text-body-1 text-medium-emphasis">
            歡迎使用管理後台系統
          </p>
        </v-col>
      </v-row>

      <v-row class="mt-4">
        <v-col
          v-for="item in visibleMenuItems"
          :key="item.id"
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
            @click="router.push(item.route)"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                :color="item.color"
                :icon="item.icon"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                {{ item.title }}
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                {{ item.description }}
              </p>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>
