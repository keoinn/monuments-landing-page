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

  // 表單文件相關
  const formDocuments = ref([])
  const documentsLoading = ref(false)
  const documentsError = ref(null)
  const showDocumentDeleteDialog = ref(false)
  const documentToDelete = ref(null)

  // 表單文件表單對話框
  const showDocumentFormDialog = ref(false)
  const documentFormMode = ref('new') // 'new' 或 'edit'
  const documentFormLoading = ref(false)
  const documentFormError = ref(null)
  const documentForm = ref({
    id: null,
    title: '',
    description: '',
    date: new Date().toISOString().split('T')[0],
    type: 'PDF',
    icon: 'mdi-file-document',
    color: 'primary',
    category: '',
    url: '',
    storage_path: '',
    display_order: 0,
  })
  const documentFormErrors = ref({})
  const documentFile = ref(null)
  const documentFilePreview = ref(null)
  const documentFileInput = ref(null)
  const documentUrlMode = ref('url') // 'url' 或 'upload'
  const BUCKET_NAME = 'wanxuanju-files'

  // 聯絡資訊相關
  const contactInfo = ref([])
  const contactLoading = ref(false)
  const contactError = ref(null)
  const showContactDeleteDialog = ref(false)
  const contactToDelete = ref(null)

  // 聯絡資訊表單對話框
  const showContactFormDialog = ref(false)
  const contactFormMode = ref('new') // 'new' 或 'edit'
  const contactFormLoading = ref(false)
  const contactFormError = ref(null)
  const contactForm = ref({
    id: null,
    title: '',
    description: '',
    value: '',
    icon: 'mdi-phone',
    color: 'primary',
    action: '',
    button_text: '',
    display_order: 0,
  })
  const contactFormErrors = ref({})

  // 圖示選項（從 Supabase 載入）
  const iconOptions = ref([])

  // 顏色選項（從 Supabase 載入）
  const colorOptions = ref([])

  // 文件類型選項（從 Supabase 載入）
  const documentTypeOptions = ref([])

  // 從 Supabase 載入表單文件
  async function loadFormDocuments () {
    documentsLoading.value = true
    documentsError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('form_documents')
        .select('*')
        .order('display_order', { ascending: true })
        .order('date', { ascending: false })

      if (fetchError) throw fetchError

      formDocuments.value = data || []
    } catch (error_) {
      console.error('載入表單文件失敗:', error_)
      documentsError.value = error_.message || '載入表單文件時發生錯誤'
    } finally {
      documentsLoading.value = false
    }
  }

  // 從 Supabase 載入聯絡資訊
  async function loadContactInfo () {
    contactLoading.value = true
    contactError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('contact_info')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      contactInfo.value = data || []
    } catch (error_) {
      console.error('載入聯絡資訊失敗:', error_)
      contactError.value = error_.message || '載入聯絡資訊時發生錯誤'
    } finally {
      contactLoading.value = false
    }
  }

  // 刪除表單文件
  async function deleteDocument (document) {
    documentToDelete.value = document
    showDocumentDeleteDialog.value = true
  }

  async function confirmDeleteDocument () {
    if (!documentToDelete.value) return

    try {
      documentsLoading.value = true
      documentsError.value = null

      // 如果有檔案在 Storage 中，刪除檔案
      if (documentToDelete.value.storage_path) {
        const { error: storageError } = await supabase.storage
          .from(BUCKET_NAME)
          .remove([documentToDelete.value.storage_path])

        if (storageError) {
          console.error('刪除檔案失敗:', storageError)
          // 不中斷流程，繼續刪除記錄
        }
      }

      // 刪除記錄
      const { error: deleteError } = await supabase
        .from('form_documents')
        .delete()
        .eq('id', documentToDelete.value.id)

      if (deleteError) throw deleteError

      await loadFormDocuments()
      showDocumentDeleteDialog.value = false
      documentToDelete.value = null
    } catch (error_) {
      console.error('刪除表單文件失敗:', error_)
      documentsError.value = error_.message || '刪除表單文件時發生錯誤'
    } finally {
      documentsLoading.value = false
    }
  }

  // 刪除聯絡資訊
  async function deleteContact (contact) {
    contactToDelete.value = contact
    showContactDeleteDialog.value = true
  }

  async function confirmDeleteContact () {
    if (!contactToDelete.value) return

    try {
      contactLoading.value = true
      contactError.value = null

      const { error: deleteError } = await supabase
        .from('contact_info')
        .delete()
        .eq('id', contactToDelete.value.id)

      if (deleteError) throw deleteError

      await loadContactInfo()
      showContactDeleteDialog.value = false
      contactToDelete.value = null
    } catch (error_) {
      console.error('刪除聯絡資訊失敗:', error_)
      contactError.value = error_.message || '刪除聯絡資訊時發生錯誤'
    } finally {
      contactLoading.value = false
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

  // 格式化日期
  function formatDate (date) {
    if (!date) return ''
    const d = new Date(date)
    return d.toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    })
  }

  // 從 Supabase 載入選項資料
  async function loadOptions () {
    try {
      // 載入圖示選項
      const { data: iconData, error: iconError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'publicAffairs')
        .eq('cate', 'iconOptions')
        .order('key')

      iconOptions.value = (!iconError && iconData)
        ? iconData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
        : [
          { value: 'mdi-file-document', text: '文件' },
          { value: 'mdi-hammer-wrench', text: '工具' },
          { value: 'mdi-calendar-check', text: '日曆' },
          { value: 'mdi-book-search', text: '書籍' },
          { value: 'mdi-account-group', text: '人員' },
          { value: 'mdi-school', text: '學校' },
          { value: 'mdi-camera', text: '相機' },
          { value: 'mdi-package-variant', text: '包裹' },
        ]

      // 載入顏色選項
      const { data: colorData, error: colorError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'publicAffairs')
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
          { value: 'teal', text: '青色', color: 'teal' },
        ]

      // 載入文件類型選項
      const { data: documentTypeData, error: documentTypeError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'publicAffairs')
        .eq('cate', 'documentTypeOptions')
        .order('key')

      documentTypeOptions.value = (!documentTypeError && documentTypeData)
        ? documentTypeData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
        : [
          { value: 'PDF', text: 'PDF' },
          { value: 'DOC', text: 'DOC' },
          { value: 'DOCX', text: 'DOCX' },
          { value: 'XLS', text: 'XLS' },
          { value: 'XLSX', text: 'XLSX' },
        ]
    } catch (error_) {
      console.error('載入選項資料失敗:', error_)
      // 使用預設值
      iconOptions.value = [
        { value: 'mdi-file-document', text: '文件' },
        { value: 'mdi-hammer-wrench', text: '工具' },
        { value: 'mdi-calendar-check', text: '日曆' },
        { value: 'mdi-book-search', text: '書籍' },
        { value: 'mdi-account-group', text: '人員' },
        { value: 'mdi-school', text: '學校' },
        { value: 'mdi-camera', text: '相機' },
        { value: 'mdi-package-variant', text: '包裹' },
      ]
      colorOptions.value = [
        { value: 'primary', text: '主要', color: 'primary' },
        { value: 'success', text: '成功', color: 'success' },
        { value: 'info', text: '資訊', color: 'info' },
        { value: 'warning', text: '警告', color: 'warning' },
        { value: 'error', text: '錯誤', color: 'error' },
        { value: 'purple', text: '紫色', color: 'purple' },
        { value: 'teal', text: '青色', color: 'teal' },
      ]
      documentTypeOptions.value = [
        { value: 'PDF', text: 'PDF' },
        { value: 'DOC', text: 'DOC' },
        { value: 'DOCX', text: 'DOCX' },
        { value: 'XLS', text: 'XLS' },
        { value: 'XLSX', text: 'XLSX' },
      ]
    }
  }

  // 開啟新增表單文件表單
  function openNewDocumentForm () {
    documentFormMode.value = 'new'
    documentForm.value = {
      id: null,
      title: '',
      description: '',
      date: new Date().toISOString().split('T')[0],
      type: 'PDF',
      icon: 'mdi-file-document',
      color: 'primary',
      category: '',
      url: '',
      storage_path: '',
      display_order: 0,
    }
    documentFormErrors.value = {}
    documentFormError.value = null
    documentFile.value = null
    documentFilePreview.value = null
    documentUrlMode.value = 'url'
    if (documentFileInput.value) {
      documentFileInput.value.value = ''
    }
    showDocumentFormDialog.value = true
  }

  // 開啟編輯表單文件表單
  function openEditDocumentForm (document) {
    documentFormMode.value = 'edit'
    documentForm.value = {
      id: document.id,
      title: document.title || '',
      description: document.description || '',
      date: document.date ? document.date.split('T')[0] : new Date().toISOString().split('T')[0],
      type: document.type || 'PDF',
      icon: document.icon || 'mdi-file-document',
      color: document.color || 'primary',
      category: document.category || '',
      url: document.url || '',
      storage_path: document.storage_path || '',
      display_order: document.display_order || 0,
    }
    documentFormErrors.value = {}
    documentFormError.value = null
    documentFile.value = null
    documentFilePreview.value = null
    // 如果有 storage_path，預設為上傳模式，否則為 URL 模式
    documentUrlMode.value = document.storage_path ? 'upload' : 'url'
    if (documentFileInput.value) {
      documentFileInput.value.value = ''
    }
    showDocumentFormDialog.value = true
  }

  // 處理檔案選擇
  function handleDocumentFileSelect (event) {
    const file = event.target.files?.[0]
    if (!file) {
      return
    }

    documentFile.value = file
    documentFormError.value = null

    const reader = new FileReader()
    reader.addEventListener('load', e => {
      documentFilePreview.value = e.target.result
    })
    reader.readAsDataURL(file)
  }

  // 移除檔案
  function removeDocumentFile () {
    documentFile.value = null
    documentFilePreview.value = null
    documentForm.value.storage_path = ''
    documentForm.value.url = ''
    if (documentFileInput.value) {
      documentFileInput.value.value = ''
    }
  }

  // 上傳檔案到 Supabase Storage
  async function uploadDocumentFile (documentId) {
    if (!documentFile.value) return null

    try {
      const fileExt = documentFile.value.name.split('.').pop()
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).slice(2, 9)
      const fileName = `${timestamp}_${randomStr}.${fileExt}`
      const filePath = `public-affairs-documents/${documentId}/${fileName}`

      const { error: uploadError } = await supabase.storage
        .from(BUCKET_NAME)
        .upload(filePath, documentFile.value, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        throw new Error(`檔案上傳失敗: ${uploadError.message || '未知錯誤'}`)
      }

      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(filePath)

      return {
        storage_path: filePath,
        url: publicUrl,
      }
    } catch (error_) {
      console.error('上傳檔案失敗:', error_)
      throw error_
    }
  }

  // 驗證表單文件表單
  function validateDocumentForm () {
    documentFormErrors.value = {}

    if (!documentForm.value.title?.trim()) {
      documentFormErrors.value.title = '請輸入標題'
    }

    if (!documentForm.value.description?.trim()) {
      documentFormErrors.value.description = '請輸入描述'
    }

    if (!documentForm.value.date) {
      documentFormErrors.value.date = '請選擇日期'
    }

    if (!documentForm.value.type?.trim()) {
      documentFormErrors.value.type = '請選擇類型'
    }

    if (!documentForm.value.icon?.trim()) {
      documentFormErrors.value.icon = '請選擇圖示'
    }

    if (!documentForm.value.color?.trim()) {
      documentFormErrors.value.color = '請選擇顏色'
    }

    // 驗證下載連結或檔案
    if (documentUrlMode.value === 'url') {
      if (!documentForm.value.url?.trim()) {
        documentFormErrors.value.url = '請輸入下載連結'
      }
    } else {
      if (!documentFile.value && !documentForm.value.storage_path) {
        documentFormErrors.value.file = '請選擇要上傳的檔案'
      }
    }

    return Object.keys(documentFormErrors.value).length === 0
  }

  // 提交表單文件表單
  async function submitDocumentForm () {
    if (!validateDocumentForm()) {
      documentFormError.value = '請填寫所有必填欄位'
      return
    }

    documentFormLoading.value = true
    documentFormError.value = null

    try {
      const formData = {
        title: documentForm.value.title.trim(),
        description: documentForm.value.description.trim(),
        date: documentForm.value.date,
        type: documentForm.value.type.trim(),
        icon: documentForm.value.icon.trim(),
        color: documentForm.value.color.trim(),
        category: documentForm.value.category?.trim() || null,
        display_order: documentForm.value.display_order || 0,
      }

      if (documentFormMode.value === 'new') {
        // 新增模式：先建立記錄取得 ID，然後上傳檔案，最後更新記錄
        const { data: newDocument, error: insertError } = await supabase
          .from('form_documents')
          .insert(formData)
          .select()
          .single()

        if (insertError) throw insertError

        // 如果有新檔案，現在上傳（使用新建立的 ID）
        if (documentUrlMode.value === 'upload' && documentFile.value) {
          try {
            const fileData = await uploadDocumentFile(newDocument.id)
            if (fileData) {
              // 更新記錄，加入檔案資訊
              const { error: updateError } = await supabase
                .from('form_documents')
                .update({
                  storage_path: fileData.storage_path,
                  url: fileData.url,
                })
                .eq('id', newDocument.id)

              if (updateError) {
                // 如果更新失敗，嘗試刪除已上傳的檔案
                const { error: removeError } = await supabase.storage
                  .from(BUCKET_NAME)
                  .remove([fileData.storage_path])
                if (removeError) {
                  console.error('刪除已上傳檔案失敗:', removeError)
                }
                throw new Error(`更新檔案資訊失敗: ${updateError.message}`)
              }
            }
          } catch (uploadError) {
            console.error('上傳檔案失敗，錯誤詳情:', uploadError)
            // 如果檔案上傳失敗，刪除已建立的記錄
            const { error: deleteError } = await supabase
              .from('form_documents')
              .delete()
              .eq('id', newDocument.id)
            if (deleteError) {
              console.error('刪除記錄失敗:', deleteError)
            }
            throw new Error(`上傳檔案失敗: ${uploadError.message || '未知錯誤'}`)
          }
        } else {
          // URL 模式：直接更新 URL
          const { error: updateError } = await supabase
            .from('form_documents')
            .update({
              url: documentForm.value.url.trim(),
              storage_path: null,
            })
            .eq('id', newDocument.id)

          if (updateError) throw updateError
        }
      } else {
        // 編輯模式
        let fileData = null

        // 如果有新檔案，先上傳
        if (documentUrlMode.value === 'upload' && documentFile.value) {
          fileData = await uploadDocumentFile(documentForm.value.id)

          // 如果有舊檔案在 Storage 中，刪除舊檔案
          if (documentForm.value.storage_path) {
            const { error: deleteError } = await supabase.storage
              .from(BUCKET_NAME)
              .remove([documentForm.value.storage_path])

            if (deleteError) {
              console.error('刪除舊檔案失敗:', deleteError)
              // 不中斷流程，繼續更新
            }
          }
        }

        // 根據模式設定 URL 和 storage_path
        if (documentUrlMode.value === 'upload') {
          if (fileData) {
            formData.storage_path = fileData.storage_path
            formData.url = fileData.url
          } else if (documentForm.value.storage_path) {
            // 保留現有的 storage_path（編輯時沒有上傳新檔案）
            formData.storage_path = documentForm.value.storage_path
            formData.url = documentForm.value.url
          }
        } else {
          // URL 模式
          formData.url = documentForm.value.url.trim()
          formData.storage_path = null
          // 如果有舊檔案，刪除它
          if (documentForm.value.storage_path) {
            const { error: deleteError } = await supabase.storage
              .from(BUCKET_NAME)
              .remove([documentForm.value.storage_path])

            if (deleteError) {
              console.error('刪除舊檔案失敗:', deleteError)
            }
          }
        }

        const { error: updateError } = await supabase
          .from('form_documents')
          .update(formData)
          .eq('id', documentForm.value.id)

        if (updateError) throw updateError
      }

      await loadFormDocuments()
      showDocumentFormDialog.value = false
    } catch (error_) {
      console.error('提交表單文件表單失敗:', error_)
      documentFormError.value = error_.message || '提交表單時發生錯誤'
    } finally {
      documentFormLoading.value = false
    }
  }

  // 開啟新增聯絡資訊表單
  function openNewContactForm () {
    contactFormMode.value = 'new'
    contactForm.value = {
      id: null,
      title: '',
      description: '',
      value: '',
      icon: 'mdi-phone',
      color: 'primary',
      action: '',
      button_text: '',
      display_order: 0,
    }
    contactFormErrors.value = {}
    contactFormError.value = null
    showContactFormDialog.value = true
  }

  // 開啟編輯聯絡資訊表單
  function openEditContactForm (contact) {
    contactFormMode.value = 'edit'
    contactForm.value = {
      id: contact.id,
      title: contact.title || '',
      description: contact.description || '',
      value: contact.value || '',
      icon: contact.icon || 'mdi-phone',
      color: contact.color || 'primary',
      action: contact.action || '',
      button_text: contact.button_text || '',
      display_order: contact.display_order || 0,
    }
    contactFormErrors.value = {}
    contactFormError.value = null
    showContactFormDialog.value = true
  }

  // 驗證聯絡資訊表單
  function validateContactForm () {
    contactFormErrors.value = {}

    if (!contactForm.value.title?.trim()) {
      contactFormErrors.value.title = '請輸入標題'
    }

    if (!contactForm.value.description?.trim()) {
      contactFormErrors.value.description = '請輸入描述'
    }

    if (!contactForm.value.value?.trim()) {
      contactFormErrors.value.value = '請輸入值'
    }

    if (!contactForm.value.icon?.trim()) {
      contactFormErrors.value.icon = '請選擇圖示'
    }

    if (!contactForm.value.color?.trim()) {
      contactFormErrors.value.color = '請選擇顏色'
    }

    if (!contactForm.value.action?.trim()) {
      contactFormErrors.value.action = '請輸入動作連結'
    }

    if (!contactForm.value.button_text?.trim()) {
      contactFormErrors.value.button_text = '請輸入按鈕文字'
    }

    return Object.keys(contactFormErrors.value).length === 0
  }

  // 提交聯絡資訊表單
  async function submitContactForm () {
    if (!validateContactForm()) {
      contactFormError.value = '請填寫所有必填欄位'
      return
    }

    contactFormLoading.value = true
    contactFormError.value = null

    try {
      const formData = {
        title: contactForm.value.title.trim(),
        description: contactForm.value.description.trim(),
        value: contactForm.value.value.trim(),
        icon: contactForm.value.icon.trim(),
        color: contactForm.value.color.trim(),
        action: contactForm.value.action.trim(),
        button_text: contactForm.value.button_text.trim(),
        display_order: contactForm.value.display_order || 0,
      }

      if (contactFormMode.value === 'new') {
        const { error: insertError } = await supabase
          .from('contact_info')
          .insert(formData)

        if (insertError) throw insertError
      } else {
        const { error: updateError } = await supabase
          .from('contact_info')
          .update(formData)
          .eq('id', contactForm.value.id)

        if (updateError) throw updateError
      }

      await loadContactInfo()
      showContactFormDialog.value = false
    } catch (error_) {
      console.error('提交聯絡資訊表單失敗:', error_)
      contactFormError.value = error_.message || '提交表單時發生錯誤'
    } finally {
      contactFormLoading.value = false
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
      loadFormDocuments(),
      loadContactInfo(),
    ])
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-h4 font-weight-bold mb-2">
        公務資訊管理
      </h1>
      <p class="text-body-2 text-medium-emphasis">
        管理表單文件與聯絡資訊
      </p>
    </div>

    <!-- 表單文件區塊 -->
    <v-card class="mb-8" elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            表單文件管理
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理各類公務表單與文件下載
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewDocumentForm"
        >
          新增文件
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="documentsError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="documentsError = null"
      >
        {{ documentsError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="documentsLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 表單文件列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              標題
            </th>
            <th class="text-left">
              描述
            </th>
            <th class="text-center">
              日期
            </th>
            <th class="text-center">
              類型
            </th>
            <th class="text-center">
              分類
            </th>
            <th class="text-center">
              圖示/顏色
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
            v-if="formDocuments.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="8">
              目前沒有表單文件資料
            </td>
          </tr>
          <tr
            v-for="document in formDocuments"
            :key="document.id"
          >
            <td>
              <div class="font-weight-medium">
                {{ document.title }}
              </div>
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ document.description?.slice(0, 50) }}{{ document.description?.length > 50 ? '...' : '' }}
              </div>
            </td>
            <td class="text-center">
              {{ formatDate(document.date) }}
            </td>
            <td class="text-center">
              <v-chip
                color="info"
                size="small"
                variant="tonal"
              >
                {{ document.type }}
              </v-chip>
            </td>
            <td class="text-center">
              <v-chip
                v-if="document.category"
                :color="getColorVariant(document.color)"
                size="small"
                variant="tonal"
              >
                {{ document.category }}
              </v-chip>
              <span v-else class="text-medium-emphasis">-</span>
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(document.color)">
                {{ document.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              {{ document.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditDocumentForm(document)"
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
                @click="deleteDocument(document)"
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
      <v-card-text v-if="!documentsLoading" class="text-body-2 text-medium-emphasis">
        共 {{ formDocuments.length }} 個表單文件
      </v-card-text>
    </v-card>

    <!-- 聯絡資訊區塊 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            聯絡資訊管理
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理聯絡方式資訊
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewContactForm"
        >
          新增聯絡資訊
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="contactError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="contactError = null"
      >
        {{ contactError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="contactLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 聯絡資訊列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              標題
            </th>
            <th class="text-left">
              描述
            </th>
            <th class="text-center">
              值
            </th>
            <th class="text-center">
              圖示/顏色
            </th>
            <th class="text-center">
              按鈕文字
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
            v-if="contactInfo.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="7">
              目前沒有聯絡資訊資料
            </td>
          </tr>
          <tr
            v-for="contact in contactInfo"
            :key="contact.id"
          >
            <td>
              <div class="font-weight-medium">
                {{ contact.title }}
              </div>
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ contact.description }}
              </div>
            </td>
            <td class="text-center">
              {{ contact.value }}
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(contact.color)">
                {{ contact.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              {{ contact.button_text }}
            </td>
            <td class="text-center">
              {{ contact.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditContactForm(contact)"
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
                @click="deleteContact(contact)"
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
      <v-card-text v-if="!contactLoading" class="text-body-2 text-medium-emphasis">
        共 {{ contactInfo.length }} 筆聯絡資訊
      </v-card-text>
    </v-card>

    <!-- 表單文件刪除確認對話框 -->
    <v-dialog
      v-model="showDocumentDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除表單文件
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下表單文件嗎？
          </p>
          <v-card
            v-if="documentToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ documentToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ documentToDelete.description?.slice(0, 100) }}{{ documentToDelete.description?.length > 100 ? '...' : '' }}
            </div>
            <div class="text-caption text-medium-emphasis mt-2">
              日期：{{ formatDate(documentToDelete.date) }}
            </div>
            <div class="text-caption text-medium-emphasis">
              類型：{{ documentToDelete.type }}
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
            @click="showDocumentDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            :loading="documentsLoading"
            variant="flat"
            @click="confirmDeleteDocument"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 聯絡資訊刪除確認對話框 -->
    <v-dialog
      v-model="showContactDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除聯絡資訊
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下聯絡資訊嗎？
          </p>
          <v-card
            v-if="contactToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ contactToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ contactToDelete.description }}
            </div>
            <div class="text-caption text-medium-emphasis mt-2">
              值：{{ contactToDelete.value }}
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
            @click="showContactDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="error"
            :loading="contactLoading"
            variant="flat"
            @click="confirmDeleteContact"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 表單文件表單對話框 -->
    <v-dialog
      v-model="showDocumentFormDialog"
      max-width="800"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ documentFormMode === 'new' ? '新增表單文件' : '編輯表單文件' }}
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="documentFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="documentFormError = null"
          >
            {{ documentFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="documentForm.title"
                  :error-messages="documentFormErrors.title"
                  label="標題 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-textarea
                  v-model="documentForm.description"
                  :error-messages="documentFormErrors.description"
                  label="描述 *"
                  required
                  rows="3"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="documentForm.date"
                  :error-messages="documentFormErrors.date"
                  label="日期 *"
                  required
                  type="date"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="documentForm.type"
                  :error-messages="documentFormErrors.type"
                  item-title="text"
                  item-value="value"
                  :items="documentTypeOptions"
                  label="類型 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="documentForm.icon"
                  :error-messages="documentFormErrors.icon"
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
                  v-model="documentForm.color"
                  :error-messages="documentFormErrors.color"
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
              <v-col cols="12">
                <v-text-field
                  v-model="documentForm.category"
                  label="分類"
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-label class="mb-2">
                  下載方式 *
                </v-label>
                <v-radio-group
                  v-model="documentUrlMode"
                  inline
                >
                  <v-radio
                    label="輸入連結"
                    value="url"
                  />
                  <v-radio
                    label="上傳檔案"
                    value="upload"
                  />
                </v-radio-group>
              </v-col>

              <!-- URL 輸入模式 -->
              <v-col v-if="documentUrlMode === 'url'" cols="12">
                <v-text-field
                  v-model="documentForm.url"
                  :error-messages="documentFormErrors.url"
                  label="下載連結 *"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 檔案上傳模式 -->
              <v-col v-if="documentUrlMode === 'upload'" cols="12">
                <v-file-input
                  ref="documentFileInput"
                  accept=".pdf,.doc,.docx,.xls,.xlsx"
                  :error-messages="documentFormErrors.file"
                  label="選擇檔案 *"
                  prepend-icon="mdi-file-document"
                  variant="outlined"
                  @change="handleDocumentFileSelect"
                >
                  <template #prepend-inner>
                    <v-icon icon="mdi-file-document" />
                  </template>
                </v-file-input>
                <div
                  v-if="documentFilePreview || documentForm.storage_path"
                  class="mt-2"
                >
                  <v-card
                    v-if="documentFilePreview"
                    class="pa-2"
                    color="surface-variant"
                    variant="tonal"
                  >
                    <div class="d-flex align-center">
                      <v-icon class="mr-2" icon="mdi-file-document" />
                      <span class="text-body-2">{{ documentFile?.name }}</span>
                      <v-spacer />
                      <v-btn
                        icon
                        size="small"
                        variant="text"
                        @click="removeDocumentFile"
                      >
                        <v-icon icon="mdi-close" />
                      </v-btn>
                    </div>
                  </v-card>
                  <v-card
                    v-else-if="documentForm.storage_path"
                    class="pa-2"
                    color="surface-variant"
                    variant="tonal"
                  >
                    <div class="d-flex align-center">
                      <v-icon class="mr-2" icon="mdi-file-check" />
                      <span class="text-body-2">已上傳檔案</span>
                      <v-spacer />
                      <v-btn
                        icon
                        size="small"
                        variant="text"
                        @click="removeDocumentFile"
                      >
                        <v-icon icon="mdi-close" />
                      </v-btn>
                    </div>
                  </v-card>
                </div>
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model.number="documentForm.display_order"
                  label="顯示順序"
                  type="number"
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
            @click="showDocumentFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="documentFormLoading"
            variant="flat"
            @click="submitDocumentForm"
          >
            {{ documentFormMode === 'new' ? '新增' : '更新' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 聯絡資訊表單對話框 -->
    <v-dialog
      v-model="showContactFormDialog"
      max-width="600"
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ contactFormMode === 'new' ? '新增聯絡資訊' : '編輯聯絡資訊' }}
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="contactFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="contactFormError = null"
          >
            {{ contactFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="contactForm.title"
                  :error-messages="contactFormErrors.title"
                  label="標題 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="contactForm.description"
                  :error-messages="contactFormErrors.description"
                  label="描述 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="contactForm.value"
                  :error-messages="contactFormErrors.value"
                  label="值 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-select
                  v-model="contactForm.icon"
                  :error-messages="contactFormErrors.icon"
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
                  v-model="contactForm.color"
                  :error-messages="contactFormErrors.color"
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
              <v-col cols="12">
                <v-text-field
                  v-model="contactForm.action"
                  :error-messages="contactFormErrors.action"
                  label="動作連結 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="contactForm.button_text"
                  :error-messages="contactFormErrors.button_text"
                  label="按鈕文字 *"
                  required
                  variant="outlined"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model.number="contactForm.display_order"
                  label="顯示順序"
                  type="number"
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
            @click="showContactFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="primary"
            :loading="contactFormLoading"
            variant="flat"
            @click="submitContactForm"
          >
            {{ contactFormMode === 'new' ? '新增' : '更新' }}
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
