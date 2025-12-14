<script setup>
  import { onMounted, ref } from 'vue'
  import { fetchOrganizationData } from '@/apis/mocks/organizationApi'

  const departments = ref([])
  const organizationChart = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // 從 API 獲取組織資料
  async function loadOrganizationData () {
    loading.value = true
    error.value = null

    try {
      const data = await fetchOrganizationData()
      departments.value = data.departments
      organizationChart.value = data.organizationChart
    } catch (error_) {
      error.value = error_.message || '載入資料時發生錯誤'
      console.error('載入組織資料失敗:', error_)
    } finally {
      loading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(() => {
    loadOrganizationData()
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
            <h2 class="text-h2 text-md-h1 font-weight-bold mb-4 text-white">組織架構</h2>
            <p class="text-h6 text-white">
              了解古蹟管理組織的結構與運作方式
            </p>
          </v-col>
        </v-row>
      </v-container>
    </div>

    <!-- Organization Chart -->
    <v-container class="pb-16">
      <v-row>
        <v-col
          class="text-center mb-8"
          cols="12"
        >
          <h2 class="text-h3 font-weight-bold mb-4">組織架構圖</h2>
          <p class="text-h6 text-medium-emphasis">
            古蹟管理處的完整組織架構與職責分工
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
            @click="loadOrganizationData"
          >
            重試
          </v-btn>
        </v-col>
      </v-row>

      <!-- Organization Chart Content -->
      <v-row v-else>
        <v-col cols="12" md="10">
          <v-card elevation="2" rounded="lg">
            <v-card-text class="pa-8">
              <div class="organization-chart">
                <!-- 理事長 -->
                <div
                  v-if="organizationChart"
                  class="org-level-1 text-center mb-6"
                >
                  <v-card
                    class="mx-auto"
                    :color="organizationChart.chairman.color"
                    rounded="lg"
                    style="max-width: 300px;"
                  >
                    <v-card-text class="pa-4">
                      <v-icon
                        class="mb-2"
                        color="white"
                        :icon="organizationChart.chairman.icon"
                        size="32"
                      />
                      <div class="text-h6 font-weight-bold text-white">
                        {{ organizationChart.chairman.title }}
                      </div>
                      <div class="text-body-2 text-white">
                        {{ organizationChart.chairman.name }}
                      </div>
                    </v-card-text>
                  </v-card>
                </div>

                <!-- 副理事長 -->
                <div
                  v-if="organizationChart"
                  class="org-level-2 text-center mb-6"
                >
                  <v-row justify="center">
                    <v-col cols="12" md="6">
                      <v-card
                        class="mx-auto"
                        :color="organizationChart.viceChairman.color"
                        rounded="lg"
                        style="max-width: 250px;"
                      >
                        <v-card-text class="pa-4">
                          <v-icon
                            class="mb-2"
                            color="white"
                            :icon="organizationChart.viceChairman.icon"
                            size="28"
                          />
                          <div class="text-h6 font-weight-bold text-white">
                            {{ organizationChart.viceChairman.title }}
                          </div>
                          <div class="text-body-2 text-white">
                            {{ organizationChart.viceChairman.name }}
                          </div>
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
                      class="mb-4"
                      cols="12"
                      md="4"
                    >
                      <v-card
                        class="h-100"
                        :color="department.color"
                        rounded="lg"
                      >
                        <v-card-text class="pa-4 text-center">
                          <v-icon
                            class="mb-2"
                            color="white"
                            :icon="department.icon"
                            size="24"
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
            <h2 class="text-h3 font-weight-bold mb-4">部門職責</h2>
            <p class="text-h6 text-medium-emphasis">
              各部門的詳細職責與工作內容
            </p>
          </v-col>
        </v-row>

        <v-row v-if="!loading && !error">
          <v-col
            v-for="department in departments"
            :key="department.name"
            class="mb-6"
            cols="12"
            md="6"
          >
            <v-card
              class="h-100"
              elevation="2"
              rounded="lg"
            >
              <v-card-text class="pa-6">
                <div class="d-flex align-center mb-4">
                  <v-icon
                    class="mr-3"
                    :color="department.color"
                    :icon="department.icon"
                    size="32"
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
                          :color="department.color"
                          icon="mdi-check-circle"
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
                      <v-icon
                        class="mr-2"
                        icon="mdi-account"
                        size="16"
                      />
                      負責人：{{ department.manager }}
                    </div>
                    <div class="mb-1">
                      <v-icon
                        class="mr-2"
                        icon="mdi-phone"
                        size="16"
                      />
                      電話：{{ department.phone }}
                    </div>
                    <div>
                      <v-icon
                        class="mr-2"
                        icon="mdi-email"
                        size="16"
                      />
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
<style scoped lang="scss">
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
