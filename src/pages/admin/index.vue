<script setup>
  import { onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

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
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
            @click="router.push('/admin/announcements')"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                color="primary"
                icon="mdi-bullhorn"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                公告管理
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                管理公告內容與附件
              </p>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
            @click="router.push('/admin/history')"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                color="warning"
                icon="mdi-history"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                歷史沿革管理
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                管理時間軸事件與歷史意義
              </p>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
            @click="router.push('/admin/directors')"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                color="info"
                icon="mdi-account-tie"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                委員會管理
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                管理理事會成員、結構與會議行程
              </p>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                color="success"
                icon="mdi-account-group"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                用戶管理
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                管理系統用戶與權限
              </p>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                color="info"
                icon="mdi-cog"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-2">
                系統設定
              </h3>
              <p class="text-body-2 text-medium-emphasis">
                系統設定與配置
              </p>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>
