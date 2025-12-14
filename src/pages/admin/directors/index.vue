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

  // 理事會成員相關
  const boardMembers = ref([])
  const membersLoading = ref(false)
  const membersError = ref(null)
  const showMemberDeleteDialog = ref(false)
  const memberToDelete = ref(null)

  // 理事會成員表單對話框
  const showMemberFormDialog = ref(false)
  const memberFormMode = ref('new') // 'new' 或 'edit'
  const memberFormLoading = ref(false)
  const memberFormError = ref(null)
  const memberForm = ref({
    id: null,
    name: '',
    title: '',
    role: '',
    photo_url: '',
    storage_path: '',
    description: '',
    education: '',
    expertise: [],
    experience: [],
    email: '',
    linkedin: '',
    display_order: 0,
  })
  const memberFormErrors = ref({})
  const memberPhotoFile = ref(null)
  const memberPhotoPreview = ref(null)
  const memberPhotoInput = ref(null)
  const memberExpertiseInput = ref('')
  const memberExperienceInput = ref('')

  // 理事會結構相關
  const boardStructure = ref([])
  const structureLoading = ref(false)
  const structureError = ref(null)
  const showStructureDeleteDialog = ref(false)
  const structureToDelete = ref(null)

  // 理事會結構表單對話框
  const showStructureFormDialog = ref(false)
  const structureFormMode = ref('new')
  const structureFormLoading = ref(false)
  const structureFormError = ref(null)
  const structureForm = ref({
    id: null,
    title: '',
    description: '',
    icon: 'mdi-account-group',
    color: 'primary',
    count: 0,
    unit: '人',
    display_order: 0,
  })
  const structureFormErrors = ref({})

  // 會議行程相關
  const meetingSchedule = ref([])
  const scheduleLoading = ref(false)
  const scheduleError = ref(null)
  const showScheduleDeleteDialog = ref(false)
  const scheduleToDelete = ref(null)

  // 會議行程表單對話框
  const showScheduleFormDialog = ref(false)
  const scheduleFormMode = ref('new')
  const scheduleFormLoading = ref(false)
  const scheduleFormError = ref(null)
  const scheduleForm = ref({
    id: null,
    date: new Date().toISOString().split('T')[0],
    title: '',
    description: '',
    time: '',
    location: '',
    icon: 'mdi-calendar',
    color: 'primary',
    display_order: 0,
  })
  const scheduleFormErrors = ref({})

  // 圖示選項（從 Supabase 載入）
  const iconOptions = ref([])

  // 顏色選項（從 Supabase 載入）
  const colorOptions = ref([])

  // 角色選項（從 Supabase 載入）
  const roleOptions = ref([])

  // Storage bucket 名稱
  const BUCKET_NAME = 'wanxuanju-files'

  // 從 Supabase 載入理事會成員
  async function loadBoardMembers () {
    membersLoading.value = true
    membersError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('board_members')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      boardMembers.value = data || []
    } catch (error_) {
      console.error('載入理事會成員失敗:', error_)
      membersError.value = error_.message || '載入理事會成員時發生錯誤'
    } finally {
      membersLoading.value = false
    }
  }

  // 從 Supabase 載入理事會結構
  async function loadBoardStructure () {
    structureLoading.value = true
    structureError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('board_structure')
        .select('*')
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      boardStructure.value = data || []
    } catch (error_) {
      console.error('載入理事會結構失敗:', error_)
      structureError.value = error_.message || '載入理事會結構時發生錯誤'
    } finally {
      structureLoading.value = false
    }
  }

  // 從 Supabase 載入會議行程
  async function loadMeetingSchedule () {
    scheduleLoading.value = true
    scheduleError.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('meeting_schedule')
        .select('*')
        .order('date', { ascending: false })
        .order('display_order', { ascending: true })

      if (fetchError) throw fetchError

      meetingSchedule.value = data || []
    } catch (error_) {
      console.error('載入會議行程失敗:', error_)
      scheduleError.value = error_.message || '載入會議行程時發生錯誤'
    } finally {
      scheduleLoading.value = false
    }
  }

  // 刪除理事會成員
  async function deleteMember (member) {
    memberToDelete.value = member
    showMemberDeleteDialog.value = true
  }

  async function confirmDeleteMember () {
    if (!memberToDelete.value) return

    try {
      membersLoading.value = true
      membersError.value = null

      // 如果有照片在 Storage 中，刪除照片
      if (memberToDelete.value.storage_path) {
        const { error: storageError } = await supabase.storage
          .from(BUCKET_NAME)
          .remove([memberToDelete.value.storage_path])

        if (storageError) {
          console.error('刪除照片檔案失敗:', storageError)
        }
      }

      // 刪除記錄
      const { error: deleteError } = await supabase
        .from('board_members')
        .delete()
        .eq('id', memberToDelete.value.id)

      if (deleteError) throw deleteError

      // 重新載入列表
      await loadBoardMembers()
      showMemberDeleteDialog.value = false
      memberToDelete.value = null
    } catch (error_) {
      console.error('刪除理事會成員失敗:', error_)
      membersError.value = error_.message || '刪除理事會成員時發生錯誤'
    } finally {
      membersLoading.value = false
    }
  }

  // 刪除理事會結構
  async function deleteStructure (item) {
    structureToDelete.value = item
    showStructureDeleteDialog.value = true
  }

  async function confirmDeleteStructure () {
    if (!structureToDelete.value) return

    try {
      structureLoading.value = true
      structureError.value = null

      const { error: deleteError } = await supabase
        .from('board_structure')
        .delete()
        .eq('id', structureToDelete.value.id)

      if (deleteError) throw deleteError

      await loadBoardStructure()
      showStructureDeleteDialog.value = false
      structureToDelete.value = null
    } catch (error_) {
      console.error('刪除理事會結構失敗:', error_)
      structureError.value = error_.message || '刪除理事會結構時發生錯誤'
    } finally {
      structureLoading.value = false
    }
  }

  // 刪除會議行程
  async function deleteSchedule (item) {
    scheduleToDelete.value = item
    showScheduleDeleteDialog.value = true
  }

  async function confirmDeleteSchedule () {
    if (!scheduleToDelete.value) return

    try {
      scheduleLoading.value = true
      scheduleError.value = null

      const { error: deleteError } = await supabase
        .from('meeting_schedule')
        .delete()
        .eq('id', scheduleToDelete.value.id)

      if (deleteError) throw deleteError

      await loadMeetingSchedule()
      showScheduleDeleteDialog.value = false
      scheduleToDelete.value = null
    } catch (error_) {
      console.error('刪除會議行程失敗:', error_)
      scheduleError.value = error_.message || '刪除會議行程時發生錯誤'
    } finally {
      scheduleLoading.value = false
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
    if (item.photo_url) {
      return item.photo_url
    }
    if (item.storage_path) {
      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(item.storage_path)
      return publicUrl
    }
    return null
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

  // ============================================
  // 理事會成員表單相關函數
  // ============================================

  // 打開新增成員表單
  function openNewMemberForm () {
    memberFormMode.value = 'new'
    memberForm.value = {
      id: null,
      name: '',
      title: '',
      role: '',
      photo_url: '',
      storage_path: '',
      description: '',
      education: '',
      expertise: [],
      experience: [],
      email: '',
      linkedin: '',
      display_order: boardMembers.value.length > 0
        ? Math.max(...boardMembers.value.map(m => m.display_order || 0)) + 1
        : 0,
    }
    memberPhotoFile.value = null
    memberPhotoPreview.value = null
    memberExpertiseInput.value = ''
    memberExperienceInput.value = ''
    memberFormErrors.value = {}
    memberFormError.value = null
    showMemberFormDialog.value = true
  }

  // 打開編輯成員表單
  function openEditMemberForm (member) {
    memberFormMode.value = 'edit'
    memberForm.value = {
      id: member.id,
      name: member.name || '',
      title: member.title || '',
      role: member.role || '',
      photo_url: member.photo_url || '',
      storage_path: member.storage_path || '',
      description: member.description || '',
      education: member.education || '',
      expertise: member.expertise || [],
      experience: member.experience || [],
      email: member.email || '',
      linkedin: member.linkedin || '',
      display_order: member.display_order || 0,
    }
    memberPhotoFile.value = null
    memberPhotoPreview.value = getImageUrl(member)
    memberExpertiseInput.value = member.expertise?.join(', ') || ''
    memberExperienceInput.value = member.experience?.join('\n') || ''
    memberFormErrors.value = {}
    memberFormError.value = null
    showMemberFormDialog.value = true
  }

  // 處理照片選擇
  function handleMemberPhotoSelect (file) {
    if (!file) {
      memberPhotoFile.value = null
      memberPhotoPreview.value = null
      return
    }

    const maxSize = 5 * 1024 * 1024
    if (file.size > maxSize) {
      memberFormError.value = '圖片檔案大小不能超過 5MB'
      memberPhotoFile.value = null
      memberPhotoPreview.value = null
      return
    }

    if (!file.type.startsWith('image/')) {
      memberFormError.value = '請選擇圖片檔案'
      memberPhotoFile.value = null
      memberPhotoPreview.value = null
      return
    }

    memberPhotoFile.value = file
    memberFormError.value = null

    const reader = new FileReader()
    reader.addEventListener('load', e => {
      memberPhotoPreview.value = e.target.result
    })
    reader.readAsDataURL(file)
  }

  // 移除照片
  function removeMemberPhoto () {
    memberPhotoFile.value = null
    memberPhotoPreview.value = null
    memberForm.value.photo_url = ''
    memberForm.value.storage_path = ''
    if (memberPhotoInput.value) {
      memberPhotoInput.value.value = ''
    }
  }

  // 添加專長
  function addExpertise () {
    if (memberExpertiseInput.value.trim()) {
      const items = memberExpertiseInput.value.split(',').map(item => item.trim()).filter(Boolean)
      memberForm.value.expertise = [...new Set([...memberForm.value.expertise, ...items])]
      memberExpertiseInput.value = ''
    }
  }

  // 移除專長
  function removeExpertise (index) {
    memberForm.value.expertise.splice(index, 1)
  }

  // 添加經歷
  function addExperience () {
    if (memberExperienceInput.value.trim()) {
      const items = memberExperienceInput.value.split('\n').map(item => item.trim()).filter(Boolean)
      memberForm.value.experience = [...new Set([...memberForm.value.experience, ...items])]
      memberExperienceInput.value = ''
    }
  }

  // 移除經歷
  function removeExperience (index) {
    memberForm.value.experience.splice(index, 1)
  }

  // 驗證成員表單
  function validateMemberForm () {
    memberFormErrors.value = {}

    if (!memberForm.value.name?.trim()) {
      memberFormErrors.value.name = '請輸入姓名'
    }

    if (!memberForm.value.title?.trim()) {
      memberFormErrors.value.title = '請輸入職稱'
    }

    if (!memberForm.value.role?.trim()) {
      memberFormErrors.value.role = '請選擇角色'
    }

    if (!memberForm.value.description?.trim()) {
      memberFormErrors.value.description = '請輸入描述'
    }

    return Object.keys(memberFormErrors.value).length === 0
  }

  // 上傳成員照片
  async function uploadMemberPhoto (memberId) {
    if (!memberPhotoFile.value) return null

    try {
      const fileExt = memberPhotoFile.value.name.split('.').pop()
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).slice(2, 9)
      const fileName = `${timestamp}_${randomStr}.${fileExt}`
      const filePath = `directors-members/${memberId}/${fileName}`

      const { error: uploadError } = await supabase.storage
        .from(BUCKET_NAME)
        .upload(filePath, memberPhotoFile.value, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        throw new Error(`圖片上傳失敗: ${uploadError.message || '未知錯誤'}`)
      }

      const { data: { publicUrl } } = supabase.storage
        .from(BUCKET_NAME)
        .getPublicUrl(filePath)

      return {
        storage_path: filePath,
        photo_url: publicUrl,
      }
    } catch (error_) {
      console.error('上傳照片失敗:', error_)
      throw error_
    }
  }

  // 提交成員表單
  async function submitMemberForm () {
    if (!validateMemberForm()) {
      memberFormError.value = '請填寫所有必填欄位'
      return
    }

    memberFormLoading.value = true
    memberFormError.value = null

    try {
      const formData = {
        name: memberForm.value.name.trim(),
        title: memberForm.value.title.trim(),
        role: memberForm.value.role.trim(),
        description: memberForm.value.description.trim(),
        education: memberForm.value.education?.trim() || null,
        expertise: memberForm.value.expertise || [],
        experience: memberForm.value.experience || [],
        email: memberForm.value.email?.trim() || null,
        linkedin: memberForm.value.linkedin?.trim() || null,
        display_order: memberForm.value.display_order || 0,
      }

      if (memberFormMode.value === 'new') {
        const { data: newMember, error: insertError } = await supabase
          .from('board_members')
          .insert(formData)
          .select()
          .single()

        if (insertError) throw insertError

        if (memberPhotoFile.value) {
          try {
            const photoData = await uploadMemberPhoto(newMember.id)
            if (photoData) {
              const { error: updateError } = await supabase
                .from('board_members')
                .update({
                  storage_path: photoData.storage_path,
                  photo_url: photoData.photo_url,
                })
                .eq('id', newMember.id)

              if (updateError) {
                await supabase.storage
                  .from(BUCKET_NAME)
                  .remove([photoData.storage_path])
                throw updateError
              }
            }
          } catch (uploadError) {
            await supabase
              .from('board_members')
              .delete()
              .eq('id', newMember.id)
            throw new Error(`上傳照片失敗: ${uploadError.message || '未知錯誤'}`)
          }
        } else if (memberForm.value.photo_url) {
          const { error: updateError } = await supabase
            .from('board_members')
            .update({
              photo_url: memberForm.value.photo_url,
            })
            .eq('id', newMember.id)

          if (updateError) throw updateError
        }
      } else {
        let photoData = null

        if (memberPhotoFile.value) {
          photoData = await uploadMemberPhoto(memberForm.value.id)
        }

        if (photoData) {
          formData.storage_path = photoData.storage_path
          formData.photo_url = photoData.photo_url

          if (memberForm.value.storage_path) {
            await supabase.storage
              .from(BUCKET_NAME)
              .remove([memberForm.value.storage_path])
          }
        } else if (memberForm.value.photo_url && !memberPhotoFile.value) {
          formData.photo_url = memberForm.value.photo_url
          formData.storage_path = memberForm.value.storage_path
        }

        const { error: updateError } = await supabase
          .from('board_members')
          .update(formData)
          .eq('id', memberForm.value.id)

        if (updateError) throw updateError
      }

      await loadBoardMembers()
      showMemberFormDialog.value = false
    } catch (error_) {
      console.error('儲存理事會成員失敗:', error_)
      memberFormError.value = error_.message || '儲存理事會成員時發生錯誤'
    } finally {
      memberFormLoading.value = false
    }
  }

  // ============================================
  // 理事會結構表單相關函數
  // ============================================

  // 打開新增結構表單
  function openNewStructureForm () {
    structureFormMode.value = 'new'
    structureForm.value = {
      id: null,
      title: '',
      description: '',
      icon: 'mdi-account-group',
      color: 'primary',
      count: 0,
      unit: '人',
      display_order: boardStructure.value.length > 0
        ? Math.max(...boardStructure.value.map(s => s.display_order || 0)) + 1
        : 0,
    }
    structureFormErrors.value = {}
    structureFormError.value = null
    showStructureFormDialog.value = true
  }

  // 打開編輯結構表單
  function openEditStructureForm (item) {
    structureFormMode.value = 'edit'
    structureForm.value = {
      id: item.id,
      title: item.title || '',
      description: item.description || '',
      icon: item.icon || 'mdi-account-group',
      color: item.color || 'primary',
      count: item.count || 0,
      unit: item.unit || '人',
      display_order: item.display_order || 0,
    }
    structureFormErrors.value = {}
    structureFormError.value = null
    showStructureFormDialog.value = true
  }

  // 驗證結構表單
  function validateStructureForm () {
    structureFormErrors.value = {}

    if (!structureForm.value.title?.trim()) {
      structureFormErrors.value.title = '請輸入職稱'
    }

    if (!structureForm.value.description?.trim()) {
      structureFormErrors.value.description = '請輸入描述'
    }

    return Object.keys(structureFormErrors.value).length === 0
  }

  // 提交結構表單
  async function submitStructureForm () {
    if (!validateStructureForm()) {
      structureFormError.value = '請填寫所有必填欄位'
      return
    }

    structureFormLoading.value = true
    structureFormError.value = null

    try {
      const formData = {
        title: structureForm.value.title.trim(),
        description: structureForm.value.description.trim(),
        icon: structureForm.value.icon,
        color: structureForm.value.color,
        count: structureForm.value.count || 0,
        unit: structureForm.value.unit || '人',
        display_order: structureForm.value.display_order || 0,
      }

      if (structureFormMode.value === 'new') {
        const { error: insertError } = await supabase
          .from('board_structure')
          .insert(formData)

        if (insertError) throw insertError
      } else {
        const { error: updateError } = await supabase
          .from('board_structure')
          .update(formData)
          .eq('id', structureForm.value.id)

        if (updateError) throw updateError
      }

      await loadBoardStructure()
      showStructureFormDialog.value = false
    } catch (error_) {
      console.error('儲存理事會結構失敗:', error_)
      structureFormError.value = error_.message || '儲存理事會結構時發生錯誤'
    } finally {
      structureFormLoading.value = false
    }
  }

  // ============================================
  // 會議行程表單相關函數
  // ============================================

  // 打開新增行程表單
  function openNewScheduleForm () {
    scheduleFormMode.value = 'new'
    scheduleForm.value = {
      id: null,
      date: new Date().toISOString().split('T')[0],
      title: '',
      description: '',
      time: '',
      location: '',
      icon: 'mdi-calendar',
      color: 'primary',
      display_order: meetingSchedule.value.length > 0
        ? Math.max(...meetingSchedule.value.map(s => s.display_order || 0)) + 1
        : 0,
    }
    scheduleFormErrors.value = {}
    scheduleFormError.value = null
    showScheduleFormDialog.value = true
  }

  // 打開編輯行程表單
  function openEditScheduleForm (item) {
    scheduleFormMode.value = 'edit'
    scheduleForm.value = {
      id: item.id,
      date: item.date ? item.date.split('T')[0] : new Date().toISOString().split('T')[0],
      title: item.title || '',
      description: item.description || '',
      time: item.time || '',
      location: item.location || '',
      icon: item.icon || 'mdi-calendar',
      color: item.color || 'primary',
      display_order: item.display_order || 0,
    }
    scheduleFormErrors.value = {}
    scheduleFormError.value = null
    showScheduleFormDialog.value = true
  }

  // 驗證行程表單
  function validateScheduleForm () {
    scheduleFormErrors.value = {}

    if (!scheduleForm.value.date) {
      scheduleFormErrors.value.date = '請選擇日期'
    }

    if (!scheduleForm.value.title?.trim()) {
      scheduleFormErrors.value.title = '請輸入標題'
    }

    if (!scheduleForm.value.description?.trim()) {
      scheduleFormErrors.value.description = '請輸入描述'
    }

    return Object.keys(scheduleFormErrors.value).length === 0
  }

  // 提交行程表單
  async function submitScheduleForm () {
    if (!validateScheduleForm()) {
      scheduleFormError.value = '請填寫所有必填欄位'
      return
    }

    scheduleFormLoading.value = true
    scheduleFormError.value = null

    try {
      const formData = {
        date: scheduleForm.value.date,
        title: scheduleForm.value.title.trim(),
        description: scheduleForm.value.description.trim(),
        time: scheduleForm.value.time?.trim() || null,
        location: scheduleForm.value.location?.trim() || null,
        icon: scheduleForm.value.icon,
        color: scheduleForm.value.color,
        display_order: scheduleForm.value.display_order || 0,
      }

      if (scheduleFormMode.value === 'new') {
        const { error: insertError } = await supabase
          .from('meeting_schedule')
          .insert(formData)

        if (insertError) throw insertError
      } else {
        const { error: updateError } = await supabase
          .from('meeting_schedule')
          .update(formData)
          .eq('id', scheduleForm.value.id)

        if (updateError) throw updateError
      }

      await loadMeetingSchedule()
      showScheduleFormDialog.value = false
    } catch (error_) {
      console.error('儲存會議行程失敗:', error_)
      scheduleFormError.value = error_.message || '儲存會議行程時發生錯誤'
    } finally {
      scheduleFormLoading.value = false
    }
  }

  // 從 Supabase 載入選項資料
  async function loadOptions () {
    try {
      // 載入圖示選項
      const { data: iconData, error: iconError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'directors')
        .eq('cate', 'iconOptions')
        .order('key')

      if (!iconError && iconData) {
        iconOptions.value = iconData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
      }

      // 載入顏色選項
      const { data: colorData, error: colorError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'directors')
        .eq('cate', 'colorOptions')
        .order('key')

      if (!colorError && colorData) {
        colorOptions.value = colorData.map(item => {
          const value = item.value || item.label
          return {
            value,
            text: item.label || value,
            color: value,
          }
        })
      }

      // 載入角色選項
      const { data: roleData, error: roleError } = await supabase
        .from('option')
        .select('value, label')
        .eq('module', 'directors')
        .eq('cate', 'roleOptions')
        .order('key')

      if (!roleError && roleData) {
        roleOptions.value = roleData.map(item => ({
          value: item.value || item.label,
          text: item.label || item.value,
        }))
      }
    } catch (error_) {
      console.error('載入選項資料失敗:', error_)
      // 如果載入失敗，使用預設值
      if (iconOptions.value.length === 0) {
        iconOptions.value = [
          { value: 'mdi-account-tie', text: '理事長' },
          { value: 'mdi-account-group', text: '群組' },
          { value: 'mdi-account-multiple', text: '多人' },
          { value: 'mdi-calendar', text: '日曆' },
          { value: 'mdi-calendar-clock', text: '時程' },
          { value: 'mdi-calendar-check', text: '確認' },
        ]
      }
      if (colorOptions.value.length === 0) {
        colorOptions.value = [
          { value: 'primary', text: '主要', color: 'primary' },
          { value: 'success', text: '成功', color: 'success' },
          { value: 'info', text: '資訊', color: 'info' },
          { value: 'warning', text: '警告', color: 'warning' },
          { value: 'error', text: '錯誤', color: 'error' },
        ]
      }
      if (roleOptions.value.length === 0) {
        roleOptions.value = [
          { value: '理事長', text: '理事長' },
          { value: '副理事長', text: '副理事長' },
          { value: '常務理事', text: '常務理事' },
          { value: '理事', text: '理事' },
        ]
      }
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
      loadOptions(),
      loadBoardMembers(),
      loadBoardStructure(),
      loadMeetingSchedule(),
    ])
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-h4 font-weight-bold mb-2">
        委員會管理
      </h1>
      <p class="text-body-2 text-medium-emphasis">
        管理理事會成員、組織結構與會議行程
      </p>
    </div>

    <!-- 理事會成員區塊 -->
    <v-card class="mb-8" elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            理事會成員
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理理事會成員資訊
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewMemberForm"
        >
          新增成員
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="membersError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="membersError = null"
      >
        {{ membersError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="membersLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 成員列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              照片
            </th>
            <th class="text-left">
              姓名
            </th>
            <th class="text-left">
              職稱
            </th>
            <th class="text-left">
              角色
            </th>
            <th class="text-left">
              學歷
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
            v-if="boardMembers.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="7">
              目前沒有理事會成員
            </td>
          </tr>
          <tr
            v-for="member in boardMembers"
            :key="member.id"
          >
            <td>
              <v-avatar
                v-if="getImageUrl(member)"
                rounded
                size="50"
              >
                <v-img :src="getImageUrl(member)" />
              </v-avatar>
              <v-avatar
                v-else
                rounded
                size="50"
              >
                <v-icon>mdi-account</v-icon>
              </v-avatar>
            </td>
            <td>
              <div class="font-weight-medium">
                {{ member.name }}
              </div>
            </td>
            <td>
              <v-chip
                :color="getColorVariant('primary')"
                size="small"
                variant="tonal"
              >
                {{ member.title }}
              </v-chip>
            </td>
            <td>
              {{ member.role }}
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ member.education?.slice(0, 30) }}{{ member.education?.length > 30 ? '...' : '' }}
              </div>
            </td>
            <td class="text-center">
              {{ member.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditMemberForm(member)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
              <v-btn
                icon
                size="small"
                color="error"
                variant="text"
                @click="deleteMember(member)"
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
      <v-card-text v-if="!membersLoading" class="text-body-2 text-medium-emphasis">
        共 {{ boardMembers.length }} 位理事會成員
      </v-card-text>
    </v-card>

    <!-- 理事會結構區塊 -->
    <v-card class="mb-8" elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            理事會結構
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理理事會組織架構
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewStructureForm"
        >
          新增結構
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="structureError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="structureError = null"
      >
        {{ structureError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="structureLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 結構列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              職稱
            </th>
            <th class="text-left">
              描述
            </th>
            <th class="text-center">
              圖示/顏色
            </th>
            <th class="text-center">
              人數
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
            v-if="boardStructure.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="6">
              目前沒有理事會結構資料
            </td>
          </tr>
          <tr
            v-for="item in boardStructure"
            :key="item.id"
          >
            <td>
              <div class="font-weight-medium">
                {{ item.title }}
              </div>
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ item.description?.slice(0, 50) }}{{ item.description?.length > 50 ? '...' : '' }}
              </div>
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(item.color)">
                {{ item.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              {{ item.count }} {{ item.unit }}
            </td>
            <td class="text-center">
              {{ item.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditStructureForm(item)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
              <v-btn
                icon
                size="small"
                color="error"
                variant="text"
                @click="deleteStructure(item)"
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
      <v-card-text v-if="!structureLoading" class="text-body-2 text-medium-emphasis">
        共 {{ boardStructure.length }} 筆理事會結構資料
      </v-card-text>
    </v-card>

    <!-- 會議行程區塊 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <h2 class="text-h5 font-weight-bold">
            會議行程
          </h2>
          <p class="text-body-2 text-medium-emphasis mt-1">
            管理理事會會議行程
          </p>
        </div>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openNewScheduleForm"
        >
          新增行程
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- 錯誤訊息 -->
      <v-alert
        v-if="scheduleError"
        class="ma-4"
        closable
        color="error"
        type="error"
        variant="tonal"
        @click:close="scheduleError = null"
      >
        {{ scheduleError }}
      </v-alert>

      <!-- 載入中 -->
      <div v-if="scheduleLoading" class="text-center py-12">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        />
        <p class="mt-4 text-body-1 text-medium-emphasis">
          載入中...
        </p>
      </div>

      <!-- 行程列表 -->
      <v-table v-else>
        <thead>
          <tr>
            <th class="text-left">
              日期
            </th>
            <th class="text-left">
              標題
            </th>
            <th class="text-left">
              描述
            </th>
            <th class="text-left">
              時間/地點
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
            v-if="meetingSchedule.length === 0"
            class="text-center"
          >
            <td class="py-8 text-medium-emphasis" colspan="7">
              目前沒有會議行程
            </td>
          </tr>
          <tr
            v-for="item in meetingSchedule"
            :key="item.id"
          >
            <td>
              {{ formatDate(item.date) }}
            </td>
            <td>
              <div class="font-weight-medium">
                {{ item.title }}
              </div>
            </td>
            <td>
              <div class="text-body-2 text-medium-emphasis">
                {{ item.description?.slice(0, 50) }}{{ item.description?.length > 50 ? '...' : '' }}
              </div>
            </td>
            <td>
              <div class="text-body-2">
                {{ item.time }}
              </div>
              <div class="text-caption text-medium-emphasis">
                {{ item.location }}
              </div>
            </td>
            <td class="text-center">
              <v-icon :color="getColorVariant(item.color)">
                {{ item.icon }}
              </v-icon>
            </td>
            <td class="text-center">
              {{ item.display_order }}
            </td>
            <td class="text-center">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openEditScheduleForm(item)"
              >
                <v-icon icon="mdi-pencil" />
                <v-tooltip activator="parent">
                  編輯
                </v-tooltip>
              </v-btn>
              <v-btn
                icon
                size="small"
                color="error"
                variant="text"
                @click="deleteSchedule(item)"
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
      <v-card-text v-if="!scheduleLoading" class="text-body-2 text-medium-emphasis">
        共 {{ meetingSchedule.length }} 筆會議行程
      </v-card-text>
    </v-card>

    <!-- 理事會成員刪除確認對話框 -->
    <v-dialog
      v-model="showMemberDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除理事會成員
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下理事會成員嗎？
          </p>
          <v-card
            v-if="memberToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ memberToDelete.name }} - {{ memberToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ memberToDelete.description?.slice(0, 100) }}{{ memberToDelete.description?.length > 100 ? '...' : '' }}
            </div>
            <div
              v-if="memberToDelete.storage_path || memberToDelete.photo_url"
              class="text-caption text-error mt-2"
            >
              ⚠️ 此成員包含照片，刪除後將一併移除
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
            @click="showMemberDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="membersLoading"
            variant="flat"
            color="error"
            @click="confirmDeleteMember"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 理事會結構刪除確認對話框 -->
    <v-dialog
      v-model="showStructureDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除理事會結構
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下理事會結構項目嗎？
          </p>
          <v-card
            v-if="structureToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ structureToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ structureToDelete.description?.slice(0, 100) }}{{ structureToDelete.description?.length > 100 ? '...' : '' }}
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
            @click="showStructureDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="structureLoading"
            variant="flat"
            color="error"
            @click="confirmDeleteStructure"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 會議行程刪除確認對話框 -->
    <v-dialog
      v-model="showScheduleDeleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="text-h6">
          確認刪除會議行程
        </v-card-title>
        <v-card-text>
          <p class="mb-2">
            您確定要刪除以下會議行程嗎？
          </p>
          <v-card
            v-if="scheduleToDelete"
            class="pa-4"
            color="surface-variant"
            variant="tonal"
          >
            <div class="font-weight-bold mb-2">
              {{ formatDate(scheduleToDelete.date) }} - {{ scheduleToDelete.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ scheduleToDelete.description?.slice(0, 100) }}{{ scheduleToDelete.description?.length > 100 ? '...' : '' }}
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
            @click="showScheduleDeleteDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="scheduleLoading"
            variant="flat"
            color="error"
            @click="confirmDeleteSchedule"
          >
            確認刪除
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 理事會成員表單對話框 -->
    <v-dialog
      v-model="showMemberFormDialog"
      max-width="900"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ memberFormMode === 'new' ? '新增理事會成員' : '編輯理事會成員' }}
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <v-alert
            v-if="memberFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="memberFormError = null"
          >
            {{ memberFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <!-- 姓名 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="memberForm.name"
                  :error-messages="memberFormErrors.name"
                  label="姓名 *"
                  prepend-inner-icon="mdi-account"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 職稱 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="memberForm.title"
                  :error-messages="memberFormErrors.title"
                  label="職稱 *"
                  prepend-inner-icon="mdi-badge-account"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 角色 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="memberForm.role"
                  :error-messages="memberFormErrors.role"
                  :items="roleOptions"
                  item-title="text"
                  item-value="value"
                  label="角色 *"
                  prepend-inner-icon="mdi-account-tie"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 顯示順序 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model.number="memberForm.display_order"
                  hint="數字越小越前面"
                  label="顯示順序"
                  persistent-hint
                  prepend-inner-icon="mdi-sort"
                  type="number"
                  variant="outlined"
                />
              </v-col>

              <!-- 描述 -->
              <v-col cols="12">
                <v-textarea
                  v-model="memberForm.description"
                  :error-messages="memberFormErrors.description"
                  hint="個人簡介"
                  label="描述 *"
                  persistent-hint
                  prepend-inner-icon="mdi-text"
                  required
                  rows="3"
                  variant="outlined"
                />
              </v-col>

              <!-- 學歷 -->
              <v-col cols="12">
                <v-text-field
                  v-model="memberForm.education"
                  label="學歷"
                  prepend-inner-icon="mdi-school"
                  variant="outlined"
                />
              </v-col>

              <!-- 專長 -->
              <v-col cols="12">
                <div class="text-body-2 text-medium-emphasis mb-2">
                  專長
                </div>
                <div class="d-flex gap-2 mb-2">
                  <v-text-field
                    v-model="memberExpertiseInput"
                    density="compact"
                    hint="輸入後按 Enter 或點擊新增按鈕，可用逗號分隔多個"
                    label="輸入專長"
                    persistent-hint
                    variant="outlined"
                    @keyup.enter="addExpertise"
                  />
                  <v-btn
                    color="primary"
                    @click="addExpertise"
                  >
                    新增
                  </v-btn>
                </div>
                <div v-if="memberForm.expertise.length > 0" class="d-flex flex-wrap gap-2">
                  <v-chip
                    v-for="(item, index) in memberForm.expertise"
                    :key="index"
                    closable
                    @click:close="removeExpertise(index)"
                  >
                    {{ item }}
                  </v-chip>
                </div>
              </v-col>

              <!-- 經歷 -->
              <v-col cols="12">
                <div class="text-body-2 text-medium-emphasis mb-2">
                  經歷
                </div>
                <v-textarea
                  v-model="memberExperienceInput"
                  hint="每行一個經歷，輸入後點擊新增按鈕"
                  label="輸入經歷"
                  persistent-hint
                  rows="3"
                  variant="outlined"
                />
                <v-btn
                  class="mt-2"
                  color="primary"
                  @click="addExperience"
                >
                  新增經歷
                </v-btn>
                <div v-if="memberForm.experience.length > 0" class="mt-4">
                  <v-list>
                    <v-list-item
                      v-for="(item, index) in memberForm.experience"
                      :key="index"
                    >
                      <template #prepend>
                        <v-icon>mdi-check-circle</v-icon>
                      </template>
                      <v-list-item-title>{{ item }}</v-list-item-title>
                      <template #append>
                        <v-btn
                          icon
                          size="small"
                          variant="text"
                          @click="removeExperience(index)"
                        >
                          <v-icon>mdi-delete</v-icon>
                        </v-btn>
                      </template>
                    </v-list-item>
                  </v-list>
                </div>
              </v-col>

              <!-- 電子郵件 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="memberForm.email"
                  label="電子郵件"
                  prepend-inner-icon="mdi-email"
                  type="email"
                  variant="outlined"
                />
              </v-col>

              <!-- LinkedIn -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="memberForm.linkedin"
                  label="LinkedIn 連結"
                  prepend-inner-icon="mdi-linkedin"
                  variant="outlined"
                />
              </v-col>

              <!-- 照片 URL -->
              <v-col cols="12">
                <v-text-field
                  v-model="memberForm.photo_url"
                  hint="外部圖片連結，或留空使用上傳的照片"
                  label="照片 URL（選填）"
                  persistent-hint
                  prepend-inner-icon="mdi-image"
                  variant="outlined"
                />
              </v-col>

              <!-- 照片上傳 -->
              <v-col cols="12">
                <div class="text-body-2 text-medium-emphasis mb-2">
                  上傳照片（選填）
                </div>
                <v-file-input
                  ref="memberPhotoInput"
                  accept="image/*"
                  label="選擇照片"
                  prepend-icon="mdi-camera"
                  show-size
                  variant="outlined"
                  @update:model-value="handleMemberPhotoSelect"
                />
                <div v-if="memberPhotoPreview" class="mt-4">
                  <v-img
                    :src="memberPhotoPreview"
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
                    @click="removeMemberPhoto"
                  >
                    移除照片
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
            @click="showMemberFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="memberFormLoading"
            color="primary"
            variant="flat"
            @click="submitMemberForm"
          >
            {{ memberFormMode === 'new' ? '新增' : '儲存' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 理事會結構表單對話框 -->
    <v-dialog
      v-model="showStructureFormDialog"
      max-width="700"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ structureFormMode === 'new' ? '新增理事會結構' : '編輯理事會結構' }}
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <v-alert
            v-if="structureFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="structureFormError = null"
          >
            {{ structureFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <!-- 職稱 -->
              <v-col cols="12">
                <v-text-field
                  v-model="structureForm.title"
                  :error-messages="structureFormErrors.title"
                  label="職稱 *"
                  prepend-inner-icon="mdi-badge-account"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 描述 -->
              <v-col cols="12">
                <v-textarea
                  v-model="structureForm.description"
                  :error-messages="structureFormErrors.description"
                  hint="描述此職位的職責"
                  label="描述 *"
                  persistent-hint
                  prepend-inner-icon="mdi-text"
                  required
                  rows="3"
                  variant="outlined"
                />
              </v-col>

              <!-- 圖示 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="structureForm.icon"
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
                  v-model="structureForm.color"
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

              <!-- 人數 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model.number="structureForm.count"
                  label="人數"
                  prepend-inner-icon="mdi-account-multiple"
                  type="number"
                  variant="outlined"
                />
              </v-col>

              <!-- 單位 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="structureForm.unit"
                  label="單位"
                  prepend-inner-icon="mdi-format-text"
                  variant="outlined"
                />
              </v-col>

              <!-- 顯示順序 -->
              <v-col cols="12">
                <v-text-field
                  v-model.number="structureForm.display_order"
                  hint="數字越小越前面"
                  label="顯示順序"
                  persistent-hint
                  prepend-inner-icon="mdi-sort"
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
            @click="showStructureFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="structureFormLoading"
            color="primary"
            variant="flat"
            @click="submitStructureForm"
          >
            {{ structureFormMode === 'new' ? '新增' : '儲存' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 會議行程表單對話框 -->
    <v-dialog
      v-model="showScheduleFormDialog"
      max-width="700"
      scrollable
    >
      <v-card>
        <v-card-title class="text-h6">
          {{ scheduleFormMode === 'new' ? '新增會議行程' : '編輯會議行程' }}
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <v-alert
            v-if="scheduleFormError"
            class="mb-4"
            closable
            color="error"
            type="error"
            variant="tonal"
            @click:close="scheduleFormError = null"
          >
            {{ scheduleFormError }}
          </v-alert>

          <v-form>
            <v-row>
              <!-- 日期 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="scheduleForm.date"
                  :error-messages="scheduleFormErrors.date"
                  label="日期 *"
                  prepend-inner-icon="mdi-calendar"
                  required
                  type="date"
                  variant="outlined"
                />
              </v-col>

              <!-- 顯示順序 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model.number="scheduleForm.display_order"
                  hint="數字越小越前面"
                  label="顯示順序"
                  persistent-hint
                  prepend-inner-icon="mdi-sort"
                  type="number"
                  variant="outlined"
                />
              </v-col>

              <!-- 標題 -->
              <v-col cols="12">
                <v-text-field
                  v-model="scheduleForm.title"
                  :error-messages="scheduleFormErrors.title"
                  label="標題 *"
                  prepend-inner-icon="mdi-format-title"
                  required
                  variant="outlined"
                />
              </v-col>

              <!-- 描述 -->
              <v-col cols="12">
                <v-textarea
                  v-model="scheduleForm.description"
                  :error-messages="scheduleFormErrors.description"
                  hint="會議內容描述"
                  label="描述 *"
                  persistent-hint
                  prepend-inner-icon="mdi-text"
                  required
                  rows="3"
                  variant="outlined"
                />
              </v-col>

              <!-- 時間 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="scheduleForm.time"
                  hint="例如：14:00-16:00"
                  label="時間"
                  persistent-hint
                  prepend-inner-icon="mdi-clock"
                  variant="outlined"
                />
              </v-col>

              <!-- 地點 -->
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="scheduleForm.location"
                  label="地點"
                  prepend-inner-icon="mdi-map-marker"
                  variant="outlined"
                />
              </v-col>

              <!-- 圖示 -->
              <v-col cols="12" md="6">
                <v-select
                  v-model="scheduleForm.icon"
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
                  v-model="scheduleForm.color"
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
            </v-row>
          </v-form>
        </v-card-text>

        <v-divider />

        <v-card-actions>
          <v-spacer />
          <v-btn
            variant="text"
            @click="showScheduleFormDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            :loading="scheduleFormLoading"
            color="primary"
            variant="flat"
            @click="submitScheduleForm"
          >
            {{ scheduleFormMode === 'new' ? '新增' : '儲存' }}
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
