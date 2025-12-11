-- ============================================
-- Option Raw Data Schema for Supabase
-- 選項原始資料插入語句
-- 從 announcements 相關文件收集的選項資訊
-- ============================================

-- 插入公告分類選項 (categories)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('announcements', 'categories', '0', '工程公告', '工程公告'),
  ('announcements', 'categories', '1', '活動訊息', '活動訊息'),
  ('announcements', 'categories', '2', '服務異動', '服務異動'),
  ('announcements', 'categories', '3', '法規更新', '法規更新'),
  ('announcements', 'categories', '4', '人事異動', '人事異動')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入圖示選項 (iconOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('announcements', 'iconOptions', '0', 'mdi-bullhorn', 'bullhorn'),
  ('announcements', 'iconOptions', '1', 'mdi-hammer-wrench', 'hammer-wrench'),
  ('announcements', 'iconOptions', '2', 'mdi-calendar-star', 'calendar-star'),
  ('announcements', 'iconOptions', '3', 'mdi-information', 'information'),
  ('announcements', 'iconOptions', '4', 'mdi-book-open-variant', 'book-open-variant'),
  ('announcements', 'iconOptions', '5', 'mdi-account-group', 'account-group'),
  ('announcements', 'iconOptions', '6', 'mdi-alert', 'alert'),
  ('announcements', 'iconOptions', '7', 'mdi-check-circle', 'check-circle')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入顏色選項 (colorOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('announcements', 'colorOptions', '0', 'primary', 'Primary'),
  ('announcements', 'colorOptions', '1', 'success', 'Success'),
  ('announcements', 'colorOptions', '2', 'info', 'Info'),
  ('announcements', 'colorOptions', '3', 'warning', 'Warning'),
  ('announcements', 'colorOptions', '4', 'error', 'Error')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- 插入狀態選項 (statusOptions)
INSERT INTO option (module, cate, key, value, label) VALUES
  ('announcements', 'statusOptions', '0', '全部', '全部'),
  ('announcements', 'statusOptions', '1', '最新', '最新'),
  ('announcements', 'statusOptions', '2', '進行中', '進行中'),
  ('announcements', 'statusOptions', '3', '已結束', '已結束')
ON CONFLICT (module, cate, key) DO UPDATE SET
  value = EXCLUDED.value,
  label = EXCLUDED.label,
  updated_at = NOW();

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有公告分類選項
-- SELECT * FROM option WHERE module = 'announcements' AND cate = 'categories' ORDER BY key;

-- 查詢所有圖示選項
-- SELECT * FROM option WHERE module = 'announcements' AND cate = 'iconOptions' ORDER BY key;

-- 查詢所有顏色選項
-- SELECT * FROM option WHERE module = 'announcements' AND cate = 'colorOptions' ORDER BY key;

-- 查詢所有狀態選項
-- SELECT * FROM option WHERE module = 'announcements' AND cate = 'statusOptions' ORDER BY key;

-- 使用 Supabase Client 查詢範例
-- 查詢所有公告分類選項
-- const { data } = await supabase
--   .from('option')
--   .select('*')
--   .eq('module', 'announcements')
--   .eq('cate', 'categories')
--   .order('key');

-- 查詢特定選項
-- const { data } = await supabase
--   .from('option')
--   .select('value, label')
--   .eq('module', 'announcements')
--   .eq('cate', 'categories')
--   .eq('key', '0')
--   .single();

-- 查詢所有狀態選項
-- const { data } = await supabase
--   .from('option')
--   .select('*')
--   .eq('module', 'announcements')
--   .eq('cate', 'statusOptions')
--   .order('key');
