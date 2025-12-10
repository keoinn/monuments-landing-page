<script setup>
  import { computed, onMounted, ref } from 'vue'
  import { fetchAnnouncements } from '@/apis/mocks/announcementsApi'

  const searchQuery = ref('')
  const selectedCategory = ref('')
  const selectedStatus = ref('')
  const currentPage = ref(1)
  const showDetailDialog = ref(false)
  const selectedAnnouncement = ref(null)
  const announcements = ref([])
  const loading = ref(false)
  const error = ref(null)

  const categories = [
    '全部',
    '重要公告',
    '活動訊息',
    '服務異動',
    '法規更新',
    '工程公告',
    '人事異動',
  ]

  const statusOptions = [
    '全部',
    '最新',
    '進行中',
    '已結束',
  ]

  // 從 API 獲取公告資料
  async function loadAnnouncements () {
    loading.value = true
    error.value = null

    try {
      const data = await fetchAnnouncements()
      announcements.value = data
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入公告資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(() => {
    loadAnnouncements()
  })

  const filteredAnnouncements = computed(() => {
    let filtered = announcements.value

    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(announcement =>
        announcement.title.toLowerCase().includes(query)
        || announcement.content.toLowerCase().includes(query),
      )
    }

    if (selectedCategory.value && selectedCategory.value !== '全部') {
      filtered = filtered.filter(announcement =>
        announcement.category === selectedCategory.value,
      )
    }

    if (selectedStatus.value === '最新') {
      filtered = filtered.filter(announcement => announcement.isImportant)
    }

    return filtered
  })

  const totalPages = computed(() => {
    return Math.ceil(filteredAnnouncements.value.length / 10)
  })

  function viewAnnouncement (announcement) {
    selectedAnnouncement.value = announcement
    showDetailDialog.value = true
    // 增加瀏覽次數
    announcement.views++
  }

  function downloadAttachment (attachment) {
    // 模擬下載
    console.log(`下載附件: ${attachment}`)
  }

  function shareAnnouncement () {
    // 模擬分享功能
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

                  <div v-if="announcement.attachments" class="mb-2">
                    <v-chip
                      v-for="attachment in announcement.attachments"
                      :key="attachment"
                      class="mr-2"
                      size="small"
                      variant="outlined"
                    >
                      <v-icon
                        class="mr-1"
                        icon="mdi-paperclip"
                        size="14"
                      />
                      {{ attachment }}
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
          <div class="text-body-1 line-height-2">
            {{ selectedAnnouncement.fullContent }}
          </div>

          <div v-if="selectedAnnouncement.attachments" class="mt-6">
            <h4 class="text-subtitle-1 font-weight-bold mb-3">附件下載：</h4>
            <div class="d-flex flex-wrap gap-2">
              <v-chip
                v-for="attachment in selectedAnnouncement.attachments"
                :key="attachment"
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
                {{ attachment }}
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
