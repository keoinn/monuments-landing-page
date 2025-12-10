<script setup>
  import { onMounted, ref } from 'vue'
  import { fetchPublicAffairsData } from '@/apis/mocks/publicAffairsApi'

  const quickStats = ref([])
  const publicAffairsCategories = ref([])
  const recentDocuments = ref([])
  const contactInfo = ref([])
  const loading = ref(false)
  const error = ref(null)

  // 從 API 獲取公務資訊資料
  async function loadPublicAffairsData () {
    loading.value = true
    error.value = null

    try {
      const data = await fetchPublicAffairsData()
      quickStats.value = data.quickStats
      publicAffairsCategories.value = data.publicAffairsCategories
      recentDocuments.value = data.recentDocuments
      contactInfo.value = data.contactInfo
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入公務資訊資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

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

    <!-- Quick Stats -->
    <v-container class="pb-8">
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

      <!-- Quick Stats Content -->
      <v-row v-else>
        <v-col
          v-for="stat in quickStats"
          :key="stat.title"
          cols="6"
          md="3"
        >
          <v-card
            class="text-center"
            :color="stat.color"
            rounded="lg"
          >
            <v-card-text class="pa-4">
              <v-icon
                class="mb-2"
                color="white"
                :icon="stat.icon"
                size="32"
              />
              <div class="text-h4 font-weight-bold text-white mb-1">
                {{ stat.value }}
              </div>
              <div class="text-body-2 text-white">
                {{ stat.title }}
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Public Affairs Categories -->
    <v-container class="pb-16">
      <v-row>
        <v-col
          class="text-center mb-8"
          cols="12"
        >
          <h2 class="text-h3 font-weight-bold mb-4">公務分類</h2>
          <p class="text-h6 text-medium-emphasis">
            各類公務資訊與服務項目
          </p>
        </v-col>
      </v-row>

      <v-row v-if="!loading && !error">
        <v-col
          v-for="category in publicAffairsCategories"
          :key="category.title"
          class="mb-6"
          cols="12"
          lg="4"
          md="6"
        >
          <v-card
            class="h-100"
            elevation="2"
            hover
            rounded="lg"
          >
            <v-card-text class="pa-6">
              <div class="d-flex align-center mb-4">
                <v-icon
                  class="mr-3"
                  :color="category.color"
                  :icon="category.icon"
                  size="32"
                />
                <h3 class="text-h5 font-weight-bold">
                  {{ category.title }}
                </h3>
              </div>
              <p class="text-body-1 text-medium-emphasis mb-4">
                {{ category.description }}
              </p>
              <v-list density="compact">
                <v-list-item
                  v-for="item in category.items"
                  :key="item"
                  class="px-0"
                >
                  <template #prepend>
                    <v-icon
                      :color="category.color"
                      icon="mdi-check-circle"
                      size="16"
                    />
                  </template>
                  <v-list-item-title class="text-body-2">
                    {{ item }}
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-card-text>
            <v-card-actions class="pa-6 pt-0">
              <v-btn
                block
                :color="category.color"
                rounded
                variant="outlined"
              >
                查看詳情
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Recent Documents -->
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
            <h2 class="text-h3 font-weight-bold mb-4">最新文件</h2>
            <p class="text-h6 text-medium-emphasis">
              最近發布的重要文件與公告
            </p>
          </v-col>
        </v-row>

        <v-row v-if="!loading && !error">
          <v-col cols="12" md="8" offset-md="2">
            <v-card elevation="2" rounded="lg">
              <v-card-text class="pa-0">
                <v-list>
                  <v-list-item
                    v-for="(document, index) in recentDocuments"
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
                        icon="mdi-account"
                        size="14"
                      />
                      {{ document.author }}
                      <v-icon
                        class="mr-1 ml-3"
                        icon="mdi-file-document"
                        size="14"
                      />
                      {{ document.type }}
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
      </v-container>
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
