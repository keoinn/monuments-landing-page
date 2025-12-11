<script setup>
  import { onMounted, ref } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import RichTextEditor from '@/components/RichTextEditor.vue'
  import { deleteAnnouncementAttachment, uploadMultipleAttachments } from '@/lib/storageUtils'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const route = useRoute()
  const authStore = useAuthStore()

  // 從路由參數獲取公告 ID
  const announcementId = route.params.id

  // 表單數據
  const form = ref({
    title: '',
    content: '',
    fullContent: '',
    date: new Date().toISOString().split('T')[0],
    author: '',
    category: '',
    isImportant: false,
    icon: 'mdi-bullhorn',
    color: 'primary',
  })

  // 附件相關
  const existingAttachments = ref([]) // 現有附件（從資料庫載入）
  const newAttachments = ref([]) // 新上傳的附件
  const attachmentsToDelete = ref([]) // 標記要刪除的附件
  const uploadingFiles = ref(false)
  const fileInput = ref(null)

  // 編輯器引用
  const editorRef = ref(null)

  // 表單驗證
  const errors = ref({})
  const loading = ref(false)
  const loadingData = ref(false)
  const error = ref(null)

  // 分類選項（從 Supabase 載入）
  const categories = ref([])

  // 圖示選項（從 Supabase 載入）
  const iconOptions = ref([])

  // 顏色選項（從 Supabase 載入）
  const colorOptions = ref([])

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

    return Object.keys(errors.value).length === 0
  }

  // 載入公告數據
  async function loadAnnouncement () {
    loadingData.value = true
    error.value = null

    try {
      // 載入公告及其附件
      const { data: announcement, error: fetchError } = await supabase
        .from('announcements')
        .select(`
          *,
          announcement_attachments (
            id,
            file_name,
            file_url,
            file_size,
            file_type,
            storage_path,
            display_order
          )
        `)
        .eq('id', announcementId)
        .single()

      if (fetchError) throw fetchError

      if (!announcement) {
        error.value = '找不到指定的公告'
        router.push('/admin/announcements')
        return
      }

      // 填充表單
      form.value = {
        title: announcement.title || '',
        content: announcement.content || '',
        fullContent: announcement.full_content || '',
        date: announcement.date ? announcement.date.split('T')[0] : new Date().toISOString().split('T')[0],
        author: announcement.author || '',
        category: announcement.category || '',
        isImportant: announcement.is_important || false,
        icon: announcement.icon || 'mdi-bullhorn',
        color: announcement.color || 'primary',
      }

      // 載入現有附件
      if (announcement.announcement_attachments) {
        existingAttachments.value = announcement.announcement_attachments.map(att => ({
          id: att.id,
          name: att.file_name,
          url: att.file_url,
          size: att.file_size,
          type: att.file_type,
          storagePath: att.storage_path,
          displayOrder: att.display_order,
        }))
      }
    } catch (error_) {
      console.error('載入公告失敗:', error_)
      error.value = error_.message || '載入公告時發生錯誤'
    } finally {
      loadingData.value = false
    }
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

    // 添加到新附件列表
    newAttachments.value.push(...files.map(file => ({
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

  // 移除新附件
  function removeNewAttachment (index) {
    newAttachments.value.splice(index, 1)
  }

  // 標記刪除現有附件
  function markDeleteAttachment (attachment) {
    attachmentsToDelete.value.push(attachment.id)
    // 從現有附件列表中移除
    const index = existingAttachments.value.findIndex(a => a.id === attachment.id)
    if (index !== -1) {
      existingAttachments.value.splice(index, 1)
    }
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
      // 更新公告記錄
      const { error: updateError } = await supabase
        .from('announcements')
        .update({
          title: form.value.title.trim(),
          content: form.value.content.trim(),
          full_content: form.value.fullContent.trim(),
          date: form.value.date,
          author: form.value.author.trim(),
          category: form.value.category,
          is_important: form.value.isImportant,
          icon: form.value.icon,
          color: form.value.color,
        })
        .eq('id', announcementId)

      if (updateError) throw updateError

      // 刪除標記的附件
      if (attachmentsToDelete.value.length > 0) {
        try {
          // 先取得要刪除的附件的 storage_path
          const { data: attachmentsToDeleteData, error: fetchError } = await supabase
            .from('announcement_attachments')
            .select('id, storage_path')
            .in('id', attachmentsToDelete.value)

          if (!fetchError && attachmentsToDeleteData) {
            // 刪除每個附件
            for (const attachment of attachmentsToDeleteData) {
              await deleteAnnouncementAttachment(attachment.id, attachment.storage_path)
            }
          }
        } catch (deleteError) {
          console.error('刪除附件失敗:', deleteError)
          // 即使附件刪除失敗，也繼續（公告已更新）
          error.value = `公告已更新，但部分附件刪除失敗：${deleteError.message}`
        }
      }

      // 上傳新附件
      if (newAttachments.value.length > 0) {
        uploadingFiles.value = true
        try {
          const files = newAttachments.value.map(item => item.file)
          await uploadMultipleAttachments(announcementId, files)
        } catch (uploadError) {
          console.error('上傳附件失敗:', uploadError)
          // 即使附件上傳失敗，也繼續（公告已更新）
          error.value = `公告已更新，但附件上傳失敗：${uploadError.message}`
        } finally {
          uploadingFiles.value = false
        }
      }

      // 成功後導向公告列表
      router.push('/admin/announcements')
    } catch (error_) {
      console.error('更新公告失敗:', error_)
      error.value = error_.message || '更新公告時發生錯誤'
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
    }
  }

  // 取消並返回
  function cancel () {
    router.push('/admin/announcements')
  }

  // 元件掛載時初始化
  onMounted(async () => {
    // 路由守衛已經處理了認證檢查，這裡只需要確保認證狀態已初始化
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

    // 先載入選項，再載入公告數據
    await loadOptions()
    await loadAnnouncement()
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="d-flex align-center justify-space-between mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          編輯公告
        </h1>
        <p class="text-body-2 text-medium-emphasis">
          修改公告內容
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

    <!-- 載入中 -->
    <div v-if="loadingData" class="text-center py-12">
      <v-progress-circular
        color="primary"
        indeterminate
        size="64"
      />
      <p class="mt-4 text-body-1 text-medium-emphasis">
        載入公告資料中...
      </p>
    </div>

    <!-- 表單 -->
    <v-form v-else @submit.prevent="submitForm">
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

      <!-- 附件管理 -->
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
            新增檔案
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
          <!-- 現有附件 -->
          <div v-if="existingAttachments.length > 0" class="mb-4">
            <div class="text-body-2 font-weight-medium mb-2">
              現有附件
            </div>
            <v-list>
              <v-list-item
                v-for="attachment in existingAttachments"
                :key="attachment.id"
                class="px-0"
              >
                <template #prepend>
                  <v-icon color="primary">
                    mdi-file
                  </v-icon>
                </template>
                <v-list-item-title>
                  <a
                    :href="attachment.url"
                    target="_blank"
                    class="text-decoration-none"
                  >
                    {{ attachment.name }}
                  </a>
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
                    @click="markDeleteAttachment(attachment)"
                  >
                    <v-icon>mdi-delete</v-icon>
                    <v-tooltip activator="parent">
                      刪除附件
                    </v-tooltip>
                  </v-btn>
                </template>
              </v-list-item>
            </v-list>
          </div>

          <!-- 新附件 -->
          <div v-if="newAttachments.length > 0" class="mb-4">
            <div class="text-body-2 font-weight-medium mb-2">
              新附件（將在儲存時上傳）
            </div>
            <v-list>
              <v-list-item
                v-for="(attachment, index) in newAttachments"
                :key="index"
                class="px-0"
              >
                <template #prepend>
                  <v-icon color="success">
                    mdi-file-plus
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
                    @click="removeNewAttachment(index)"
                  >
                    <v-icon>mdi-delete</v-icon>
                    <v-tooltip activator="parent">
                      移除
                    </v-tooltip>
                  </v-btn>
                </template>
              </v-list-item>
            </v-list>
          </div>

          <!-- 空狀態 -->
          <div
            v-if="existingAttachments.length === 0 && newAttachments.length === 0"
            class="text-center py-8 text-medium-emphasis"
          >
            目前沒有附件，點擊上方「新增檔案」按鈕新增附件
          </div>

          <v-alert
            v-if="existingAttachments.length > 0 || newAttachments.length > 0"
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
          {{ uploadingFiles ? '上傳附件中...' : '儲存變更' }}
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
