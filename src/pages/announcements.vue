<script setup>
  import { computed, onMounted, ref } from 'vue'
  import { supabase } from '@/lib/supabaseClient'

  const searchQuery = ref('')
  const selectedCategory = ref('全部')
  const selectedStatus = ref('全部')
  const currentPage = ref(1)
  const showDetailDialog = ref(false)
  const selectedAnnouncement = ref(null)
  const announcements = ref([])
  const loading = ref(false)
  const error = ref(null)

  const categories = ref(['全部', '重要公告'])
  const statusOptions = ref(['全部'])

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

  // 轉換 Supabase 數據格式為前端格式
  function transformAnnouncement (announcement) {
    return {
      id: announcement.id,
      title: announcement.title,
      content: announcement.content,
      fullContent: announcement.full_content,
      date: formatDate(announcement.date),
      author: announcement.author,
      category: announcement.category,
      views: announcement.views || 0,
      isImportant: announcement.is_important || false,
      icon: announcement.icon || 'mdi-bullhorn',
      color: announcement.color || 'primary',
      attachments: announcement.announcement_attachments?.map(att => ({
        id: att.id,
        name: att.file_name,
        url: att.file_url,
        size: att.file_size,
        type: att.file_type,
      })) || [],
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
        // 將資料庫中的分類添加到 categories（保留 '全部' 和 '重要公告'）
        const dbCategories = categoriesData.map(item => item.value || item.label)
        categories.value = ['全部', '重要公告', ...dbCategories]
      }

      // 載入狀態選項
      const { data: statusData, error: statusError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'announcements')
        .eq('cate', 'statusOptions')
        .order('key')

      if (!statusError && statusData) {
        // 將資料庫中的狀態選項添加到 statusOptions
        statusOptions.value = statusData.map(item => item.value || item.label)
      }
    } catch (error_) {
      console.error('載入選項資料失敗:', error_)
      // 如果載入失敗，使用預設值
      if (categories.value.length === 2) {
        categories.value = ['全部', '重要公告', '活動訊息', '服務異動', '法規更新', '工程公告', '人事異動']
      }
      if (statusOptions.value.length === 1) {
        statusOptions.value = ['全部', '最新', '進行中', '已結束']
      }
    }
  }

  // 從 Supabase 獲取公告資料
  async function loadAnnouncements () {
    loading.value = true
    error.value = null

    try {
      // 查詢公告及其附件
      const { data, error: fetchError } = await supabase
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

      if (fetchError) throw fetchError

      // 轉換數據格式
      announcements.value = (data || []).map(item => transformAnnouncement(item))
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入公告資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 更新瀏覽次數
  async function updateViews (announcementId) {
    try {
      // 先獲取當前瀏覽次數
      const { data: currentAnnouncement, error: fetchError } = await supabase
        .from('announcements')
        .select('views')
        .eq('id', announcementId)
        .single()

      if (fetchError) {
        console.error('獲取瀏覽次數失敗:', fetchError)
        return
      }

      // 更新瀏覽次數
      const { error: updateError } = await supabase
        .from('announcements')
        .update({ views: (currentAnnouncement.views || 0) + 1 })
        .eq('id', announcementId)

      if (updateError) {
        console.error('更新瀏覽次數失敗:', updateError)
      }
    } catch (error_) {
      console.error('更新瀏覽次數時發生錯誤:', error_)
    }
  }

  // 元件掛載時載入資料
  onMounted(async () => {
    // 先載入選項，再載入公告
    await loadOptions()
    await loadAnnouncements()
  })

  const filteredAnnouncements = computed(() => {
    let filtered = announcements.value

    // 搜尋篩選
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(announcement =>
        announcement.title?.toLowerCase().includes(query)
        || announcement.content?.toLowerCase().includes(query)
        || announcement.fullContent?.toLowerCase().includes(query),
      )
    }

    // 分類篩選
    if (selectedCategory.value && selectedCategory.value !== '全部') {
      // 處理「重要公告」特殊情況
      filtered = selectedCategory.value === '重要公告'
        ? filtered.filter(announcement => announcement.isImportant)
        : filtered.filter(announcement =>
          announcement.category === selectedCategory.value,
        )
    }

    // 狀態篩選
    if (selectedStatus.value === '最新') {
      filtered = filtered.filter(announcement => announcement.isImportant)
    }

    return filtered
  })

  const totalPages = computed(() => {
    return Math.ceil(filteredAnnouncements.value.length / 10)
  })

  async function viewAnnouncement (announcement) {
    selectedAnnouncement.value = announcement
    showDetailDialog.value = true

    // 更新瀏覽次數（異步，不阻塞 UI）
    if (announcement.id) {
      await updateViews(announcement.id)
      // 更新本地顯示的瀏覽次數
      announcement.views = (announcement.views || 0) + 1
    }
  }

  function downloadAttachment (attachment) {
    // 如果有 URL，直接打開下載
    if (attachment.url) {
      window.open(attachment.url, '_blank')
    } else {
      console.error('附件 URL 不存在:', attachment)
    }
  }

  function shareAnnouncement () {
    // 分享功能
    if (navigator.share) {
      navigator.share({
        title: selectedAnnouncement.value.title,
        text: selectedAnnouncement.value.content,
        url: window.location.href,
      })
    } else {
      // 複製到剪貼板
      navigator.clipboard.writeText(window.location.href)
      alert('連結已複製到剪貼板')
    }
  }
  </script>
<template>
  <div>
    <!-- Page Header -->
    <div class="page-header">
      <v-container class="py-12">
        <v-row justify="center">
          <v-col
            class="text-center"
            cols="12"
            md="8"
          >
            <h2 class="text-h2 text-md-h1 font-weight-bold mb-4 text-white">最新公告</h2>
            <p class="text-h6 text-white">
              古蹟管理處的最新公告與重要消息
            </p>
          </v-col>
        </v-row>
      </v-container>
    </div>

    <!-- Filter and Search -->
    <v-container class="pb-8">
      <v-row>
        <v-col cols="12" md="8" offset-md="2">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-6">
              <v-row>
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="searchQuery"
                    clearable
                    hide-details
                    label="搜尋公告"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                  />
                </v-col>
                <v-col cols="12" md="3">
                  <v-select
                    v-model="selectedCategory"
                    clearable
                    hide-details
                    :items="categories"
                    label="分類篩選"
                    variant="outlined"
                  />
                </v-col>
                <v-col cols="12" md="3">
                  <v-select
                    v-model="selectedStatus"
                    clearable
                    hide-details
                    :items="statusOptions"
                    label="狀態篩選"
                    variant="outlined"
                  />
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Announcements List -->
    <v-container class="pb-16">
      <!-- Loading State -->
      <v-row v-if="loading">
        <v-col
          class="text-center"
          cols="12"
        >
          <v-progress-circular
            color="primary"
            indeterminate
            size="64"
          />
          <p class="mt-4 text-body-1 text-medium-emphasis">
            載入中...
          </p>
        </v-col>
      </v-row>

      <!-- Error State -->
      <v-row v-else-if="error">
        <v-col
          class="text-center"
          cols="12"
        >
          <v-alert
            color="error"
            type="error"
            variant="tonal"
          >
            {{ error }}
          </v-alert>
          <v-btn
            class="mt-4"
            color="primary"
            @click="loadAnnouncements"
          >
            重試
          </v-btn>
        </v-col>
      </v-row>

      <!-- Announcements Content -->
      <v-row v-else>
        <v-col cols="12" md="8" offset-md="2">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-0">
              <v-list>
                <v-list-item
                  v-for="(announcement, index) in filteredAnnouncements"
                  :key="index"
                  class="border-b"
                  :class="{ 'bg-primary-lighten-5': announcement.isImportant }"
                >
                  <template #prepend>
                    <v-avatar
                      :color="announcement.color"
                      size="40"
                    >
                      <v-icon
                        color="white"
                        :icon="announcement.icon"
                        size="20"
                      />
                    </v-avatar>
                  </template>

                  <v-list-item-title class="text-h6 font-weight-bold mb-1">
                    <v-chip
                      v-if="announcement.isImportant"
                      class="mr-2"
                      color="error"
                      size="small"
                    >
                      重要
                    </v-chip>
                    {{ announcement.title }}
                  </v-list-item-title>

                  <v-list-item-subtitle class="text-body-2 text-medium-emphasis mb-2">
                    {{ announcement.content }}
                  </v-list-item-subtitle>

                  <div class="d-flex align-center text-caption text-medium-emphasis mb-2">
                    <v-icon
                      class="mr-1"
                      icon="mdi-calendar"
                      size="14"
                    />
                    {{ announcement.date }}
                    <v-icon
                      class="mr-1 ml-3"
                      icon="mdi-account"
                      size="14"
                    />
                    {{ announcement.author }}
                    <v-icon
                      class="mr-1 ml-3"
                      icon="mdi-tag"
                      size="14"
                    />
                    {{ announcement.category }}
                    <v-icon
                      class="mr-1 ml-3"
                      icon="mdi-eye"
                      size="14"
                    />
                    {{ announcement.views }} 次瀏覽
                  </div>

                  <div v-if="announcement.attachments && announcement.attachments.length > 0" class="mb-2">
                    <v-chip
                      v-for="attachment in announcement.attachments"
                      :key="attachment.id"
                      class="mr-2"
                      clickable
                      size="small"
                      variant="outlined"
                      @click="downloadAttachment(attachment)"
                    >
                      <v-icon
                        class="mr-1"
                        icon="mdi-paperclip"
                        size="14"
                      />
                      {{ attachment.name }}
                    </v-chip>
                  </div>

                  <template #append>
                    <v-btn
                      color="primary"
                      size="small"
                      variant="text"
                      @click="viewAnnouncement(announcement)"
                    >
                      查看詳情
                    </v-btn>
                  </template>
                </v-list-item>
              </v-list>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Pagination -->
    <v-container class="pb-16">
      <v-row justify="center">
        <v-col cols="12" md="6">
          <v-pagination
            v-model="currentPage"
            color="primary"
            :length="totalPages"
            :total-visible="5"
          />
        </v-col>
      </v-row>
    </v-container>

    <!-- Announcement Detail Dialog -->
    <v-dialog
      v-model="showDetailDialog"
      max-width="800"
      scrollable
    >
      <v-card v-if="selectedAnnouncement">
        <v-card-title class="text-h5 font-weight-bold pa-6 pb-4">
          <v-chip
            v-if="selectedAnnouncement.isImportant"
            class="mr-3"
            color="error"
            size="small"
          >
            重要
          </v-chip>
          {{ selectedAnnouncement.title }}
        </v-card-title>

        <v-card-subtitle class="pa-6 pt-0">
          <div class="d-flex align-center text-body-2 text-medium-emphasis">
            <v-icon
              class="mr-1"
              icon="mdi-calendar"
              size="16"
            />
            {{ selectedAnnouncement.date }}
            <v-icon
              class="mr-1 ml-3"
              icon="mdi-account"
              size="16"
            />
            {{ selectedAnnouncement.author }}
            <v-icon
              class="mr-1 ml-3"
              icon="mdi-tag"
              size="16"
            />
            {{ selectedAnnouncement.category }}
            <v-icon
              class="mr-1 ml-3"
              icon="mdi-eye"
              size="16"
            />
            {{ selectedAnnouncement.views }} 次瀏覽
          </div>
        </v-card-subtitle>

        <v-card-text class="pa-6 pt-0">
          <div
            class="text-body-1 line-height-2"
            v-html="selectedAnnouncement.fullContent"
          />

          <div v-if="selectedAnnouncement.attachments && selectedAnnouncement.attachments.length > 0" class="mt-6">
            <h4 class="text-subtitle-1 font-weight-bold mb-3">附件下載：</h4>
            <div class="d-flex flex-wrap gap-2">
              <v-chip
                v-for="attachment in selectedAnnouncement.attachments"
                :key="attachment.id"
                clickable
                size="small"
                variant="outlined"
                @click="downloadAttachment(attachment)"
              >
                <v-icon
                  class="mr-1"
                  icon="mdi-download"
                  size="14"
                />
                {{ attachment.name }}
              </v-chip>
            </div>
          </div>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer />
          <v-btn
            color="primary"
            variant="outlined"
            @click="showDetailDialog = false"
          >
            關閉
          </v-btn>
          <v-btn
            color="primary"
            @click="shareAnnouncement"
          >
            分享
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<style scoped lang="scss">
.page-header {
  position: relative;
  background-image: url('@/assets/img/landing-view.webp');
  background-size: cover;
  background-position: center 20%;
  background-repeat: no-repeat;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.4); /* 深色半透明遮罩，alpha 值 0.4 */
    z-index: 0;
  }

  .v-container {
    position: relative;
    z-index: 1;
  }
}
</style>
