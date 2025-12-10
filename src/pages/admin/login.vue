<script setup>
  import { onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'

  // 使用無 layout 模式（登入頁面不需要管理後台的 layout）
  defineOptions({
    layout: false,
  })

  const router = useRouter()
  const authStore = useAuthStore()

  const email = ref('')
  const password = ref('')
  const showPassword = ref(false)
  const loading = ref(false)
  const error = ref(null)
  const rememberMe = ref(false)

  // 初始化認證狀態
  onMounted(async () => {
    await authStore.initAuth()
    
    // 如果已經登入，導向管理後台首頁
    if (authStore.isAuthenticated) {
      router.push('/admin')
    }
  })

  // 登入處理
  async function handleLogin () {
    if (!email.value || !password.value) {
      error.value = '請輸入電子郵件和密碼'
      return
    }

    loading.value = true
    error.value = null

    try {
      const result = await authStore.signIn(email.value, password.value)

      if (result.success) {
        // 登入成功，導向管理後台
        router.push('/admin')
      } else {
        error.value = result.error || '登入失敗，請檢查您的帳號密碼'
      }
    } catch (err) {
      error.value = err.message || '登入時發生錯誤'
    } finally {
      loading.value = false
    }
  }

  // 處理 Enter 鍵
  function handleKeyPress (event) {
    if (event.key === 'Enter') {
      handleLogin()
    }
  }
</script>

<template>
  <div class="login-container">
    <v-container class="fill-height d-flex align-center justify-center">
      <v-row justify="center" class="w-100">
        <v-col cols="12" sm="8" md="6" lg="4" xl="3">
          <v-card
            class="login-card"
            elevation="8"
            rounded="xl"
          >
            <v-card-text class="pa-8">
              <!-- Logo/標題 -->
              <div class="text-center mb-8">
                <v-icon
                  class="mb-4"
                  color="primary"
                  icon="mdi-shield-lock"
                  size="64"
                />
                <h1 class="text-h4 font-weight-bold mb-2">
                  管理後台登入
                </h1>
                <p class="text-body-2 text-medium-emphasis">
                  請使用您的帳號登入管理系統
                </p>
              </div>

              <!-- 錯誤訊息 -->
              <v-alert
                v-if="error"
                class="mb-6"
                color="error"
                type="error"
                variant="tonal"
                closable
                @click:close="error = null"
              >
                {{ error }}
              </v-alert>

              <!-- 登入表單 -->
              <v-form @submit.prevent="handleLogin">
                <v-text-field
                  v-model="email"
                  class="mb-4"
                  label="電子郵件"
                  type="email"
                  prepend-inner-icon="mdi-email"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="email"
                  @keypress="handleKeyPress"
                />

                <v-text-field
                  v-model="password"
                  class="mb-4"
                  label="密碼"
                  :type="showPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock"
                  :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="current-password"
                  @click:append-inner="showPassword = !showPassword"
                  @keypress="handleKeyPress"
                />

                <div class="d-flex align-center justify-space-between mb-6">
                  <v-checkbox
                    v-model="rememberMe"
                    label="記住我"
                    hide-details
                    :disabled="loading"
                  />
                  <v-btn
                    variant="text"
                    size="small"
                    :disabled="loading"
                    @click="router.push('/admin/forgot-password')"
                  >
                    忘記密碼？
                  </v-btn>
                </div>

                <v-btn
                  block
                  color="primary"
                  size="large"
                  type="submit"
                  :loading="loading"
                  :disabled="loading || !email || !password"
                >
                  <span v-if="!loading">登入</span>
                  <span v-else>登入中...</span>
                </v-btn>
              </v-form>

              <!-- 分隔線 -->
              <v-divider class="my-6" />

              <!-- 註冊連結 -->
              <div class="text-center mb-4">
                <p class="text-body-2 text-medium-emphasis mb-2">
                  還沒有帳號？
                </p>
                <v-btn
                  variant="text"
                  :disabled="loading"
                  @click="router.push('/admin/register')"
                >
                  立即註冊
                </v-btn>
              </div>

              <!-- 返回首頁 -->
              <div class="text-center">
                <v-btn
                  variant="text"
                  size="small"
                  :disabled="loading"
                  @click="router.push('/')"
                >
                  <v-icon class="mr-2" icon="mdi-arrow-left" />
                  返回首頁
                </v-btn>
              </div>
            </v-card-text>
          </v-card>

          <!-- 版權資訊 -->
          <div class="text-center mt-4">
            <p class="text-caption text-medium-emphasis">
              © 2024 青錢萬選 - 萬選居 管理系統
            </p>
          </div>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<style scoped lang="scss">
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: 
      radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
      radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
    pointer-events: none;
  }
}

.login-card {
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95) !important;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.w-100 {
  width: 100%;
}

// 響應式調整
@media (max-width: 600px) {
  .login-card {
    margin: 16px;
  }
}
</style>

