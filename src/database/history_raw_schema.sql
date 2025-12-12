-- ============================================
-- History Raw Data Insert Statements
-- 歷史資料初始資料插入語句
-- 此檔案包含從 mock 資料轉換而來的 INSERT 語句
-- ============================================

-- ============================================
-- History Timeline Events
-- 歷史時間軸事件資料
-- ============================================

INSERT INTO history_timeline_events (year, title, description, icon, color, image_url, display_order) VALUES
  ('1820', '古蹟建造', '這座古蹟始建於清朝道光年間，最初作為地方官員的辦公場所，見證了當時的政治與社會變遷。建築風格融合了傳統中式建築與當時的時代特色。', 'mdi-home', 'primary', NULL, 0),
  ('1895', '日治時期', '進入日治時期後，建築物被重新規劃使用，成為重要的行政中心。在此期間，建築物經歷了部分改建，但仍保持原有的基本結構。', 'mdi-flag', 'success', NULL, 1),
  ('1945', '戰後重建', '第二次世界大戰結束後，建築物在戰火中受損，經過精心修復後重新開放。這個時期標誌著古蹟保護意識的萌芽。', 'mdi-hammer-wrench', 'warning', NULL, 2),
  ('1985', '列為古蹟', '正式被政府列為歷史古蹟，開始受到法律保護。這標誌著古蹟保護工作進入新的階段，也為後續的修復與維護奠定了基礎。', 'mdi-shield-star', 'info', NULL, 3),
  ('2000', '全面修復', '進行了全面的修復工程，採用傳統工法與現代技術相結合的方式，確保古蹟的結構安全與歷史風貌的完整性。', 'mdi-tools', 'error', NULL, 4)
ON CONFLICT DO NOTHING;

-- 注意：第一個事件有圖片（landing-view.webp），如果需要上傳到 Supabase Storage，
-- 請先上傳圖片，然後更新對應的 image_url 或 storage_path 欄位
-- 例如：
-- UPDATE history_timeline_events 
-- SET image_url = 'https://your-project.supabase.co/storage/v1/object/public/history-images/landing-view.webp',
--     storage_path = 'history-images/landing-view.webp'
-- WHERE year = '1820';

-- ============================================
-- History Significance
-- 歷史意義資料
-- ============================================

INSERT INTO history_significance (title, description, icon, color, display_order) VALUES
  ('建築藝術', '展現了清朝中後期的建築特色，融合了傳統工藝與時代美學，是研究當時建築技術的重要實例。', 'mdi-palette', 'primary', 0),
  ('歷史見證', '見證了從清朝到現代的重要歷史變遷，承載了豐富的歷史記憶與文化內涵。', 'mdi-book-open', 'success', 1),
  ('文化傳承', '作為重要的文化載體，傳承了當地的歷史文化，是後代了解過去的重要窗口。', 'mdi-account-group', 'info', 2)
ON CONFLICT DO NOTHING;

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有時間軸事件（按顯示順序排序）
-- SELECT * FROM history_timeline_events ORDER BY display_order ASC, year ASC;

-- 查詢所有歷史意義項目（按顯示順序排序）
-- SELECT * FROM history_significance ORDER BY display_order ASC;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: timelineEvents } = await supabase
--   .from('history_timeline_events')
--   .select('*')
--   .order('display_order', { ascending: true })
--   .order('year', { ascending: true });
--
-- const { data: significance } = await supabase
--   .from('history_significance')
--   .select('*')
--   .order('display_order', { ascending: true });
