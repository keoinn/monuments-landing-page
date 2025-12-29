<script setup>
  import { computed, onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'
  import { getRoleDisplayText, getRoleOptions } from '@/utils/roleHelper'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // 用戶列表相關
  const users = ref([])
  const usersLoading = ref(false)
  const usersError = ref(null)
  const showUserDeleteDialog = ref(false)
  const userToDelete = ref(null)

  // 搜尋
  const searchQuery = ref('')

  // 編輯用戶對話框（主要管理 user_meta_info：姓名與角色）
  const showUserFormDialog = ref(false)
  const userFormLoading = ref(false)
  const userFormError = ref(null)
  const userForm = ref({
    id: null,
    email: '',
    full_name: '',
    role: '',
    email_confirmed_at: null,
    created_at: null,
    last_sign_in_at: null,
  })
  const userFormErrors = ref({})

  // 分頁
  const currentPage = ref(1)
  const itemsPerPage = 50

  // 計算屬性：篩選後的用戶列表
  const filteredUsers = computed(() => {
    let filtered = users.value

    if (searchQuery.value.trim()) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(user => {
        const email = user.email?.toLowerCase() || ''
        const fullName = user.user_metadata?.full_name?.toLowerCase() || ''
        return email.includes(query) || fullName.includes(query)
      })
    }

    return filtered.sort((a, b) => {
      // 按創建時間降序排序
      const dateA = new Date(a.created_at || 0)
      const dateB = new Date(b.created_at || 0)
      return dateB - dateA
    })
  })

  // 計算屬性：分頁後的用戶列表
  const paginatedUsers = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage
    const end = start + itemsPerPage
    return filteredUsers.value.slice(start, end)
  })

  // 計算屬性：總頁數
  const totalPages = computed(() => {
    return Math.ceil(filteredUsers.value.length / itemsPerPage)
  })

  // 格式化日期
  function formatDate (dateString) {
    if (!dateString) return '-'
    const date = new Date(dateString)
    return date.toLocaleString('zh-TW', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  // 從 Supabase 載入用戶列表
  async function loadUsers () {
    usersLoading.value = true
    usersError.value = null

    try {
      const { data, error: fetchError } = await supabase.rpc('get_users_list')

      if (fetchError) {
        throw new Error(`無法載入用戶列表，請先在 Supabase 執行 RPC 函數 get_users_list。錯誤：${fetchError.message}`)
      }

      const userRows = data || []
      const userIds = userRows.map(user => user.id)

      // 從 user_meta_info 載入對應的姓名與角色
      let metaMap = {}
      if (userIds.length > 0) {
        const { data: metaData, error: metaError } = await supabase
          .from('user_meta_info')
          .select('*')
          .in('user_id', userIds)

        if (metaError) {
          throw metaError
        }

        metaMap = (metaData || []).reduce((acc, meta) => {
          acc[meta.user_id] = meta
          return acc
        }, {})
      }

      // 將 auth.users 與 user_meta_info 合併
      users.value = userRows.map(user => ({
        ...user,
        user_meta: metaMap[user.id] || null,
      }))
    } catch (error_) {
      console.error('載入用戶失敗:', error_)
      usersError.value = error_.message || '載入用戶時發生錯誤'
    } finally {
      usersLoading.value = false
    }
  }

  // 開啟編輯用戶表單
  function openEditUserForm (user) {
    userForm.value = {
      id: user.id,
      email: user.email || '',
      full_name: user.user_meta?.full_name || '',
      role: user.user_meta?.role || '',
      email_confirmed_at: user.email_confirmed_at,
      created_at: user.created_at,
      last_sign_in_at: user.last_sign_in_at,
    }
    userFormErrors.value = {}
    userFormError.value = null
    showUserFormDialog.value = true
  }

  // 驗證用戶表單
  function validateUserForm () {
    // 目前僅管理姓名與角色，沒有必填限制
    userFormErrors.value = {}
    return true
  }

  // 提交用戶表單（更新 user_meta_info 的姓名與角色）
  async function submitUserForm () {
    if (!validateUserForm()) {
      userFormError.value = '請填寫所有必填欄位'
      return
    }

    userFormLoading.value = true
    userFormError.value = null

    try {
      const payload = {
        user_id: userForm.value.id,
        full_name: userForm.value.full_name?.trim() || null,
        role: userForm.value.role?.trim() || null,
      }

      const { error: upsertError } = await supabase
        .from('user_meta_info')
        .upsert(payload)

      if (upsertError) throw upsertError

      await loadUsers()
      showUserFormDialog.value = false
    } catch (error_) {
      console.error('更新用戶失敗:', error_)
      userFormError.value = error_.message || '更新用戶時發生錯誤'
    } finally {
      userFormLoading.value = false
    }
  }

  // 開啟刪除確認對話框
  function openDeleteUserDialog (user) {
    userToDelete.value = user
    showUserDeleteDialog.value = true
  }

  // 確認刪除用戶
  async function confirmDeleteUser () {
    if (!userToDelete.value) return

    try {
      usersLoading.value = true
      usersError.value = null

      // 僅刪除 user_meta_info 中的姓名與角色，不刪除 auth.users
      const { error: deleteError } = await supabase
        .from('user_meta_info')
        .delete()
        .eq('user_id', userToDelete.value.id)

      if (deleteError) throw deleteError

      await loadUsers()
      showUserDeleteDialog.value = false
      userToDelete.value = null
    } catch (error_) {
      console.error('刪除用戶失敗:', error_)
      usersError.value = error_.message || '刪除用戶時發生錯誤'
    } finally {
      usersLoading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(async () => {
    await authStore.initAuth()

    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    await loadUsers()
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-h4 font-weight-bold mb-2">
        用戶管理
      </h1>
      <p class="text-body-2 text-medium-emphasis">
        管理系統用戶資訊與權限
      </p>
    </div>

    <!-- 用戶列表卡片 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            用戶列表
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            查看和管理所有系統用戶
          </p>
        </div>
      </v-card-title>

      <v-divider />

      <!-- 搜尋欄 -->
      <v-card-text>
        <v-text-field
          v-model="searchQuery"
          clearable
          label="搜尋用戶（電子郵件或姓名）"
          prepend-inner-icon="mdi-magnify"
          variant="outlined"
        />
      </v-card-text>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="usersError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="usersError = null"
      >
        {{ usersError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="usersLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 用戶列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              電子郵件
            </th>
            <th class="text-left">
              姓名
            </th>
            <th class="text-left">
              角色
            </th>
            <th class="text-left">
              電子郵件確認
            </th>
            <th class="text-left">
              最後登入
            </th>
            <th class="text-left">
              建立時間
            </th>
            <th class="text-right">
              操作
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="user in paginatedUsers"
            :key="user.id"
          >
            <td>{{ user.email || '-' }}</td>
            <td>{{ user.user_meta?.full_name || '-' }}</td>
            <td>
              <v-chip
                :color="user.user_meta?.role === 'admin' ? 'error' : 'primary'"
                size="small"
                variant="tonal"
              >
                {{ getRoleDisplayText(user.user_meta?.role || 'user') }}
              </v-chip>
            </td>
            <td>
              <v-icon
                :color="user.email_confirmed_at ? 'success' : 'warning'"
                :icon="user.email_confirmed_at ? 'mdi-check-circle' : 'mdi-alert-circle'"
                size="small"
              />
              <span class="ml-1 text-caption">
                {{ user.email_confirmed_at ? '已確認' : '未確認' }}
              </span>
            </td>
            <td>
              <span class="text-body-2">{{ formatDate(user.last_sign_in_at) }}</span>
            </td>
            <td>
              <span class="text-body-2">{{ formatDate(user.created_at) }}</span>
            </td>
            <td class="text-right">
              <v-btn
                class="mr-2"
                icon
                size="small"
                variant="text"
                @click="openEditUserForm(user)"
              >
                <v-icon icon="mdi-pencil" />
              </v-btn>
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openDeleteUserDialog(user)"
              >
                <v-icon icon="mdi-delete" />
              </v-btn>
            </td>
          </tr>
          <tr v-if="paginatedUsers.length === 0">
            <td class="text-center py-8 text-medium-emphasis" colspan="7">
              {{ searchQuery ? '沒有找到符合條件的用戶' : '沒有用戶資料' }}
            </td>
          </tr>
        </tbody>
      </v-table>

      <!-- 分頁 -->
      <v-card-actions v-if="totalPages > 1" class="justify-center">
        <v-pagination
          v-model="currentPage"
          color="primary"
          :length="totalPages"
          :total-visible="7"
        />
      </v-card-actions>

      <!-- 統計資訊 -->
      <v-card-text class="pt-0">
        <div class="text-caption text-medium-emphasis">
          顯示 {{ paginatedUsers.length }} / {{ filteredUsers.length }} 位用戶
          <span v-if="searchQuery">（已篩選）</span>
        </div>
      </v-card-text>
    </v-card>

    <!-- 編輯用戶對話框 -->
    <v-dialog
      v-model="showUserFormDialog"
      max-width="600"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          編輯用戶
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="userFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="userFormError = null"
          >
            {{ userFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="userForm.email"
                  label="電子郵件 *"
                  readonly
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="userForm.full_name"
                  label="姓名"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-select
                  v-model="userForm.role"
                  item-title="text"
                  item-value="value"
                  :items="getRoleOptions()"
                  label="角色"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-card
                  class="pa-3"
                  color="surface-variant"
                  variant="tonal"
                >
                  <div class="text-caption text-medium-emphasis mb-1">
                    用戶 ID
                  </div>
                  <code class="text-caption">{{ userForm.id }}</code>
                </v-card>
              </v-col>
              <v-col cols="12">
                <v-card
                  class="pa-3"
                  color="surface-variant"
                  variant="tonal"
                >
                  <div class="text-caption text-medium-emphasis mb-1">
                    建立時間
                  </div>
                  <div class="text-body-2">
                    {{ formatDate(userForm.created_at) }}
                  </div>
                </v-card>
              </v-col>
            </v-row>
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showUserFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="userFormLoading"
            variant="flat"
            @click="submitUserForm"
          >
            更新
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 刪除確認對話框 -->
    <v-dialog
      v-model="showUserDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除用戶
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <p class="mb-4">
            您確定要刪除此用戶嗎？此操作無法復原。
          </p>
          <v-card
            v-if="userToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ userToDelete.email }}
            </div>
            <div v-if="userToDelete.user_meta?.full_name" class="text-caption text-medium-emphasis">
              姓名：{{ userToDelete.user_meta.full_name }}
            </div>
            <div class="text-caption text-medium-emphasis mt-1">
              角色：{{ getRoleDisplayText(userToDelete.user_meta?.role || 'user') }}
            </div>
          </v-card>
          <p class="mt-4 text-error">
            此操作無法復原！
          </p>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showUserDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            :loading="usersLoading"
            variant="flat"
            @click="confirmDeleteUser"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<style scoped>
code {
  background-color: rgba(var(--v-theme-on-surface), 0.05);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}
</style>
