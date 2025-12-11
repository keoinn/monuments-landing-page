<script setup>
  import { computed, onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  const announcements = ref([])
  const loading = ref(false)
  const error = ref(null)
  const searchQuery = ref('')
  const selectedCategory = ref('')
  const showDeleteDialog = ref(false)
  const announcementToDelete = ref(null)

  // 分類選項
  const categories = [
    { value: '', text: '全部分類' },
    { value: '工程公告', text: '工程公告' },
    { value: '活動訊息', text: '活動訊息' },
    { value: '服務異動', text: '服務異動' },
    { value: '法規更新', text: '法規更新' },
    { value: '人事異動', text: '人事異動' },
  ]

  // 從 Supabase 獲取公告列表
  async function loadAnnouncements () {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('announcements')
        .select(`
          *,
          announcement_attachments (
            id,
            file_name,
            file_url,
            file_size,
            file_type,
            display_order
          )
        `)
        .order('date', { ascending: false })
        .order('created_at', { ascending: false })

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      announcements.value = data || []
    } catch (err) {
      console.error('載入公告失敗:', err)
      error.value = err.message || '載入公告時發生錯誤'
    } finally {
      loading.value = false
    }
  }

  // 篩選後的公告列表
  const filteredAnnouncements = computed(() => {
    let filtered = announcements.value

    // 搜尋篩選
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(announcement =>
        announcement.title?.toLowerCase().includes(query)
        || announcement.content?.toLowerCase().includes(query)
        || announcement.author?.toLowerCase().includes(query),
      )
    }

    // 分類篩選
    if (selectedCategory.value) {
      filtered = filtered.filter(announcement =>
        announcement.category === selectedCategory.value,
      )
    }

    return filtered
  })

  // 刪除公告
  async function deleteAnnouncement (announcement) {
    announcementToDelete.value = announcement
    showDeleteDialog.value = true
  }

  async function confirmDelete () {
    if (!announcementToDelete.value) return

    try {
      loading.value = true
      error.value = null

      // 刪除附件（如果有的話）
      if (announcementToDelete.value.announcement_attachments?.length > 0) {
        const storagePaths = announcementToDelete.value.announcement_attachments
          .map(att => att.storage_path)
          .filter(Boolean)

        if (storagePaths.length > 0) {
          const { error: storageError } = await supabase.storage
            .from('wanxuanju-files')
            .remove(storagePaths)

          if (storageError) {
            console.error('刪除附件檔案失敗:', storageError)
          }
        }
      }

      // 刪除公告（CASCADE 會自動刪除相關附件記錄）
      const { error: deleteError } = await supabase
        .from('announcements')
        .delete()
        .eq('id', announcementToDelete.value.id)

      if (deleteError) throw deleteError

      // 重新載入列表
      await loadAnnouncements()
      showDeleteDialog.value = false
      announcementToDelete.value = null
    } catch (err) {
      console.error('刪除公告失敗:', err)
      error.value = err.message || '刪除公告時發生錯誤'
    } finally {
      loading.value = false
    }
  }

  // 格式化日期
  function formatDate (date) {
    if (!date) return ''
    const d = new Date(date)
    return d.toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    })
  }

  // 格式化檔案大小
  function formatFileSize (bytes) {
    if (!bytes) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  // 獲取狀態顏色
  function getStatusColor (status) {
    const statusColorMap = {
      進行中: 'info',
      已結束: 'default',
      最新: 'success',
    }
    return statusColorMap[status] || 'info'
  }

  // 元件掛載時載入資料
  onMounted(async () => {
    await authStore.initAuth()

    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    await loadAnnouncements()
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題和操作按鈕 -->
    <div class="d-flex align-center justify-space-between mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          公告管理
        </h1>
        <p class="text-body-2 text-medium-emphasis">
          管理所有公告內容與附件
        </p>
      </div>
      <v-btn
        color="primary"
        prepend-icon="mdi-plus"
        @click="router.push('/admin/announcements/new')"
      >
        新增公告
      </v-btn>
    </div>

    <!-- 錯誤訊息 -->
    <v-alert
      v-if="error"
      class="mb-4"
      color="error"
      type="error"
      variant="tonal"
      closable
      @click:close="error = null"
    >
      {{ error }}
    </v-alert>

    <!-- 搜尋和篩選 -->
    <v-card class="mb-4" elevation="2">
      <v-card-text>
        <v-row>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="searchQuery"
              label="搜尋公告"
              prepend-inner-icon="mdi-magnify"
              variant="outlined"
              density="compact"
              clearable
              hide-details
            />
          </v-col>
          <v-col cols="12" md="6">
            <v-select
              v-model="selectedCategory"
              :items="categories"
              item-title="text"
              item-value="value"
              label="分類篩選"
              variant="outlined"
              density="compact"
              clearable
              hide-details
            />
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- 載入中 -->
    <div v-if="loading" class="text-center py-12">
      <v-progress-circular
        color="primary"
        indeterminate
        size="64"
      />
      <p class="mt-4 text-body-1 text-medium-emphasis">
        載入中...
      </p>
    </div>

    <!-- 公告列表 -->
    <v-card v-else elevation="2">
      <v-table>
        <thead>
          <tr>
            <th class="text-left">
              標題
            </th>
            <th class="text-left">
              分類
            </th>
            <th class="text-left">
              發布者
            </th>
            <th class="text-left">
              日期
            </th>
            <th class="text-center">
              狀態
            </th>
            <th class="text-center">
              瀏覽次數
            </th>
            <th class="text-center">
              附件
            </th>
            <th class="text-center">
              重要
            </th>
            <th class="text-center">
              操作
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-if="filteredAnnouncements.length === 0"
            class="text-center"
          >
            <td colspan="9" class="py-8 text-medium-emphasis">
              目前沒有公告
            </td>
          </tr>
          <tr
            v-for="announcement in filteredAnnouncements"
            :key="announcement.id"
          >
            <td>
              <div class="font-weight-medium">
                {{ announcement.title }}
              </div>
              <div class="text-caption text-medium-emphasis mt-1">
                {{ announcement.content?.substring(0, 50) }}...
              </div>
            </td>
            <td>
              <v-chip
                :color="announcement.color || 'primary'"
                size="small"
                variant="tonal"
              >
                {{ announcement.category }}
              </v-chip>
            </td>
            <td>
              {{ announcement.author }}
            </td>
            <td>
              {{ formatDate(announcement.date) }}
            </td>
            <td class="text-center">
              <v-chip
                :color="getStatusColor(announcement.status)"
                size="small"
                variant="tonal"
              >
                {{ announcement.status || '進行中' }}
              </v-chip>
            </td>
            <td class="text-center">
              {{ announcement.views || 0 }}
            </td>
            <td class="text-center">
              <v-chip
                v-if="announcement.announcement_attachments?.length > 0"
                color="info"
                size="small"
                variant="tonal"
              >
                {{ announcement.announcement_attachments.length }} 個
              </v-chip>
              <span v-else class="text-medium-emphasis">-</span>
            </td>
            <td class="text-center">
              <v-icon
                v-if="announcement.is_important"
                color="error"
                icon="mdi-star"
              />
              <span v-else class="text-medium-emphasis">-</span>
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="router.push(`/admin/announcements/${announcement.id}/edit`)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
              <v-btn
                icon
                size="small"
                variant="text"
                color="error"
                @click="deleteAnnouncement(announcement)"
              >
                <v-icon icon="mdi-delete" />
                <v-tooltip activator="parent">
                  刪除
                </v-tooltip>
              </v-btn>
            </td>
          </tr>
        </tbody>
      </v-table>
    </v-card>

    <!-- 統計資訊 -->
    <div class="mt-4 text-body-2 text-medium-emphasis">
      共 {{ filteredAnnouncements.length }} 筆公告
      <span v-if="searchQuery || selectedCategory">
        （已篩選）
      </span>
    </div>

    <!-- 刪除確認對話框 -->
    <v-dialog
      v-model="showDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下公告嗎？
          </p>
          <v-card
            v-if="announcementToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ announcementToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              分類：{{ announcementToDelete.category }} | 
              發布者：{{ announcementToDelete.author }} | 
              日期：{{ formatDate(announcementToDelete.date) }}
            </div>
            <div
              v-if="announcementToDelete.announcement_attachments?.length > 0"
              class="text-caption text-error mt-2"
            >
              ⚠️ 此公告包含 {{ announcementToDelete.announcement_attachments.length }} 個附件，刪除後將一併移除
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
            @click="showDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            variant="flat"
            :loading="loading"
            @click="confirmDelete"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<style scoped lang="scss">
// 表格樣式
.v-table {
  th {
    font-weight: 600;
  }
}
</style>

