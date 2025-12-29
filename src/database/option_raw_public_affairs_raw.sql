-- ============================================
-- Option Raw Data Schema for Public Affairs Module
-- 公務資訊模組選項原始資料插入語句
-- 從 src/pages/admin/public-affairs/index.vue 收集的選項資訊
-- ============================================

-- 插入圖示選項 (iconOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('publicAffairs', 'iconOptions', '0', 'mdi-file-document', '文件'),
  ('publicAffairs', 'iconOptions', '1', 'mdi-hammer-wrench', '工具'),
  ('publicAffairs', 'iconOptions', '2', 'mdi-calendar-check', '日曆'),
  ('publicAffairs', 'iconOptions', '3', 'mdi-book-search', '書籍'),
  ('publicAffairs', 'iconOptions', '4', 'mdi-account-group', '人員'),
  ('publicAffairs', 'iconOptions', '5', 'mdi-school', '學校'),
  ('publicAffairs', 'iconOptions', '6', 'mdi-camera', '相機'),
  ('publicAffairs', 'iconOptions', '7', 'mdi-package-variant', '包裹')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入顏色選項 (colorOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('publicAffairs', 'colorOptions', '0', 'primary', '主要'),
  ('publicAffairs', 'colorOptions', '1', 'success', '成功'),
  ('publicAffairs', 'colorOptions', '2', 'info', '資訊'),
  ('publicAffairs', 'colorOptions', '3', 'warning', '警告'),
  ('publicAffairs', 'colorOptions', '4', 'error', '錯誤'),
  ('publicAffairs', 'colorOptions', '5', 'purple', '紫色'),
  ('publicAffairs', 'colorOptions', '6', 'teal', '青色')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入文件類型選項 (documentTypeOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('publicAffairs', 'documentTypeOptions', '0', 'PDF', 'PDF'),
  ('publicAffairs', 'documentTypeOptions', '1', 'DOC', 'DOC'),
  ('publicAffairs', 'documentTypeOptions', '2', 'DOCX', 'DOCX'),
  ('publicAffairs', 'documentTypeOptions', '3', 'XLS', 'XLS'),
  ('publicAffairs', 'documentTypeOptions', '4', 'XLSX', 'XLSX')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有公務資訊圖示選項
-- SELECT * FROM option WHERE module = 'publicAffairs' AND cate = 'iconOptions' ORDER BY key;

-- 查詢所有公務資訊顏色選項
-- SELECT * FROM option WHERE module = 'publicAffairs' AND cate = 'colorOptions' ORDER BY key;

-- 查詢所有公務資訊文件類型選項
-- SELECT * FROM option WHERE module = 'publicAffairs' AND cate = 'documentTypeOptions' ORDER BY key;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: iconOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'publicAffairs')
--   .eq('cate', 'iconOptions')
--   .order('key');
--
-- const { data: colorOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'publicAffairs')
--   .eq('cate', 'colorOptions')
--   .order('key');
--
-- const { data: documentTypeOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'publicAffairs')
--   .eq('cate', 'documentTypeOptions')
--   .order('key');



