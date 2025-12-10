# Supabase Storage 設定指南

本指南說明如何設定 Supabase Storage 來儲存公告附件檔案。

## 步驟 1: 建立 Storage Bucket

### 在 Supabase Dashboard 中建立

1. 登入 Supabase Dashboard
2. 進入 **Storage** 頁面
3. 點擊 **New bucket**
4. 設定以下資訊：
   - **Bucket name**: `wanxuanju-files`（或您選擇的名稱）
   - **Public bucket**: ✅ 勾選（允許公開讀取）
   - **File size limit**: 根據需求設定（建議 10MB 或更大）
   - **Allowed MIME types**: 根據需求設定，例如：
     - `application/pdf`
     - `application/msword`
     - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
     - `application/vnd.ms-excel`
     - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
     - `image/*`（如果需要圖片）
5. 點擊 **Create bucket**

## 步驟 2: 設定 Storage 政策

在 Supabase Dashboard > Storage > Policies 中設定以下政策：

### 1. 公開讀取政策

- **Policy name**: `Public read access`
- **Allowed operation**: `SELECT`
- **Policy definition**:
```sql
(bucket_id = 'wanxuanju-files'::text)
```

### 2. 認證用戶上傳政策

- **Policy name**: `Authenticated users can upload`
- **Allowed operation**: `INSERT`
- **Policy definition**:
```sql
(bucket_id = 'wanxuanju-files'::text)
AND
(auth.role() = 'authenticated'::text)
```

### 3. 認證用戶更新政策

- **Policy name**: `Authenticated users can update`
- **Allowed operation**: `UPDATE`
- **Policy definition**:
```sql
(bucket_id = 'wanxuanju-files'::text)
AND
(auth.role() = 'authenticated'::text)
```

### 4. 認證用戶刪除政策

- **Policy name**: `Authenticated users can delete`
- **Allowed operation**: `DELETE`
- **Policy definition**:
```sql
(bucket_id = 'wanxuanju-files'::text)
AND
(auth.role() = 'authenticated'::text)
```

## 步驟 3: 設定專案引用（用於自動產生 URL）

在 Supabase Dashboard > Settings > API 中，找到 **Project URL**，從 URL 中提取專案引用（project reference）。

例如：如果 Project URL 是 `https://tlcuvnvdfupuxgbbmtib.supabase.co`，則專案引用是 `tlcuvnvdfupuxgbbmtib`。

**注意**：專案引用已經在 `announcements_schema.sql` 的 `get_storage_url()` 函數中設定。如果需要修改，請直接編輯該函數中的 `project_ref` 變數。

```sql
-- 在 get_storage_url() 函數中修改
DECLARE
  project_ref TEXT := 'your-project-ref'; -- 替換為您的專案引用
  bucket_name TEXT := 'wanxuanju-files';
```

或直接在 `get_storage_url` 函數中替換 `'your-project-ref'` 為實際的專案引用。

## 檔案路徑結構建議

建議使用以下路徑結構來組織檔案：

```
wanxuanju-files/
  └── announcements/
      └── {announcement_id}/
          └── {timestamp}_{random}.{ext}
```

例如：
- `announcements/550e8400-e29b-41d4-a716-446655440000/1704067200_abc123.pdf`
- `announcements/550e8400-e29b-41d4-a716-446655440000/1704067201_def456.docx`

**注意**：檔案名稱使用時間戳記和隨機字串，避免檔案名稱衝突。

這樣的結構有助於：
- 組織檔案
- 清理時可以一次刪除整個公告的所有附件
- 避免檔案名稱衝突

