-- ============================================
-- Announcements Table Schema for Supabase
-- 公告資料表結構
-- ============================================

-- 建立 announcements 表格
CREATE TABLE IF NOT EXISTS announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  full_content TEXT NOT NULL,
  date DATE NOT NULL,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  status TEXT DEFAULT '進行中' NOT NULL,
  views INTEGER DEFAULT 0 NOT NULL,
  is_important BOOLEAN DEFAULT false NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_announcements_date ON announcements(date DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_category ON announcements(category);
CREATE INDEX IF NOT EXISTS idx_announcements_status ON announcements(status);
CREATE INDEX IF NOT EXISTS idx_announcements_is_important ON announcements(is_important);
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON announcements(created_at DESC);

-- 建立更新時間的自動更新函數
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 建立全文搜尋索引（用於標題和內容搜尋）
CREATE INDEX IF NOT EXISTS idx_announcements_search ON announcements USING gin(
  to_tsvector('simple', title || ' ' || content || ' ' || full_content)
);

-- 新增註解說明
COMMENT ON TABLE announcements IS '公告資料表，儲存古蹟管理處的公告資訊';
COMMENT ON COLUMN announcements.id IS '公告唯一識別碼';
COMMENT ON COLUMN announcements.title IS '公告標題';
COMMENT ON COLUMN announcements.content IS '公告簡短內容（摘要）';
COMMENT ON COLUMN announcements.full_content IS '公告完整內容';
COMMENT ON COLUMN announcements.date IS '公告日期';
COMMENT ON COLUMN announcements.author IS '發布者/部門';
COMMENT ON COLUMN announcements.category IS '公告分類（工程公告、活動訊息、服務異動、法規更新、人事異動等）';
COMMENT ON COLUMN announcements.status IS '公告狀態（進行中、已結束等）';
COMMENT ON COLUMN announcements.views IS '瀏覽次數';
COMMENT ON COLUMN announcements.is_important IS '是否為重要公告';
COMMENT ON COLUMN announcements.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN announcements.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN announcements.created_at IS '建立時間';
COMMENT ON COLUMN announcements.updated_at IS '最後更新時間';

-- ============================================
-- Announcement Attachments Table Schema
-- 公告附件資料表結構
-- ============================================

-- 建立 announcement_attachments 表格
CREATE TABLE IF NOT EXISTS announcement_attachments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  file_url TEXT,
  file_size BIGINT,
  file_type TEXT,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_announcement_attachments_announcement_id 
  ON announcement_attachments(announcement_id);
CREATE INDEX IF NOT EXISTS idx_announcement_attachments_display_order 
  ON announcement_attachments(announcement_id, display_order);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_announcement_attachments_updated_at
  BEFORE UPDATE ON announcement_attachments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE announcement_attachments IS '公告附件資料表，儲存公告的附件檔案資訊';
COMMENT ON COLUMN announcement_attachments.id IS '附件唯一識別碼';
COMMENT ON COLUMN announcement_attachments.announcement_id IS '關聯的公告 ID（外鍵）';
COMMENT ON COLUMN announcement_attachments.file_name IS '檔案名稱（顯示用）';
COMMENT ON COLUMN announcement_attachments.storage_path IS 'Supabase Storage 路徑（bucket/檔案路徑）';
COMMENT ON COLUMN announcement_attachments.file_url IS '檔案完整 URL（自動產生或手動設定）';
COMMENT ON COLUMN announcement_attachments.file_size IS '檔案大小（位元組）';
COMMENT ON COLUMN announcement_attachments.file_type IS '檔案類型（MIME type，如 application/pdf）';
COMMENT ON COLUMN announcement_attachments.display_order IS '顯示順序（用於排序）';
COMMENT ON COLUMN announcement_attachments.created_at IS '建立時間';
COMMENT ON COLUMN announcement_attachments.updated_at IS '最後更新時間';

-- ============================================
-- Row Level Security (RLS) 政策
-- ============================================

-- 啟用 RLS
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 選項 1: 公開讀取，認證用戶可 CRUD
-- ============================================

-- SELECT (Read): 允許所有人讀取公告（公開資料）
CREATE POLICY "Allow public read access to announcements"
  ON announcements
  FOR SELECT
  USING (true);

-- INSERT (Create): 允許認證用戶新增公告
CREATE POLICY "Allow authenticated users to insert announcements"
  ON announcements
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- UPDATE (Update): 允許認證用戶更新公告
CREATE POLICY "Allow authenticated users to update announcements"
  ON announcements
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- DELETE (Delete): 允許認證用戶刪除公告
CREATE POLICY "Allow authenticated users to delete announcements"
  ON announcements
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- ============================================
-- Announcement Attachments RLS 政策
-- ============================================

-- 啟用 RLS
ALTER TABLE announcement_attachments ENABLE ROW LEVEL SECURITY;

-- SELECT (Read): 允許所有人讀取附件（公開資料）
CREATE POLICY "Allow public read access to announcement_attachments"
  ON announcement_attachments
  FOR SELECT
  USING (true);

-- INSERT (Create): 允許認證用戶新增附件
CREATE POLICY "Allow authenticated users to insert announcement_attachments"
  ON announcement_attachments
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- UPDATE (Update): 允許認證用戶更新附件
CREATE POLICY "Allow authenticated users to update announcement_attachments"
  ON announcement_attachments
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- DELETE (Delete): 允許認證用戶刪除附件
CREATE POLICY "Allow authenticated users to delete announcement_attachments"
  ON announcement_attachments
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- ============================================
-- 選項 2: 公開讀取，只有管理員可 CRUD（註解狀態，可替換選項 1）
-- ============================================

-- 如果只需要管理員可以 CRUD，請取消註解以下政策，並註解上面的認證用戶政策

-- DROP POLICY IF EXISTS "Allow authenticated users to insert announcements" ON announcements;
-- DROP POLICY IF EXISTS "Allow authenticated users to update announcements" ON announcements;
-- DROP POLICY IF EXISTS "Allow authenticated users to delete announcements" ON announcements;

-- CREATE POLICY "Allow admin to insert announcements"
--   ON announcements
--   FOR INSERT
--   WITH CHECK (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- CREATE POLICY "Allow admin to update announcements"
--   ON announcements
--   FOR UPDATE
--   USING (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   )
--   WITH CHECK (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- CREATE POLICY "Allow admin to delete announcements"
--   ON announcements
--   FOR DELETE
--   USING (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- ============================================
-- 選項 3: 使用自訂函數檢查角色（更靈活的方案）
-- ============================================

-- 建立檢查用戶角色的函數（可選，用於更複雜的權限控制）
-- CREATE OR REPLACE FUNCTION is_admin()
-- RETURNS BOOLEAN AS $$
-- BEGIN
--   RETURN EXISTS (
--     SELECT 1 FROM auth.users
--     WHERE auth.users.id = auth.uid()
--     AND auth.users.raw_user_meta_data->>'role' = 'admin'
--   );
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- 使用函數的政策範例：
-- CREATE POLICY "Allow admin to insert announcements"
--   ON announcements
--   FOR INSERT
--   WITH CHECK (is_admin());

-- ============================================
-- 範例資料插入（可選）
-- ============================================

-- 插入範例公告資料（如果需要）
-- INSERT INTO announcements (
--   title,
--   content,
--   full_content,
--   date,
--   author,
--   category,
--   status,
--   views,
--   is_important,
--   icon,
--   color
-- ) VALUES (
--   '古蹟維護工程期間參觀注意事項',
--   '因進行古蹟維護工程，部分區域將暫時關閉，請參觀民眾注意安全...',
--   '因進行古蹟維護工程，部分區域將暫時關閉。工程期間，請參觀民眾注意以下事項：\n\n1. 請遵循現場工作人員指示，勿進入施工區域\n2. 參觀時請保持安靜，避免影響工程進行\n3. 建議提前預約參觀時間，避免現場等候\n4. 如有任何疑問，請洽詢服務台工作人員\n\n工程預計於2024年3月底完成，感謝您的配合與諒解。',
--   '2024-01-20',
--   '維護部',
--   '工程公告',
--   '進行中',
--   156,
--   true,
--   'mdi-hammer-wrench',
--   'warning'
-- ) RETURNING id;

-- 插入範例附件資料（假設上面的 INSERT 返回的 id 為 'announcement-uuid'）
-- INSERT INTO announcement_attachments (
--   announcement_id,
--   file_name,
--   file_url,
--   file_size,
--   file_type,
--   display_order
-- ) VALUES
--   (
--     'announcement-uuid',
--     '工程公告.pdf',
--     'https://your-storage-url.com/attachments/工程公告.pdf',
--     1024000,
--     'application/pdf',
--     1
--   ),
--   (
--     'announcement-uuid',
--     '參觀須知.docx',
--     'announcements/announcement-uuid/參觀須知.docx',
--     'https://your-project-ref.supabase.co/storage/v1/object/public/announcement-attachments/announcements/announcement-uuid/參觀須知.docx',
--     512000,
--     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
--     2
--   );

-- ============================================
-- Supabase Storage 設定
-- ============================================

-- 注意：Storage bucket 需要在 Supabase Dashboard 中手動建立
-- 或使用 Supabase Management API

-- 建立 Storage bucket（如果使用 Supabase Management API）
-- 建議在 Supabase Dashboard > Storage 中手動建立：
-- 1. 進入 Storage 頁面
-- 2. 點擊 "New bucket"
-- 3. Bucket 名稱：wanxuanju-files
-- 4. Public bucket：勾選（公開讀取）
-- 5. File size limit：根據需求設定（例如 10MB）
-- 6. Allowed MIME types：根據需求設定（例如 application/pdf, application/msword, ...）

-- ============================================
-- Storage 政策設定（在 Supabase Dashboard 中設定）
-- ============================================

-- 在 Supabase Dashboard > Storage > Policies 中設定以下政策：

-- 1. 公開讀取政策（Public Read）
-- Policy name: Public read access
-- Allowed operation: SELECT
-- Policy definition:
--   (bucket_id = 'wanxuanju-files'::text)

-- 2. 認證用戶上傳政策（Authenticated Upload）
-- Policy name: Authenticated users can upload
-- Allowed operation: INSERT
-- Policy definition:
--   (bucket_id = 'wanxuanju-files'::text)
--   AND
--   (auth.role() = 'authenticated'::text)

-- 3. 認證用戶更新政策（Authenticated Update）
-- Policy name: Authenticated users can update
-- Allowed operation: UPDATE
-- Policy definition:
--   (bucket_id = 'wanxuanju-files'::text)
--   AND
--   (auth.role() = 'authenticated'::text)

-- 4. 認證用戶刪除政策（Authenticated Delete）
-- Policy name: Authenticated users can delete
-- Allowed operation: DELETE
-- Policy definition:
--   (bucket_id = 'wanxuanju-files'::text)
--   AND
--   (auth.role() = 'authenticated'::text)

-- ============================================
-- 產生 Storage URL 的函數（可選）
-- ============================================

-- 建立函數，自動產生 Supabase Storage 的公開 URL
-- 注意：請將 'tlcuvnvdfupuxgbbmtib' 替換為您的實際 Supabase 專案引用
-- 專案引用可以從 Supabase Dashboard > Settings > API > Project URL 中取得
CREATE OR REPLACE FUNCTION get_storage_url(storage_path TEXT)
RETURNS TEXT AS $$
DECLARE
  project_ref TEXT := 'tlcuvnvdfupuxgbbmtib'; -- 從 URL 中提取的專案引用
  bucket_name TEXT := 'wanxuanju-files'; -- Storage bucket 名稱
BEGIN
  RETURN format(
    'https://%s.supabase.co/storage/v1/object/public/%s/%s',
    project_ref,
    bucket_name,
    storage_path
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 建立觸發器，自動產生 file_url（可選）
-- 當 storage_path 更新時，自動更新 file_url
CREATE OR REPLACE FUNCTION update_file_url_from_storage_path()
RETURNS TRIGGER AS $$
BEGIN
  -- 如果 file_url 為空或 storage_path 有變更，自動產生 URL
  IF NEW.file_url IS NULL OR NEW.file_url = '' OR NEW.storage_path != OLD.storage_path THEN
    NEW.file_url := get_storage_url(NEW.storage_path);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 建立觸發器
CREATE TRIGGER update_attachment_file_url
  BEFORE INSERT OR UPDATE OF storage_path ON announcement_attachments
  FOR EACH ROW
  EXECUTE FUNCTION update_file_url_from_storage_path();

-- 註解說明
COMMENT ON FUNCTION get_storage_url IS '產生 Supabase Storage 的公開 URL';
COMMENT ON FUNCTION update_file_url_from_storage_path IS '自動從 storage_path 產生 file_url';

-- ============================================
-- Migration: 為現有表格添加 status 欄位（如果表格已存在）
-- ============================================

-- 如果表格已經存在但沒有 status 欄位，執行以下 SQL 來添加
-- ALTER TABLE announcements 
-- ADD COLUMN IF NOT EXISTS status TEXT DEFAULT '進行中' NOT NULL;

-- 為現有記錄設定預設狀態（如果需要）
-- UPDATE announcements 
-- SET status = '進行中' 
-- WHERE status IS NULL OR status = '';

-- 建立索引（如果尚未存在）
-- CREATE INDEX IF NOT EXISTS idx_announcements_status ON announcements(status);

-- 添加註解
-- COMMENT ON COLUMN announcements.status IS '公告狀態（進行中、已結束等）';

