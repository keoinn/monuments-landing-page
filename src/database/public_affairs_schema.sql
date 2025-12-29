-- ============================================
-- Form Documents Table Schema for Supabase
-- 表單文件資料表結構
-- ============================================

-- 建立 form_documents 表格
CREATE TABLE IF NOT EXISTS form_documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  date DATE NOT NULL,
  type TEXT NOT NULL, -- PDF, DOC, XLS 等
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  category TEXT,
  url TEXT,
  storage_path TEXT,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_form_documents_display_order ON form_documents(display_order);
CREATE INDEX IF NOT EXISTS idx_form_documents_date ON form_documents(date DESC);
CREATE INDEX IF NOT EXISTS idx_form_documents_category ON form_documents(category);
CREATE INDEX IF NOT EXISTS idx_form_documents_created_at ON form_documents(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_form_documents_updated_at
  BEFORE UPDATE ON form_documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE form_documents IS '表單文件資料表，儲存公務資訊頁面的表單文件下載資訊';
COMMENT ON COLUMN form_documents.id IS '文件唯一識別碼';
COMMENT ON COLUMN form_documents.title IS '文件標題';
COMMENT ON COLUMN form_documents.description IS '文件描述';
COMMENT ON COLUMN form_documents.date IS '文件日期';
COMMENT ON COLUMN form_documents.type IS '文件類型（PDF、DOC、XLS等）';
COMMENT ON COLUMN form_documents.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN form_documents.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN form_documents.category IS '文件分類（申請表單、工程申請、研究申請等）';
COMMENT ON COLUMN form_documents.url IS '文件下載連結（外部 URL 或從 storage_path 生成的公開 URL）';
COMMENT ON COLUMN form_documents.storage_path IS 'Supabase Storage 檔案路徑（如果使用檔案上傳）';
COMMENT ON COLUMN form_documents.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN form_documents.created_at IS '建立時間';
COMMENT ON COLUMN form_documents.updated_at IS '最後更新時間';

-- ============================================
-- Contact Info Table Schema for Supabase
-- 聯絡資訊資料表結構
-- ============================================

-- 建立 contact_info 表格
CREATE TABLE IF NOT EXISTS contact_info (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  value TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  action TEXT NOT NULL, -- URL、tel:、mailto: 等
  button_text TEXT NOT NULL,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_contact_info_display_order ON contact_info(display_order);
CREATE INDEX IF NOT EXISTS idx_contact_info_created_at ON contact_info(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_contact_info_updated_at
  BEFORE UPDATE ON contact_info
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE contact_info IS '聯絡資訊資料表，儲存公務資訊頁面的聯絡方式';
COMMENT ON COLUMN contact_info.id IS '聯絡資訊唯一識別碼';
COMMENT ON COLUMN contact_info.title IS '聯絡方式標題';
COMMENT ON COLUMN contact_info.description IS '聯絡方式描述';
COMMENT ON COLUMN contact_info.value IS '聯絡方式的值（電話號碼、電子郵件、地址等）';
COMMENT ON COLUMN contact_info.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN contact_info.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN contact_info.action IS '動作連結（URL、tel:、mailto:等）';
COMMENT ON COLUMN contact_info.button_text IS '按鈕文字';
COMMENT ON COLUMN contact_info.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN contact_info.created_at IS '建立時間';
COMMENT ON COLUMN contact_info.updated_at IS '最後更新時間';

-- ============================================
-- Row Level Security (RLS) Policies
-- 行級安全策略
-- ============================================

-- 啟用 RLS
ALTER TABLE form_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_info ENABLE ROW LEVEL SECURITY;

-- form_documents 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "form_documents_select_public"
  ON form_documents
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "form_documents_insert_authenticated"
  ON form_documents
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "form_documents_update_authenticated"
  ON form_documents
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "form_documents_delete_authenticated"
  ON form_documents
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- contact_info 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "contact_info_select_public"
  ON contact_info
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "contact_info_insert_authenticated"
  ON contact_info
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "contact_info_update_authenticated"
  ON contact_info
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "contact_info_delete_authenticated"
  ON contact_info
  FOR DELETE
  USING (auth.role() = 'authenticated');



