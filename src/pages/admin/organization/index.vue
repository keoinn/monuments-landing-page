<script setup>
  import { onMounted, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { supabase } from '@/lib/supabaseClient'
  import { useAuthStore } from '@/stores/auth'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // 部門相關
  const departments = ref([])
  const departmentsLoading = ref(false)
  const departmentsError = ref(null)
  const showDepartmentDeleteDialog = ref(false)
  const departmentToDelete = ref(null)

  // 組織架構圖相關
  const organizationChart = ref([])
  const chartLoading = ref(false)
  const chartError = ref(null)

  // 部門表單對話框
  const showDepartmentFormDialog = ref(false)
  const departmentFormMode = ref('new') // 'new' 或 'edit'
  const departmentFormLoading = ref(false)
  const departmentFormError = ref(null)
  const departmentForm = ref({
    id: null,
    name: '',
    manager: '',
    description: '',
    icon: 'mdi-office-building',
    color: 'primary',
    phone: '',
    email: '',
    responsibilities: [],
    display_order: 0,
  })
  const departmentFormErrors = ref({})
  const departmentResponsibilityInput = ref('')

  // 組織架構圖表單對話框
  const showChartFormDialog = ref(false)
  const chartFormLoading = ref(false)
  const chartFormError = ref(null)
  const chartForm = ref({
    id: null,
    position: '',
    name: '',
    title: '',
    icon: 'mdi-account-tie',
    color: 'primary',
  })
  const chartFormErrors = ref({})

  // 圖示選項（從 Supabase 載入）
  const iconOptions = ref([])

  // 顏色選項（從 Supabase 載入）
  const colorOptions = ref([])

  // 職位選項（從 Supabase 載入）
  const positionOptions = ref([])

  // 從 Supabase 載入部門
  async function loadDepartments () {
    departmentsLoading.value = true
    departmentsError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('departments')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      departments.value = data || []
    } catch (error_) {
      console.error('載入部門失敗:', error_)
      departmentsError.value = error_.message || '載入部門時發生錯誤'
    } finally {
      departmentsLoading.value = false
    }
  }

  // 從 Supabase 載入組織架構圖
  async function loadOrganizationChart () {
    chartLoading.value = true
    chartError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('organization_chart')
        .select('*')
        .order('position')

      if (fetchError) throw fetchError

      organizationChart.value = data || []
    } catch (error_) {
      console.error('載入組織架構圖失敗:', error_)
      chartError.value = error_.message || '載入組織架構圖時發生錯誤'
    } finally {
      chartLoading.value = false
    }
  }

  // 刪除部門
  async function deleteDepartment (department) {
    departmentToDelete.value = department
    showDepartmentDeleteDialog.value = true
  }

  async function confirmDeleteDepartment () {
    if (!departmentToDelete.value) return

    try {
      departmentsLoading.value = true
      departmentsError.value = null

      const { error: deleteError } = await supabase
        .from('departments')
        .delete()
        .eq('id', departmentToDelete.value.id)

      if (deleteError) throw deleteError

      await loadDepartments()
      showDepartmentDeleteDialog.value = false
      departmentToDelete.value = null
    } catch (error_) {
      console.error('刪除部門失敗:', error_)
      departmentsError.value = error_.message || '刪除部門時發生錯誤'
    } finally {
      departmentsLoading.value = false
    }
  }

  // 獲取顏色對應的 Vuetify 顏色
  function getColorVariant (color) {
    const colorMap = {
      primary: 'primary',
      success: 'success',
      info: 'info',
      warning: 'warning',
      error: 'error',
      purple: 'purple',
    }
    return colorMap[color] || 'primary'
  }

  // 獲取職位中文名稱
  function getPositionName (position) {
    const positionMap = {
      chairman: '理事長',
      viceChairman: '副理事長',
    }
    return positionMap[position] || position
  }

  // 從 Supabase 載入選項資料
  async function loadOptions () {
    try {
      // 載入圖示選項
      const { data: iconData, error: iconError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'organization')
        .eq('cate', 'iconOptions')
        .order('key')

      iconOptions.value = (!iconError && iconData)
        ? iconData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
        : [
          { value: 'mdi-office-building', text: '辦公室' },
          { value: 'mdi-account-group', text: '人員' },
          { value: 'mdi-tools', text: '工具' },
          { value: 'mdi-book-open-variant', text: '書籍' },
          { value: 'mdi-palette', text: '藝術' },
          { value: 'mdi-shield-star', text: '保護' },
          { value: 'mdi-hammer-wrench', text: '修復' },
          { value: 'mdi-information', text: '資訊' },
        ]

      // 載入顏色選項
      const { data: colorData, error: colorError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'organization')
        .eq('cate', 'colorOptions')
        .order('key')

      colorOptions.value = (!colorError && colorData)
        ? colorData.map(item => {
          const value = item.value || item.label
          return {
            value,
            text: item.label || value,
            color: value,
          }
        })
        : [
          { value: 'primary', text: '主要', color: 'primary' },
          { value: 'success', text: '成功', color: 'success' },
          { value: 'info', text: '資訊', color: 'info' },
          { value: 'warning', text: '警告', color: 'warning' },
          { value: 'error', text: '錯誤', color: 'error' },
          { value: 'purple', text: '紫色', color: 'purple' },
        ]

      // 載入職位選項
      const { data: positionData, error: positionError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'organization')
        .eq('cate', 'positionOptions')
        .order('key')

      if (!positionError && positionData) {
        positionOptions.value = positionData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
      } else {
        // 預設職位選項
        positionOptions.value = [
          { value: 'chairman', text: '理事長' },
          { value: 'viceChairman', text: '副理事長' },
        ]
      }
    } catch (error_) {
      console.error('載入選項資料失敗:', error_)
      // 使用預設值
      iconOptions.value = [
        { value: 'mdi-office-building', text: '辦公室' },
        { value: 'mdi-account-group', text: '人員' },
        { value: 'mdi-tools', text: '工具' },
        { value: 'mdi-book-open-variant', text: '書籍' },
        { value: 'mdi-palette', text: '藝術' },
        { value: 'mdi-shield-star', text: '保護' },
        { value: 'mdi-hammer-wrench', text: '修復' },
        { value: 'mdi-information', text: '資訊' },
      ]
      colorOptions.value = [
        { value: 'primary', text: '主要', color: 'primary' },
        { value: 'success', text: '成功', color: 'success' },
        { value: 'info', text: '資訊', color: 'info' },
        { value: 'warning', text: '警告', color: 'warning' },
        { value: 'error', text: '錯誤', color: 'error' },
        { value: 'purple', text: '紫色', color: 'purple' },
      ]
      positionOptions.value = [
        { value: 'chairman', text: '理事長' },
        { value: 'viceChairman', text: '副理事長' },
      ]
    }
  }

  // 開啟新增部門表單
  function openNewDepartmentForm () {
    departmentFormMode.value = 'new'
    departmentForm.value = {
      id: null,
      name: '',
      manager: '',
      description: '',
      icon: 'mdi-office-building',
      color: 'primary',
      phone: '',
      email: '',
      responsibilities: [],
      display_order: 0,
    }
    departmentFormErrors.value = {}
    departmentFormError.value = null
    departmentResponsibilityInput.value = ''
    showDepartmentFormDialog.value = true
  }

  // 開啟編輯部門表單
  function openEditDepartmentForm (department) {
    departmentFormMode.value = 'edit'
    departmentForm.value = {
      id: department.id,
      name: department.name || '',
      manager: department.manager || '',
      description: department.description || '',
      icon: department.icon || 'mdi-office-building',
      color: department.color || 'primary',
      phone: department.phone || '',
      email: department.email || '',
      responsibilities: department.responsibilities ? [...department.responsibilities] : [],
      display_order: department.display_order || 0,
    }
    departmentFormErrors.value = {}
    departmentFormError.value = null
    departmentResponsibilityInput.value = ''
    showDepartmentFormDialog.value = true
  }

  // 添加職責
  function addResponsibility () {
    if (departmentResponsibilityInput.value.trim()) {
      const items = departmentResponsibilityInput.value.split(',').map(item => item.trim()).filter(Boolean)
      departmentForm.value.responsibilities = [...new Set([...departmentForm.value.responsibilities, ...items])]
      departmentResponsibilityInput.value = ''
    }
  }

  // 移除職責
  function removeResponsibility (index) {
    departmentForm.value.responsibilities.splice(index, 1)
  }

  // 驗證部門表單
  function validateDepartmentForm () {
    departmentFormErrors.value = {}

    if (!departmentForm.value.name?.trim()) {
      departmentFormErrors.value.name = '請輸入部門名稱'
    }

    if (!departmentForm.value.manager?.trim()) {
      departmentFormErrors.value.manager = '請輸入主管'
    }

    if (!departmentForm.value.description?.trim()) {
      departmentFormErrors.value.description = '請輸入描述'
    }

    if (!departmentForm.value.icon?.trim()) {
      departmentFormErrors.value.icon = '請選擇圖示'
    }

    if (!departmentForm.value.color?.trim()) {
      departmentFormErrors.value.color = '請選擇顏色'
    }

    return Object.keys(departmentFormErrors.value).length === 0
  }

  // 提交部門表單
  async function submitDepartmentForm () {
    if (!validateDepartmentForm()) {
      departmentFormError.value = '請填寫所有必填欄位'
      return
    }

    departmentFormLoading.value = true
    departmentFormError.value = null

    try {
      const formData = {
        name: departmentForm.value.name.trim(),
        manager: departmentForm.value.manager.trim(),
        description: departmentForm.value.description.trim(),
        icon: departmentForm.value.icon.trim(),
        color: departmentForm.value.color.trim(),
        phone: departmentForm.value.phone?.trim() || null,
        email: departmentForm.value.email?.trim() || null,
        responsibilities: departmentForm.value.responsibilities || [],
        display_order: departmentForm.value.display_order || 0,
      }

      if (departmentFormMode.value === 'new') {
        const { error: insertError } = await supabase
          .from('departments')
          .insert(formData)

        if (insertError) throw insertError
      } else {
        const { error: updateError } = await supabase
          .from('departments')
          .update(formData)
          .eq('id', departmentForm.value.id)

        if (updateError) throw updateError
      }

      await loadDepartments()
      showDepartmentFormDialog.value = false
    } catch (error_) {
      console.error('提交部門表單失敗:', error_)
      departmentFormError.value = error_.message || '提交表單時發生錯誤'
    } finally {
      departmentFormLoading.value = false
    }
  }

  // 開啟編輯組織架構圖表單
  function openEditChartForm (item) {
    chartForm.value = {
      id: item.id,
      position: item.position || '',
      name: item.name || '',
      title: item.title || '',
      icon: item.icon || 'mdi-account-tie',
      color: item.color || 'primary',
    }
    chartFormErrors.value = {}
    chartFormError.value = null
    showChartFormDialog.value = true
  }

  // 驗證組織架構圖表單
  function validateChartForm () {
    chartFormErrors.value = {}

    if (!chartForm.value.position?.trim()) {
      chartFormErrors.value.position = '請選擇職位'
    }

    if (!chartForm.value.name?.trim()) {
      chartFormErrors.value.name = '請輸入姓名'
    }

    if (!chartForm.value.title?.trim()) {
      chartFormErrors.value.title = '請輸入職稱'
    }

    if (!chartForm.value.icon?.trim()) {
      chartFormErrors.value.icon = '請選擇圖示'
    }

    if (!chartForm.value.color?.trim()) {
      chartFormErrors.value.color = '請選擇顏色'
    }

    return Object.keys(chartFormErrors.value).length === 0
  }

  // 提交組織架構圖表單
  async function submitChartForm () {
    if (!validateChartForm()) {
      chartFormError.value = '請填寫所有必填欄位'
      return
    }

    chartFormLoading.value = true
    chartFormError.value = null

    try {
      const formData = {
        position: chartForm.value.position.trim(),
        name: chartForm.value.name.trim(),
        title: chartForm.value.title.trim(),
        icon: chartForm.value.icon.trim(),
        color: chartForm.value.color.trim(),
      }

      // 使用 ON CONFLICT 來處理更新或插入
      const { error: upsertError } = await supabase
        .from('organization_chart')
        .upsert(formData, {
          onConflict: 'position',
        })

      if (upsertError) throw upsertError

      await loadOrganizationChart()
      showChartFormDialog.value = false
    } catch (error_) {
      console.error('提交組織架構圖表單失敗:', error_)
      chartFormError.value = error_.message || '提交表單時發生錯誤'
    } finally {
      chartFormLoading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(async () => {
    await authStore.initAuth()

    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    await loadOptions()
    await Promise.all([
      loadDepartments(),
      loadOrganizationChart(),
    ])
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-h4 font-weight-bold mb-2">
        組織架構管理
      </h1>
      <p class="text-body-2 text-medium-emphasis">
        管理部門資訊與組織架構圖
      </p>
    </div>

    <!-- 部門區塊 -->
    <v-card class="mb-8" elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            部門管理
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理各部門資訊與職責
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewDepartmentForm"
        >
          新增部門
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="departmentsError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="departmentsError = null"
      >
        {{ departmentsError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="departmentsLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 部門列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              部門名稱
            </th>
            <th class="text-left">
              主管
            </th>
            <th class="text-left">
              描述
            </th>
            <th class="text-center">
              圖示/顏色
            </th>
            <th class="text-center">
              聯絡資訊
            </th>
            <th class="text-center">
              職責數量
            </th>
            <th class="text-center">
              順序
            </th>
            <th class="text-center">
              操作
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-if="departments.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="8">
              目前沒有部門資料
            </td>
          </tr>
          <tr
            v-for="department in departments"
            :key="department.id"
          >
            <td>
              <div class="font-weight-medium">
                {{ department.name }}
              </div>
            </td>
            <td>
              {{ department.manager }}
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ department.description?.slice(0, 50) }}{{ department.description?.length > 50 ? '...' : '' }}
              </div>
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(department.color)">
                {{ department.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              <div class="text-body-2">
                {{ department.phone || '-' }}
              </div>
              <div class="text-caption text-medium-emphasis">
                {{ department.email || '-' }}
              </div>
            </td>
            <td class="text-center">
              <v-chip
                color="info"
                size="small"
                variant="tonal"
              >
                {{ department.responsibilities?.length || 0 }} 項
              </v-chip>
            </td>
            <td class="text-center">
              {{ department.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditDepartmentForm(department)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
              <v-btn
                color="error"
                icon
                size="small"
                variant="text"
                @click="deleteDepartment(department)"
              >
                <v-icon icon="mdi-delete" />
                <v-tooltip activator="parent">
                  刪除
                </v-tooltip>
              </v-btn>
            </td>
          </tr>
        </tbody>
      </v-table>

      <!-- 統計資訊 -->
      <v-card-text v-if="!departmentsLoading" class="text-body-2 text-medium-emphasis">
        共 {{ departments.length }} 個部門
      </v-card-text>
    </v-card>

    <!-- 組織架構圖區塊 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            組織架構圖
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理高層組織架構（理事長、副理事長）
          </p>
        </div>
        <v-btn
          color="primary"
          :disabled="organizationChart.length === 0"
          prepend-icon="mdi-pencil"
          @click="openEditChartForm(organizationChart[0] || {})"
        >
          編輯架構圖
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="chartError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="chartError = null"
      >
        {{ chartError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="chartLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 組織架構圖列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              職位
            </th>
            <th class="text-left">
              姓名
            </th>
            <th class="text-left">
              職稱
            </th>
            <th class="text-center">
              圖示/顏色
            </th>
            <th class="text-center">
              操作
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-if="organizationChart.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="5">
              目前沒有組織架構圖資料
            </td>
          </tr>
          <tr
            v-for="item in organizationChart"
            :key="item.id"
          >
            <td>
              <v-chip
                :color="getColorVariant(item.color)"
                size="small"
                variant="tonal"
              >
                {{ getPositionName(item.position) }}
              </v-chip>
            </td>
            <td>
              <div class="font-weight-medium">
                {{ item.name }}
              </div>
            </td>
            <td>
              {{ item.title }}
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(item.color)">
                {{ item.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditChartForm(item)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
            </td>
          </tr>
        </tbody>
      </v-table>

      <!-- 統計資訊 -->
      <v-card-text v-if="!chartLoading" class="text-body-2 text-medium-emphasis">
        共 {{ organizationChart.length }} 筆組織架構圖資料
      </v-card-text>
    </v-card>

    <!-- 部門刪除確認對話框 -->
    <v-dialog
      v-model="showDepartmentDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除部門
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下部門嗎？
          </p>
          <v-card
            v-if="departmentToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ departmentToDelete.name }}
            </div>
            <div class="text-caption text-medium-emphasis">
              主管：{{ departmentToDelete.manager }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ departmentToDelete.description?.slice(0, 100) }}{{ departmentToDelete.description?.length > 100 ? '...' : '' }}
            </div>
            <div
              v-if="departmentToDelete.responsibilities?.length > 0"
              class="text-caption text-error mt-2"
            >
              ⚠️ 此部門包含 {{ departmentToDelete.responsibilities.length }} 項職責
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
            @click="showDepartmentDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            :loading="departmentsLoading"
            variant="flat"
            @click="confirmDeleteDepartment"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 部門表單對話框 -->
    <v-dialog
      v-model="showDepartmentFormDialog"
      max-width="800"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ departmentFormMode === 'new' ? '新增部門' : '編輯部門' }}
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="departmentFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="departmentFormError = null"
          >
            {{ departmentFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="departmentForm.name"
                  :error-messages="departmentFormErrors.name"
                  label="部門名稱 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="departmentForm.manager"
                  :error-messages="departmentFormErrors.manager"
                  label="主管 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-textarea
                  v-model="departmentForm.description"
                  :error-messages="departmentFormErrors.description"
                  label="描述 *"
                  required
                  rows="3"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="departmentForm.icon"
                  :error-messages="departmentFormErrors.icon"
                  item-title="text"
                  item-value="value"
                  :items="iconOptions"
                  label="圖示 *"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :icon="item.raw.value" />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <v-icon class="mr-2" :icon="item.raw.value" />
                    {{ item.raw.text }}
                  </template>
                </v-select>
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="departmentForm.color"
                  :error-messages="departmentFormErrors.color"
                  item-title="text"
                  item-value="value"
                  :items="colorOptions"
                  label="顏色 *"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :color="item.raw.color" icon="mdi-circle" />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <v-icon class="mr-2" :color="item.raw.color" icon="mdi-circle" />
                    {{ item.raw.text }}
                  </template>
                </v-select>
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="departmentForm.phone"
                  label="聯絡電話"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="departmentForm.email"
                  label="電子郵件"
                  type="email"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model.number="departmentForm.display_order"
                  label="顯示順序"
                  type="number"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-label class="mb-2">
                  職責
                </v-label>
                <div class="d-flex gap-2 mb-2">
                  <v-text-field
                    v-model="departmentResponsibilityInput"
                    density="compact"
                    placeholder="輸入職責（可用逗號分隔多個）"
                    variant="outlined"
                    @keyup.enter="addResponsibility"
                  />
                  <v-btn
                    color="primary"
                    @click="addResponsibility"
                  >
                    新增
                  </v-btn>
                </div>
                <v-chip
                  v-for="(responsibility, index) in departmentForm.responsibilities"
                  :key="index"
                  class="ma-1"
                  closable
                  @click:close="removeResponsibility(index)"
                >
                  {{ responsibility }}
                </v-chip>
                <div
                  v-if="departmentForm.responsibilities.length === 0"
                  class="text-caption text-medium-emphasis"
                >
                  目前沒有職責項目
                </div>
              </v-col>
            </v-row>
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showDepartmentFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="departmentFormLoading"
            variant="flat"
            @click="submitDepartmentForm"
          >
            {{ departmentFormMode === 'new' ? '新增' : '更新' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 組織架構圖表單對話框 -->
    <v-dialog
      v-model="showChartFormDialog"
      max-width="600"
    >
      <v-card>
        <v-card-title class="text-h6">
          編輯組織架構圖
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="chartFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="chartFormError = null"
          >
            {{ chartFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12">
                <v-select
                  v-model="chartForm.position"
                  :error-messages="chartFormErrors.position"
                  item-title="text"
                  item-value="value"
                  :items="positionOptions"
                  label="職位 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="chartForm.name"
                  :error-messages="chartFormErrors.name"
                  label="姓名 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="chartForm.title"
                  :error-messages="chartFormErrors.title"
                  label="職稱 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="chartForm.icon"
                  :error-messages="chartFormErrors.icon"
                  item-title="text"
                  item-value="value"
                  :items="iconOptions"
                  label="圖示 *"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :icon="item.raw.value" />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <v-icon class="mr-2" :icon="item.raw.value" />
                    {{ item.raw.text }}
                  </template>
                </v-select>
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="chartForm.color"
                  :error-messages="chartFormErrors.color"
                  item-title="text"
                  item-value="value"
                  :items="colorOptions"
                  label="顏色 *"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :color="item.raw.color" icon="mdi-circle" />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <v-icon class="mr-2" :color="item.raw.color" icon="mdi-circle" />
                    {{ item.raw.text }}
                  </template>
                </v-select>
              </v-col>
            </v-row>
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showChartFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="chartFormLoading"
            variant="flat"
            @click="submitChartForm"
          >
            更新
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<style scoped lang="scss">
// 表格樣式
.v-table {
  th {
    font-weight: 600;
  }
}
</style>
