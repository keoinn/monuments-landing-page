/**
 * Mock API for fetching public affairs data
 * 模擬從後端 API 獲取公務資訊資料
 */

// 模擬 API 延遲時間（毫秒）
const API_DELAY = 500

// 表單文件模擬資料
const mockFormDocuments = [
  {
    title: '古蹟參觀申請表',
    description: '申請參觀古蹟所需填寫的表單，包含個人資料與參觀時間',
    date: '2024-01-15',
    type: 'PDF',
    icon: 'mdi-file-document',
    color: 'primary',
    category: '申請表單',
    url: '#',
  },
  {
    title: '古蹟修復工程申請表',
    description: '申請進行古蹟修復工程所需填寫的申請表單',
    date: '2024-01-12',
    type: 'DOC',
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    category: '工程申請',
    url: '#',
  },
  {
    title: '古蹟使用許可申請表',
    description: '申請使用古蹟場地進行活動所需填寫的表單',
    date: '2024-01-10',
    type: 'PDF',
    icon: 'mdi-calendar-check',
    color: 'success',
    category: '申請表單',
    url: '#',
  },
  {
    title: '古蹟研究調查申請表',
    description: '申請進行古蹟相關研究調查所需填寫的表單',
    date: '2024-01-08',
    type: 'DOC',
    icon: 'mdi-book-search',
    color: 'info',
    category: '研究申請',
    url: '#',
  },
  {
    title: '古蹟維護志工報名表',
    description: '報名成為古蹟維護志工所需填寫的表單',
    date: '2024-01-05',
    type: 'PDF',
    icon: 'mdi-account-group',
    color: 'purple',
    category: '志工報名',
    url: '#',
  },
  {
    title: '古蹟導覽服務預約表',
    description: '預約古蹟導覽服務所需填寫的表單',
    date: '2024-01-03',
    type: 'PDF',
    icon: 'mdi-school',
    color: 'success',
    category: '服務預約',
    url: '#',
  },
  {
    title: '古蹟攝影申請表',
    description: '申請在古蹟內進行攝影所需填寫的表單',
    date: '2024-01-01',
    type: 'DOC',
    icon: 'mdi-camera',
    color: 'primary',
    category: '申請表單',
    url: '#',
  },
  {
    title: '古蹟文物借展申請表',
    description: '申請借展古蹟文物所需填寫的表單',
    date: '2023-12-28',
    type: 'PDF',
    icon: 'mdi-package-variant',
    color: 'warning',
    category: '文物借展',
    url: '#',
  },
]

// 聯絡資訊模擬資料
const mockContactInfo = [
  {
    title: '總機電話',
    description: '古蹟管理處總機',
    value: '02-1234-5678',
    icon: 'mdi-phone',
    color: 'primary',
    action: 'tel:02-1234-5678',
    buttonText: '撥打電話',
  },
  {
    title: '電子信箱',
    description: '公務信箱',
    value: 'info@monument.gov.tw',
    icon: 'mdi-email',
    color: 'success',
    action: 'mailto:info@monument.gov.tw',
    buttonText: '發送郵件',
  },
  {
    title: '地址',
    description: '古蹟管理處地址',
    value: '台北市中正區重慶南路一段122號',
    icon: 'mdi-map-marker',
    color: 'info',
    action: 'https://maps.google.com',
    buttonText: '查看地圖',
  },
]

/**
 * 模擬從後端 API 獲取所有公務資訊資料
 * @returns {Promise<Object>} 包含 formDocuments 和 contactInfo 的物件
 */
export async function fetchPublicAffairsData () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return {
    formDocuments: mockFormDocuments,
    contactInfo: mockContactInfo,
  }
}
