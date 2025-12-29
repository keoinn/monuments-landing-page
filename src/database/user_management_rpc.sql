-- ============================================
-- User Management RPC Functions for Supabase
-- 用戶管理 RPC 函數
-- ============================================

-- 注意：這些函數需要在 Supabase Dashboard > SQL Editor 中執行
-- 並且需要適當的權限設置

-- RPC 函數：獲取用戶列表
-- ============================================

-- 先刪除舊的同名函式（如果存在），避免回傳型別不相容
DROP FUNCTION IF EXISTS get_users_list();

CREATE OR REPLACE FUNCTION get_users_list()
RETURNS SETOF auth.users
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- 檢查是否為認證用戶（可以在這裡再加上管理員檢查）
  IF auth.role() != 'authenticated' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- 直接回傳 auth.users 的完整結構，避免回傳型別不相符問題
  RETURN QUERY
  SELECT *
  FROM auth.users
  ORDER BY created_at DESC;
END;
$$;

-- 添加註解
COMMENT ON FUNCTION get_users_list IS '獲取用戶列表（需要認證）';

-- ============================================
-- RPC 函數：更新用戶資訊（可選）
-- ============================================

-- 注意：更新用戶資訊通常應該通過 Supabase Admin API 進行
-- 這個函數僅作為參考，實際使用時需要謹慎考慮安全性

-- CREATE OR REPLACE FUNCTION update_user_info(
--   user_id UUID,
--   new_email TEXT DEFAULT NULL,
--   new_metadata JSONB DEFAULT NULL
-- )
-- RETURNS BOOLEAN
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   -- 檢查是否為認證用戶且為管理員
--   IF auth.role() != 'authenticated' THEN
--     RAISE EXCEPTION 'Unauthorized';
--   END IF;
--
--   -- 檢查是否為管理員（根據 user_metadata.role）
--   DECLARE
--     current_user_role TEXT;
--   BEGIN
--     SELECT raw_user_meta_data->>'role' INTO current_user_role
--     FROM auth.users
--     WHERE id = auth.uid();
--
--     IF current_user_role != 'admin' THEN
--       RAISE EXCEPTION 'Only admins can update users';
--     END IF;
--   END;
--
--   -- 更新用戶資訊
--   IF new_email IS NOT NULL THEN
--     UPDATE auth.users
--     SET email = new_email
--     WHERE id = user_id;
--   END IF;
--
--   IF new_metadata IS NOT NULL THEN
--     UPDATE auth.users
--     SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || new_metadata
--     WHERE id = user_id;
--   END IF;
--
--   RETURN TRUE;
-- END;
-- $$;

-- ============================================
-- 使用說明
-- ============================================

-- 1. 在 Supabase Dashboard > SQL Editor 中執行此文件
-- 2. 確保 RLS 政策允許認證用戶調用此函數
-- 3. 在客戶端調用：
--    const { data, error } = await supabase.rpc('get_users_list')

-- ============================================
-- 安全建議
-- ============================================

-- 1. 考慮添加管理員角色檢查
-- 2. 限制返回的用戶資訊（例如不返回敏感資訊）
-- 3. 添加分頁支持
-- 4. 添加搜尋和篩選功能
-- 5. 記錄所有用戶管理操作

-- ============================================
-- 範例：帶管理員檢查的版本
-- ============================================

-- CREATE OR REPLACE FUNCTION get_users_list_admin_only()
-- RETURNS TABLE (
--   id UUID,
--   email TEXT,
--   user_metadata JSONB,
--   email_confirmed_at TIMESTAMPTZ,
--   created_at TIMESTAMPTZ,
--   last_sign_in_at TIMESTAMPTZ
-- )
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- DECLARE
--   current_user_role TEXT;
-- BEGIN
--   -- 檢查是否為認證用戶
--   IF auth.role() != 'authenticated' THEN
--     RAISE EXCEPTION 'Unauthorized';
--   END IF;
--
--   -- 檢查是否為管理員
--   SELECT raw_user_meta_data->>'role' INTO current_user_role
--   FROM auth.users
--   WHERE id = auth.uid();
--
--   IF current_user_role != 'admin' THEN
--     RAISE EXCEPTION 'Only admins can view user list';
--   END IF;
--
--   -- 返回用戶列表
--   RETURN QUERY
--   SELECT
--     u.id,
--     u.email,
--     u.raw_user_meta_data as user_metadata,
--     u.email_confirmed_at,
--     u.created_at,
--     u.last_sign_in_at
--   FROM auth.users u
--   ORDER BY u.created_at DESC;
-- END;
-- $$;
