-- ============================================
-- Option Raw Data Schema for Directors Module
-- 委員會模組選項原始資料插入語句
-- 從 src/pages/admin/directors/index.vue 收集的選項資訊
-- ============================================

-- 插入圖示選項 (iconOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('directors', 'iconOptions', '0', 'mdi-account-tie', '理事長'),
  ('directors', 'iconOptions', '1', 'mdi-account-group', '群組'),
  ('directors', 'iconOptions', '2', 'mdi-account-multiple', '多人'),
  ('directors', 'iconOptions', '3', 'mdi-calendar', '日曆'),
  ('directors', 'iconOptions', '4', 'mdi-calendar-clock', '時程'),
  ('directors', 'iconOptions', '5', 'mdi-calendar-check', '確認')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入顏色選項 (colorOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('directors', 'colorOptions', '0', 'primary', '主要'),
  ('directors', 'colorOptions', '1', 'success', '成功'),
  ('directors', 'colorOptions', '2', 'info', '資訊'),
  ('directors', 'colorOptions', '3', 'warning', '警告'),
  ('directors', 'colorOptions', '4', 'error', '錯誤')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入角色選項 (roleOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('directors', 'roleOptions', '0', '理事長', '理事長'),
  ('directors', 'roleOptions', '1', '副理事長', '副理事長'),
  ('directors', 'roleOptions', '2', '常務理事', '常務理事'),
  ('directors', 'roleOptions', '3', '理事', '理事')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有委員會圖示選項
-- SELECT * FROM option WHERE module = 'directors' AND cate = 'iconOptions' ORDER BY key;

-- 查詢所有委員會顏色選項
-- SELECT * FROM option WHERE module = 'directors' AND cate = 'colorOptions' ORDER BY key;

-- 查詢所有委員會角色選項
-- SELECT * FROM option WHERE module = 'directors' AND cate = 'roleOptions' ORDER BY key;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: iconOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'directors')
--   .eq('cate', 'iconOptions')
--   .order('key');
--
-- const { data: colorOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'directors')
--   .eq('cate', 'colorOptions')
--   .order('key');
--
-- const { data: roleOptions } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'directors')
--   .eq('cate', 'roleOptions')
--   .order('key');
