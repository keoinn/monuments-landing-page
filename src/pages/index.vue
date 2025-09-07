<template>
  <div>
    <!-- Hero Section -->
    <div class="hero-section">
      <v-img
        height="100vh"
        cover
        class="d-flex align-center"
        :src="monumentImage"
      >
            <v-overlay
              contained
              class="d-flex align-center justify-center"
              no-click-animation
              persistent
              :model-value="true"
            >
              <v-container class="hero-content-container">
                <v-row justify="center">
                  <v-col cols="12" md="8" class="text-center d-flex flex-column align-center justify-center">
                    <h1 class="hero-title text-h2 text-md-h1 font-weight-bold mb-4">
                      青錢萬選
                    </h1>
                    <p class="text-h6 text-white mb-6 hero-description">
                      深入了解這座珍貴古蹟的歷史沿革、組織架構與文化價值
                    </p>
                    <v-btn
                      color="primary"
                      size="large"
                      rounded
                      class="text-h6 px-8 hero-button"
                      to="/history"
                    >
                      開始探索
                    </v-btn>
                  </v-col>
                </v-row>
              </v-container>
            </v-overlay>
          </v-img>
    </div>

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
    <v-container fluid class="py-16 bg-primary">
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
import landingViewImage from '@/assets/img/landing-view.jpg'

const monumentImage = ref(landingViewImage)

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

<style scoped>
.hero-section {
  position: relative;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.hero-section .v-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 響應式調整 */
@media (max-width: 768px) {
  .hero-section {
    height: 100vh;
  }
}

@media (max-width: 480px) {
  .hero-section {
    height: 100vh;
  }
}

/* 確保圖片在各種螢幕比例下都能填滿 */
@media (orientation: landscape) and (max-height: 500px) {
  .hero-section {
    height: 100vh;
  }
}

/* Hero 內容容器樣式 */
.hero-content-container {
  transform: translateY(-25%) translateX(-10%) !important;
  position: relative;
  z-index: 1;
}

/* 描述文字樣式 */
.hero-description {
  transform: translateX(15%) !important;
  position: relative;
  z-index: 1;
  white-space: normal !important;
  line-height: 1.4 !important;
  max-width: 400px !important;
  text-align: center !important;
}

/* 按鈕樣式 */
.hero-button {
  transform: translateX(30%) !important;
  position: relative;
  z-index: 1;
}

/* 標題美化樣式 */
.hero-title {
  color: #ffffff;
  text-shadow: 
    0 0 10px rgba(0, 0, 0, 0.8),
    0 0 20px rgba(0, 0, 0, 0.6),
    0 0 30px rgba(0, 0, 0, 0.4);
  position: relative;
  padding: 20px 30px;
  border-radius: 15px;
  background: linear-gradient(145deg, 
    rgba(139, 69, 19, 0.85) 0%, 
    rgba(160, 82, 45, 0.85) 25%,
    rgba(205, 133, 63, 0.85) 50%,
    rgba(222, 184, 135, 0.85) 75%,
    rgba(245, 222, 179, 0.85) 100%);
  border: 3px solid rgba(255, 215, 0, 0.6);
  box-shadow: 
    0 10px 40px rgba(0, 0, 0, 0.4),
    0 0 0 1px rgba(255, 255, 255, 0.1),
    inset 0 2px 0 rgba(255, 255, 255, 0.3);
  display: inline-block;
  margin: 0 auto;
  font-family: 'Noto Serif TC', serif;
  letter-spacing: 0.1em;
  white-space: nowrap;
  transform: perspective(1000px) rotateX(5deg);
  transition: all 0.3s ease;
}

.hero-title:hover {
  transform: perspective(1000px) rotateX(0deg) scale(1.05);
  box-shadow:
    0 15px 50px rgba(0, 0, 0, 0.5),
    0 0 0 1px rgba(255, 255, 255, 0.2),
    inset 0 2px 0 rgba(255, 255, 255, 0.4);
}

.hero-title::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg, 
    #ffd700, #ffed4e, #ffd700, #ffed4e);
  border-radius: 17px;
  z-index: -1;
  animation: shimmer 3s ease-in-out infinite;
}

@keyframes shimmer {
  0%, 100% { opacity: 0.8; }
  50% { opacity: 1; }
}

/* 響應式標題調整 */
@media (min-width: 960px) {
  .hero-content-container {
    transform: translateY(-25%) translateX(-10%) !important;
  }
  
  .hero-description {
    transform: translateX(25%) !important;
    white-space: normal !important;
    line-height: 1.4 !important;
    max-width: 400px !important;
    text-align: center !important;
  }
  
  .hero-button {
    transform: translateX(40%) !important;
  }
}

@media (min-width: 769px) and (max-width: 959px) {
  .hero-content-container {
    transform: translateY(-25%) translateX(0%) !important;
  }
  
  .hero-description {
    transform: translateX(0%) !important;
    white-space: normal !important;
    line-height: 1.4 !important;
    max-width: 350px !important;
    text-align: center !important;
  }
  
  .hero-button {
    transform: translateX(0%) !important;
  }
}

@media (min-width: 480px) and (max-width: 768px) {
  .hero-content-container {
    transform: translateY(-25%) translateX(0%) !important;
  }
  
  .hero-description {
    transform: translateX(0%) !important;
    white-space: normal !important;
    line-height: 1.4 !important;
    max-width: 300px !important;
    text-align: center !important;
  }
  
  .hero-button {
    transform: translateX(0%) !important;
  }
}

@media (min-width: 363px) and (max-width: 479px) {
  .hero-content-container {
    transform: translateY(-25%) translateX(0%) !important;
  }
  
  .hero-description {
    transform: translateX(0%) !important;
    white-space: normal !important;
    line-height: 1.4 !important;
    max-width: 280px !important;
    text-align: center !important;
  }
  
  .hero-button {
    transform: translateX(0%) !important;
  }
}

@media (max-width: 362px) {
  .hero-content-container {
    transform: translateY(-25%) translateX(0%) !important;
  }
  
  .hero-description {
    transform: translateX(0%) !important;
    white-space: normal !important;
    line-height: 1.4 !important;
    max-width: 250px !important;
    text-align: center !important;
  }
  
  .hero-button {
    transform: translateX(0%) !important;
  }
}

@media (max-width: 768px) {
  .hero-title {
    padding: 20px 35px;
    font-size: 2.2rem !important;
    transform: perspective(1000px) rotateX(2deg);
    white-space: nowrap;
  }
  
  .hero-title:hover {
    transform: perspective(1000px) rotateX(0deg) scale(1.02);
  }
}

@media (max-width: 480px) {
  .hero-title {
    padding: 15px 25px;
    font-size: 1.8rem !important;
    transform: perspective(1000px) rotateX(1deg);
    letter-spacing: 0.05em;
    white-space: nowrap;
  }
  
  .hero-title:hover {
    transform: perspective(1000px) rotateX(0deg) scale(1.01);
  }
}

@media (max-width: 360px) {
  .hero-title {
    padding: 12px 20px;
    font-size: 1.5rem !important;
    letter-spacing: 0.03em;
    white-space: nowrap;
  }
}
</style>
