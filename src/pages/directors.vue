<template>
  <div>
    <!-- Page Header -->
    <v-container class="py-12">
      <v-row justify="center">
        <v-col cols="12" md="8" class="text-center">
          <h1 class="text-h2 text-md-h1 font-weight-bold mb-4">理事公</h1>
          <p class="text-h6 text-medium-emphasis">
            認識古蹟管理處的理事會成員與其專業背景
          </p>
        </v-col>
      </v-row>
    </v-container>

    <!-- Board Members -->
    <v-container class="pb-16">
      <v-row>
        <v-col cols="12" class="text-center mb-8">
          <h2 class="text-h3 font-weight-bold mb-4">理事會成員</h2>
          <p class="text-h6 text-medium-emphasis">
            由各界專業人士組成的理事會，共同推動古蹟保護與文化傳承
          </p>
        </v-col>
      </v-row>

      <v-row>
        <v-col
          v-for="member in boardMembers"
          :key="member.name"
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
            <v-img
              :src="member.photo"
              height="300"
              cover
              class="position-relative"
            >
              <v-overlay
                :model-value="true"
                contained
                class="d-flex align-end"
              >
                <div class="pa-4">
                  <v-chip
                    :color="member.role === '理事長' ? 'primary' : 'success'"
                    size="small"
                    class="mb-2"
                  >
                    {{ member.role }}
                  </v-chip>
                </div>
              </v-overlay>
            </v-img>

            <v-card-text class="pa-6">
              <h3 class="text-h5 font-weight-bold mb-2">
                {{ member.name }}
              </h3>
              <p class="text-subtitle-1 text-medium-emphasis mb-3">
                {{ member.title }}
              </p>
              <p class="text-body-2 text-medium-emphasis mb-4">
                {{ member.description }}
              </p>

              <div class="mb-4">
                <h4 class="text-subtitle-2 font-weight-bold mb-2">專業領域：</h4>
                <div class="d-flex flex-wrap gap-1">
                  <v-chip
                    v-for="expertise in member.expertise"
                    :key="expertise"
                    size="small"
                    variant="outlined"
                  >
                    {{ expertise }}
                  </v-chip>
                </div>
              </div>

              <div class="mb-4">
                <h4 class="text-subtitle-2 font-weight-bold mb-2">學歷：</h4>
                <p class="text-body-2">{{ member.education }}</p>
              </div>

              <div>
                <h4 class="text-subtitle-2 font-weight-bold mb-2">經歷：</h4>
                <ul class="text-body-2 pl-4">
                  <li
                    v-for="experience in member.experience"
                    :key="experience"
                    class="mb-1"
                  >
                    {{ experience }}
                  </li>
                </ul>
              </div>
            </v-card-text>

            <v-card-actions class="pa-6 pt-0">
              <v-btn
                :href="`mailto:${member.email}`"
                color="primary"
                variant="outlined"
                size="small"
                prepend-icon="mdi-email"
              >
                聯絡
              </v-btn>
              <v-spacer />
              <v-btn
                :href="member.linkedin"
                target="_blank"
                icon="mdi-linkedin"
                size="small"
                variant="text"
              />
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Board Structure -->
    <v-container fluid class="py-16" color="surface-variant">
      <v-container>
        <v-row>
          <v-col cols="12" class="text-center mb-8">
            <h2 class="text-h3 font-weight-bold mb-4">理事會架構</h2>
            <p class="text-h6 text-medium-emphasis">
              理事會的組織架構與運作方式
            </p>
          </v-col>
        </v-row>

        <v-row>
          <v-col
            v-for="structure in boardStructure"
            :key="structure.title"
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
                  :icon="structure.icon"
                  size="48"
                  :color="structure.color"
                  class="mb-4"
                />
                <h3 class="text-h5 font-weight-bold mb-3">
                  {{ structure.title }}
                </h3>
                <p class="text-body-1 text-medium-emphasis mb-4">
                  {{ structure.description }}
                </p>
                <div class="text-h4 font-weight-bold" :class="`text-${structure.color}`">
                  {{ structure.count }}
                </div>
                <div class="text-body-2 text-medium-emphasis">
                  {{ structure.unit }}
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-container>

    <!-- Meeting Schedule -->
    <v-container class="py-16">
      <v-row>
        <v-col cols="12" class="text-center mb-8">
          <h2 class="text-h3 font-weight-bold mb-4">會議時程</h2>
          <p class="text-h6 text-medium-emphasis">
            理事會定期會議與重要活動時程
          </p>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12" md="8" offset-md="2">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-6">
              <v-timeline
                side="end"
                align="start"
                line-color="primary"
                line-thickness="2"
              >
                <v-timeline-item
                  v-for="(meeting, index) in meetingSchedule"
                  :key="index"
                  :dot-color="meeting.color"
                  size="small"
                >
                  <template #icon>
                    <v-icon :color="meeting.color" size="16">
                      {{ meeting.icon }}
                    </v-icon>
                  </template>
                  
                  <v-card
                    class="mb-2"
                    elevation="1"
                    rounded="lg"
                  >
                    <v-card-text class="pa-4">
                      <div class="d-flex align-center mb-2">
                        <v-chip
                          :color="meeting.color"
                          size="small"
                          class="mr-3"
                        >
                          {{ meeting.date }}
                        </v-chip>
                        <h4 class="text-subtitle-1 font-weight-bold">
                          {{ meeting.title }}
                        </h4>
                      </div>
                      <p class="text-body-2 text-medium-emphasis mb-2">
                        {{ meeting.description }}
                      </p>
                      <div class="text-caption">
                        <v-icon icon="mdi-clock" size="14" class="mr-1" />
                        {{ meeting.time }}
                        <v-icon icon="mdi-map-marker" size="14" class="mr-1 ml-3" />
                        {{ meeting.location }}
                      </div>
                    </v-card-text>
                  </v-card>
                </v-timeline-item>
              </v-timeline>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import landingViewImage from '@/assets/img/landing-view.webp'

const boardMembers = [
  {
    name: '張文華',
    title: '理事長',
    role: '理事長',
    photo: landingViewImage,
    description: '致力於古蹟保護與文化傳承，擁有豐富的歷史建築修復經驗。',
    education: '國立台灣大學建築與城鄉研究所博士',
    expertise: ['古蹟修復', '建築史', '文化政策'],
    experience: [
      '文化部古蹟審議委員',
      '台灣古蹟保護協會理事長',
      '國立故宮博物院建築顧問'
    ],
    email: 'zhang@monument.gov.tw',
    linkedin: '#'
  },
  {
    name: '李美玲',
    title: '副理事長',
    role: '副理事長',
    photo: landingViewImage,
    description: '專精於文化資產管理與教育推廣，推動古蹟活化再利用。',
    education: '國立政治大學歷史學系碩士',
    expertise: ['文化資產', '教育推廣', '博物館學'],
    experience: [
      '台北市文化局文化資產科科長',
      '國立歷史博物館研究員',
      '台灣博物館學會常務理事'
    ],
    email: 'li@monument.gov.tw',
    linkedin: '#'
  },
  {
    name: '陳志明',
    title: '常務理事',
    role: '常務理事',
    photo: landingViewImage,
    description: '建築工程專家，專精於古蹟結構安全評估與修復技術。',
    education: '國立成功大學建築學系學士',
    expertise: ['結構工程', '古蹟修復', '工程管理'],
    experience: [
      '中華民國建築師公會理事',
      '古蹟修復工程顧問',
      '營建署古蹟修復審查委員'
    ],
    email: 'chen@monument.gov.tw',
    linkedin: '#'
  },
  {
    name: '林雅婷',
    title: '常務理事',
    role: '常務理事',
    photo: landingViewImage,
    description: '文化創意產業專家，致力於古蹟文化價值推廣與創新應用。',
    education: '國立台灣藝術大學文化創意產業學系碩士',
    expertise: ['文化創意', '行銷推廣', '活動企劃'],
    experience: [
      '文化部文創發展司專員',
      '台北市文化基金會執行長',
      '台灣文創產業聯盟理事'
    ],
    email: 'lin@monument.gov.tw',
    linkedin: '#'
  },
  {
    name: '黃文博',
    title: '理事',
    role: '理事',
    photo: landingViewImage,
    description: '歷史學者，專精於台灣史研究與文獻整理，為古蹟歷史研究提供學術支持。',
    education: '國立台灣大學歷史學系博士',
    expertise: ['台灣史', '文獻研究', '口述歷史'],
    experience: [
      '中央研究院台灣史研究所研究員',
      '國立台灣大學歷史學系兼任教授',
      '台灣史學會常務理事'
    ],
    email: 'huang@monument.gov.tw',
    linkedin: '#'
  },
  {
    name: '劉美惠',
    title: '理事',
    role: '理事',
    photo: landingViewImage,
    description: '財務管理專家，負責古蹟管理處的財務規劃與預算管理。',
    education: '國立政治大學會計學系碩士',
    expertise: ['財務管理', '會計', '預算規劃'],
    experience: [
      '會計師事務所合夥人',
      '文化部財務管理顧問',
      '非營利組織財務管理專家'
    ],
    email: 'liu@monument.gov.tw',
    linkedin: '#'
  }
]

const boardStructure = [
  {
    title: '理事長',
    description: '負責理事會整體運作與決策',
    icon: 'mdi-account-tie',
    color: 'primary',
    count: 1,
    unit: '人'
  },
  {
    title: '常務理事',
    description: '協助理事長處理日常事務',
    icon: 'mdi-account-group',
    color: 'success',
    count: 3,
    unit: '人'
  },
  {
    title: '一般理事',
    description: '參與重大決策與監督管理',
    icon: 'mdi-account-multiple',
    color: 'info',
    count: 8,
    unit: '人'
  }
]

const meetingSchedule = [
  {
    date: '2024-01-15',
    title: '第一季理事會會議',
    description: '討論年度工作計畫與預算分配',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'primary'
  },
  {
    date: '2024-04-15',
    title: '第二季理事會會議',
    description: '檢討第一季執行成果與調整計畫',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'success'
  },
  {
    date: '2024-07-15',
    title: '第三季理事會會議',
    description: '中期檢討與下半年重點工作',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'info'
  },
  {
    date: '2024-10-15',
    title: '第四季理事會會議',
    description: '年度總結與下年度規劃',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'warning'
  }
]
</script>

