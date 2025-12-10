# Database Schema

此目錄包含 Supabase 資料庫的 schema 定義檔案。

## 檔案說明

### announcements_schema.sql
公告資料表的 schema 定義，包含：
- `announcements` 表格結構定義
- `announcement_attachments` 關聯表格（附件）
- 外鍵關聯設定
- 索引建立（提升查詢效能）
- 全文搜尋索引
- Row Level Security (RLS) 政策（兩個表格都有）
- 自動更新時間戳記的觸發器

## 使用方式

### 在 Supabase Dashboard 中執行

1. 登入 Supabase Dashboard
2. 進入 SQL Editor
3. 複製 `announcements_schema.sql` 的內容
4. 貼上並執行

### 使用 Supabase CLI

```bash
# 如果使用 Supabase CLI
supabase db reset
# 或
supabase migration new announcements_schema
# 然後將 SQL 內容放入 migration 檔案
```

## 資料表結構

### announcements

| 欄位名稱 | 類型 | 說明 |
|---------|------|------|
| id | UUID | 主鍵，自動產生 |
| title | TEXT | 公告標題 |
| content | TEXT | 公告簡短內容（摘要） |
| full_content | TEXT | 公告完整內容 |
| date | DATE | 公告日期 |
| author | TEXT | 發布者/部門 |
| category | TEXT | 公告分類 |
| views | INTEGER | 瀏覽次數，預設 0 |
| is_important | BOOLEAN | 是否為重要公告，預設 false |
| icon | TEXT | 圖示名稱（Material Design Icons） |
| color | TEXT | 顏色主題 |
| created_at | TIMESTAMPTZ | 建立時間，自動產生 |
| updated_at | TIMESTAMPTZ | 最後更新時間，自動更新 |

### announcement_attachments

| 欄位名稱 | 類型 | 說明 |
|---------|------|------|
| id | UUID | 主鍵，自動產生 |
| announcement_id | UUID | 關聯的公告 ID（外鍵，參考 announcements.id） |
| file_name | TEXT | 檔案名稱（顯示用） |
| storage_path | TEXT | Supabase Storage 路徑（bucket/檔案路徑） |
| file_url | TEXT | 檔案完整 URL（自動產生或手動設定） |
| file_size | BIGINT | 檔案大小（位元組） |
| file_type | TEXT | 檔案類型（MIME type，如 application/pdf） |
| display_order | INTEGER | 顯示順序（用於排序），預設 0 |
| created_at | TIMESTAMPTZ | 建立時間，自動產生 |
| updated_at | TIMESTAMPTZ | 最後更新時間，自動更新 |

### 關聯說明

- `announcement_attachments.announcement_id` → `announcements.id`
- 使用 `ON DELETE CASCADE`，當公告被刪除時，相關附件也會自動刪除
- 一個公告可以有多個附件（一對多關係）

## 索引

### announcements 表格索引
- `idx_announcements_date`: 依日期降序排列
- `idx_announcements_category`: 依分類查詢
- `idx_announcements_is_important`: 篩選重要公告
- `idx_announcements_created_at`: 依建立時間排序
- `idx_announcements_search`: 全文搜尋索引（標題、內容、完整內容）

### announcement_attachments 表格索引
- `idx_announcement_attachments_announcement_id`: 依公告 ID 查詢附件
- `idx_announcement_attachments_display_order`: 依公告 ID 和顯示順序排序

## Row Level Security (RLS)

### announcements 表格

目前設定為（選項 1）：
- **SELECT (Read)**：所有人都可以讀取公告資料（公開資料）
- **INSERT (Create)**：認證用戶可以新增公告
- **UPDATE (Update)**：認證用戶可以更新公告
- **DELETE (Delete)**：認證用戶可以刪除公告

### announcement_attachments 表格

- **SELECT (Read)**：所有人都可以讀取附件資料（公開資料）
- **INSERT (Create)**：認證用戶可以新增附件
- **UPDATE (Update)**：認證用戶可以更新附件
- **DELETE (Delete)**：認證用戶可以刪除附件

### 其他選項

Schema 檔案中還提供了其他權限設定選項：

**選項 2：只有管理員可 CRUD**
- 公開讀取，但只有管理員可以新增、更新、刪除
- 需要在使用者的 `raw_user_meta_data` 中設定 `role: 'admin'`

**選項 3：使用自訂函數**
- 更靈活的權限控制方案
- 可以建立自訂函數來檢查用戶角色

### 如何切換選項

1. 在 `announcements_schema.sql` 中找到對應的選項區塊
2. 註解掉目前使用的政策（選項 1）
3. 取消註解想要使用的選項（選項 2 或 3）
4. 重新執行 SQL

### 設定管理員角色

如果使用選項 2，需要在 Supabase Dashboard 中設定用戶角色：

```sql
-- 將用戶設為管理員
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE id = 'user-uuid-here';
```

## 查詢範例

### 查詢公告及其附件

```sql
-- 查詢公告並包含所有附件
SELECT 
  a.*,
  json_agg(
    json_build_object(
      'id', att.id,
      'file_name', att.file_name,
      'file_url', att.file_url,
      'file_size', att.file_size,
      'file_type', att.file_type,
      'display_order', att.display_order
    ) ORDER BY att.display_order
  ) FILTER (WHERE att.id IS NOT NULL) as attachments
FROM announcements a
LEFT JOIN announcement_attachments att ON a.id = att.announcement_id
GROUP BY a.id
ORDER BY a.date DESC;
```

### 使用 Supabase Client 查詢

```javascript
// 查詢公告列表（不包含附件）
const { data: announcements } = await supabase
  .from('announcements')
  .select('*')
  .order('date', { ascending: false });

// 查詢單一公告及其附件
const { data: announcement } = await supabase
  .from('announcements')
  .select(`
    *,
    announcement_attachments (
      id,
      file_name,
      file_url,
      file_size,
      file_type,
      display_order
    )
  `)
  .eq('id', announcementId)
  .single();

// 新增公告及附件
const { data: newAnnouncement } = await supabase
  .from('announcements')
  .insert({
    title: '新公告',
    content: '公告內容...',
    // ... 其他欄位
  })
  .select()
  .single();

// 新增附件
await supabase
  .from('announcement_attachments')
  .insert({
    announcement_id: newAnnouncement.id,
    file_name: '檔案.pdf',
    file_url: 'https://storage-url.com/file.pdf',
    file_size: 1024000,
    file_type: 'application/pdf',
    display_order: 1
  });
```

## Supabase Storage 整合

### 設定 Storage

請參考 `storage_setup.md` 檔案，包含：
- 建立 Storage bucket 的步驟
- Storage 政策設定
- 檔案路徑結構建議

### 使用工具函數（推薦）

專案中已提供 `src/lib/storageUtils.js` 工具函數，可以直接使用：

```javascript
import {
  uploadAnnouncementAttachment,
  uploadMultipleAttachments,
  deleteAnnouncementAttachment,
  deleteAllAnnouncementAttachments,
  getAttachmentUrl
} from '@/lib/storageUtils'

// 上傳單一檔案
const attachment = await uploadAnnouncementAttachment(
  announcementId,
  file,
  0 // display_order
)

// 上傳多個檔案
const attachments = await uploadMultipleAttachments(
  announcementId,
  [file1, file2, file3]
)

// 刪除附件
await deleteAnnouncementAttachment(attachmentId, storagePath)

// 刪除公告的所有附件
await deleteAllAnnouncementAttachments(announcementId)

// 取得檔案 URL
const url = getAttachmentUrl(storagePath)
```

### 手動上傳檔案（不使用工具函數）

```javascript
import { supabase } from '@/lib/supabaseClient'

// 上傳檔案到 Supabase Storage
async function uploadAttachment(announcementId, file) {
  // 產生檔案路徑
  const fileExt = file.name.split('.').pop()
  const fileName = `${Date.now()}_${Math.random().toString(36).substring(7)}.${fileExt}`
  const filePath = `announcements/${announcementId}/${fileName}`
  
  // 上傳檔案
  const { data: uploadData, error: uploadError } = await supabase.storage
    .from('announcement-attachments')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false
    })
  
  if (uploadError) {
    throw uploadError
  }
  
  // 取得公開 URL
  const { data: { publicUrl } } = supabase.storage
    .from('announcement-attachments')
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
      display_order: 0
    })
    .select()
    .single()
  
  if (dbError) {
    // 如果資料庫插入失敗，刪除已上傳的檔案
    await supabase.storage
      .from('announcement-attachments')
      .remove([filePath])
    throw dbError
  }
  
  return attachment
}
```

### 查詢附件並取得 URL

```javascript
// 查詢公告及其附件
const { data: announcement } = await supabase
  .from('announcements')
  .select(`
    *,
    announcement_attachments (
      id,
      file_name,
      storage_path,
      file_url,
      file_size,
      file_type,
      display_order
    )
  `)
  .eq('id', announcementId)
  .single()

// file_url 會自動從 storage_path 產生（如果設定了觸發器）
// 或可以手動使用 get_storage_url 函數
```

### 自動產生 URL

Schema 中包含了 `get_storage_url()` 函數和觸發器，會自動從 `storage_path` 產生 `file_url`。

**注意**：需要在函數中設定正確的專案引用（project reference）。

## 注意事項

1. 執行 schema 前請確認 Supabase 專案已建立
2. 如果需要管理功能，請根據實際需求調整 RLS 政策
3. 附件使用關聯表格，支援儲存更多附件資訊（檔案大小、類型、URL 等）
4. 刪除公告時，相關附件會自動刪除（CASCADE）
5. **必須先設定 Supabase Storage**：建立 bucket 和設定政策（參考 `storage_setup.md`）
6. `storage_path` 欄位儲存 Storage 中的路徑，`file_url` 會自動產生或手動設定
7. 建議使用結構化的路徑：`announcements/{announcement_id}/{file_name}`

