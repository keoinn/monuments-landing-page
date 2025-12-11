<script setup>
  import { onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import RichTextEditor from '@/components/RichTextEditor.vue'
  import { uploadMultipleAttachments } from '@/lib/storageUtils'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // 表單數據
  const form = ref({
    title: '',
    content: '',
    fullContent: '',
    date: new Date().toISOString().split('T')[0], // 預設今天
    author: '',
    category: '',
    status: '進行中',
    isImportant: false,
    icon: 'mdi-bullhorn',
    color: 'primary',
  })

  // 附件相關
  const attachments = ref([])
  const uploadingFiles = ref(false)
  const fileInput = ref(null)

  // 編輯器引用
  const editorRef = ref(null)

  // 表單驗證
  const errors = ref({})
  const loading = ref(false)
  const error = ref(null)

  // 分類選項（從 Supabase 載入）
  const categories = ref([])

  // 圖示選項（從 Supabase 載入）
  const iconOptions = ref([])

  // 顏色選項（從 Supabase 載入）
  const colorOptions = ref([])

  // 狀態選項（從 Supabase 載入）
  const statusOptions = ref([])

  // 分類與圖示、顏色的映射（用於自動設定）
  const categoryIconColorMap = {
    工程公告: { icon: 'mdi-hammer-wrench', color: 'warning' },
    活動訊息: { icon: 'mdi-calendar-star', color: 'info' },
    服務異動: { icon: 'mdi-information', color: 'primary' },
    法規更新: { icon: 'mdi-book-open-variant', color: 'success' },
    人事異動: { icon: 'mdi-account-group', color: 'error' },
  }

  // 根據分類自動設定圖示和顏色
  function updateCategoryDefaults () {
    const mapping = categoryIconColorMap[form.value.category]
    if (mapping) {
      form.value.icon = mapping.icon
      form.value.color = mapping.color
    }
  }

  // 從完整內容自動生成簡短內容
  function generateSummary () {
    if (editorRef.value) {
      const text = editorRef.value.getText()
      // 取前 150 個字元作為摘要
      form.value.content = text.slice(0, 150).trim()
      if (text.length > 150) {
        form.value.content += '...'
      }
    }
  }

  // 驗證表單
  function validateForm () {
    errors.value = {}

    if (!form.value.title?.trim()) {
      errors.value.title = '請輸入公告標題'
    }

    if (!form.value.content?.trim()) {
      errors.value.content = '請輸入公告摘要'
    }

    if (!form.value.fullContent?.trim()) {
      errors.value.fullContent = '請輸入公告完整內容'
    }

    if (!form.value.date) {
      errors.value.date = '請選擇公告日期'
    }

    if (!form.value.author?.trim()) {
      errors.value.author = '請輸入發布者'
    }

    if (!form.value.category) {
      errors.value.category = '請選擇分類'
    }

    if (!form.value.status) {
      errors.value.status = '請選擇狀態'
    }

    return Object.keys(errors.value).length === 0
  }

  // 處理檔案選擇
  function handleFileSelect (event) {
    const files = Array.from(event.target.files || [])
    if (files.length === 0) return

    // 驗證檔案大小（最大 10MB）
    const maxSize = 10 * 1024 * 1024 // 10MB
    const invalidFiles = files.filter(file => file.size > maxSize)

    if (invalidFiles.length > 0) {
      error.value = `以下檔案超過 10MB 限制：${invalidFiles.map(f => f.name).join(', ')}`
      return
    }

    // 添加到附件列表
    attachments.value.push(...files.map(file => ({
      file,
      name: file.name,
      size: file.size,
      type: file.type,
      uploading: false,
      error: null,
    })))

    // 清空 input
    event.target.value = ''
  }

  // 移除附件
  function removeAttachment (index) {
    attachments.value.splice(index, 1)
  }

  // 格式化檔案大小
  function formatFileSize (bytes) {
    if (!bytes) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  // 提交表單
  async function submitForm () {
    // 驗證表單
    if (!validateForm()) {
      error.value = '請填寫所有必填欄位'
      return
    }

    loading.value = true
    error.value = null

    try {
      // 先建立公告記錄
      const { data: announcement, error: insertError } = await supabase
        .from('announcements')
        .insert({
          title: form.value.title.trim(),
          content: form.value.content.trim(),
          full_content: form.value.fullContent.trim(),
          date: form.value.date,
          author: form.value.author.trim(),
          category: form.value.category,
          status: form.value.status,
          is_important: form.value.isImportant,
          icon: form.value.icon,
          color: form.value.color,
          views: 0,
        })
        .select()
        .single()

      if (insertError) throw insertError

      // 如果有附件，上傳附件
      if (attachments.value.length > 0) {
        uploadingFiles.value = true
        try {
          const files = attachments.value.map(item => item.file)
          await uploadMultipleAttachments(announcement.id, files)
        } catch (uploadError) {
          console.error('上傳附件失敗:', uploadError)
          // 即使附件上傳失敗，也繼續（公告已建立）
          error.value = `公告已建立，但附件上傳失敗：${uploadError.message}`
        } finally {
          uploadingFiles.value = false
        }
      }

      // 成功後導向公告列表
      router.push('/admin/announcements')
    } catch (error_) {
      console.error('建立公告失敗:', error_)
      error.value = error_.message || '建立公告時發生錯誤'
    } finally {
      loading.value = false
    }
  }

  // 從 Supabase 載入選項資料
  async function loadOptions () {
    try {
      // 載入分類選項
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'announcements')
        .eq('cate', 'categories')
        .order('key')

      if (!categoriesError && categoriesData) {
        // 轉換為前端格式，添加 icon 和 color
        categories.value = categoriesData.map(item => {
          const value = item.value || item.label
          const mapping = categoryIconColorMap[value] || {}
          return {
            value,
            text: item.label || value,
            icon: mapping.icon || 'mdi-bullhorn',
            color: mapping.color || 'primary',
          }
        })
      }

      // 載入圖示選項
      const { data: iconData, error: iconError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'announcements')
        .eq('cate', 'iconOptions')
        .order('key')

      if (!iconError && iconData) {
        iconOptions.value = iconData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
      }

      // 載入顏色選項
      const { data: colorData, error: colorError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'announcements')
        .eq('cate', 'colorOptions')
        .order('key')

      if (!colorError && colorData) {
        colorOptions.value = colorData.map(item => {
          const value = item.value || item.label
          return {
            value,
            text: item.label || value,
            color: value,
          }
        })
      }

      // 載入狀態選項
      const { data: statusData, error: statusError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'announcements')
        .eq('cate', 'statusOptions')
        .order('key')

      if (!statusError && statusData) {
        // 過濾掉「全部」選項，只保留實際狀態
        statusOptions.value = statusData
          .filter(item => {
            const value = item.value || item.label
            return value !== '全部'
          })
          .map(item => ({
            value: item.value || item.label,
            text: item.label || item.value,
          }))
      }
    } catch (error_) {
      console.error('載入選項資料失敗:', error_)
      // 如果載入失敗，使用預設值
      if (categories.value.length === 0) {
        categories.value = [
          { value: '工程公告', text: '工程公告', icon: 'mdi-hammer-wrench', color: 'warning' },
          { value: '活動訊息', text: '活動訊息', icon: 'mdi-calendar-star', color: 'info' },
          { value: '服務異動', text: '服務異動', icon: 'mdi-information', color: 'primary' },
          { value: '法規更新', text: '法規更新', icon: 'mdi-book-open-variant', color: 'success' },
          { value: '人事異動', text: '人事異動', icon: 'mdi-account-group', color: 'error' },
        ]
      }
      if (iconOptions.value.length === 0) {
        iconOptions.value = [
          { value: 'mdi-bullhorn', text: '公告' },
          { value: 'mdi-hammer-wrench', text: '工程' },
          { value: 'mdi-calendar-star', text: '活動' },
          { value: 'mdi-information', text: '資訊' },
          { value: 'mdi-book-open-variant', text: '法規' },
          { value: 'mdi-account-group', text: '人事' },
          { value: 'mdi-alert', text: '警告' },
          { value: 'mdi-check-circle', text: '完成' },
        ]
      }
      if (colorOptions.value.length === 0) {
        colorOptions.value = [
          { value: 'primary', text: '主要', color: 'primary' },
          { value: 'success', text: '成功', color: 'success' },
          { value: 'info', text: '資訊', color: 'info' },
          { value: 'warning', text: '警告', color: 'warning' },
          { value: 'error', text: '錯誤', color: 'error' },
        ]
      }
      if (statusOptions.value.length === 0) {
        statusOptions.value = [
          { value: '最新', text: '最新' },
          { value: '進行中', text: '進行中' },
          { value: '已結束', text: '已結束' },
        ]
      }
    }
  }

  // 取消並返回
  function cancel () {
    router.push('/admin/announcements')
  }

  // 元件掛載時初始化
  onMounted(async () => {
    // 路由守衛已經處理了認證檢查，這裡只需要確保認證狀態已初始化
    // 如果認證狀態尚未初始化，等待一下讓路由守衛完成
    if (!authStore.user && !authStore.loading) {
      await authStore.initAuth()
    } else if (authStore.loading) {
      // 如果正在載入，等待載入完成
      let waitCount = 0
      while (authStore.loading && waitCount < 30) {
        await new Promise(resolve => setTimeout(resolve, 100))
        waitCount++
      }
    }

    // 如果仍未認證，導向登入頁面（雙重檢查）
    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    // 載入選項資料
    await loadOptions()

    // 預設使用當前用戶的 email 作為發布者
    if (authStore.user?.email) {
      form.value.author = authStore.user.email.split('@')[0] || authStore.user.email
    }
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="d-flex align-center justify-space-between mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          新增公告
        </h1>
        <p class="text-body-2 text-medium-emphasis">
          建立新的公告內容
        </p>
      </div>
      <v-btn
        color="primary"
        prepend-icon="mdi-arrow-left"
        variant="outlined"
        @click="cancel"
      >
        返回列表
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

    <!-- 表單 -->
    <v-form @submit.prevent="submitForm">
      <v-card elevation="2">
        <v-card-title class="d-flex align-center">
          <v-icon class="mr-2" icon="mdi-file-document-edit" />
          公告資訊
        </v-card-title>
        <v-divider />
        <v-card-text class="pa-6">
          <v-row>
            <!-- 標題 -->
            <v-col cols="12">
              <v-text-field
                v-model="form.title"
                label="公告標題 *"
                variant="outlined"
                :error-messages="errors.title"
                required
                prepend-inner-icon="mdi-format-title"
              />
            </v-col>

            <!-- 分類 -->
            <v-col cols="12" md="6">
              <v-select
                v-model="form.category"
                :items="categories"
                item-title="text"
                item-value="value"
                label="分類 *"
                variant="outlined"
                :error-messages="errors.category"
                required
                prepend-inner-icon="mdi-tag"
                @update:model-value="updateCategoryDefaults"
              >
                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #prepend>
                      <v-icon :color="item.raw.color">
                        {{ item.raw.icon }}
                      </v-icon>
                    </template>
                  </v-list-item>
                </template>
              </v-select>
            </v-col>

            <!-- 發布者 -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="form.author"
                label="發布者 *"
                variant="outlined"
                :error-messages="errors.author"
                required
                prepend-inner-icon="mdi-account"
              />
            </v-col>

            <!-- 日期 -->
            <v-col cols="12" md="6">
              <v-text-field
                v-model="form.date"
                label="公告日期 *"
                type="date"
                variant="outlined"
                :error-messages="errors.date"
                required
                prepend-inner-icon="mdi-calendar"
              />
            </v-col>

            <!-- 狀態 -->
            <v-col cols="12" md="6">
              <v-select
                v-model="form.status"
                :items="statusOptions"
                item-title="text"
                item-value="value"
                label="狀態 *"
                variant="outlined"
                :error-messages="errors.status"
                required
                prepend-inner-icon="mdi-information-outline"
              />
            </v-col>

            <!-- 是否重要 -->
            <v-col cols="12" md="6">
              <v-switch
                v-model="form.isImportant"
                label="重要公告"
                color="error"
                prepend-icon="mdi-star"
                hide-details
              />
            </v-col>

            <!-- 圖示 -->
            <v-col cols="12" md="6">
              <v-select
                v-model="form.icon"
                :items="iconOptions"
                item-title="text"
                item-value="value"
                label="圖示"
                variant="outlined"
                prepend-inner-icon="mdi-palette"
              >
                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #prepend>
                      <v-icon>
                        {{ item.raw.value }}
                      </v-icon>
                    </template>
                  </v-list-item>
                </template>
                <template #selection="{ item }">
                  <v-icon class="mr-2">
                    {{ item.raw.value }}
                  </v-icon>
                  {{ item.raw.text }}
                </template>
              </v-select>
            </v-col>

            <!-- 顏色 -->
            <v-col cols="12" md="6">
              <v-select
                v-model="form.color"
                :items="colorOptions"
                item-title="text"
                item-value="value"
                label="顏色主題"
                variant="outlined"
                prepend-inner-icon="mdi-palette-outline"
              >
                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #prepend>
                      <v-chip
                        :color="item.raw.color"
                        size="small"
                        variant="tonal"
                      >
                        {{ item.raw.text }}
                      </v-chip>
                    </template>
                  </v-list-item>
                </template>
                <template #selection="{ item }">
                  <v-chip
                    :color="item.raw.color"
                    size="small"
                    variant="tonal"
                  >
                    {{ item.raw.text }}
                  </v-chip>
                </template>
              </v-select>
            </v-col>

            <!-- 簡短內容（摘要） -->
            <v-col cols="12">
              <v-textarea
                v-model="form.content"
                label="公告摘要 *"
                variant="outlined"
                :error-messages="errors.content"
                required
                rows="3"
                hint="建議 100-200 字，將顯示在公告列表中"
                persistent-hint
                prepend-inner-icon="mdi-text-short"
              />
              <div class="d-flex justify-end mt-2">
                <v-btn
                  size="small"
                  variant="text"
                  prepend-icon="mdi-auto-fix"
                  @click="generateSummary"
                >
                  從完整內容自動生成
                </v-btn>
              </div>
            </v-col>

            <!-- 完整內容（富文本編輯器） -->
            <v-col cols="12">
              <div class="mb-2">
                <label class="text-body-2 font-weight-medium">
                  公告完整內容 *
                </label>
                <v-chip
                  v-if="errors.fullContent"
                  color="error"
                  size="small"
                  variant="tonal"
                  class="ml-2"
                >
                  {{ errors.fullContent }}
                </v-chip>
              </div>
              <RichTextEditor
                ref="editorRef"
                v-model="form.fullContent"
                placeholder="請輸入公告完整內容..."
                height="400px"
              />
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>

      <!-- 附件上傳 -->
      <v-card class="mt-4" elevation="2">
        <v-card-title class="d-flex align-center">
          <v-icon class="mr-2" icon="mdi-paperclip" />
          附件
          <v-spacer />
          <v-btn
            color="primary"
            size="small"
            prepend-icon="mdi-upload"
            variant="outlined"
            @click="fileInput?.click()"
          >
            選擇檔案
          </v-btn>
          <input
            ref="fileInput"
            type="file"
            multiple
            accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png"
            style="display: none;"
            @change="handleFileSelect"
          >
        </v-card-title>
        <v-divider />
        <v-card-text class="pa-4">
          <div v-if="attachments.length === 0" class="text-center py-8 text-medium-emphasis">
            目前沒有附件，點擊上方「選擇檔案」按鈕新增附件
          </div>
          <v-list v-else>
            <v-list-item
              v-for="(attachment, index) in attachments"
              :key="index"
              class="px-0"
            >
              <template #prepend>
                <v-icon color="primary">
                  mdi-file
                </v-icon>
              </template>
              <v-list-item-title>
                {{ attachment.name }}
              </v-list-item-title>
              <v-list-item-subtitle>
                {{ formatFileSize(attachment.size) }} · {{ attachment.type }}
              </v-list-item-subtitle>
              <template #append>
                <v-btn
                  icon
                  size="small"
                  variant="text"
                  color="error"
                  @click="removeAttachment(index)"
                >
                  <v-icon>mdi-delete</v-icon>
                </v-btn>
              </template>
            </v-list-item>
          </v-list>
          <v-alert
            v-if="attachments.length > 0"
            class="mt-4"
            type="info"
            variant="tonal"
            density="compact"
          >
            <div class="text-caption">
              <strong>注意：</strong>單個檔案大小限制為 10MB，支援 PDF、Word、Excel、圖片等格式
            </div>
          </v-alert>
        </v-card-text>
      </v-card>

      <!-- 操作按鈕 -->
      <div class="d-flex justify-end gap-2 mt-4">
        <v-btn
          color="default"
          variant="outlined"
          size="large"
          @click="cancel"
        >
          取消
        </v-btn>
        <v-btn
          color="primary"
          variant="flat"
          size="large"
          :loading="loading || uploadingFiles"
          :disabled="loading || uploadingFiles"
          prepend-icon="mdi-content-save"
          @click="submitForm"
        >
          {{ uploadingFiles ? '上傳附件中...' : '儲存公告' }}
        </v-btn>
      </div>
    </v-form>
  </v-container>
</template>

<style scoped lang="scss">
// 表單樣式
.v-card {
  margin-bottom: 16px;
}
</style>
