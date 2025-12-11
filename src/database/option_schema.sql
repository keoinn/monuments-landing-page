-- ============================================
-- Option Table Schema for Supabase
-- 選項資料表結構
-- ============================================

-- 建立 option 表格
CREATE TABLE IF NOT EXISTS option (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  module TEXT NOT NULL,
  cate TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT,
  label TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  -- 確保同一模組、分類下的鍵是唯一的
  UNIQUE(module, cate, key)
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_option_module ON option(module);
CREATE INDEX IF NOT EXISTS idx_option_cate ON option(cate);
CREATE INDEX IF NOT EXISTS idx_option_key ON option(key);
CREATE INDEX IF NOT EXISTS idx_option_module_cate ON option(module, cate);
CREATE INDEX IF NOT EXISTS idx_option_module_cate_key ON option(module, cate, key);
CREATE INDEX IF NOT EXISTS idx_option_created_at ON option(created_at DESC);

-- 建立更新時間的自動更新函數（如果尚未存在）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_option_updated_at
  BEFORE UPDATE ON option
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE option IS '選項資料表，儲存系統配置選項（鍵值對）';
COMMENT ON COLUMN option.id IS '選項唯一識別碼';
COMMENT ON COLUMN option.module IS '選項模組（例如：site、admin、api 等）';
COMMENT ON COLUMN option.cate IS '選項分類（例如：general、email、notification 等）';
COMMENT ON COLUMN option.key IS '選項鍵名（在同一模組和分類下必須唯一）';
COMMENT ON COLUMN option.value IS '選項值（可以是任何文字內容）';
COMMENT ON COLUMN option.label IS '選項標籤（用於顯示的友好名稱）';
COMMENT ON COLUMN option.created_at IS '建立時間，自動產生';
COMMENT ON COLUMN option.updated_at IS '最後更新時間，自動更新';

-- ============================================
-- Row Level Security (RLS) 政策
-- ============================================

-- 啟用 RLS
ALTER TABLE option ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 選項 1: 公開讀取，認證用戶可 CRUD
-- ============================================

-- SELECT (Read): 允許所有人讀取選項（公開資料）
CREATE POLICY "Allow public read access to option"
  ON option
  FOR SELECT
  USING (true);

-- INSERT (Create): 允許認證用戶新增選項
CREATE POLICY "Allow authenticated users to insert option"
  ON option
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- UPDATE (Update): 允許認證用戶更新選項
CREATE POLICY "Allow authenticated users to update option"
  ON option
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- DELETE (Delete): 允許認證用戶刪除選項
CREATE POLICY "Allow authenticated users to delete option"
  ON option
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- ============================================
-- 選項 2: 公開讀取，只有管理員可 CRUD（註解狀態，可替換選項 1）
-- ============================================

-- 如果只需要管理員可以 CRUD，請取消註解以下政策，並註解上面的認證用戶政策

-- DROP POLICY IF EXISTS "Allow authenticated users to insert option" ON option;
-- DROP POLICY IF EXISTS "Allow authenticated users to update option" ON option;
-- DROP POLICY IF EXISTS "Allow authenticated users to delete option" ON option;

-- CREATE POLICY "Allow admin to insert option"
--   ON option
--   FOR INSERT
--   WITH CHECK (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- CREATE POLICY "Allow admin to update option"
--   ON option
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

-- CREATE POLICY "Allow admin to delete option"
--   ON option
--   FOR DELETE
--   USING (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE auth.users.id = auth.uid()
--       AND auth.users.raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- ============================================
-- 範例資料插入（可選）
-- ============================================

-- 插入範例選項資料（如果需要）
-- INSERT INTO option (module, cate, key, value, label) VALUES
--   ('site', 'general', 'title', '青錢萬選 - 萬選居', '網站標題'),
--   ('site', 'general', 'description', '古蹟管理處官方網站', '網站描述'),
--   ('site', 'contact', 'email', 'contact@example.com', '聯絡信箱'),
--   ('site', 'contact', 'phone', '02-1234-5678', '聯絡電話'),
--   ('admin', 'email', 'smtp_host', 'smtp.example.com', 'SMTP 主機'),
--   ('admin', 'email', 'smtp_port', '587', 'SMTP 埠號'),
--   ('admin', 'email', 'smtp_user', 'noreply@example.com', 'SMTP 用戶名'),
--   ('admin', 'notification', 'enable_email', 'true', '啟用郵件通知'),
--   ('admin', 'notification', 'enable_sms', 'false', '啟用簡訊通知'),
--   ('system', 'general', 'maintenance_mode', 'false', '維護模式'),
--   ('system', 'upload', 'max_size', '10485760', '最大上傳大小') -- 10MB in bytes
-- ON CONFLICT (module, cate, key) DO NOTHING;

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢特定模組的所有選項
-- SELECT * FROM option WHERE module = 'site' ORDER BY cate, key;

-- 查詢特定模組和分類的所有選項
-- SELECT * FROM option WHERE module = 'site' AND cate = 'general' ORDER BY key;

-- 查詢特定選項
-- SELECT value FROM option WHERE module = 'site' AND cate = 'general' AND key = 'title';

-- 更新選項值
-- UPDATE option SET value = '新值' WHERE module = 'site' AND cate = 'general' AND key = 'title';

-- 使用 Supabase Client 查詢範例
-- 查詢特定模組的所有選項
-- const { data } = await supabase
--   .from('option')
--   .select('*')
--   .eq('module', 'site');

-- 查詢特定模組和分類的所有選項
-- const { data } = await supabase
--   .from('option')
--   .select('*')
--   .eq('module', 'site')
--   .eq('cate', 'general');

-- 查詢單一選項
-- const { data } = await supabase
--   .from('option')
--   .select('value')
--   .eq('module', 'site')
--   .eq('cate', 'general')
--   .eq('key', 'title')
--   .single();

-- 更新選項
-- await supabase
--   .from('option')
--   .update({ value: '新值' })
--   .eq('module', 'site')
--   .eq('cate', 'general')
--   .eq('key', 'title');

-- 新增選項
-- await supabase
--   .from('option')
--   .insert({ module: 'site', cate: 'general', key: 'new_key', value: 'new_value', label: '新選項標籤' });
