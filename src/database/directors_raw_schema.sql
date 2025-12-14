-- ============================================
-- Directors Raw Data Insert Statements
-- 理事會資料初始資料插入語句
-- 此檔案包含從 mock 資料轉換而來的 INSERT 語句
-- ============================================

-- ============================================
-- Board Members
-- 理事會成員資料
-- ============================================

INSERT INTO board_members (name, title, role, description, education, expertise, experience, email, linkedin, display_order) VALUES
  ('張文華', '理事長', '理事長', '致力於古蹟保護與文化傳承，擁有豐富的歷史建築修復經驗。', '國立台灣大學建築與城鄉研究所博士', 
   ARRAY['古蹟修復', '建築史', '文化政策'], 
   ARRAY['文化部古蹟審議委員', '台灣古蹟保護協會理事長', '國立故宮博物院建築顧問'], 
   'zhang@monument.gov.tw', '#', 0),
  
  ('李美玲', '副理事長', '副理事長', '專精於文化資產管理與教育推廣，推動古蹟活化再利用。', '國立政治大學歷史學系碩士', 
   ARRAY['文化資產', '教育推廣', '博物館學'], 
   ARRAY['台北市文化局文化資產科科長', '國立歷史博物館研究員', '台灣博物館學會常務理事'], 
   'li@monument.gov.tw', '#', 1),
  
  ('陳志明', '常務理事', '常務理事', '建築工程專家，專精於古蹟結構安全評估與修復技術。', '國立成功大學建築學系學士', 
   ARRAY['結構工程', '古蹟修復', '工程管理'], 
   ARRAY['中華民國建築師公會理事', '古蹟修復工程顧問', '營建署古蹟修復審查委員'], 
   'chen@monument.gov.tw', '#', 2),
  
  ('林雅婷', '常務理事', '常務理事', '文化創意產業專家，致力於古蹟文化價值推廣與創新應用。', '國立台灣藝術大學文化創意產業學系碩士', 
   ARRAY['文化創意', '行銷推廣', '活動企劃'], 
   ARRAY['文化部文創發展司專員', '台北市文化基金會執行長', '台灣文創產業聯盟理事'], 
   'lin@monument.gov.tw', '#', 3),
  
  ('黃文博', '理事', '理事', '歷史學者，專精於台灣史研究與文獻整理，為古蹟歷史研究提供學術支持。', '國立台灣大學歷史學系博士', 
   ARRAY['台灣史', '文獻研究', '口述歷史'], 
   ARRAY['中央研究院台灣史研究所研究員', '國立台灣大學歷史學系兼任教授', '台灣史學會常務理事'], 
   'huang@monument.gov.tw', '#', 4),
  
  ('劉美惠', '理事', '理事', '財務管理專家，負責古蹟管理處的財務規劃與預算管理。', '國立政治大學會計學系碩士', 
   ARRAY['財務管理', '會計', '預算規劃'], 
   ARRAY['會計師事務所合夥人', '文化部財務管理顧問', '非營利組織財務管理專家'], 
   'liu@monument.gov.tw', '#', 5)
ON CONFLICT DO NOTHING;

-- 注意：照片需要上傳到 Supabase Storage，然後更新對應的 photo_url 或 storage_path 欄位
-- 例如：
-- UPDATE board_members 
-- SET photo_url = 'https://your-project.supabase.co/storage/v1/object/public/directors-photos/zhang-wenhua.jpg',
--     storage_path = 'directors-photos/zhang-wenhua.jpg'
-- WHERE name = '張文華';

-- ============================================
-- Board Structure
-- 理事會結構資料
-- ============================================

INSERT INTO board_structure (title, description, icon, color, count, unit, display_order) VALUES
  ('理事長', '負責理事會整體運作與決策', 'mdi-account-tie', 'primary', 1, '人', 0),
  ('常務理事', '協助理事長處理日常事務', 'mdi-account-group', 'success', 3, '人', 1),
  ('一般理事', '參與重大決策與監督管理', 'mdi-account-multiple', 'info', 8, '人', 2)
ON CONFLICT DO NOTHING;

-- ============================================
-- Meeting Schedule
-- 會議行程資料
-- ============================================

INSERT INTO meeting_schedule (date, title, description, time, location, icon, color, display_order) VALUES
  ('2024-01-15', '第一季理事會會議', '討論年度工作計畫與預算分配', '14:00-16:00', '古蹟管理處會議室', 'mdi-calendar', 'primary', 0),
  ('2024-04-15', '第二季理事會會議', '檢討第一季執行成果與調整計畫', '14:00-16:00', '古蹟管理處會議室', 'mdi-calendar', 'success', 1),
  ('2024-07-15', '第三季理事會會議', '中期檢討與下半年重點工作', '14:00-16:00', '古蹟管理處會議室', 'mdi-calendar', 'info', 2),
  ('2024-10-15', '第四季理事會會議', '年度總結與下年度規劃', '14:00-16:00', '古蹟管理處會議室', 'mdi-calendar', 'warning', 3)
ON CONFLICT DO NOTHING;

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有理事會成員（按顯示順序排序）
-- SELECT * FROM board_members ORDER BY display_order ASC;

-- 查詢所有理事會結構（按顯示順序排序）
-- SELECT * FROM board_structure ORDER BY display_order ASC;

-- 查詢所有會議行程（按日期排序）
-- SELECT * FROM meeting_schedule ORDER BY date ASC, display_order ASC;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: boardMembers } = await supabase
--   .from('board_members')
--   .select('*')
--   .order('display_order', { ascending: true });
--
-- const { data: boardStructure } = await supabase
--   .from('board_structure')
--   .select('*')
--   .order('display_order', { ascending: true });
--
-- const { data: meetingSchedule } = await supabase
--   .from('meeting_schedule')
--   .select('*')
--   .order('date', { ascending: true })
--   .order('display_order', { ascending: true });
