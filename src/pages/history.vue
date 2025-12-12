<script setup>
  import { onMounted, ref } from 'vue'
  import { supabase } from '@/lib/supabaseClient'

  const timelineEvents = ref([])
  const historicalSignificance = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Storage bucket 名稱
  const BUCKET_NAME = 'wanxuanju-files'

  // 轉換時間軸事件資料格式
  function transformTimelineEvent (event) {
    // 處理圖片 URL：優先使用 image_url，如果有 storage_path 則生成公開 URL
    let imageUrl = null
    if (event.image_url) {
      imageUrl = event.image_url
    } else if (event.storage_path) {
      // 從 Supabase Storage 生成公開 URL
      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(event.storage_path)
      imageUrl = publicUrl
    }

    return {
      year: event.year,
      title: event.title,
      description: event.description,
      icon: event.icon || 'mdi-calendar',
      color: event.color || 'primary',
      image: imageUrl,
    }
  }

  // 轉換歷史意義資料格式
  function transformSignificance (item) {
    // 處理圖片 URL：優先使用 image_url，如果有 storage_path 則生成公開 URL
    let imageUrl = null
    if (item.image_url) {
      imageUrl = item.image_url
    } else if (item.storage_path) {
      // 從 Supabase Storage 生成公開 URL
      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(item.storage_path)
      imageUrl = publicUrl
    }

    return {
      title: item.title,
      description: item.description,
      icon: item.icon || 'mdi-information',
      color: item.color || 'primary',
      image: imageUrl,
    }
  }

  // 從 Supabase 載入時間軸事件
  async function loadTimelineEvents () {
    try {
      const { data, error: fetchError } = await supabase
        .from('history_timeline_events')
        .select('*')
        .order('display_order', { ascending: true })
        .order('year', { ascending: true })

      if (fetchError) throw fetchError

      if (data) {
        timelineEvents.value = data.map(event => transformTimelineEvent(event))
      }
    } catch (error_) {
      console.error('載入時間軸事件失敗:', error_)
      throw error_
    }
  }

  // 從 Supabase 載入歷史意義資料
  async function loadHistoricalSignificance () {
    try {
      const { data, error: fetchError } = await supabase
        .from('history_significance')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      if (data) {
        historicalSignificance.value = data.map(item => transformSignificance(item))
      }
    } catch (error_) {
      console.error('載入歷史意義資料失敗:', error_)
      throw error_
    }
  }

  // 從 Supabase 獲取歷史資料
  async function loadHistoryData () {
    loading.value = true
    error.value = null

    try {
      // 並行載入兩個資料表
      await Promise.all([
        loadTimelineEvents(),
        loadHistoricalSignificance(),
      ])
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入歷史資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(() => {
    loadHistoryData()
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
            <h2 class="text-h2 text-md-h1 font-weight-bold mb-4 text-white">歷史沿革</h2>
            <p class="text-h6 text-white">
              探索這座珍貴古蹟的建造背景與歷史變遷
            </p>
          </v-col>
        </v-row>
      </v-container>
    </div>

    <!-- Timeline Section -->
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
            @click="loadHistoryData"
          >
            重試
          </v-btn>
        </v-col>
      </v-row>

      <!-- Timeline Content -->
      <v-row v-else>
        <v-col cols="12" md="8" offset-md="2">
          <v-timeline
            align="start"
            line-color="primary"
            line-thickness="3"
            side="end"
          >
            <v-timeline-item
              v-for="(event, index) in timelineEvents"
              :key="index"
              :dot-color="event.color"
              size="large"
            >
              <template #icon>
                <v-icon :color="event.color" size="24">
                  {{ event.icon }}
                </v-icon>
              </template>

              <v-card
                class="mb-4"
                elevation="2"
                rounded="lg"
              >
                <v-card-text class="pa-6">
                  <div class="d-flex align-center mb-3">
                    <v-chip
                      class="mr-3"
                      :color="event.color"
                      size="small"
                    >
                      {{ event.year }}
                    </v-chip>
                    <h3 class="text-h5 font-weight-bold">
                      {{ event.title }}
                    </h3>
                  </div>
                  <p class="text-body-1 text-medium-emphasis">
                    {{ event.description }}
                  </p>
                  <div v-if="event.image" class="mt-4">
                    <v-img
                      contain
                      max-height="800"
                      min-width="400"
                      rounded="lg"
                      :src="event.image"
                    />
                  </div>
                </v-card-text>
              </v-card>
            </v-timeline-item>
          </v-timeline>
        </v-col>
      </v-row>
    </v-container>

    <!-- Historical Significance -->
    <v-container
      class="py-16"
      color="surface-variant"
      fluid
    >
      <v-container>
        <v-row>
          <v-col
            class="text-center mb-8"
            cols="12"
          >
            <h2 class="text-h3 font-weight-bold mb-4">歷史意義</h2>
            <p class="text-h6 text-medium-emphasis">
              這座古蹟在歷史上的重要地位與文化價值
            </p>
          </v-col>
        </v-row>

        <v-row v-if="!loading && !error">
          <v-col
            v-for="significance in historicalSignificance"
            :key="significance.title"
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
                <div v-if="significance.image" class="mb-4">
                  <v-img
                    contain
                    max-height="200"
                    min-width="200"
                    rounded="lg"
                    :src="significance.image"
                  />
                </div>
                <v-icon
                  v-else
                  class="mb-4"
                  :color="significance.color"
                  :icon="significance.icon"
                  size="48"
                />
                <h3 class="text-h5 font-weight-bold mb-3">
                  {{ significance.title }}
                </h3>
                <p class="text-body-1 text-medium-emphasis">
                  {{ significance.description }}
                </p>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
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
