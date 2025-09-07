<template>
  <div>
    <!-- Page Header -->
    <v-container class="py-12">
      <v-row justify="center">
        <v-col cols="12" md="8" class="text-center">
          <h1 class="text-h2 text-md-h1 font-weight-bold mb-4">組織架構</h1>
          <p class="text-h6 text-medium-emphasis">
            了解古蹟管理組織的結構與運作方式
          </p>
        </v-col>
      </v-row>
    </v-container>

    <!-- Organization Chart -->
    <v-container class="pb-16">
      <v-row>
        <v-col cols="12" class="text-center mb-8">
          <h2 class="text-h3 font-weight-bold mb-4">組織架構圖</h2>
          <p class="text-h6 text-medium-emphasis">
            古蹟管理處的完整組織架構與職責分工
          </p>
        </v-col>
      </v-row>

      <v-row justify="center">
        <v-col cols="12" md="10">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-8">
              <div class="organization-chart">
                <!-- 理事長 -->
                <div class="org-level-1 text-center mb-6">
                  <v-card
                    color="primary"
                    class="mx-auto"
                    style="max-width: 300px;"
                    rounded="lg"
                  >
                    <v-card-text class="pa-4">
                      <v-icon size="32" color="white" class="mb-2">mdi-account-tie</v-icon>
                      <div class="text-h6 font-weight-bold text-white">理事長</div>
                      <div class="text-body-2 text-white">張文華</div>
                    </v-card-text>
                  </v-card>
                </div>

                <!-- 副理事長 -->
                <div class="org-level-2 text-center mb-6">
                  <v-row justify="center">
                    <v-col cols="12" md="6">
                      <v-card
                        color="success"
                        class="mx-auto"
                        style="max-width: 250px;"
                        rounded="lg"
                      >
                        <v-card-text class="pa-4">
                          <v-icon size="28" color="white" class="mb-2">mdi-account-tie-outline</v-icon>
                          <div class="text-h6 font-weight-bold text-white">副理事長</div>
                          <div class="text-body-2 text-white">李美玲</div>
                        </v-card-text>
                      </v-card>
                    </v-col>
                  </v-row>
                </div>

                <!-- 各部門 -->
                <div class="org-level-3">
                  <v-row>
                    <v-col
                      v-for="department in departments"
                      :key="department.name"
                      cols="12"
                      md="4"
                      class="mb-4"
                    >
                      <v-card
                        :color="department.color"
                        class="h-100"
                        rounded="lg"
                      >
                        <v-card-text class="pa-4 text-center">
                          <v-icon
                            :icon="department.icon"
                            size="24"
                            color="white"
                            class="mb-2"
                          />
                          <div class="text-subtitle-1 font-weight-bold text-white mb-1">
                            {{ department.name }}
                          </div>
                          <div class="text-body-2 text-white mb-2">
                            {{ department.manager }}
                          </div>
                          <div class="text-caption text-white">
                            {{ department.description }}
                          </div>
                        </v-card-text>
                      </v-card>
                    </v-col>
                  </v-row>
                </div>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Department Details -->
    <v-container fluid class="py-16" color="surface-variant">
      <v-container>
        <v-row>
          <v-col cols="12" class="text-center mb-8">
            <h2 class="text-h3 font-weight-bold mb-4">部門職責</h2>
            <p class="text-h6 text-medium-emphasis">
              各部門的詳細職責與工作內容
            </p>
          </v-col>
        </v-row>

        <v-row>
                    <v-col
                      v-for="department in departments"
                      :key="department.name"
                      cols="12"
                      md="6"
                      class="mb-6"
                    >
            <v-card
              class="h-100"
              elevation="2"
              rounded="lg"
            >
              <v-card-text class="pa-6">
                <div class="d-flex align-center mb-4">
                  <v-icon
                    :icon="department.icon"
                    :color="department.color"
                    size="32"
                    class="mr-3"
                  />
                  <h3 class="text-h5 font-weight-bold">
                    {{ department.name }}
                  </h3>
                </div>
                <p class="text-body-1 text-medium-emphasis mb-4">
                  {{ department.description }}
                </p>
                <div class="mb-4">
                  <h4 class="text-subtitle-1 font-weight-bold mb-2">主要職責：</h4>
                  <v-list density="compact">
                    <v-list-item
                      v-for="responsibility in department.responsibilities"
                      :key="responsibility"
                      class="px-0"
                    >
                      <template #prepend>
                        <v-icon
                          icon="mdi-check-circle"
                          :color="department.color"
                          size="16"
                        />
                      </template>
                      <v-list-item-title class="text-body-2">
                        {{ responsibility }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
                <div>
                  <h4 class="text-subtitle-1 font-weight-bold mb-2">聯絡方式：</h4>
                  <div class="text-body-2">
                    <div class="mb-1">
                      <v-icon icon="mdi-account" size="16" class="mr-2" />
                      負責人：{{ department.manager }}
                    </div>
                    <div class="mb-1">
                      <v-icon icon="mdi-phone" size="16" class="mr-2" />
                      電話：{{ department.phone }}
                    </div>
                    <div>
                      <v-icon icon="mdi-email" size="16" class="mr-2" />
                      信箱：{{ department.email }}
                    </div>
                  </div>
                </div>
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

const departments = [
  {
    name: '行政部',
    manager: '王建國',
    description: '負責古蹟管理處的日常行政事務與人事管理',
    icon: 'mdi-office-building',
    color: 'primary',
    phone: '02-1234-5678',
    email: 'admin@monument.gov.tw',
    responsibilities: [
      '人事管理與員工培訓',
      '財務預算編列與執行',
      '文書處理與檔案管理',
      '對外聯絡與協調',
      '會議安排與記錄'
    ]
  },
  {
    name: '維護部',
    manager: '陳志明',
    description: '負責古蹟的日常維護與修復工作',
    icon: 'mdi-hammer-wrench',
    color: 'success',
    phone: '02-1234-5679',
    email: 'maintenance@monument.gov.tw',
    responsibilities: [
      '古蹟結構安全檢查',
      '日常清潔與保養',
      '修復工程規劃與執行',
      '設備維護與更新',
      '安全監控系統管理'
    ]
  },
  {
    name: '教育推廣部',
    manager: '林雅婷',
    description: '負責古蹟的教育推廣與文化活動',
    icon: 'mdi-school',
    color: 'info',
    phone: '02-1234-5680',
    email: 'education@monument.gov.tw',
    responsibilities: [
      '導覽服務與解說',
      '教育活動規劃與執行',
      '文化推廣活動',
      '志工培訓與管理',
      '文宣品製作與發行'
    ]
  },
  {
    name: '研究部',
    manager: '黃文博',
    description: '負責古蹟的學術研究與文獻整理',
    icon: 'mdi-book-search',
    color: 'warning',
    phone: '02-1234-5681',
    email: 'research@monument.gov.tw',
    responsibilities: [
      '古蹟歷史研究',
      '文獻資料整理',
      '學術論文發表',
      '國際交流合作',
      '數位典藏建置'
    ]
  },
  {
    name: '財務部',
    manager: '劉美惠',
    description: '負責古蹟管理處的財務管理與會計事務',
    icon: 'mdi-calculator',
    color: 'error',
    phone: '02-1234-5682',
    email: 'finance@monument.gov.tw',
    responsibilities: [
      '預算編列與執行',
      '會計帳務處理',
      '財務報表製作',
      '採購管理',
      '成本控制與分析'
    ]
  },
  {
    name: '資訊部',
    manager: '張志強',
    description: '負責古蹟管理處的資訊系統與數位化服務',
    icon: 'mdi-laptop',
    color: 'purple',
    phone: '02-1234-5683',
    email: 'it@monument.gov.tw',
    responsibilities: [
      '資訊系統維護',
      '網站管理與更新',
      '數位化服務開發',
      '網路安全維護',
      '技術支援服務'
    ]
  }
]
</script>

<style scoped>
.organization-chart {
  position: relative;
}

.org-level-1::after,
.org-level-2::after {
  content: '';
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  background-color: rgb(var(--v-theme-primary));
}

.org-level-1::after {
  height: 40px;
  bottom: -40px;
}

.org-level-2::after {
  height: 40px;
  bottom: -40px;
}
</style>
