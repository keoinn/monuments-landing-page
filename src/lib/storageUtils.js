/**
 * Supabase Storage 工具函數
 * 用於處理公告附件的上傳、下載和刪除
 */

import { supabase } from './supabaseClient'

// Storage bucket 名稱
const BUCKET_NAME = 'wanxuanju-files'

/**
 * 上傳檔案到 Supabase Storage 並儲存附件資訊
 * @param {string} announcementId - 公告 ID
 * @param {File} file - 要上傳的檔案
 * @param {number} displayOrder - 顯示順序（可選）
 * @returns {Promise<Object>} 附件資料
 */
export async function uploadAnnouncementAttachment (announcementId, file, displayOrder = 0) {
  try {
    // 產生唯一檔案名稱（避免檔案名稱衝突）
    const fileExt = file.name.split('.').pop()
    const timestamp = Date.now()
    const randomStr = Math.random().toString(36).substring(2, 9)
    const fileName = `${timestamp}_${randomStr}.${fileExt}`
    
    // 產生檔案路徑：announcements/{announcement_id}/{file_name}
    const filePath = `announcements/${announcementId}/${fileName}`
    
    // 上傳檔案到 Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from(BUCKET_NAME)
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false
      })
    
    if (uploadError) {
      throw new Error(`檔案上傳失敗: ${uploadError.message}`)
    }
    
    // 取得公開 URL
    const { data: { publicUrl } } = supabase.storage
      .from(BUCKET_NAME)
      .getPublicUrl(filePath)
    
    // 儲存附件資訊到資料庫
    const { data: attachment, error: dbError } = await supabase
      .from('announcement_attachments')
      .insert({
        announcement_id: announcementId,
        file_name: file.name,
        storage_path: filePath,
        file_url: publicUrl,
        file_size: file.size,
        file_type: file.type,
        display_order: displayOrder
      })
      .select()
      .single()
    
    if (dbError) {
      // 如果資料庫插入失敗，刪除已上傳的檔案
      await supabase.storage
        .from(BUCKET_NAME)
        .remove([filePath])
      
      throw new Error(`資料庫儲存失敗: ${dbError.message}`)
    }
    
    return attachment
  } catch (error) {
    console.error('上傳附件時發生錯誤:', error)
    throw error
  }
}

/**
 * 上傳多個檔案
 * @param {string} announcementId - 公告 ID
 * @param {File[]} files - 要上傳的檔案陣列
 * @returns {Promise<Object[]>} 附件資料陣列
 */
export async function uploadMultipleAttachments (announcementId, files) {
  const uploadPromises = files.map((file, index) =>
    uploadAnnouncementAttachment(announcementId, file, index)
  )
  
  try {
    const attachments = await Promise.all(uploadPromises)
    return attachments
  } catch (error) {
    console.error('批量上傳附件時發生錯誤:', error)
    throw error
  }
}

/**
 * 刪除附件（從資料庫和 Storage 中刪除）
 * @param {string} attachmentId - 附件 ID
 * @param {string} storagePath - Storage 路徑
 * @returns {Promise<void>}
 */
export async function deleteAnnouncementAttachment (attachmentId, storagePath) {
  try {
    // 先從資料庫刪除（CASCADE 會自動處理，但我們需要先取得 storage_path）
    const { error: dbError } = await supabase
      .from('announcement_attachments')
      .delete()
      .eq('id', attachmentId)
    
    if (dbError) {
      throw new Error(`資料庫刪除失敗: ${dbError.message}`)
    }
    
    // 從 Storage 刪除檔案
    if (storagePath) {
      const { error: storageError } = await supabase.storage
        .from(BUCKET_NAME)
        .remove([storagePath])
      
      if (storageError) {
        console.error('從 Storage 刪除檔案失敗:', storageError)
        // 注意：資料庫記錄已刪除，但檔案可能仍在 Storage 中
        // 可以選擇是否要拋出錯誤或僅記錄
      }
    }
  } catch (error) {
    console.error('刪除附件時發生錯誤:', error)
    throw error
  }
}

/**
 * 刪除公告的所有附件
 * @param {string} announcementId - 公告 ID
 * @returns {Promise<void>}
 */
export async function deleteAllAnnouncementAttachments (announcementId) {
  try {
    // 先取得所有附件的 storage_path
    const { data: attachments, error: fetchError } = await supabase
      .from('announcement_attachments')
      .select('id, storage_path')
      .eq('announcement_id', announcementId)
    
    if (fetchError) {
      throw new Error(`取得附件列表失敗: ${fetchError.message}`)
    }
    
    if (!attachments || attachments.length === 0) {
      return
    }
    
    // 從 Storage 刪除所有檔案
    const storagePaths = attachments.map(att => att.storage_path).filter(Boolean)
    if (storagePaths.length > 0) {
      const { error: storageError } = await supabase.storage
        .from(BUCKET_NAME)
        .remove(storagePaths)
      
      if (storageError) {
        console.error('從 Storage 刪除檔案失敗:', storageError)
      }
    }
    
    // 從資料庫刪除（CASCADE 也會自動處理，但手動刪除可以確保一致性）
    const { error: dbError } = await supabase
      .from('announcement_attachments')
      .delete()
      .eq('announcement_id', announcementId)
    
    if (dbError) {
      throw new Error(`資料庫刪除失敗: ${dbError.message}`)
    }
  } catch (error) {
    console.error('刪除所有附件時發生錯誤:', error)
    throw error
  }
}

/**
 * 下載檔案（取得公開 URL）
 * @param {string} storagePath - Storage 路徑
 * @returns {string} 公開 URL
 */
export function getAttachmentUrl (storagePath) {
  const { data: { publicUrl } } = supabase.storage
    .from(BUCKET_NAME)
    .getPublicUrl(storagePath)
  
  return publicUrl
}

/**
 * 取得簽名 URL（用於私有檔案，如果需要）
 * @param {string} storagePath - Storage 路徑
 * @param {number} expiresIn - 過期時間（秒），預設 3600
 * @returns {Promise<string>} 簽名 URL
 */
export async function getSignedAttachmentUrl (storagePath, expiresIn = 3600) {
  const { data, error } = await supabase.storage
    .from(BUCKET_NAME)
    .createSignedUrl(storagePath, expiresIn)
  
  if (error) {
    throw new Error(`產生簽名 URL 失敗: ${error.message}`)
  }
  
  return data.signedUrl
}



