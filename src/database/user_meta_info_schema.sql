-- ============================================
-- User Meta Info Schema for Supabase
-- 使用者額外資訊表：紀錄姓名與角色
-- ============================================

-- 說明：
-- 1. 此表用來補充 auth.users 中的使用者資訊（例如顯示姓名、角色）
-- 2. 以 user_id 對應 auth.users.id，並設為主鍵（一對一）
-- 3. 建議由後台管理（如 /admin/user 頁面）讀寫

-- 建立 user_meta_info 表格
CREATE TABLE IF NOT EXISTS public.user_meta_info (
  user_id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  full_name TEXT,              -- 使用者姓名
  role TEXT,                   -- 使用者角色（例如：admin、user）
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 索引（視需要可擴充）
CREATE INDEX IF NOT EXISTS idx_user_meta_info_role ON public.user_meta_info(role);
CREATE INDEX IF NOT EXISTS idx_user_meta_info_created_at ON public.user_meta_info(created_at DESC);

-- ============================================
-- updated_at 自動更新觸發器
-- ============================================

-- 若尚未有共用的 updated_at 函數，可取消註解以下程式碼建立：
-- CREATE OR REPLACE FUNCTION public.update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   NEW.updated_at = NOW();
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_meta_info_updated_at
  BEFORE UPDATE ON public.user_meta_info
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Row Level Security (RLS) 設定
-- ============================================

ALTER TABLE public.user_meta_info ENABLE ROW LEVEL SECURITY;

-- 方案：所有認證用戶可讀取自己的 meta，只有自己可寫入

-- 讀取：認證用戶可以讀取自己的 meta（或由前端限制只查詢自己）
CREATE POLICY "Allow authenticated users to read their own meta_info"
  ON public.user_meta_info
  FOR SELECT
  USING (auth.uid() = user_id);

-- 新增：認證用戶可以為自己建立 meta_info
CREATE POLICY "Allow authenticated users to insert their own meta_info"
  ON public.user_meta_info
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 更新：認證用戶可以更新自己的 meta_info
CREATE POLICY "Allow authenticated users to update their own meta_info"
  ON public.user_meta_info
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 刪除：認證用戶可以刪除自己的 meta_info（通常不太需要）
CREATE POLICY "Allow authenticated users to delete their own meta_info"
  ON public.user_meta_info
  FOR DELETE
  USING (auth.uid() = user_id);

-- 若要讓管理員（role = 'admin'）可以管理所有人的 meta_info，
-- 可另外新增一組以 raw_user_meta_data->>'role' = 'admin' 為條件的政策。

-- ============================================
-- 註解
-- ============================================

COMMENT ON TABLE public.user_meta_info IS '使用者額外資訊表，紀錄姓名與角色等資訊';
COMMENT ON COLUMN public.user_meta_info.user_id IS '對應 auth.users.id 的使用者 ID（主鍵，一對一）';
COMMENT ON COLUMN public.user_meta_info.full_name IS '使用者姓名';
COMMENT ON COLUMN public.user_meta_info.role IS '使用者角色（例如：admin、user）';
COMMENT ON COLUMN public.user_meta_info.created_at IS '建立時間';
COMMENT ON COLUMN public.user_meta_info.updated_at IS '最後更新時間';

