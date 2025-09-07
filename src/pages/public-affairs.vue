<template>
  <div>
    <!-- Page Header -->
    <v-container class="py-12">
      <v-row justify="center">
        <v-col cols="12" md="8" class="text-center">
          <h1 class="text-h2 text-md-h1 font-weight-bold mb-4">公務資訊</h1>
          <p class="text-h6 text-medium-emphasis">
            古蹟管理處的公務公告與重要資訊
          </p>
        </v-col>
      </v-row>
    </v-container>

    <!-- Quick Stats -->
    <v-container class="pb-8">
      <v-row>
        <v-col
          v-for="stat in quickStats"
          :key="stat.title"
          cols="6"
          md="3"
        >
          <v-card
            :color="stat.color"
            class="text-center"
            rounded="lg"
          >
            <v-card-text class="pa-4">
              <v-icon
                :icon="stat.icon"
                size="32"
                color="white"
                class="mb-2"
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
        <v-col cols="12" class="text-center mb-8">
          <h2 class="text-h3 font-weight-bold mb-4">公務分類</h2>
          <p class="text-h6 text-medium-emphasis">
            各類公務資訊與服務項目
          </p>
        </v-col>
      </v-row>

      <v-row>
        <v-col
          v-for="category in publicAffairsCategories"
          :key="category.title"
          cols="12"
          md="6"
          lg="4"
          class="mb-6"
        >
          <v-card
            class="h-100"
            elevation="2"
            rounded="lg"
            hover
          >
            <v-card-text class="pa-6">
              <div class="d-flex align-center mb-4">
                <v-icon
                  :icon="category.icon"
                  :color="category.color"
                  size="32"
                  class="mr-3"
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
                      icon="mdi-check-circle"
                      :color="category.color"
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
                :color="category.color"
                variant="outlined"
                rounded
                block
              >
                查看詳情
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Recent Documents -->
    <v-container fluid class="py-16" color="surface-variant">
      <v-container>
        <v-row>
          <v-col cols="12" class="text-center mb-8">
            <h2 class="text-h3 font-weight-bold mb-4">最新文件</h2>
            <p class="text-h6 text-medium-emphasis">
              最近發布的重要文件與公告
            </p>
          </v-col>
        </v-row>

        <v-row>
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
                        :icon="document.icon"
                        :color="document.color"
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
                      <v-icon icon="mdi-calendar" size="14" class="mr-1" />
                      {{ document.date }}
                      <v-icon icon="mdi-account" size="14" class="mr-1 ml-3" />
                      {{ document.author }}
                      <v-icon icon="mdi-file-document" size="14" class="mr-1 ml-3" />
                      {{ document.type }}
                    </div>

                    <template #append>
                      <v-btn
                        :href="document.url"
                        target="_blank"
                        color="primary"
                        variant="text"
                        size="small"
                        prepend-icon="mdi-download"
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
        <v-col cols="12" class="text-center mb-8">
          <h2 class="text-h3 font-weight-bold mb-4">聯絡資訊</h2>
          <p class="text-h6 text-medium-emphasis">
            如有公務相關問題，歡迎與我們聯繫
          </p>
        </v-col>
      </v-row>

      <v-row>
        <v-col
          v-for="contact in contactInfo"
          :key="contact.title"
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
                :icon="contact.icon"
                :color="contact.color"
                size="48"
                class="mb-4"
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
                :href="contact.action"
                :color="contact.color"
                variant="outlined"
                rounded
                size="small"
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

<script setup>
import { ref } from 'vue'

const quickStats = [
  {
    title: '待辦事項',
    value: '12',
    icon: 'mdi-clipboard-list',
    color: 'primary'
  },
  {
    title: '本月公告',
    value: '8',
    icon: 'mdi-bullhorn',
    color: 'success'
  },
  {
    title: '處理中案件',
    value: '25',
    icon: 'mdi-cog',
    color: 'info'
  },
  {
    title: '已完成',
    value: '156',
    icon: 'mdi-check-circle',
    color: 'warning'
  }
]

const publicAffairsCategories = [
  {
    title: '法規政策',
    description: '古蹟保護相關法規與政策文件',
    icon: 'mdi-gavel',
    color: 'primary',
    items: [
      '文化資產保存法',
      '古蹟修復準則',
      '管理辦法',
      '申請表格'
    ]
  },
  {
    title: '預算財務',
    description: '年度預算與財務報告',
    icon: 'mdi-calculator',
    color: 'success',
    items: [
      '年度預算書',
      '財務報表',
      '採購公告',
      '決標結果'
    ]
  },
  {
    title: '人事管理',
    description: '人事相關公告與規定',
    icon: 'mdi-account-group',
    color: 'info',
    items: [
      '職缺公告',
      '人事異動',
      '考核辦法',
      '福利制度'
    ]
  },
  {
    title: '工程維護',
    description: '古蹟維護工程相關資訊',
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    items: [
      '工程招標',
      '施工公告',
      '安全檢查',
      '修復報告'
    ]
  },
  {
    title: '教育推廣',
    description: '教育活動與推廣計畫',
    icon: 'mdi-school',
    color: 'error',
    items: [
      '導覽活動',
      '教育課程',
      '文化講座',
      '志工招募'
    ]
  },
  {
    title: '研究報告',
    description: '學術研究與調查報告',
    icon: 'mdi-book-search',
    color: 'purple',
    items: [
      '歷史研究',
      '調查報告',
      '學術論文',
      '文獻整理'
    ]
  }
]

const recentDocuments = [
  {
    title: '2024年度古蹟維護計畫',
    description: '詳細說明本年度古蹟維護工作的規劃與執行方式',
    date: '2024-01-15',
    author: '維護部',
    type: 'PDF',
    icon: 'mdi-file-document',
    color: 'primary',
    url: '#'
  },
  {
    title: '古蹟參觀導覽服務公告',
    description: '提供專業導覽服務，歡迎民眾預約參觀',
    date: '2024-01-12',
    author: '教育推廣部',
    type: 'DOC',
    icon: 'mdi-bullhorn',
    color: 'success',
    url: '#'
  },
  {
    title: '古蹟修復工程招標公告',
    description: '公開招標古蹟修復工程，歡迎合格廠商投標',
    date: '2024-01-10',
    author: '工程部',
    type: 'PDF',
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    url: '#'
  },
  {
    title: '古蹟管理處人事異動公告',
    description: '公告最新人事異動情況與職務調整',
    date: '2024-01-08',
    author: '人事部',
    type: 'DOC',
    icon: 'mdi-account-group',
    color: 'info',
    url: '#'
  },
  {
    title: '古蹟歷史研究報告',
    description: '最新完成的古蹟歷史研究與文獻整理報告',
    date: '2024-01-05',
    author: '研究部',
    type: 'PDF',
    icon: 'mdi-book-search',
    color: 'purple',
    url: '#'
  }
]

const contactInfo = [
  {
    title: '總機電話',
    description: '古蹟管理處總機',
    value: '02-1234-5678',
    icon: 'mdi-phone',
    color: 'primary',
    action: 'tel:02-1234-5678',
    buttonText: '撥打電話'
  },
  {
    title: '電子信箱',
    description: '公務信箱',
    value: 'info@monument.gov.tw',
    icon: 'mdi-email',
    color: 'success',
    action: 'mailto:info@monument.gov.tw',
    buttonText: '發送郵件'
  },
  {
    title: '地址',
    description: '古蹟管理處地址',
    value: '台北市中正區重慶南路一段122號',
    icon: 'mdi-map-marker',
    color: 'info',
    action: 'https://maps.google.com',
    buttonText: '查看地圖'
  }
]
</script>

