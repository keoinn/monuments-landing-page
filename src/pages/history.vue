<template>
  <div>
    <!-- Page Header -->
    <v-container class="py-12">
      <v-row justify="center">
        <v-col cols="12" md="8" class="text-center">
          <h1 class="text-h2 text-md-h1 font-weight-bold mb-4">歷史沿革</h1>
          <p class="text-h6 text-medium-emphasis">
            探索這座珍貴古蹟的建造背景與歷史變遷
          </p>
        </v-col>
      </v-row>
    </v-container>

    <!-- Timeline Section -->
    <v-container class="pb-16">
      <v-row>
        <v-col cols="12" md="8" offset-md="2">
          <v-timeline
            side="end"
            align="start"
            line-color="primary"
            line-thickness="3"
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
                      :color="event.color"
                      size="small"
                      class="mr-3"
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
                      :src="event.image"
                      height="200"
                      cover
                      rounded="lg"
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
    <v-container fluid class="py-16" color="surface-variant">
      <v-container>
        <v-row>
          <v-col cols="12" class="text-center mb-8">
            <h2 class="text-h3 font-weight-bold mb-4">歷史意義</h2>
            <p class="text-h6 text-medium-emphasis">
              這座古蹟在歷史上的重要地位與文化價值
            </p>
          </v-col>
        </v-row>

        <v-row>
          <v-col
            v-for="significance in historicalSignificance"
            :key="significance.title"
            cols="12"
            md="4"
            class="mb-6"
          >
            <v-card
              class="h-100"
              elevation="2"
              rounded="lg"
            >
              <v-card-text class="pa-6 text-center">
                <v-icon
                  :icon="significance.icon"
                  size="48"
                  :color="significance.color"
                  class="mb-4"
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

<script setup>
import { ref } from 'vue'
import landingViewImage from '@/assets/img/landing-view.webp'

const timelineEvents = [
  {
    year: '1820',
    title: '古蹟建造',
    description: '這座古蹟始建於清朝道光年間，最初作為地方官員的辦公場所，見證了當時的政治與社會變遷。建築風格融合了傳統中式建築與當時的時代特色。',
    icon: 'mdi-home',
    color: 'primary',
    image: landingViewImage
  },
  {
    year: '1895',
    title: '日治時期',
    description: '進入日治時期後，建築物被重新規劃使用，成為重要的行政中心。在此期間，建築物經歷了部分改建，但仍保持原有的基本結構。',
    icon: 'mdi-flag',
    color: 'success',
    image: null
  },
  {
    year: '1945',
    title: '戰後重建',
    description: '第二次世界大戰結束後，建築物在戰火中受損，經過精心修復後重新開放。這個時期標誌著古蹟保護意識的萌芽。',
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    image: null
  },
  {
    year: '1985',
    title: '列為古蹟',
    description: '正式被政府列為歷史古蹟，開始受到法律保護。這標誌著古蹟保護工作進入新的階段，也為後續的修復與維護奠定了基礎。',
    icon: 'mdi-shield-star',
    color: 'info',
    image: null
  },
  {
    year: '2000',
    title: '全面修復',
    description: '進行了全面的修復工程，採用傳統工法與現代技術相結合的方式，確保古蹟的結構安全與歷史風貌的完整性。',
    icon: 'mdi-tools',
    color: 'error',
    image: null
  }
]

const historicalSignificance = [
  {
    title: '建築藝術',
    description: '展現了清朝中後期的建築特色，融合了傳統工藝與時代美學，是研究當時建築技術的重要實例。',
    icon: 'mdi-palette',
    color: 'primary'
  },
  {
    title: '歷史見證',
    description: '見證了從清朝到現代的重要歷史變遷，承載了豐富的歷史記憶與文化內涵。',
    icon: 'mdi-book-open',
    color: 'success'
  },
  {
    title: '文化傳承',
    description: '作為重要的文化載體，傳承了當地的歷史文化，是後代了解過去的重要窗口。',
    icon: 'mdi-account-group',
    color: 'info'
  }
]
</script>

