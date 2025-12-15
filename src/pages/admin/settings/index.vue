<script setup>
  import { computed, onMounted, ref, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // Tab 管理
  const currentTab = ref('options')

  // Option 管理相關
  const options = ref([])
  const optionsLoading = ref(false)
  const optionsError = ref(null)
  const showOptionDeleteDialog = ref(false)
  const optionToDelete = ref(null)

  // 搜尋與篩選
  const searchModule = ref(null)
  const searchCate = ref(null)

  // 表單對話框
  const showOptionFormDialog = ref(false)
  const optionFormMode = ref('new') // 'new' 或 'edit'
  const optionFormLoading = ref(false)
  const optionFormError = ref(null)
  const optionForm = ref({
    id: null,
    module: '',
    cate: '',
    key: '',
    value: '',
    label: '',
  })
  const optionFormErrors = ref({})

  // 計算屬性：所有唯一的 module 列表
  const moduleOptions = computed(() => {
    const modules = [...new Set(options.value.map(opt => opt.module))]
    return modules.sort().map(module => ({
      value: module,
      text: module,
    }))
  })

  // 計算屬性：根據選擇的 module 獲取對應的 cate 列表
  const cateOptions = computed(() => {
    if (!searchModule.value) {
      return []
    }
    const cates = [...new Set(
      options.value
        .filter(opt => opt.module === searchModule.value)
        .map(opt => opt.cate)
    )]
    return cates.sort().map(cate => ({
      value: cate,
      text: cate,
    }))
  })

  // 計算屬性：篩選後的選項列表
  const filteredOptions = computed(() => {
    let filtered = options.value

    if (searchModule.value) {
      filtered = filtered.filter(opt => opt.module === searchModule.value)
    }

    if (searchCate.value) {
      filtered = filtered.filter(opt => opt.cate === searchCate.value)
    }

    return filtered.sort((a, b) => {
      // 先按 module 排序，再按 cate 排序，最後按 key 排序
      if (a.module !== b.module) {
        return a.module.localeCompare(b.module)
      }
      if (a.cate !== b.cate) {
        return a.cate.localeCompare(b.cate)
      }
      return a.key.localeCompare(b.key)
    })
  })

  // 從 Supabase 載入選項
  async function loadOptions () {
    optionsLoading.value = true
    optionsError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('option')
        .select('*')
        .order('module', { ascending: true })
        .order('cate', { ascending: true })
        .order('key', { ascending: true })

      if (fetchError) throw fetchError

      options.value = data || []
    } catch (error_) {
      console.error('載入選項失敗:', error_)
      optionsError.value = error_.message || '載入選項時發生錯誤'
    } finally {
      optionsLoading.value = false
    }
  }

  // 開啟新增選項表單
  function openNewOptionForm () {
    optionFormMode.value = 'new'
    optionForm.value = {
      id: null,
      module: searchModule.value || '',
      cate: searchCate.value || '',
      key: '',
      value: '',
      label: '',
    }
    optionFormErrors.value = {}
    optionFormError.value = null
    showOptionFormDialog.value = true
  }

  // 開啟編輯選項表單
  function openEditOptionForm (option) {
    optionFormMode.value = 'edit'
    optionForm.value = {
      id: option.id,
      module: option.module,
      cate: option.cate,
      key: option.key,
      value: option.value || '',
      label: option.label || '',
    }
    optionFormErrors.value = {}
    optionFormError.value = null
    showOptionFormDialog.value = true
  }

  // 驗證選項表單
  function validateOptionForm () {
    optionFormErrors.value = {}

    if (!optionForm.value.module?.trim()) {
      optionFormErrors.value.module = '請選擇或輸入模組'
    }

    if (!optionForm.value.cate?.trim()) {
      optionFormErrors.value.cate = '請選擇或輸入分類'
    }

    if (!optionForm.value.key?.trim()) {
      optionFormErrors.value.key = '請輸入鍵名'
    }

    return Object.keys(optionFormErrors.value).length === 0
  }

  // 提交選項表單
  async function submitOptionForm () {
    if (!validateOptionForm()) {
      optionFormError.value = '請填寫所有必填欄位'
      return
    }

    optionFormLoading.value = true
    optionFormError.value = null

    try {
      const formData = {
        module: optionForm.value.module.trim(),
        cate: optionForm.value.cate.trim(),
        key: optionForm.value.key.trim(),
        value: optionForm.value.value?.trim() || null,
        label: optionForm.value.label?.trim() || null,
      }

      if (optionFormMode.value === 'new') {
        const { error: insertError } = await supabase
          .from('option')
          .insert(formData)

        if (insertError) throw insertError
      } else {
        // 編輯模式：需要檢查是否更改了 module, cate, key（因為有唯一約束）
        const originalOption = options.value.find(opt => opt.id === optionForm.value.id)
        const hasChangedUniqueFields = (
          originalOption.module !== formData.module ||
          originalOption.cate !== formData.cate ||
          originalOption.key !== formData.key
        )

        if (hasChangedUniqueFields) {
          // 如果更改了唯一欄位，需要先刪除舊記錄，再插入新記錄
          const { error: deleteError } = await supabase
            .from('option')
            .delete()
            .eq('id', optionForm.value.id)

          if (deleteError) throw deleteError

          const { error: insertError } = await supabase
            .from('option')
            .insert(formData)

          if (insertError) throw insertError
        } else {
          // 如果沒有更改唯一欄位，直接更新
          const { error: updateError } = await supabase
            .from('option')
            .update(formData)
            .eq('id', optionForm.value.id)

          if (updateError) throw updateError
        }
      }

      await loadOptions()
      showOptionFormDialog.value = false
    } catch (error_) {
      console.error('提交選項表單失敗:', error_)
      optionFormError.value = error_.message || '提交表單時發生錯誤'
    } finally {
      optionFormLoading.value = false
    }
  }

  // 開啟刪除確認對話框
  function openDeleteOptionDialog (option) {
    optionToDelete.value = option
    showOptionDeleteDialog.value = true
  }

  // 確認刪除選項
  async function confirmDeleteOption () {
    if (!optionToDelete.value) return

    try {
      optionsLoading.value = true
      optionsError.value = null

      const { error: deleteError } = await supabase
        .from('option')
        .delete()
        .eq('id', optionToDelete.value.id)

      if (deleteError) throw deleteError

      await loadOptions()
      showOptionDeleteDialog.value = false
      optionToDelete.value = null
    } catch (error_) {
      console.error('刪除選項失敗:', error_)
      optionsError.value = error_.message || '刪除選項時發生錯誤'
    } finally {
      optionsLoading.value = false
    }
  }

  // 當 module 改變時，重置 cate
  watch(searchModule, () => {
    searchCate.value = null
  })

  // 元件掛載時載入資料
  onMounted(async () => {
    await authStore.initAuth()

    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    await loadOptions()
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-h4 font-weight-bold mb-2">
        系統設定
      </h1>
      <p class="text-body-2 text-medium-emphasis">
        管理整個網站的設定資訊
      </p>
    </div>

    <!-- Tab 導航 -->
    <v-tabs
      v-model="currentTab"
      class="mb-6"
    >
      <v-tab value="options">
        <v-icon class="mr-2" icon="mdi-cog" />
        選項管理
      </v-tab>
      <!-- 可以在這裡添加更多 tab -->
    </v-tabs>

    <!-- Tab 內容 -->
    <v-window v-model="currentTab">
      <!-- 選項管理 Tab -->
      <v-window-item value="options">
        <v-card elevation="2">
          <v-card-title class="d-flex align-center justify-space-between">
            <div>
              <h2 class="text-h5 font-weight-bold">
                選項管理
              </h2>
              <p class="text-body-2 text-medium-emphasis mt-1">
                管理系統配置選項（鍵值對）
              </p>
            </div>
            <v-btn
              color="primary"
              prepend-icon="mdi-plus"
              @click="openNewOptionForm"
            >
              新增選項
            </v-btn>
          </v-card-title>

          <v-divider />

          <!-- 搜尋與篩選 -->
          <v-card-text>
            <v-row>
              <v-col cols="12" md="6">
                <v-select
                  v-model="searchModule"
                  :items="moduleOptions"
                  item-title="text"
                  item-value="value"
                  label="模組 (Module)"
                  clearable
                  variant="outlined"
                >
                  <template #prepend-inner>
                    <v-icon icon="mdi-folder" />
                  </template>
                </v-select>
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="searchCate"
                  :items="cateOptions"
                  :disabled="!searchModule"
                  item-title="text"
                  item-value="value"
                  label="分類 (Cate)"
                  clearable
                  variant="outlined"
                >
                  <template #prepend-inner>
                    <v-icon icon="mdi-tag" />
                  </template>
                </v-select>
              </v-col>
            </v-row>
          </v-card-text>

          <v-divider />

          <!-- 錯誤訊息 -->
          <v-alert
            v-if="optionsError"
            class="ma-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="optionsError = null"
          >
            {{ optionsError }}
          </v-alert>

          <!-- 載入中 -->
          <div v-if="optionsLoading" class="text-center py-12">
            <v-progress-circular
              color="primary"
              indeterminate
              size="64"
            />
            <p class="mt-4 text-body-1 text-medium-emphasis">
              載入中...
            </p>
          </div>

          <!-- 選項列表 -->
          <v-table v-else>
            <thead>
              <tr>
                <th class="text-left">
                  模組 (Module)
                </th>
                <th class="text-left">
                  分類 (Cate)
                </th>
                <th class="text-left">
                  鍵名 (Key)
                </th>
                <th class="text-left">
                  值 (Value)
                </th>
                <th class="text-left">
                  標籤 (Label)
                </th>
                <th class="text-right">
                  操作 (Action)
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="option in filteredOptions"
                :key="option.id"
              >
                <td>{{ option.module }}</td>
                <td>{{ option.cate }}</td>
                <td>
                  <code class="text-caption">{{ option.key }}</code>
                </td>
                <td>
                  <span class="text-body-2">{{ option.value || '-' }}</span>
                </td>
                <td>
                  <span class="text-body-2">{{ option.label || '-' }}</span>
                </td>
                <td class="text-right">
                  <v-btn
                    class="mr-2"
                    icon
                    size="small"
                    variant="text"
                    @click="openEditOptionForm(option)"
                  >
                    <v-icon icon="mdi-pencil" />
                  </v-btn>
                  <v-btn
                    icon
                    size="small"
                    variant="text"
                    @click="openDeleteOptionDialog(option)"
                  >
                    <v-icon icon="mdi-delete" />
                  </v-btn>
                </td>
              </tr>
              <tr v-if="filteredOptions.length === 0">
                <td colspan="6" class="text-center py-8 text-medium-emphasis">
                  沒有找到符合條件的選項
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-card>
      </v-window-item>
    </v-window>

    <!-- 選項表單對話框 -->
    <v-dialog
      v-model="showOptionFormDialog"
      max-width="600"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ optionFormMode === 'new' ? '新增選項' : '編輯選項' }}
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="optionFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="optionFormError = null"
          >
            {{ optionFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="optionForm.module"
                  :error-messages="optionFormErrors.module"
                  label="模組 (Module) *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="optionForm.cate"
                  :error-messages="optionFormErrors.cate"
                  label="分類 (Cate) *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="optionForm.key"
                  :error-messages="optionFormErrors.key"
                  label="鍵名 (Key) *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-textarea
                  v-model="optionForm.value"
                  label="值 (Value)"
                  rows="3"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="optionForm.label"
                  label="標籤 (Label)"
                  variant="outlined"
                />
              </v-col>
            </v-row>
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showOptionFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="optionFormLoading"
            variant="flat"
            @click="submitOptionForm"
          >
            {{ optionFormMode === 'new' ? '新增' : '更新' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 刪除確認對話框 -->
    <v-dialog
      v-model="showOptionDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除選項
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <p class="mb-4">
            您確定要刪除此選項嗎？此操作無法復原。
          </p>
          <v-card
            v-if="optionToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ optionToDelete.module }} / {{ optionToDelete.cate }} / {{ optionToDelete.key }}
            </div>
            <div v-if="optionToDelete.label" class="text-caption text-medium-emphasis">
              標籤：{{ optionToDelete.label }}
            </div>
            <div v-if="optionToDelete.value" class="text-caption text-medium-emphasis mt-1">
              值：{{ optionToDelete.value }}
            </div>
          </v-card>
          <p class="mt-4 text-error">
            此操作無法復原！
          </p>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showOptionDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            :loading="optionsLoading"
            variant="flat"
            @click="confirmDeleteOption"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<style scoped>
code {
  background-color: rgba(var(--v-theme-on-surface), 0.05);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}
</style>

