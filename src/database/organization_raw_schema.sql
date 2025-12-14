-- ============================================
-- Organization Raw Data Insert Statements
-- 組織架構資料初始資料插入語句
-- 此檔案包含從 mock 資料轉換而來的 INSERT 語句
-- ============================================

-- ============================================
-- Departments
-- 部門資料
-- ============================================

INSERT INTO departments (name, manager, description, icon, color, phone, email, responsibilities, display_order) VALUES
  ('行政部', '王建國', '負責古蹟管理處的日常行政事務與人事管理', 'mdi-office-building', 'primary', '02-1234-5678', 'admin@monument.gov.tw',
   ARRAY['人事管理與員工培訓', '財務預算編列與執行', '文書處理與檔案管理', '對外聯絡與協調', '會議安排與記錄'], 0),
  
  ('維護部', '陳志明', '負責古蹟的日常維護與修復工作', 'mdi-hammer-wrench', 'success', '02-1234-5679', 'maintenance@monument.gov.tw',
   ARRAY['古蹟結構安全檢查', '日常清潔與保養', '修復工程規劃與執行', '設備維護與更新', '安全監控系統管理'], 1),
  
  ('教育推廣部', '林雅婷', '負責古蹟的教育推廣與文化活動', 'mdi-school', 'info', '02-1234-5680', 'education@monument.gov.tw',
   ARRAY['導覽服務與解說', '教育活動規劃與執行', '文化推廣活動', '志工培訓與管理', '文宣品製作與發行'], 2),
  
  ('研究部', '黃文博', '負責古蹟的學術研究與文獻整理', 'mdi-book-search', 'warning', '02-1234-5681', 'research@monument.gov.tw',
   ARRAY['古蹟歷史研究', '文獻資料整理', '學術論文發表', '國際交流合作', '數位典藏建置'], 3),
  
  ('財務部', '劉美惠', '負責古蹟管理處的財務管理與會計事務', 'mdi-calculator', 'error', '02-1234-5682', 'finance@monument.gov.tw',
   ARRAY['預算編列與執行', '會計帳務處理', '財務報表製作', '採購管理', '成本控制與分析'], 4),
  
  ('資訊部', '張志強', '負責古蹟管理處的資訊系統與數位化服務', 'mdi-laptop', 'purple', '02-1234-5683', 'it@monument.gov.tw',
   ARRAY['資訊系統維護', '網站管理與更新', '數位化服務開發', '網路安全維護', '技術支援服務'], 5)
ON CONFLICT DO NOTHING;

-- ============================================
-- Organization Chart
-- 組織架構圖資料
-- ============================================

INSERT INTO organization_chart (position, name, title, icon, color) VALUES
  ('chairman', '張文華', '理事長', 'mdi-account-tie', 'primary'),
  ('viceChairman', '李美玲', '副理事長', 'mdi-account-tie-outline', 'success')
ON CONFLICT (position) DO UPDATE SET
  name = EXCLUDED.name,
  title = EXCLUDED.title,
  icon = EXCLUDED.icon,
  color = EXCLUDED.color,
  updated_at = NOW();

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有部門（按顯示順序排序）
-- SELECT * FROM departments ORDER BY display_order ASC;

-- 查詢組織架構圖
-- SELECT * FROM organization_chart ORDER BY position;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: departments } = await supabase
--   .from('departments')
--   .select('*')
--   .order('display_order', { ascending: true });
--
-- const { data: organizationChart } = await supabase
--   .from('organization_chart')
--   .select('*')
--   .order('position');
--
-- // 轉換為前端格式
-- const chartData = {
--   chairman: organizationChart.find(item => item.position === 'chairman'),
--   viceChairman: organizationChart.find(item => item.position === 'viceChairman'),
-- };
