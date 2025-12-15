<script setup>
  import { onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'

  // 使用無 layout 模式
  defineOptions({
    layout: false,
  })

  const router = useRouter()
  const authStore = useAuthStore()

  const email = ref('')
  const password = ref('')
  const confirmPassword = ref('')
  const name = ref('')
  const showPassword = ref(false)
  const showConfirmPassword = ref(false)
  const loading = ref(false)
  const error = ref(null)
  const success = ref(false)

  // 初始化認證狀態
  onMounted(async () => {
    await authStore.initAuth()

    // 如果已經登入，導向管理後台首頁
    if (authStore.isAuthenticated) {
      router.push('/admin')
    }
  })

  // 註冊處理
  async function handleRegister () {
    // 驗證
    if (!email.value || !password.value || !confirmPassword.value) {
      error.value = '請填寫所有必填欄位'
      return
    }

    if (password.value !== confirmPassword.value) {
      error.value = '兩次輸入的密碼不一致'
      return
    }

    if (password.value.length < 6) {
      error.value = '密碼長度至少需要 6 個字元'
      return
    }

    // 驗證電子郵件格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email.value)) {
      error.value = '請輸入有效的電子郵件地址'
      return
    }

    loading.value = true
    error.value = null
    success.value = false

    try {
      const result = await authStore.signUp(
        email.value,
        password.value,
        {
          name: name.value || email.value.split('@')[0],
        }
      )

      if (result.success) {
        if (result.needsEmailConfirmation) {
          // 需要確認郵件
          success.value = true
        } else {
          // 不需要確認郵件，直接登入
          router.push('/admin')
        }
      } else {
        error.value = result.error || '註冊失敗，請稍後再試'
      }
    } catch (err) {
      error.value = err.message || '註冊時發生錯誤'
    } finally {
      loading.value = false
    }
  }

  // 處理 Enter 鍵
  function handleKeyPress (event) {
    if (event.key === 'Enter') {
      handleRegister()
    }
  }
</script>

<template>
  <div class="register-container">
    <v-container class="fill-height d-flex align-center justify-center">
      <v-row justify="center" class="w-100">
        <v-col cols="12" sm="8" md="6" lg="4" xl="3">
          <v-card
            class="register-card"
            elevation="8"
            rounded="xl"
          >
            <v-card-text class="pa-8">
              <!-- Logo/標題 -->
              <div class="text-center mb-8">
                <v-icon
                  class="mb-4"
                  color="primary"
                  icon="mdi-account-plus"
                  size="64"
                />
                <h1 class="text-h4 font-weight-bold mb-2">
                  註冊帳號
                </h1>
                <p class="text-body-2 text-medium-emphasis">
                  建立新的管理帳號
                </p>
              </div>

              <!-- 成功訊息 -->
              <v-alert
                v-if="success"
                class="mb-6"
                color="success"
                type="success"
                variant="tonal"
              >
                <div class="mb-2">
                  <strong>註冊成功！</strong>
                </div>
                <div class="text-body-2">
                  我們已將確認郵件發送到 <strong>{{ email }}</strong>
                  <br>
                  請檢查您的郵件並點擊確認連結來啟用帳號。
                  <br>
                  確認後即可使用此帳號登入。
                </div>
              </v-alert>

              <!-- 錯誤訊息 -->
              <v-alert
                v-else-if="error"
                class="mb-6"
                color="error"
                type="error"
                variant="tonal"
                closable
                @click:close="error = null"
              >
                {{ error }}
              </v-alert>

              <!-- 註冊表單 -->
              <v-form
                v-if="!success"
                @submit.prevent="handleRegister"
              >
                <v-text-field
                  v-model="name"
                  class="mb-4"
                  label="姓名（選填）"
                  prepend-inner-icon="mdi-account"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="name"
                  @keypress="handleKeyPress"
                />

                <v-text-field
                  v-model="email"
                  class="mb-4"
                  label="電子郵件 *"
                  type="email"
                  prepend-inner-icon="mdi-email"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="email"
                  required
                  :rules="[
                    v => !!v || '請輸入電子郵件',
                    v => /.+@.+\..+/.test(v) || '請輸入有效的電子郵件地址'
                  ]"
                  @keypress="handleKeyPress"
                />

                <v-text-field
                  v-model="password"
                  class="mb-4"
                  label="密碼 *"
                  :type="showPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock"
                  :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="new-password"
                  required
                  :rules="[
                    v => !!v || '請輸入密碼',
                    v => (v && v.length >= 6) || '密碼長度至少需要 6 個字元'
                  ]"
                  @click:append-inner="showPassword = !showPassword"
                  @keypress="handleKeyPress"
                />

                <v-text-field
                  v-model="confirmPassword"
                  class="mb-6"
                  label="確認密碼 *"
                  :type="showConfirmPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock-check"
                  :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="new-password"
                  required
                  :rules="[
                    v => !!v || '請確認密碼',
                    v => v === password || '兩次輸入的密碼不一致'
                  ]"
                  @click:append-inner="showConfirmPassword = !showConfirmPassword"
                  @keypress="handleKeyPress"
                />

                <v-btn
                  block
                  color="primary"
                  size="large"
                  type="submit"
                  :loading="loading"
                  :disabled="loading || !email || !password || !confirmPassword"
                >
                  <span v-if="!loading">註冊</span>
                  <span v-else>註冊中...</span>
                </v-btn>
              </v-form>

              <!-- 分隔線 -->
              <v-divider class="my-6" />

              <!-- 登入連結 -->
              <div class="text-center">
                <p class="text-body-2 text-medium-emphasis mb-2">
                  已經有帳號了？
                </p>
                <v-btn
                  variant="text"
                  :disabled="loading"
                  @click="router.push('/admin/login')"
                >
                  前往登入
                </v-btn>
              </div>

              <!-- 返回首頁 -->
              <div class="text-center mt-4">
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
.register-container {
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

.register-card {
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95) !important;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.w-100 {
  width: 100%;
}

// 響應式調整
@media (max-width: 600px) {
  .register-card {
    margin: 16px;
  }
}
</style>




