<script setup>
  import { onMounted, ref } from 'vue'
  import { fetchHistoryData } from '@/apis/mocks/historyApi'

  const timelineEvents = ref([])
  const historicalSignificance = ref([])
  const loading = ref(false)
  const error = ref(null)

  // 從 API 獲取歷史資料
  async function loadHistoryData () {
    loading.value = true
    error.value = null

    try {
      const data = await fetchHistoryData()
      timelineEvents.value = data.timelineEvents
      historicalSignificance.value = data.historicalSignificance
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
                      cover
                      height="200"
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
                <v-icon
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
