<template>
  <div>
    <!-- Hero Section -->
    <v-container fluid class="pa-0">
      <v-row no-gutters>
        <v-col cols="12">
          <v-img
            :src="monumentImage"
            height="600"
            cover
            class="d-flex align-center"
          >
            <v-overlay
              :model-value="true"
              contained
              class="d-flex align-center justify-center"
            >
              <v-container>
                <v-row justify="center">
                  <v-col cols="12" md="8" class="text-center">
                    <h1 class="text-h2 text-md-h1 font-weight-bold text-white mb-4">
                      探索歷史古蹟之美
                    </h1>
                    <p class="text-h6 text-white mb-6">
                      深入了解這座珍貴古蹟的歷史沿革、組織架構與文化價值
                    </p>
                    <v-btn
                      color="primary"
                      size="large"
                      rounded
                      class="text-h6 px-8"
                      to="/history"
                    >
                      開始探索
                    </v-btn>
                  </v-col>
                </v-row>
              </v-container>
            </v-overlay>
          </v-img>
        </v-col>
      </v-row>
    </v-container>

    <!-- Features Section -->
    <v-container class="py-16">
      <v-row>
        <v-col cols="12" class="text-center mb-12">
          <h2 class="text-h3 font-weight-bold mb-4">古蹟資訊</h2>
          <p class="text-h6 text-medium-emphasis">
            深入了解這座古蹟的豐富歷史與文化內涵
          </p>
        </v-col>
      </v-row>

      <v-row>
        <v-col
          v-for="feature in features"
          :key="feature.title"
          cols="12"
          md="4"
          class="mb-6"
        >
          <v-card
            class="h-100"
            elevation="2"
            rounded="lg"
            hover
          >
            <v-card-text class="pa-8 text-center">
              <v-icon
                :icon="feature.icon"
                size="64"
                :color="feature.color"
                class="mb-4"
              />
              <h3 class="text-h5 font-weight-bold mb-3">
                {{ feature.title }}
              </h3>
              <p class="text-body-1 text-medium-emphasis">
                {{ feature.description }}
              </p>
            </v-card-text>
            <v-card-actions class="justify-center pb-6">
              <v-btn
                :to="feature.to"
                color="primary"
                variant="outlined"
                rounded
              >
                了解更多
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Statistics Section -->
    <v-container fluid class="py-16" color="primary">
      <v-container>
        <v-row>
          <v-col
            v-for="stat in statistics"
            :key="stat.label"
            cols="6"
            md="3"
            class="text-center"
          >
            <div class="text-h2 font-weight-bold text-white mb-2">
              {{ stat.value }}
            </div>
            <div class="text-h6 text-white">
              {{ stat.label }}
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-container>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const monumentImage = ref('/S__45940821.jpg')

const features = [
  {
    title: '歷史沿革',
    description: '探索古蹟的建造背景、歷史變遷與文化意義',
    icon: 'mdi-history',
    color: 'primary',
    to: '/history'
  },
  {
    title: '組織架構',
    description: '了解古蹟管理組織的結構與運作方式',
    icon: 'mdi-account-group',
    color: 'success',
    to: '/organization'
  },
  {
    title: '理事公務',
    description: '查看理事會成員與相關公務資訊',
    icon: 'mdi-account-tie',
    color: 'info',
    to: '/directors'
  },
  {
    title: '公務資訊',
    description: '瀏覽古蹟相關的公務公告與重要資訊',
    icon: 'mdi-file-document',
    color: 'warning',
    to: '/public-affairs'
  },
  {
    title: '最新公告',
    description: '掌握古蹟管理處的最新公告與消息',
    icon: 'mdi-bullhorn',
    color: 'error',
    to: '/announcements'
  }
]

const statistics = [
  { value: '200+', label: '年歷史' },
  { value: '50+', label: '重要文物' },
  { value: '1000+', label: '參觀人次' },
  { value: '5', label: '星級評等' }
]
</script>
