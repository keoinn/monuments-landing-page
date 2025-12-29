-- ============================================
-- Option Raw Data Schema for Organization Module
-- 組織架構模組選項原始資料插入語句
-- 從 src/pages/admin/organization/index.vue 收集的選項資訊
-- ============================================

-- 插入圖示選項 (iconOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('organization', 'iconOptions', '0', 'mdi-office-building', '辦公室'),
  ('organization', 'iconOptions', '1', 'mdi-account-group', '人員'),
  ('organization', 'iconOptions', '2', 'mdi-tools', '工具'),
  ('organization', 'iconOptions', '3', 'mdi-book-open-variant', '書籍'),
  ('organization', 'iconOptions', '4', 'mdi-palette', '藝術'),
  ('organization', 'iconOptions', '5', 'mdi-shield-star', '保護'),
  ('organization', 'iconOptions', '6', 'mdi-hammer-wrench', '修復'),
  ('organization', 'iconOptions', '7', 'mdi-information', '資訊')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入顏色選項 (colorOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('organization', 'colorOptions', '0', 'primary', '主要'),
  ('organization', 'colorOptions', '1', 'success', '成功'),
  ('organization', 'colorOptions', '2', 'info', '資訊'),
  ('organization', 'colorOptions', '3', 'warning', '警告'),
  ('organization', 'colorOptions', '4', 'error', '錯誤'),
  ('organization', 'colorOptions', '5', 'purple', '紫色')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入職位選項 (positionOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('organization', 'positionOptions', '0', 'chairman', '理事長'),
  ('organization', 'positionOptions', '1', 'viceChairman', '副理事長')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有組織架構圖示選項
-- SELECT * FROM option WHERE module = 'organization' AND cate = 'iconOptions' ORDER BY key;

-- 查詢所有組織架構顏色選項
-- SELECT * FROM option WHERE module = 'organization' AND cate = 'colorOptions' ORDER BY key;

-- 查詢所有組織架構職位選項
-- SELECT * FROM option WHERE module = 'organization' AND cate = 'positionOptions' ORDER BY key;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: iconOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'organization')
--   .eq('cate', 'iconOptions')
--   .order('key');
--
-- const { data: colorOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'organization')
--   .eq('cate', 'colorOptions')
--   .order('key');
--
-- const { data: positionOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'organization')
--   .eq('cate', 'positionOptions')
--   .order('key');



