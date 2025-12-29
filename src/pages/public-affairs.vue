<script setup>
  import { computed, onMounted, ref } from 'vue'
  import { supabase } from '@/lib/supabaseClient'

  const formDocuments = ref([])
  const contactInfo = ref([])
  const loading = ref(false)
  const error = ref(null)
  const currentPage = ref(1)
  const itemsPerPage = 6

  // Storage bucket 名稱
  const BUCKET_NAME = 'wanxuanju-files'

  // 格式化日期
  function formatDate (dateString) {
    if (!dateString) return ''
    const date = new Date(dateString)
    return date.toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    })
  }

  // 轉換表單文件資料格式
  function transformFormDocument (document) {
    // 處理 URL：如果有 storage_path，生成公開 URL；否則使用 url 欄位
    let documentUrl = document.url || ''
    if (document.storage_path) {
      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(document.storage_path)
      documentUrl = publicUrl
    }

    return {
      id: document.id,
      title: document.title,
      description: document.description,
      date: formatDate(document.date),
      type: document.type,
      icon: document.icon,
      color: document.color,
      category: document.category || '',
      url: documentUrl,
    }
  }

  // 轉換聯絡資訊資料格式
  function transformContactInfo (contact) {
    return {
      id: contact.id,
      title: contact.title,
      description: contact.description,
      value: contact.value,
      icon: contact.icon,
      color: contact.color,
      action: contact.action,
      buttonText: contact.button_text,
    }
  }

  // 從 Supabase 載入表單文件
  async function loadFormDocuments () {
    try {
      const { data, error: fetchError } = await supabase
        .from('form_documents')
        .select('*')
        .order('display_order', { ascending: true })
        .order('date', { ascending: false })

      if (fetchError) throw fetchError

      if (data) {
        formDocuments.value = data.map(document => transformFormDocument(document))
      }
    } catch (error_) {
      console.error('載入表單文件失敗:', error_)
      throw error_
    }
  }

  // 從 Supabase 載入聯絡資訊
  async function loadContactInfo () {
    try {
      const { data, error: fetchError } = await supabase
        .from('contact_info')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      if (data) {
        contactInfo.value = data.map(contact => transformContactInfo(contact))
      }
    } catch (error_) {
      console.error('載入聯絡資訊失敗:', error_)
      throw error_
    }
  }

  // 從 Supabase 獲取公務資訊資料
  async function loadPublicAffairsData () {
    loading.value = true
    error.value = null

    try {
      // 並行載入兩個資料表
      await Promise.all([
        loadFormDocuments(),
        loadContactInfo(),
      ])
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入公務資訊資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 計算分頁後的資料
  const paginatedDocuments = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage
    const end = start + itemsPerPage
    return formDocuments.value.slice(start, end)
  })

  // 計算總頁數
  const totalPages = computed(() => {
    return Math.ceil(formDocuments.value.length / itemsPerPage)
  })

  // 元件掛載時載入資料
  onMounted(() => {
    loadPublicAffairsData()
  })
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
            <h2 class="text-h2 text-md-h1 font-weight-bold mb-4 text-white">公務資訊</h2>
            <p class="text-h6 text-white">
              古蹟管理處的公務公告與重要資訊
            </p>
          </v-col>
        </v-row>
      </v-container>
    </div>

    <!-- Form Documents Download -->
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
            @click="loadPublicAffairsData"
          >
            重試
          </v-btn>
        </v-col>
      </v-row>

      <!-- Content -->
      <v-row v-else>
        <v-col
          class="text-center mb-8"
          cols="12"
        >
          <h2 class="text-h3 font-weight-bold mb-4">表單文件下載</h2>
          <p class="text-h6 text-medium-emphasis">
            各類公務表單與文件下載
          </p>
        </v-col>
      </v-row>

      <v-row v-if="!loading && !error">
        <v-col cols="12" md="10" offset-md="1">
            <v-card elevation="2" rounded="lg">
              <v-card-text class="pa-0">
                <v-list>
                  <v-list-item
                  v-for="(document, index) in paginatedDocuments"
                    :key="index"
                    class="border-b"
                  >
                    <template #prepend>
                      <v-icon
                        :color="document.color"
                        :icon="document.icon"
                        size="24"
                      />
                    </template>

                    <v-list-item-title class="text-h6 font-weight-bold mb-1">
                      {{ document.title }}
                    </v-list-item-title>

                    <v-list-item-subtitle class="text-body-2 text-medium-emphasis mb-2">
                      {{ document.description }}
                    </v-list-item-subtitle>

                    <div class="d-flex align-center text-caption text-medium-emphasis">
                      <v-icon
                        class="mr-1"
                        icon="mdi-calendar"
                        size="14"
                      />
                      {{ document.date }}
                      <v-icon
                        class="mr-1 ml-3"
                        icon="mdi-file-document"
                        size="14"
                      />
                      {{ document.type }}
                    <v-chip
                      v-if="document.category"
                      class="ml-3"
                      :color="document.color"
                      size="x-small"
                      variant="tonal"
                    >
                      {{ document.category }}
                    </v-chip>
                    </div>

                    <template #append>
                      <v-btn
                        color="primary"
                        :href="document.url"
                        prepend-icon="mdi-download"
                        size="small"
                        target="_blank"
                        variant="text"
                      >
                        下載
                      </v-btn>
                    </template>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

      <!-- Pagination -->
      <v-row v-if="!loading && !error && totalPages > 1" justify="center">
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

    <!-- Contact Information -->
    <v-container class="py-16">
      <v-row>
        <v-col
          class="text-center mb-8"
          cols="12"
        >
          <h2 class="text-h3 font-weight-bold mb-4">聯絡資訊</h2>
          <p class="text-h6 text-medium-emphasis">
            如有公務相關問題，歡迎與我們聯繫
          </p>
        </v-col>
      </v-row>

      <v-row v-if="!loading && !error">
        <v-col
          v-for="contact in contactInfo"
          :key="contact.title"
          class="mb-6"
          cols="12"
          md="4"
        >
          <v-card
            class="h-100"
            elevation="2"
            rounded="lg"
          >
            <v-card-text class="pa-6 text-center">
              <v-icon
                class="mb-4"
                :color="contact.color"
                :icon="contact.icon"
                size="48"
              />
              <h3 class="text-h5 font-weight-bold mb-3">
                {{ contact.title }}
              </h3>
              <p class="text-body-1 text-medium-emphasis mb-4">
                {{ contact.description }}
              </p>
              <div class="text-h6 font-weight-bold mb-2">
                {{ contact.value }}
              </div>
              <v-btn
                :color="contact.color"
                :href="contact.action"
                rounded
                size="small"
                variant="outlined"
              >
                {{ contact.buttonText }}
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
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
