-- ============================================
-- History Timeline Events Table Schema for Supabase
-- 歷史時間軸事件資料表結構
-- ============================================

-- 建立 history_timeline_events 表格
CREATE TABLE IF NOT EXISTS history_timeline_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  year TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  image_url TEXT,
  storage_path TEXT,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_history_timeline_events_year ON history_timeline_events(year);
CREATE INDEX IF NOT EXISTS idx_history_timeline_events_display_order ON history_timeline_events(display_order);
CREATE INDEX IF NOT EXISTS idx_history_timeline_events_created_at ON history_timeline_events(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_history_timeline_events_updated_at
  BEFORE UPDATE ON history_timeline_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE history_timeline_events IS '歷史時間軸事件資料表，儲存古蹟歷史沿革的時間軸事件';
COMMENT ON COLUMN history_timeline_events.id IS '事件唯一識別碼';
COMMENT ON COLUMN history_timeline_events.year IS '事件年份';
COMMENT ON COLUMN history_timeline_events.title IS '事件標題';
COMMENT ON COLUMN history_timeline_events.description IS '事件描述';
COMMENT ON COLUMN history_timeline_events.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN history_timeline_events.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN history_timeline_events.image_url IS '圖片 URL（外部連結或 Supabase Storage 公開 URL）';
COMMENT ON COLUMN history_timeline_events.storage_path IS 'Supabase Storage 路徑（如果圖片儲存在 Storage 中）';
COMMENT ON COLUMN history_timeline_events.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN history_timeline_events.created_at IS '建立時間';
COMMENT ON COLUMN history_timeline_events.updated_at IS '最後更新時間';

-- ============================================
-- History Significance Table Schema for Supabase
-- 歷史意義資料表結構
-- ============================================

-- 建立 history_significance 表格
CREATE TABLE IF NOT EXISTS history_significance (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  image_url TEXT,
  storage_path TEXT,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_history_significance_display_order ON history_significance(display_order);
CREATE INDEX IF NOT EXISTS idx_history_significance_created_at ON history_significance(created_at DESC);

-- 如果表已存在，添加圖片欄位（遷移腳本）
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'history_significance' AND column_name = 'image_url'
  ) THEN
    ALTER TABLE history_significance ADD COLUMN image_url TEXT;
    ALTER TABLE history_significance ADD COLUMN storage_path TEXT;
  END IF;
END $$;

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_history_significance_updated_at
  BEFORE UPDATE ON history_significance
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE history_significance IS '歷史意義資料表，儲存古蹟的歷史意義與文化價值';
COMMENT ON COLUMN history_significance.id IS '項目唯一識別碼';
COMMENT ON COLUMN history_significance.title IS '標題';
COMMENT ON COLUMN history_significance.description IS '描述';
COMMENT ON COLUMN history_significance.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN history_significance.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN history_significance.image_url IS '圖片 URL（外部連結或 Supabase Storage 公開 URL）';
COMMENT ON COLUMN history_significance.storage_path IS 'Supabase Storage 路徑（如果圖片儲存在 Storage 中）';
COMMENT ON COLUMN history_significance.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN history_significance.created_at IS '建立時間';
COMMENT ON COLUMN history_significance.updated_at IS '最後更新時間';

-- ============================================
-- Row Level Security (RLS) Policies
-- 行級安全策略
-- ============================================

-- 啟用 RLS
ALTER TABLE history_timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE history_significance ENABLE ROW LEVEL SECURITY;

-- history_timeline_events 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "history_timeline_events_select_public"
  ON history_timeline_events
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "history_timeline_events_insert_authenticated"
  ON history_timeline_events
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "history_timeline_events_update_authenticated"
  ON history_timeline_events
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "history_timeline_events_delete_authenticated"
  ON history_timeline_events
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- history_significance 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "history_significance_select_public"
  ON history_significance
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "history_significance_insert_authenticated"
  ON history_significance
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "history_significance_update_authenticated"
  ON history_significance
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "history_significance_delete_authenticated"
  ON history_significance
  FOR DELETE
  USING (auth.role() = 'authenticated');
