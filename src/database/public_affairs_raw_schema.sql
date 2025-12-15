-- ============================================
-- Public Affairs Raw Data Insert Statements
-- 公務資訊資料初始資料插入語句
-- 此檔案包含從 mock 資料轉換而來的 INSERT 語句
-- ============================================

-- ============================================
-- Form Documents
-- 表單文件資料
-- ============================================

INSERT INTO form_documents (title, description, date, type, icon, color, category, url, display_order) VALUES
  ('古蹟參觀申請表', '申請參觀古蹟所需填寫的表單，包含個人資料與參觀時間', '2024-01-15', 'PDF', 'mdi-file-document', 'primary', '申請表單', '#', 0),
  ('古蹟修復工程申請表', '申請進行古蹟修復工程所需填寫的申請表單', '2024-01-12', 'DOC', 'mdi-hammer-wrench', 'warning', '工程申請', '#', 1),
  ('古蹟使用許可申請表', '申請使用古蹟場地進行活動所需填寫的表單', '2024-01-10', 'PDF', 'mdi-calendar-check', 'success', '申請表單', '#', 2),
  ('古蹟研究調查申請表', '申請進行古蹟相關研究調查所需填寫的表單', '2024-01-08', 'DOC', 'mdi-book-search', 'info', '研究申請', '#', 3),
  ('古蹟維護志工報名表', '報名成為古蹟維護志工所需填寫的表單', '2024-01-05', 'PDF', 'mdi-account-group', 'purple', '志工報名', '#', 4),
  ('古蹟導覽服務預約表', '預約古蹟導覽服務所需填寫的表單', '2024-01-03', 'PDF', 'mdi-school', 'success', '服務預約', '#', 5),
  ('古蹟攝影申請表', '申請在古蹟內進行攝影所需填寫的表單', '2024-01-01', 'DOC', 'mdi-camera', 'primary', '申請表單', '#', 6),
  ('古蹟文物借展申請表', '申請借展古蹟文物所需填寫的表單', '2023-12-28', 'PDF', 'mdi-package-variant', 'warning', '文物借展', '#', 7)
ON CONFLICT DO NOTHING;

-- ============================================
-- Contact Info
-- 聯絡資訊資料
-- ============================================

INSERT INTO contact_info (title, description, value, icon, color, action, button_text, display_order) VALUES
  ('總機電話', '古蹟管理處總機', '02-1234-5678', 'mdi-phone', 'primary', 'tel:02-1234-5678', '撥打電話', 0),
  ('電子信箱', '公務信箱', 'info@monument.gov.tw', 'mdi-email', 'success', 'mailto:info@monument.gov.tw', '發送郵件', 1),
  ('地址', '古蹟管理處地址', '台北市中正區重慶南路一段122號', 'mdi-map-marker', 'info', 'https://maps.google.com', '查看地圖', 2)
ON CONFLICT DO NOTHING;

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢所有表單文件（按顯示順序和日期排序）
-- SELECT * FROM form_documents ORDER BY display_order ASC, date DESC;

-- 查詢所有聯絡資訊（按顯示順序排序）
-- SELECT * FROM contact_info ORDER BY display_order ASC;

-- 使用 Supabase 客戶端查詢範例（JavaScript/TypeScript）
-- const { data: formDocuments } = await supabase
--   .from('form_documents')
--   .select('*')
--   .order('display_order', { ascending: true })
--   .order('date', { ascending: false });
--
-- const { data: contactInfo } = await supabase
--   .from('contact_info')
--   .select('*')
--   .order('display_order', { ascending: true });

