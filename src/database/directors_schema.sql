-- ============================================
-- Board Members Table Schema for Supabase
-- 理事會成員資料表結構
-- ============================================

-- 建立 board_members 表格
CREATE TABLE IF NOT EXISTS board_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  title TEXT NOT NULL,
  role TEXT NOT NULL,
  photo_url TEXT,
  storage_path TEXT,
  description TEXT NOT NULL,
  education TEXT,
  expertise TEXT[], -- 專長陣列
  experience TEXT[], -- 經歷陣列
  email TEXT,
  linkedin TEXT,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_board_members_role ON board_members(role);
CREATE INDEX IF NOT EXISTS idx_board_members_display_order ON board_members(display_order);
CREATE INDEX IF NOT EXISTS idx_board_members_created_at ON board_members(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_board_members_updated_at
  BEFORE UPDATE ON board_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE board_members IS '理事會成員資料表，儲存古蹟管理處理事會成員資訊';
COMMENT ON COLUMN board_members.id IS '成員唯一識別碼';
COMMENT ON COLUMN board_members.name IS '姓名';
COMMENT ON COLUMN board_members.title IS '職稱（顯示用）';
COMMENT ON COLUMN board_members.role IS '角色（理事長、副理事長、常務理事、理事等）';
COMMENT ON COLUMN board_members.photo_url IS '照片 URL（外部連結或 Supabase Storage 公開 URL）';
COMMENT ON COLUMN board_members.storage_path IS 'Supabase Storage 路徑（如果照片儲存在 Storage 中）';
COMMENT ON COLUMN board_members.description IS '個人簡介';
COMMENT ON COLUMN board_members.education IS '學歷';
COMMENT ON COLUMN board_members.expertise IS '專長（陣列）';
COMMENT ON COLUMN board_members.experience IS '經歷（陣列）';
COMMENT ON COLUMN board_members.email IS '電子郵件';
COMMENT ON COLUMN board_members.linkedin IS 'LinkedIn 連結';
COMMENT ON COLUMN board_members.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN board_members.created_at IS '建立時間';
COMMENT ON COLUMN board_members.updated_at IS '最後更新時間';

-- ============================================
-- Board Structure Table Schema for Supabase
-- 理事會結構資料表結構
-- ============================================

-- 建立 board_structure 表格
CREATE TABLE IF NOT EXISTS board_structure (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  count INTEGER DEFAULT 0 NOT NULL,
  unit TEXT DEFAULT '人' NOT NULL,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_board_structure_display_order ON board_structure(display_order);
CREATE INDEX IF NOT EXISTS idx_board_structure_created_at ON board_structure(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_board_structure_updated_at
  BEFORE UPDATE ON board_structure
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE board_structure IS '理事會結構資料表，儲存理事會組織架構資訊';
COMMENT ON COLUMN board_structure.id IS '項目唯一識別碼';
COMMENT ON COLUMN board_structure.title IS '職稱';
COMMENT ON COLUMN board_structure.description IS '描述';
COMMENT ON COLUMN board_structure.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN board_structure.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN board_structure.count IS '人數';
COMMENT ON COLUMN board_structure.unit IS '單位（人、位等）';
COMMENT ON COLUMN board_structure.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN board_structure.created_at IS '建立時間';
COMMENT ON COLUMN board_structure.updated_at IS '最後更新時間';

-- ============================================
-- Meeting Schedule Table Schema for Supabase
-- 會議行程資料表結構
-- ============================================

-- 建立 meeting_schedule 表格
CREATE TABLE IF NOT EXISTS meeting_schedule (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  time TEXT,
  location TEXT,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_meeting_schedule_date ON meeting_schedule(date DESC);
CREATE INDEX IF NOT EXISTS idx_meeting_schedule_display_order ON meeting_schedule(display_order);
CREATE INDEX IF NOT EXISTS idx_meeting_schedule_created_at ON meeting_schedule(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_meeting_schedule_updated_at
  BEFORE UPDATE ON meeting_schedule
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE meeting_schedule IS '會議行程資料表，儲存理事會會議行程資訊';
COMMENT ON COLUMN meeting_schedule.id IS '會議唯一識別碼';
COMMENT ON COLUMN meeting_schedule.date IS '會議日期';
COMMENT ON COLUMN meeting_schedule.title IS '會議標題';
COMMENT ON COLUMN meeting_schedule.description IS '會議描述';
COMMENT ON COLUMN meeting_schedule.time IS '會議時間（例如：14:00-16:00）';
COMMENT ON COLUMN meeting_schedule.location IS '會議地點';
COMMENT ON COLUMN meeting_schedule.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN meeting_schedule.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN meeting_schedule.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN meeting_schedule.created_at IS '建立時間';
COMMENT ON COLUMN meeting_schedule.updated_at IS '最後更新時間';

-- ============================================
-- Row Level Security (RLS) Policies
-- 行級安全策略
-- ============================================

-- 啟用 RLS
ALTER TABLE board_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE board_structure ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_schedule ENABLE ROW LEVEL SECURITY;

-- board_members 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "board_members_select_public"
  ON board_members
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "board_members_insert_authenticated"
  ON board_members
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "board_members_update_authenticated"
  ON board_members
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "board_members_delete_authenticated"
  ON board_members
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- board_structure 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "board_structure_select_public"
  ON board_structure
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "board_structure_insert_authenticated"
  ON board_structure
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "board_structure_update_authenticated"
  ON board_structure
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "board_structure_delete_authenticated"
  ON board_structure
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- meeting_schedule 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "meeting_schedule_select_public"
  ON meeting_schedule
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "meeting_schedule_insert_authenticated"
  ON meeting_schedule
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "meeting_schedule_update_authenticated"
  ON meeting_schedule
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "meeting_schedule_delete_authenticated"
  ON meeting_schedule
  FOR DELETE
  USING (auth.role() = 'authenticated');
