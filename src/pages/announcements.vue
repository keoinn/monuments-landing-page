<template>
  <div>
    <!-- Page Header -->
    <v-container class="py-12">
      <v-row justify="center">
        <v-col cols="12" md="8" class="text-center">
          <h1 class="text-h2 text-md-h1 font-weight-bold mb-4">最新公告</h1>
          <p class="text-h6 text-medium-emphasis">
            古蹟管理處的最新公告與重要消息
          </p>
        </v-col>
      </v-row>
    </v-container>

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
                    label="搜尋公告"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    clearable
                    hide-details
                  />
                </v-col>
                <v-col cols="12" md="3">
                  <v-select
                    v-model="selectedCategory"
                    :items="categories"
                    label="分類篩選"
                    variant="outlined"
                    clearable
                    hide-details
                  />
                </v-col>
                <v-col cols="12" md="3">
                  <v-select
                    v-model="selectedStatus"
                    :items="statusOptions"
                    label="狀態篩選"
                    variant="outlined"
                    clearable
                    hide-details
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
      <v-row>
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
                        :icon="announcement.icon"
                        color="white"
                        size="20"
                      />
                    </v-avatar>
                  </template>

                  <v-list-item-title class="text-h6 font-weight-bold mb-1">
                    <v-chip
                      v-if="announcement.isImportant"
                      color="error"
                      size="small"
                      class="mr-2"
                    >
                      重要
                    </v-chip>
                    {{ announcement.title }}
                  </v-list-item-title>

                  <v-list-item-subtitle class="text-body-2 text-medium-emphasis mb-2">
                    {{ announcement.content }}
                  </v-list-item-subtitle>

                  <div class="d-flex align-center text-caption text-medium-emphasis mb-2">
                    <v-icon icon="mdi-calendar" size="14" class="mr-1" />
                    {{ announcement.date }}
                    <v-icon icon="mdi-account" size="14" class="mr-1 ml-3" />
                    {{ announcement.author }}
                    <v-icon icon="mdi-tag" size="14" class="mr-1 ml-3" />
                    {{ announcement.category }}
                    <v-icon icon="mdi-eye" size="14" class="mr-1 ml-3" />
                    {{ announcement.views }} 次瀏覽
                  </div>

                  <div v-if="announcement.attachments" class="mb-2">
                    <v-chip
                      v-for="attachment in announcement.attachments"
                      :key="attachment"
                      size="small"
                      variant="outlined"
                      class="mr-2"
                    >
                      <v-icon icon="mdi-paperclip" size="14" class="mr-1" />
                      {{ attachment }}
                    </v-chip>
                  </div>

                  <template #append>
                    <v-btn
                      color="primary"
                      variant="text"
                      size="small"
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
            :length="totalPages"
            :total-visible="5"
            color="primary"
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
            color="error"
            size="small"
            class="mr-3"
          >
            重要
          </v-chip>
          {{ selectedAnnouncement.title }}
        </v-card-title>

        <v-card-subtitle class="pa-6 pt-0">
          <div class="d-flex align-center text-body-2 text-medium-emphasis">
            <v-icon icon="mdi-calendar" size="16" class="mr-1" />
            {{ selectedAnnouncement.date }}
            <v-icon icon="mdi-account" size="16" class="mr-1 ml-3" />
            {{ selectedAnnouncement.author }}
            <v-icon icon="mdi-tag" size="16" class="mr-1 ml-3" />
            {{ selectedAnnouncement.category }}
            <v-icon icon="mdi-eye" size="16" class="mr-1 ml-3" />
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
                size="small"
                variant="outlined"
                clickable
                @click="downloadAttachment(attachment)"
              >
                <v-icon icon="mdi-download" size="14" class="mr-1" />
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

<script setup>
import { ref, computed } from 'vue'

const searchQuery = ref('')
const selectedCategory = ref('')
const selectedStatus = ref('')
const currentPage = ref(1)
const showDetailDialog = ref(false)
const selectedAnnouncement = ref(null)

const categories = [
  '全部',
  '重要公告',
  '活動訊息',
  '服務異動',
  '法規更新',
  '工程公告',
  '人事異動'
]

const statusOptions = [
  '全部',
  '最新',
  '進行中',
  '已結束'
]

const announcements = [
  {
    title: '古蹟維護工程期間參觀注意事項',
    content: '因進行古蹟維護工程，部分區域將暫時關閉，請參觀民眾注意安全...',
    fullContent: '因進行古蹟維護工程，部分區域將暫時關閉。工程期間，請參觀民眾注意以下事項：\n\n1. 請遵循現場工作人員指示，勿進入施工區域\n2. 參觀時請保持安靜，避免影響工程進行\n3. 建議提前預約參觀時間，避免現場等候\n4. 如有任何疑問，請洽詢服務台工作人員\n\n工程預計於2024年3月底完成，感謝您的配合與諒解。',
    date: '2024-01-20',
    author: '維護部',
    category: '工程公告',
    views: 156,
    isImportant: true,
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    attachments: ['工程公告.pdf', '參觀須知.docx']
  },
  {
    title: '2024年春季文化講座系列活動',
    content: '邀請知名學者分享古蹟歷史與文化價值，歡迎民眾踴躍參加...',
    fullContent: '2024年春季文化講座系列活動即將開始，我們邀請了多位知名學者與專家，為大家分享古蹟的歷史背景、建築特色與文化價值。\n\n講座主題包括：\n- 古蹟建築藝術賞析\n- 歷史文化背景探討\n- 修復技術與工法介紹\n- 文化資產保護理念\n\n活動時間：每週六下午2:00-4:00\n活動地點：古蹟管理處會議室\n報名方式：請至服務台或線上報名\n\n名額有限，歡迎有興趣的民眾踴躍參加！',
    date: '2024-01-18',
    author: '教育推廣部',
    category: '活動訊息',
    views: 89,
    isImportant: false,
    icon: 'mdi-school',
    color: 'info',
    attachments: ['講座海報.jpg', '報名表.docx']
  },
  {
    title: '古蹟導覽服務時間調整公告',
    content: '自2月1日起，導覽服務時間將調整為每週二至週日，週一休館...',
    fullContent: '自2024年2月1日起，古蹟導覽服務時間將進行調整：\n\n開放時間：\n- 週二至週日：上午9:00-下午5:00\n- 週一：休館（國定假日除外）\n\n導覽服務：\n- 定時導覽：每日上午10:00、下午2:00\n- 團體導覽：需提前3天預約\n- 語音導覽：提供中、英、日三種語言\n\n票價資訊：\n- 全票：100元\n- 優待票：50元（學生、65歲以上長者）\n- 團體票：80元（20人以上）\n\n如有任何疑問，請洽詢服務台或來電詢問。',
    date: '2024-01-15',
    author: '服務部',
    category: '服務異動',
    views: 234,
    isImportant: false,
    icon: 'mdi-clock',
    color: 'primary',
    attachments: ['服務時間表.pdf']
  },
  {
    title: '古蹟保護法規修訂公告',
    content: '文化部修訂古蹟保護相關法規，請相關人員詳閱新規定...',
    fullContent: '文化部於2024年1月10日發布修訂「文化資產保存法」部分條文，主要修訂內容包括：\n\n1. 古蹟修復準則更新\n2. 管理維護責任明確化\n3. 違規處罰標準調整\n4. 申請程序簡化\n\n詳細修訂內容請參閱附件法規條文，請相關人員務必詳閱並遵循新規定。\n\n如有疑問，請洽詢法務部門或文化部相關單位。',
    date: '2024-01-12',
    author: '法務部',
    category: '法規更新',
    views: 67,
    isImportant: true,
    icon: 'mdi-gavel',
    color: 'error',
    attachments: ['修訂法規.pdf', '修訂說明.docx']
  },
  {
    title: '古蹟管理處人事異動公告',
    content: '公告最新人事異動情況，包括新進人員與職務調整...',
    fullContent: '古蹟管理處最新人事異動公告：\n\n新進人員：\n- 王小明：教育推廣部專員\n- 李小華：維護部技師\n- 張大偉：行政部助理\n\n職務調整：\n- 陳志明：維護部技師 → 維護部組長\n- 林雅婷：教育推廣部專員 → 教育推廣部副主任\n\n以上異動自2024年2月1日起生效，請各部門配合相關交接工作。',
    date: '2024-01-10',
    author: '人事部',
    category: '人事異動',
    views: 45,
    isImportant: false,
    icon: 'mdi-account-group',
    color: 'success',
    attachments: ['人事異動令.pdf']
  }
]

const filteredAnnouncements = computed(() => {
  let filtered = announcements

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(announcement =>
      announcement.title.toLowerCase().includes(query) ||
      announcement.content.toLowerCase().includes(query)
    )
  }

  if (selectedCategory.value && selectedCategory.value !== '全部') {
    filtered = filtered.filter(announcement =>
      announcement.category === selectedCategory.value
    )
  }

  if (selectedStatus.value && selectedStatus.value !== '全部') {
    if (selectedStatus.value === '最新') {
      filtered = filtered.filter(announcement => announcement.isImportant)
    }
  }

  return filtered
})

const totalPages = computed(() => {
  return Math.ceil(filteredAnnouncements.value.length / 10)
})

const viewAnnouncement = (announcement) => {
  selectedAnnouncement.value = announcement
  showDetailDialog.value = true
  // 增加瀏覽次數
  announcement.views++
}

const downloadAttachment = (attachment) => {
  // 模擬下載
  console.log(`下載附件: ${attachment}`)
}

const shareAnnouncement = () => {
  // 模擬分享功能
  if (navigator.share) {
    navigator.share({
      title: selectedAnnouncement.value.title,
      text: selectedAnnouncement.value.content,
      url: window.location.href
    })
  } else {
    // 複製到剪貼板
    navigator.clipboard.writeText(window.location.href)
    alert('連結已複製到剪貼板')
  }
}
</script>

