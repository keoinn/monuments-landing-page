<script setup>
  import { onMounted, ref } from 'vue'
  import { fetchDirectorsData } from '@/apis/mocks/directorsApi'

  const boardMembers = ref([])
  const boardStructure = ref([])
  const meetingSchedule = ref([])
  const loading = ref(false)
  const error = ref(null)

  // 從 API 獲取理事會資料
  async function loadDirectorsData () {
    loading.value = true
    error.value = null

    try {
      const data = await fetchDirectorsData()
      boardMembers.value = data.boardMembers
      boardStructure.value = data.boardStructure
      meetingSchedule.value = data.meetingSchedule
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入理事會資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(() => {
    loadDirectorsData()
  })
</script>
<template>
  <div>
    <!-- Page Header -->
    <div class="page-header">
      <v-container class="py-12">
        <v-row justify="center">
          <v-col class="text-center" cols="12" md="8">
            <h2 class="text-h2 text-md-h1 font-weight-bold mb-4 text-white">委員會</h2>
            <p class="text-h6 text-white">
              認識古蹟管理處的理事會成員與其專業背景
            </p>
          </v-col>
        </v-row>
      </v-container>
    </div>

    <!-- Board Members -->
    <v-container class="pb-16">
      <v-row>
        <v-col class="text-center mb-8" cols="12">
          <h2 class="text-h3 font-weight-bold mb-4">理事會成員</h2>
          <p class="text-h6 text-medium-emphasis">
            由各界專業人士組成的理事會，共同推動古蹟保護與文化傳承
          </p>
        </v-col>
      </v-row>

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
            @click="loadDirectorsData"
          >
            重試
          </v-btn>
        </v-col>
      </v-row>

      <!-- Board Members List -->
      <v-row v-else>
        <v-col
          v-for="member in boardMembers"
          :key="member.name"
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
            <v-img
              class="position-relative"
              cover
              height="300"
              :src="member.photo"
            >
              <v-overlay
                class="d-flex align-end"
                contained
                :model-value="true"
              >
                <div class="pa-4">
                  <v-chip
                    class="mb-2"
                    :color="member.role === '理事長' ? 'primary' : 'success'"
                    size="small"
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
                color="primary"
                :href="`mailto:${member.email}`"
                prepend-icon="mdi-email"
                size="small"
                variant="outlined"
              >
                聯絡
              </v-btn>
              <v-spacer />
              <v-btn
                :href="member.linkedin"
                icon="mdi-linkedin"
                size="small"
                target="_blank"
                variant="text"
              />
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <!-- Board Structure -->
    <v-container class="py-16" color="surface-variant" fluid>
      <v-container>
        <v-row>
          <v-col class="text-center mb-8" cols="12">
            <h2 class="text-h3 font-weight-bold mb-4">理事會架構</h2>
            <p class="text-h6 text-medium-emphasis">
              理事會的組織架構與運作方式
            </p>
          </v-col>
        </v-row>

        <v-row v-if="!loading && !error">
          <v-col
            v-for="structure in boardStructure"
            :key="structure.title"
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
                  :color="structure.color"
                  :icon="structure.icon"
                  size="48"
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
        <v-col class="text-center mb-8" cols="12">
          <h2 class="text-h3 font-weight-bold mb-4">會議時程</h2>
          <p class="text-h6 text-medium-emphasis">
            理事會定期會議與重要活動時程
          </p>
        </v-col>
      </v-row>

      <v-row v-if="!loading && !error">
        <v-col cols="12" md="8" offset-md="2">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-6">
              <v-timeline
                align="start"
                line-color="primary"
                line-thickness="2"
                side="end"
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
                          class="mr-3"
                          :color="meeting.color"
                          size="small"
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
                        <v-icon class="mr-1" icon="mdi-clock" size="14" />
                        {{ meeting.time }}
                        <v-icon class="mr-1 ml-3" icon="mdi-map-marker" size="14" />
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
