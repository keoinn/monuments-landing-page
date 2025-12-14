-- ============================================
-- Departments Table Schema for Supabase
-- 部門資料表結構
-- ============================================

-- 建立 departments 表格
CREATE TABLE IF NOT EXISTS departments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  manager TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  responsibilities TEXT[], -- 職責陣列
  display_order INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_departments_display_order ON departments(display_order);
CREATE INDEX IF NOT EXISTS idx_departments_created_at ON departments(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_departments_updated_at
  BEFORE UPDATE ON departments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE departments IS '部門資料表，儲存古蹟管理處各部門資訊';
COMMENT ON COLUMN departments.id IS '部門唯一識別碼';
COMMENT ON COLUMN departments.name IS '部門名稱';
COMMENT ON COLUMN departments.manager IS '部門主管';
COMMENT ON COLUMN departments.description IS '部門描述';
COMMENT ON COLUMN departments.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN departments.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN departments.phone IS '聯絡電話';
COMMENT ON COLUMN departments.email IS '電子郵件';
COMMENT ON COLUMN departments.responsibilities IS '職責（陣列）';
COMMENT ON COLUMN departments.display_order IS '顯示順序（數字越小越前面）';
COMMENT ON COLUMN departments.created_at IS '建立時間';
COMMENT ON COLUMN departments.updated_at IS '最後更新時間';

-- ============================================
-- Organization Chart Table Schema for Supabase
-- 組織架構圖資料表結構
-- ============================================

-- 建立 organization_chart 表格
CREATE TABLE IF NOT EXISTS organization_chart (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  position TEXT NOT NULL UNIQUE, -- 職位（chairman, viceChairman）
  name TEXT NOT NULL,
  title TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_organization_chart_position ON organization_chart(position);
CREATE INDEX IF NOT EXISTS idx_organization_chart_created_at ON organization_chart(created_at DESC);

-- 建立觸發器，自動更新 updated_at
CREATE TRIGGER update_organization_chart_updated_at
  BEFORE UPDATE ON organization_chart
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 新增註解說明
COMMENT ON TABLE organization_chart IS '組織架構圖資料表，儲存古蹟管理處高層組織架構';
COMMENT ON COLUMN organization_chart.id IS '記錄唯一識別碼';
COMMENT ON COLUMN organization_chart.position IS '職位代碼（chairman, viceChairman）';
COMMENT ON COLUMN organization_chart.name IS '姓名';
COMMENT ON COLUMN organization_chart.title IS '職稱';
COMMENT ON COLUMN organization_chart.icon IS '圖示名稱（Material Design Icons）';
COMMENT ON COLUMN organization_chart.color IS '顏色主題（primary、success、info、warning、error等）';
COMMENT ON COLUMN organization_chart.created_at IS '建立時間';
COMMENT ON COLUMN organization_chart.updated_at IS '最後更新時間';

-- ============================================
-- Row Level Security (RLS) Policies
-- 行級安全策略
-- ============================================

-- 啟用 RLS
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_chart ENABLE ROW LEVEL SECURITY;

-- departments 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "departments_select_public"
  ON departments
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "departments_insert_authenticated"
  ON departments
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "departments_update_authenticated"
  ON departments
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "departments_delete_authenticated"
  ON departments
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- organization_chart 的 RLS 策略
-- 所有人都可以讀取（公開資料）
CREATE POLICY "organization_chart_select_public"
  ON organization_chart
  FOR SELECT
  USING (true);

-- 只有已認證用戶可以插入
CREATE POLICY "organization_chart_insert_authenticated"
  ON organization_chart
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以更新
CREATE POLICY "organization_chart_update_authenticated"
  ON organization_chart
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 只有已認證用戶可以刪除
CREATE POLICY "organization_chart_delete_authenticated"
  ON organization_chart
  FOR DELETE
  USING (auth.role() = 'authenticated');
