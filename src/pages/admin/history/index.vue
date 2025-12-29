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

  // Timeline 事件相關
  const timelineEvents = ref([])
  const timelineLoading = ref(false)
  const timelineError = ref(null)
  const showTimelineDeleteDialog = ref(false)
  const timelineEventToDelete = ref(null)

  // Timeline 表單對話框
  const showTimelineFormDialog = ref(false)
  const timelineFormMode = ref('new') // 'new' 或 'edit'
  const timelineFormLoading = ref(false)
  const timelineFormError = ref(null)
  const timelineForm = ref({
    id: null,
    year: '',
    title: '',
    description: '',
    icon: 'mdi-calendar',
    color: 'primary',
    image_url: '',
    storage_path: '',
    display_order: 0,
  })
  const timelineFormErrors = ref({})
  const timelineImageFile = ref(null)
  const timelineImagePreview = ref(null)
  const timelineImageInput = ref(null)

  // 圖示選項（從 Supabase 載入或使用預設值）
  const iconOptions = ref([
    { value: 'mdi-home', text: '首頁' },
    { value: 'mdi-flag', text: '旗幟' },
    { value: 'mdi-hammer-wrench', text: '工具' },
    { value: 'mdi-shield-star', text: '保護' },
    { value: 'mdi-tools', text: '修復' },
    { value: 'mdi-calendar', text: '日曆' },
    { value: 'mdi-book-open-variant', text: '書籍' },
    { value: 'mdi-account-group', text: '人員' },
    { value: 'mdi-palette', text: '藝術' },
    { value: 'mdi-information', text: '資訊' },
  ])

  // 顏色選項
  const colorOptions = ref([
    { value: 'primary', text: '主要', color: 'primary' },
    { value: 'success', text: '成功', color: 'success' },
    { value: 'info', text: '資訊', color: 'info' },
    { value: 'warning', text: '警告', color: 'warning' },
    { value: 'error', text: '錯誤', color: 'error' },
  ])

  // 歷史意義相關
  const historicalSignificance = ref([])
  const significanceLoading = ref(false)
  const significanceError = ref(null)
  const showSignificanceDeleteDialog = ref(false)
  const significanceToDelete = ref(null)

  // 歷史意義表單對話框
  const showSignificanceFormDialog = ref(false)
  const significanceFormMode = ref('new') // 'new' 或 'edit'
  const significanceFormLoading = ref(false)
  const significanceFormError = ref(null)
  const significanceForm = ref({
    id: null,
    title: '',
    description: '',
    icon: 'mdi-information',
    color: 'primary',
    image_url: '',
    storage_path: '',
    display_order: 0,
  })
  const significanceFormErrors = ref({})
  const significanceImageFile = ref(null)
  const significanceImagePreview = ref(null)
  const significanceImageInput = ref(null)

  // 從 Supabase 載入時間軸事件
  async function loadTimelineEvents () {
    timelineLoading.value = true
    timelineError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('history_timeline_events')
        .select('*')
        .order('display_order', { ascending: true })
        .order('year', { ascending: true })

      if (fetchError) throw fetchError

      timelineEvents.value = data || []
    } catch (error_) {
      console.error('載入時間軸事件失敗:', error_)
      timelineError.value = error_.message || '載入時間軸事件時發生錯誤'
    } finally {
      timelineLoading.value = false
    }
  }

  // 從 Supabase 載入歷史意義資料
  async function loadHistoricalSignificance () {
    significanceLoading.value = true
    significanceError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('history_significance')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      historicalSignificance.value = data || []
    } catch (error_) {
      console.error('載入歷史意義資料失敗:', error_)
      significanceError.value = error_.message || '載入歷史意義資料時發生錯誤'
    } finally {
      significanceLoading.value = false
    }
  }

  // 刪除時間軸事件
  async function deleteTimelineEvent (event) {
    timelineEventToDelete.value = event
    showTimelineDeleteDialog.value = true
  }

  async function confirmDeleteTimelineEvent () {
    if (!timelineEventToDelete.value) return

    try {
      timelineLoading.value = true
      timelineError.value = null

      // 如果有圖片在 Storage 中，刪除圖片
      if (timelineEventToDelete.value.storage_path) {
        const { error: storageError } = await supabase.storage
          .from('wanxuanju-files')
          .remove([timelineEventToDelete.value.storage_path])

        if (storageError) {
          console.error('刪除圖片檔案失敗:', storageError)
        }
      }

      // 刪除事件記錄
      const { error: deleteError } = await supabase
        .from('history_timeline_events')
        .delete()
        .eq('id', timelineEventToDelete.value.id)

      if (deleteError) throw deleteError

      // 重新載入列表
      await loadTimelineEvents()
      showTimelineDeleteDialog.value = false
      timelineEventToDelete.value = null
    } catch (error_) {
      console.error('刪除時間軸事件失敗:', error_)
      timelineError.value = error_.message || '刪除時間軸事件時發生錯誤'
    } finally {
      timelineLoading.value = false
    }
  }

  // 刪除歷史意義項目
  async function deleteSignificance (item) {
    significanceToDelete.value = item
    showSignificanceDeleteDialog.value = true
  }

  async function confirmDeleteSignificance () {
    if (!significanceToDelete.value) return

    try {
      significanceLoading.value = true
      significanceError.value = null

      // 如果有圖片在 Storage 中，刪除圖片
      if (significanceToDelete.value.storage_path) {
        const { error: storageError } = await supabase.storage
          .from('wanxuanju-files')
          .remove([significanceToDelete.value.storage_path])

        if (storageError) {
          console.error('刪除圖片檔案失敗:', storageError)
        }
      }

      // 刪除記錄
      const { error: deleteError } = await supabase
        .from('history_significance')
        .delete()
        .eq('id', significanceToDelete.value.id)

      if (deleteError) throw deleteError

      // 重新載入列表
      await loadHistoricalSignificance()
      showSignificanceDeleteDialog.value = false
      significanceToDelete.value = null
    } catch (error_) {
      console.error('刪除歷史意義項目失敗:', error_)
      significanceError.value = error_.message || '刪除歷史意義項目時發生錯誤'
    } finally {
      significanceLoading.value = false
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
    }
    return colorMap[color] || 'primary'
  }

  // 格式化圖片 URL（如果有 storage_path）
  function getImageUrl (item) {
    if (item.image_url) {
      return item.image_url
    }
    if (item.storage_path) {
      const { data: { publicUrl } } = supabase.storage
        .from('wanxuanju-files')
        .getPublicUrl(item.storage_path)
      return publicUrl
    }
    return null
  }

  // 打開新增時間軸事件表單
  function openNewTimelineForm () {
    timelineFormMode.value = 'new'
    timelineForm.value = {
      id: null,
      year: '',
      title: '',
      description: '',
      icon: 'mdi-calendar',
      color: 'primary',
      image_url: '',
      storage_path: '',
      display_order: timelineEvents.value.length > 0
        ? Math.max(...timelineEvents.value.map(e => e.display_order || 0)) + 1
        : 0,
    }
    timelineImageFile.value = null
    timelineImagePreview.value = null
    timelineFormErrors.value = {}
    timelineFormError.value = null
    showTimelineFormDialog.value = true
  }

  // 打開編輯時間軸事件表單
  function openEditTimelineForm (event) {
    timelineFormMode.value = 'edit'
    timelineForm.value = {
      id: event.id,
      year: event.year || '',
      title: event.title || '',
      description: event.description || '',
      icon: event.icon || 'mdi-calendar',
      color: event.color || 'primary',
      image_url: event.image_url || '',
      storage_path: event.storage_path || '',
      display_order: event.display_order || 0,
    }
    timelineImageFile.value = null
    timelineImagePreview.value = getImageUrl(event)
    timelineFormErrors.value = {}
    timelineFormError.value = null
    showTimelineFormDialog.value = true
  }

  // 處理圖片選擇
  function handleTimelineImageSelect (file) {
    // v-file-input 的 @update:model-value 傳遞的是檔案本身，不是事件
    if (!file) {
      timelineImageFile.value = null
      timelineImagePreview.value = null
      return
    }

    // 驗證檔案大小（最大 5MB）
    const maxSize = 5 * 1024 * 1024
    if (file.size > maxSize) {
      timelineFormError.value = '圖片檔案大小不能超過 5MB'
      timelineImageFile.value = null
      timelineImagePreview.value = null
      return
    }

    // 驗證檔案類型
    if (!file.type.startsWith('image/')) {
      timelineFormError.value = '請選擇圖片檔案'
      timelineImageFile.value = null
      timelineImagePreview.value = null
      return
    }

    timelineImageFile.value = file
    timelineFormError.value = null

    // 建立預覽
    const reader = new FileReader()
    reader.addEventListener('load', e => {
      timelineImagePreview.value = e.target.result
    })
    reader.readAsDataURL(file)
  }

  // 移除圖片
  function removeTimelineImage () {
    timelineImageFile.value = null
    timelineImagePreview.value = null
    timelineForm.value.image_url = ''
    timelineForm.value.storage_path = ''
    if (timelineImageInput.value) {
      timelineImageInput.value.value = ''
    }
  }

  // 驗證表單
  function validateTimelineForm () {
    timelineFormErrors.value = {}

    if (!timelineForm.value.year?.trim()) {
      timelineFormErrors.value.year = '請輸入年份'
    }

    if (!timelineForm.value.title?.trim()) {
      timelineFormErrors.value.title = '請輸入標題'
    }

    if (!timelineForm.value.description?.trim()) {
      timelineFormErrors.value.description = '請輸入描述'
    }

    return Object.keys(timelineFormErrors.value).length === 0
  }

  // 上傳圖片到 Supabase Storage
  async function uploadTimelineImage (eventId) {
    if (!timelineImageFile.value) return null

    try {
      const fileExt = timelineImageFile.value.name.split('.').pop()
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).slice(2, 9)
      const fileName = `${timestamp}_${randomStr}.${fileExt}`
      const filePath = `history-timeline/${eventId}/${fileName}`

      console.log('準備上傳圖片:', {
        fileName,
        filePath,
        fileSize: timelineImageFile.value.size,
        fileType: timelineImageFile.value.type,
        eventId,
      })

      // 上傳檔案
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('wanxuanju-files')
        .upload(filePath, timelineImageFile.value, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        console.error('上傳圖片錯誤詳情:', {
          error: uploadError,
          message: uploadError.message,
          statusCode: uploadError.statusCode,
          errorCode: uploadError.error,
        })
        throw new Error(`圖片上傳失敗: ${uploadError.message || '未知錯誤'}`)
      }

      console.log('圖片上傳成功:', uploadData)

      // 取得公開 URL
      const { data: { publicUrl } } = supabase.storage
        .from('wanxuanju-files')
        .getPublicUrl(filePath)

      console.log('圖片公開 URL:', publicUrl)

      return {
        storage_path: filePath,
        image_url: publicUrl,
      }
    } catch (error_) {
      console.error('上傳圖片失敗:', error_)
      throw error_
    }
  }

  // 提交時間軸事件表單
  async function submitTimelineForm () {
    if (!validateTimelineForm()) {
      timelineFormError.value = '請填寫所有必填欄位'
      return
    }

    timelineFormLoading.value = true
    timelineFormError.value = null

    try {
      const formData = {
        year: timelineForm.value.year.trim(),
        title: timelineForm.value.title.trim(),
        description: timelineForm.value.description.trim(),
        icon: timelineForm.value.icon,
        color: timelineForm.value.color,
        display_order: timelineForm.value.display_order || 0,
      }

      if (timelineFormMode.value === 'new') {
        // 新增模式：先建立記錄取得 ID，然後上傳圖片，最後更新記錄
        const { data: newEvent, error: insertError } = await supabase
          .from('history_timeline_events')
          .insert(formData)
          .select()
          .single()

        if (insertError) throw insertError

        // 如果有新圖片，現在上傳（使用新建立的 ID）
        if (timelineImageFile.value) {
          try {
            console.log('開始上傳圖片，事件 ID:', newEvent.id)
            const imageData = await uploadTimelineImage(newEvent.id)
            if (imageData) {
              console.log('圖片上傳成功，更新記錄:', imageData)
              // 更新記錄，加入圖片資訊
              const { error: updateError } = await supabase
                .from('history_timeline_events')
                .update({
                  storage_path: imageData.storage_path,
                  image_url: imageData.image_url,
                })
                .eq('id', newEvent.id)

              if (updateError) {
                console.error('更新圖片資訊失敗:', updateError)
                // 如果更新失敗，嘗試刪除已上傳的圖片
                const { error: removeError } = await supabase.storage
                  .from('wanxuanju-files')
                  .remove([imageData.storage_path])
                if (removeError) {
                  console.error('刪除已上傳圖片失敗:', removeError)
                }
                throw new Error(`更新圖片資訊失敗: ${updateError.message}`)
              }
              console.log('記錄更新成功')
            }
          } catch (uploadError) {
            console.error('上傳圖片失敗，錯誤詳情:', uploadError)
            // 如果圖片上傳失敗，刪除已建立的記錄
            const { error: deleteError } = await supabase
              .from('history_timeline_events')
              .delete()
              .eq('id', newEvent.id)
            if (deleteError) {
              console.error('刪除記錄失敗:', deleteError)
            }
            throw new Error(`上傳圖片失敗: ${uploadError.message || '未知錯誤'}`)
          }
        } else if (timelineForm.value.image_url) {
          // 如果只有外部 URL，直接更新
          const { error: updateError } = await supabase
            .from('history_timeline_events')
            .update({
              image_url: timelineForm.value.image_url,
            })
            .eq('id', newEvent.id)

          if (updateError) throw updateError
        }
      } else {
        // 編輯模式
        let imageData = null

        // 如果有新圖片，先上傳
        if (timelineImageFile.value) {
          console.log('編輯模式：開始上傳新圖片，事件 ID:', timelineForm.value.id)
          imageData = await uploadTimelineImage(timelineForm.value.id)
          console.log('編輯模式：圖片上傳成功', imageData)
        }

        // 如果有圖片資料，加入表單
        if (imageData) {
          formData.storage_path = imageData.storage_path
          formData.image_url = imageData.image_url

          // 如果有舊圖片在 Storage 中，刪除舊圖片
          if (timelineForm.value.storage_path) {
            const { error: deleteError } = await supabase.storage
              .from('wanxuanju-files')
              .remove([timelineForm.value.storage_path])

            if (deleteError) {
              console.error('刪除舊圖片失敗:', deleteError)
              // 不中斷流程，繼續更新
            }
          }
        } else if (timelineForm.value.image_url && !timelineImageFile.value) {
          // 保留現有的圖片 URL（編輯時沒有上傳新圖片）
          formData.image_url = timelineForm.value.image_url
          formData.storage_path = timelineForm.value.storage_path
        }

        const { error: updateError } = await supabase
          .from('history_timeline_events')
          .update(formData)
          .eq('id', timelineForm.value.id)

        if (updateError) throw updateError
      }

      // 重新載入列表
      await loadTimelineEvents()
      showTimelineFormDialog.value = false
    } catch (error_) {
      console.error('儲存時間軸事件失敗:', error_)
      timelineFormError.value = error_.message || '儲存時間軸事件時發生錯誤'
    } finally {
      timelineFormLoading.value = false
    }
  }

  // 打開新增歷史意義表單
  function openNewSignificanceForm () {
    significanceFormMode.value = 'new'
    significanceForm.value = {
      id: null,
      title: '',
      description: '',
      icon: 'mdi-information',
      color: 'primary',
      image_url: '',
      storage_path: '',
      display_order: historicalSignificance.value.length > 0
        ? Math.max(...historicalSignificance.value.map(item => item.display_order || 0)) + 1
        : 0,
    }
    significanceImageFile.value = null
    significanceImagePreview.value = null
    significanceFormErrors.value = {}
    significanceFormError.value = null
    showSignificanceFormDialog.value = true
  }

  // 打開編輯歷史意義表單
  function openEditSignificanceForm (item) {
    significanceFormMode.value = 'edit'
    significanceForm.value = {
      id: item.id,
      title: item.title || '',
      description: item.description || '',
      icon: item.icon || 'mdi-information',
      color: item.color || 'primary',
      image_url: item.image_url || '',
      storage_path: item.storage_path || '',
      display_order: item.display_order || 0,
    }
    significanceImageFile.value = null
    significanceImagePreview.value = getImageUrl(item)
    significanceFormErrors.value = {}
    significanceFormError.value = null
    showSignificanceFormDialog.value = true
  }

  // 處理歷史意義圖片選擇
  function handleSignificanceImageSelect (file) {
    if (!file) {
      significanceImageFile.value = null
      significanceImagePreview.value = null
      return
    }

    const maxSize = 5 * 1024 * 1024
    if (file.size > maxSize) {
      significanceFormError.value = '圖片檔案大小不能超過 5MB'
      significanceImageFile.value = null
      significanceImagePreview.value = null
      return
    }

    if (!file.type.startsWith('image/')) {
      significanceFormError.value = '請選擇圖片檔案'
      significanceImageFile.value = null
      significanceImagePreview.value = null
      return
    }

    significanceImageFile.value = file
    significanceFormError.value = null

    const reader = new FileReader()
    reader.addEventListener('load', e => {
      significanceImagePreview.value = e.target.result
    })
    reader.readAsDataURL(file)
  }

  // 移除歷史意義圖片
  function removeSignificanceImage () {
    significanceImageFile.value = null
    significanceImagePreview.value = null
    significanceForm.value.image_url = ''
    significanceForm.value.storage_path = ''
    if (significanceImageInput.value) {
      significanceImageInput.value.value = ''
    }
  }

  // 驗證歷史意義表單
  function validateSignificanceForm () {
    significanceFormErrors.value = {}

    if (!significanceForm.value.title?.trim()) {
      significanceFormErrors.value.title = '請輸入標題'
    }

    if (!significanceForm.value.description?.trim()) {
      significanceFormErrors.value.description = '請輸入描述'
    }

    return Object.keys(significanceFormErrors.value).length === 0
  }

  // 上傳歷史意義圖片到 Supabase Storage
  async function uploadSignificanceImage (itemId) {
    if (!significanceImageFile.value) return null

    try {
      const fileExt = significanceImageFile.value.name.split('.').pop()
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).slice(2, 9)
      const fileName = `${timestamp}_${randomStr}.${fileExt}`
      const filePath = `history-significance/${itemId}/${fileName}`

      console.log('準備上傳歷史意義圖片:', {
        fileName,
        filePath,
        fileSize: significanceImageFile.value.size,
        fileType: significanceImageFile.value.type,
        itemId,
      })

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('wanxuanju-files')
        .upload(filePath, significanceImageFile.value, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        console.error('上傳圖片錯誤詳情:', uploadError)
        throw new Error(`圖片上傳失敗: ${uploadError.message || '未知錯誤'}`)
      }

      console.log('歷史意義圖片上傳成功:', uploadData)

      const { data: { publicUrl } } = supabase.storage
        .from('wanxuanju-files')
        .getPublicUrl(filePath)

      console.log('歷史意義圖片公開 URL:', publicUrl)

      return {
        storage_path: filePath,
        image_url: publicUrl,
      }
    } catch (error_) {
      console.error('上傳歷史意義圖片失敗:', error_)
      throw error_
    }
  }

  // 提交歷史意義表單
  async function submitSignificanceForm () {
    if (!validateSignificanceForm()) {
      significanceFormError.value = '請填寫所有必填欄位'
      return
    }

    significanceFormLoading.value = true
    significanceFormError.value = null

    try {
      const formData = {
        title: significanceForm.value.title.trim(),
        description: significanceForm.value.description.trim(),
        icon: significanceForm.value.icon,
        color: significanceForm.value.color,
        display_order: significanceForm.value.display_order || 0,
      }

      if (significanceFormMode.value === 'new') {
        // 新增模式：先建立記錄取得 ID，然後上傳圖片，最後更新記錄
        const { data: newItem, error: insertError } = await supabase
          .from('history_significance')
          .insert(formData)
          .select()
          .single()

        if (insertError) throw insertError

        if (significanceImageFile.value) {
          try {
            console.log('開始上傳歷史意義圖片，項目 ID:', newItem.id)
            const imageData = await uploadSignificanceImage(newItem.id)
            if (imageData) {
              console.log('歷史意義圖片上傳成功，更新記錄:', imageData)
              const { error: updateError } = await supabase
                .from('history_significance')
                .update({
                  storage_path: imageData.storage_path,
                  image_url: imageData.image_url,
                })
                .eq('id', newItem.id)

              if (updateError) {
                console.error('更新圖片資訊失敗:', updateError)
                const { error: removeError } = await supabase.storage
                  .from('wanxuanju-files')
                  .remove([imageData.storage_path])
                if (removeError) {
                  console.error('刪除已上傳圖片失敗:', removeError)
                }
                throw new Error(`更新圖片資訊失敗: ${updateError.message}`)
              }
              console.log('記錄更新成功')
            }
          } catch (uploadError) {
            console.error('上傳歷史意義圖片失敗，錯誤詳情:', uploadError)
            const { error: deleteError } = await supabase
              .from('history_significance')
              .delete()
              .eq('id', newItem.id)
            if (deleteError) {
              console.error('刪除記錄失敗:', deleteError)
            }
            throw new Error(`上傳圖片失敗: ${uploadError.message || '未知錯誤'}`)
          }
        } else if (significanceForm.value.image_url) {
          const { error: updateError } = await supabase
            .from('history_significance')
            .update({
              image_url: significanceForm.value.image_url,
            })
            .eq('id', newItem.id)

          if (updateError) throw updateError
        }
      } else {
        // 編輯模式
        let imageData = null

        if (significanceImageFile.value) {
          console.log('編輯模式：開始上傳新圖片，項目 ID:', significanceForm.value.id)
          imageData = await uploadSignificanceImage(significanceForm.value.id)
          console.log('編輯模式：圖片上傳成功', imageData)
        }

        if (imageData) {
          formData.storage_path = imageData.storage_path
          formData.image_url = imageData.image_url

          if (significanceForm.value.storage_path) {
            const { error: deleteError } = await supabase.storage
              .from('wanxuanju-files')
              .remove([significanceForm.value.storage_path])

            if (deleteError) {
              console.error('刪除舊圖片失敗:', deleteError)
            }
          }
        } else if (significanceForm.value.image_url && !significanceImageFile.value) {
          formData.image_url = significanceForm.value.image_url
          formData.storage_path = significanceForm.value.storage_path
        }

        const { error: updateError } = await supabase
          .from('history_significance')
          .update(formData)
          .eq('id', significanceForm.value.id)

        if (updateError) throw updateError
      }

      await loadHistoricalSignificance()
      showSignificanceFormDialog.value = false
    } catch (error_) {
      console.error('儲存歷史意義項目失敗:', error_)
      significanceFormError.value = error_.message || '儲存歷史意義項目時發生錯誤'
    } finally {
      significanceFormLoading.value = false
    }
  }

  // 元件掛載時載入資料
  onMounted(async () => {
    await authStore.initAuth()

    if (!authStore.isAuthenticated) {
      router.push('/admin/login')
      return
    }

    await Promise.all([
      loadTimelineEvents(),
      loadHistoricalSignificance(),
    ])
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
        <h1 class="text-h4 font-weight-bold mb-2">
          歷史沿革管理
        </h1>
        <p class="text-body-2 text-medium-emphasis">
          管理時間軸事件與歷史意義內容
        </p>
    </div>

    <!-- Timeline 事件區塊 -->
    <v-card class="mb-8" elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
          時間軸事件
              </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理歷史時間軸上的重要事件
          </p>
        </div>
              <v-btn
                color="primary"
                prepend-icon="mdi-plus"
          @click="openNewTimelineForm"
              >
                新增事件
              </v-btn>
      </v-card-title>

      <v-divider />

      <!-- Timeline 錯誤訊息 -->
      <v-alert
        v-if="timelineError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="timelineError = null"
      >
        {{ timelineError }}
      </v-alert>

      <!-- Timeline 載入中 -->
      <div v-if="timelineLoading" class="text-center py-12">
              <v-progress-circular
                color="primary"
                indeterminate
                size="64"
              />
              <p class="mt-4 text-body-1 text-medium-emphasis">
                載入中...
              </p>
            </div>

      <!-- Timeline 列表 -->
            <v-table v-else>
              <thead>
                <tr>
                  <th class="text-left">
                    年份
                  </th>
                  <th class="text-left">
                    標題
                  </th>
                  <th class="text-left">
                    描述
                  </th>
                  <th class="text-center">
                    圖示/顏色
                  </th>
                  <th class="text-center">
                    圖片
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
                  v-if="timelineEvents.length === 0"
                  class="text-center"
                >
            <td class="py-8 text-medium-emphasis" colspan="7">
                    目前沒有時間軸事件
                  </td>
                </tr>
                <tr
                  v-for="event in timelineEvents"
                  :key="event.id"
                >
                  <td>
                    <v-chip
                :color="getColorVariant(event.color)"
                      size="small"
                      variant="tonal"
                    >
                      {{ event.year }}
                    </v-chip>
                  </td>
                  <td>
                    <div class="font-weight-medium">
                      {{ event.title }}
                    </div>
                  </td>
                  <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ event.description?.slice(0, 50) }}{{ event.description?.length > 50 ? '...' : '' }}
                    </div>
                  </td>
                  <td class="text-center">
              <v-icon :color="getColorVariant(event.color)">
                {{ event.icon }}
                    </v-icon>
                  </td>
                  <td class="text-center">
              <v-avatar
                v-if="getImageUrl(event)"
                size="40"
                rounded
              >
                <v-img :src="getImageUrl(event)" />
              </v-avatar>
                    <span v-else class="text-medium-emphasis">-</span>
                  </td>
                  <td class="text-center">
                    {{ event.display_order }}
                  </td>
                  <td class="text-center">
                    <v-btn
                      icon
                      size="small"
                      variant="text"
                @click="openEditTimelineForm(event)"
                    >
                      <v-icon icon="mdi-pencil" />
                      <v-tooltip activator="parent">
                        編輯
                      </v-tooltip>
                    </v-btn>
                    <v-btn
                      icon
                      size="small"
                      variant="text"
                      color="error"
                      @click="deleteTimelineEvent(event)"
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

      <!-- Timeline 統計資訊 -->
      <v-card-text v-if="!timelineLoading" class="text-body-2 text-medium-emphasis">
              共 {{ timelineEvents.length }} 筆時間軸事件
          </v-card-text>
    </v-card>

    <!-- 歷史意義區塊 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            歷史意義
              </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理古蹟的歷史意義與文化價值說明
          </p>
        </div>
              <v-btn
                color="primary"
                prepend-icon="mdi-plus"
          @click="openNewSignificanceForm"
              >
                新增項目
              </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 歷史意義錯誤訊息 -->
      <v-alert
            v-if="significanceError"
            class="ma-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="significanceError = null"
          >
        {{ significanceError }}
      </v-alert>

      <!-- 歷史意義載入中 -->
      <div v-if="significanceLoading" class="text-center py-12">
              <v-progress-circular
                color="primary"
                indeterminate
                size="64"
              />
              <p class="mt-4 text-body-1 text-medium-emphasis">
                載入中...
              </p>
            </div>

            <!-- 歷史意義列表 -->
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
                    圖示/顏色
                  </th>
            <th class="text-center">
              圖片
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
                  v-if="historicalSignificance.length === 0"
                  class="text-center"
                >
            <td class="py-8 text-medium-emphasis" colspan="6">
                    目前沒有歷史意義項目
                  </td>
                </tr>
                <tr
                  v-for="item in historicalSignificance"
                  :key="item.id"
                >
                  <td>
                    <div class="font-weight-medium">
                      {{ item.title }}
                    </div>
                  </td>
                  <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ item.description?.slice(0, 80) }}{{ item.description?.length > 80 ? '...' : '' }}
                    </div>
                  </td>
                  <td class="text-center">
              <v-icon :color="getColorVariant(item.color)">
                {{ item.icon }}
                    </v-icon>
                  </td>
            <td class="text-center">
              <v-avatar
                v-if="getImageUrl(item)"
                rounded
                size="40"
              >
                <v-img :src="getImageUrl(item)" />
              </v-avatar>
              <span v-else class="text-medium-emphasis">-</span>
            </td>
                  <td class="text-center">
                    {{ item.display_order }}
                  </td>
                  <td class="text-center">
                    <v-btn
                      icon
                      size="small"
                      variant="text"
                @click="openEditSignificanceForm(item)"
                    >
                      <v-icon icon="mdi-pencil" />
                      <v-tooltip activator="parent">
                        編輯
                      </v-tooltip>
                    </v-btn>
                    <v-btn
                      icon
                      size="small"
                      variant="text"
                      color="error"
                      @click="deleteSignificance(item)"
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

      <!-- 歷史意義統計資訊 -->
      <v-card-text v-if="!significanceLoading" class="text-body-2 text-medium-emphasis">
              共 {{ historicalSignificance.length }} 筆歷史意義項目
          </v-card-text>
    </v-card>

    <!-- Timeline 刪除確認對話框 -->
    <v-dialog
      v-model="showTimelineDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除時間軸事件
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下時間軸事件嗎？
          </p>
          <v-card
            v-if="timelineEventToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ timelineEventToDelete.year }} - {{ timelineEventToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ timelineEventToDelete.description?.slice(0, 100) }}{{ timelineEventToDelete.description?.length > 100 ? '...' : '' }}
            </div>
            <div
              v-if="timelineEventToDelete.storage_path || timelineEventToDelete.image_url"
              class="text-caption text-error mt-2"
            >
              ⚠️ 此事件包含圖片，刪除後將一併移除
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
            @click="showTimelineDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="timelineLoading"
            color="error"
            variant="flat"
            @click="confirmDeleteTimelineEvent"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Timeline 表單對話框 -->
    <v-dialog
      v-model="showTimelineFormDialog"
      max-width="800"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ timelineFormMode === 'new' ? '新增時間軸事件' : '編輯時間軸事件' }}
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="timelineFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="timelineFormError = null"
          >
            {{ timelineFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <!-- 年份 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="timelineForm.year"
                  label="年份 *"
                  variant="outlined"
                  :error-messages="timelineFormErrors.year"
                  required
                  prepend-inner-icon="mdi-calendar"
                  hint="例如：1820"
                  persistent-hint
                />
              </v-col>

              <!-- 顯示順序 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model.number="timelineForm.display_order"
                  label="顯示順序"
                  type="number"
                  variant="outlined"
                  prepend-inner-icon="mdi-sort"
                  hint="數字越小越前面"
                  persistent-hint
                />
              </v-col>

              <!-- 標題 -->
              <v-col cols="12">
                <v-text-field
                  v-model="timelineForm.title"
                  label="標題 *"
                  variant="outlined"
                  :error-messages="timelineFormErrors.title"
                  required
                  prepend-inner-icon="mdi-format-title"
                />
              </v-col>

              <!-- 描述 -->
              <v-col cols="12">
                <v-textarea
                  v-model="timelineForm.description"
                  label="描述 *"
                  variant="outlined"
                  :error-messages="timelineFormErrors.description"
                  required
                  rows="4"
                  prepend-inner-icon="mdi-text"
                  hint="詳細描述此時間軸事件"
                  persistent-hint
                />
              </v-col>

              <!-- 圖示 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="timelineForm.icon"
                  :items="iconOptions"
                  item-title="text"
                  item-value="value"
                  label="圖示 *"
                  variant="outlined"
                  required
                  prepend-inner-icon="mdi-palette"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon>{{ item.raw.value }}</v-icon>
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <div class="d-flex align-center">
                      <v-icon class="mr-2">{{ item.raw.value }}</v-icon>
                      <span>{{ item.raw.text }}</span>
                    </div>
                  </template>
                </v-select>
              </v-col>

              <!-- 顏色 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="timelineForm.color"
                  :items="colorOptions"
                  item-title="text"
                  item-value="value"
                  label="顏色 *"
                  variant="outlined"
                  required
                  prepend-inner-icon="mdi-palette-outline"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :color="item.raw.color">{{ item.raw.value }}</v-icon>
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <div class="d-flex align-center">
                      <v-chip
                        :color="item.raw.color"
                        size="small"
                        class="mr-2"
                      >
                        {{ item.raw.text }}
                      </v-chip>
                    </div>
                  </template>
                </v-select>
              </v-col>

              <!-- 圖片 URL -->
              <v-col cols="12">
                <v-text-field
                  v-model="timelineForm.image_url"
                  label="圖片 URL（選填）"
                  variant="outlined"
                  prepend-inner-icon="mdi-image"
                  hint="外部圖片連結，或留空使用上傳的圖片"
                  persistent-hint
                />
              </v-col>

              <!-- 圖片上傳 -->
              <v-col cols="12">
                <div class="text-body-2 text-medium-emphasis mb-2">
                  上傳圖片（選填）
                </div>
                <v-file-input
                  ref="timelineImageInput"
                  accept="image/*"
                  label="選擇圖片"
                  variant="outlined"
                  prepend-icon="mdi-camera"
                  show-size
                  @update:model-value="handleTimelineImageSelect"
                />
                <div v-if="timelineImagePreview" class="mt-4">
                  <v-img
                    :src="timelineImagePreview"
                    max-height="200"
                    max-width="300"
                    cover
                    class="rounded"
                  />
                  <v-btn
                    class="mt-2"
                    color="error"
                    size="small"
                    variant="text"
                    prepend-icon="mdi-delete"
                    @click="removeTimelineImage"
                  >
                    移除圖片
                  </v-btn>
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
            @click="showTimelineFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="timelineFormLoading"
            color="primary"
            variant="flat"
            @click="submitTimelineForm"
          >
            {{ timelineFormMode === 'new' ? '新增' : '儲存' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 歷史意義刪除確認對話框 -->
    <v-dialog
      v-model="showSignificanceDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除歷史意義項目
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下歷史意義項目嗎？
          </p>
          <v-card
            v-if="significanceToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ significanceToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ significanceToDelete.description?.slice(0, 100) }}{{ significanceToDelete.description?.length > 100 ? '...' : '' }}
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
            @click="showSignificanceDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="significanceLoading"
            color="error"
            variant="flat"
            @click="confirmDeleteSignificance"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 歷史意義表單對話框 -->
    <v-dialog
      v-model="showSignificanceFormDialog"
      max-width="800"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ significanceFormMode === 'new' ? '新增歷史意義項目' : '編輯歷史意義項目' }}
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <!-- 錯誤訊息 -->
          <v-alert
            v-if="significanceFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="significanceFormError = null"
          >
            {{ significanceFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <!-- 標題 -->
              <v-col cols="12">
                <v-text-field
                  v-model="significanceForm.title"
                  :error-messages="significanceFormErrors.title"
                  label="標題 *"
                  prepend-inner-icon="mdi-format-title"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 描述 -->
              <v-col cols="12">
                <v-textarea
                  v-model="significanceForm.description"
                  :error-messages="significanceFormErrors.description"
                  hint="詳細描述此歷史意義項目"
                  label="描述 *"
                  persistent-hint
                  prepend-inner-icon="mdi-text"
                  required
                  rows="4"
                  variant="outlined"
                />
              </v-col>

              <!-- 圖示 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="significanceForm.icon"
                  :items="iconOptions"
                  item-title="text"
                  item-value="value"
                  label="圖示 *"
                  prepend-inner-icon="mdi-palette"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon>{{ item.raw.value }}</v-icon>
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <div class="d-flex align-center">
                      <v-icon class="mr-2">{{ item.raw.value }}</v-icon>
                      <span>{{ item.raw.text }}</span>
                    </div>
                  </template>
                </v-select>
              </v-col>

              <!-- 顏色 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="significanceForm.color"
                  :items="colorOptions"
                  item-title="text"
                  item-value="value"
                  label="顏色 *"
                  prepend-inner-icon="mdi-palette-outline"
                  required
                  variant="outlined"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-icon :color="item.raw.color">{{ item.raw.value }}</v-icon>
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <div class="d-flex align-center">
                      <v-chip
                        :color="item.raw.color"
                        class="mr-2"
                        size="small"
                      >
                        {{ item.raw.text }}
                      </v-chip>
                    </div>
                  </template>
                </v-select>
              </v-col>

              <!-- 顯示順序 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model.number="significanceForm.display_order"
                  hint="數字越小越前面"
                  label="顯示順序"
                  persistent-hint
                  prepend-inner-icon="mdi-sort"
                  type="number"
                  variant="outlined"
                />
              </v-col>

              <!-- 圖片 URL -->
              <v-col cols="12">
                <v-text-field
                  v-model="significanceForm.image_url"
                  hint="外部圖片連結，或留空使用上傳的圖片"
                  label="圖片 URL（選填）"
                  persistent-hint
                  prepend-inner-icon="mdi-image"
                  variant="outlined"
                />
              </v-col>

              <!-- 圖片上傳 -->
              <v-col cols="12">
                <div class="text-body-2 text-medium-emphasis mb-2">
                  上傳圖片（選填）
                </div>
                <v-file-input
                  ref="significanceImageInput"
                  accept="image/*"
                  label="選擇圖片"
                  prepend-icon="mdi-camera"
                  show-size
                  variant="outlined"
                  @update:model-value="handleSignificanceImageSelect"
                />
                <div v-if="significanceImagePreview" class="mt-4">
                  <v-img
                    :src="significanceImagePreview"
                    class="rounded"
                    cover
                    max-height="200"
                    max-width="300"
                  />
                  <v-btn
                    class="mt-2"
                    color="error"
                    prepend-icon="mdi-delete"
                    size="small"
                    variant="text"
                    @click="removeSignificanceImage"
                  >
                    移除圖片
                  </v-btn>
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
            @click="showSignificanceFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="significanceFormLoading"
            color="primary"
            variant="flat"
            @click="submitSignificanceForm"
          >
            {{ significanceFormMode === 'new' ? '新增' : '儲存' }}
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
