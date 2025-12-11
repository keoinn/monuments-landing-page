<script setup>
  import { onMounted, ref } from 'vue'
  import { useRouter, useRoute } from 'vue-router'
  import { supabase } from '@/lib/supabaseClient'

  // 使用無 layout 模式
  defineOptions({
    layout: false,
  })

  const router = useRouter()
  const route = useRoute()

  const password = ref('')
  const confirmPassword = ref('')
  const showPassword = ref(false)
  const showConfirmPassword = ref(false)
  const loading = ref(false)
  const error = ref(null)
  const success = ref(false)

  // 檢查是否有有效的 session（從重設密碼連結來的）
  onMounted(async () => {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      error.value = '無效的重設密碼連結，請重新申請'
    }
  })

  // 重設密碼
  async function handleResetPassword () {
    if (!password.value || !confirmPassword.value) {
      error.value = '請輸入新密碼'
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

    loading.value = true
    error.value = null
    success.value = false

    try {
      const { error: updateError } = await supabase.auth.updateUser({
        password: password.value,
      })

      if (updateError) throw updateError

      success.value = true

      // 3 秒後導向登入頁面
      setTimeout(() => {
        router.push('/admin/login')
      }, 3000)
    } catch (err) {
      error.value = err.message || '重設密碼失敗'
    } finally {
      loading.value = false
    }
  }
</script>

<template>
  <div class="reset-password-container">
    <v-container class="fill-height d-flex align-center justify-center">
      <v-row justify="center" class="w-100">
        <v-col cols="12" sm="8" md="6" lg="4" xl="3">
          <v-card
            class="reset-password-card"
            elevation="8"
            rounded="xl"
          >
            <v-card-text class="pa-8">
              <!-- Logo/標題 -->
              <div class="text-center mb-8">
                <v-icon
                  class="mb-4"
                  color="primary"
                  icon="mdi-lock-reset"
                  size="64"
                />
                <h1 class="text-h4 font-weight-bold mb-2">
                  重設密碼
                </h1>
                <p class="text-body-2 text-medium-emphasis">
                  請輸入您的新密碼
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
                  <strong>密碼重設成功！</strong>
                </div>
                <div class="text-body-2">
                  正在導向登入頁面...
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

              <!-- 表單 -->
              <v-form
                v-if="!success"
                @submit.prevent="handleResetPassword"
              >
                <v-text-field
                  v-model="password"
                  class="mb-4"
                  label="新密碼"
                  :type="showPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock"
                  :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="new-password"
                  :rules="[
                    v => !!v || '請輸入新密碼',
                    v => (v && v.length >= 6) || '密碼長度至少需要 6 個字元'
                  ]"
                  @click:append-inner="showPassword = !showPassword"
                />

                <v-text-field
                  v-model="confirmPassword"
                  class="mb-6"
                  label="確認新密碼"
                  :type="showConfirmPassword ? 'text' : 'password'"
                  prepend-inner-icon="mdi-lock-check"
                  :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
                  variant="outlined"
                  :disabled="loading"
                  autocomplete="new-password"
                  :rules="[
                    v => !!v || '請確認新密碼',
                    v => v === password || '兩次輸入的密碼不一致'
                  ]"
                  @click:append-inner="showConfirmPassword = !showConfirmPassword"
                />

                <v-btn
                  block
                  color="primary"
                  size="large"
                  type="submit"
                  :loading="loading"
                  :disabled="loading || !password || !confirmPassword"
                >
                  <span v-if="!loading">重設密碼</span>
                  <span v-else>處理中...</span>
                </v-btn>
              </v-form>

              <!-- 分隔線 -->
              <v-divider class="my-6" />

              <!-- 返回連結 -->
              <div class="text-center">
                <v-btn
                  variant="text"
                  :disabled="loading"
                  @click="router.push('/admin/login')"
                >
                  <v-icon class="mr-2" icon="mdi-arrow-left" />
                  返回登入
                </v-btn>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<style scoped lang="scss">
.reset-password-container {
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

.reset-password-card {
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95) !important;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.w-100 {
  width: 100%;
}

// 響應式調整
@media (max-width: 600px) {
  .reset-password-card {
    margin: 16px;
  }
}
</style>


