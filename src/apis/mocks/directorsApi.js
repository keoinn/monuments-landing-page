/**
 * Mock API for fetching directors data
 * 模擬從後端 API 獲取理事會資料
 */

import landingViewImage from '@/assets/img/landing-view.webp'

// 模擬 API 延遲時間（毫秒）
const API_DELAY = 500

// Mock 資料
const mockBoardMembers = [
  {
    name: '張文華',
    title: '理事長',
    role: '理事長',
    photo: landingViewImage,
    description: '致力於古蹟保護與文化傳承，擁有豐富的歷史建築修復經驗。',
    education: '國立台灣大學建築與城鄉研究所博士',
    expertise: ['古蹟修復', '建築史', '文化政策'],
    experience: [
      '文化部古蹟審議委員',
      '台灣古蹟保護協會理事長',
      '國立故宮博物院建築顧問',
    ],
    email: 'zhang@monument.gov.tw',
    linkedin: '#',
  },
  {
    name: '李美玲',
    title: '副理事長',
    role: '副理事長',
    photo: landingViewImage,
    description: '專精於文化資產管理與教育推廣，推動古蹟活化再利用。',
    education: '國立政治大學歷史學系碩士',
    expertise: ['文化資產', '教育推廣', '博物館學'],
    experience: [
      '台北市文化局文化資產科科長',
      '國立歷史博物館研究員',
      '台灣博物館學會常務理事',
    ],
    email: 'li@monument.gov.tw',
    linkedin: '#',
  },
  {
    name: '陳志明',
    title: '常務理事',
    role: '常務理事',
    photo: landingViewImage,
    description: '建築工程專家，專精於古蹟結構安全評估與修復技術。',
    education: '國立成功大學建築學系學士',
    expertise: ['結構工程', '古蹟修復', '工程管理'],
    experience: [
      '中華民國建築師公會理事',
      '古蹟修復工程顧問',
      '營建署古蹟修復審查委員',
    ],
    email: 'chen@monument.gov.tw',
    linkedin: '#',
  },
  {
    name: '林雅婷',
    title: '常務理事',
    role: '常務理事',
    photo: landingViewImage,
    description: '文化創意產業專家，致力於古蹟文化價值推廣與創新應用。',
    education: '國立台灣藝術大學文化創意產業學系碩士',
    expertise: ['文化創意', '行銷推廣', '活動企劃'],
    experience: [
      '文化部文創發展司專員',
      '台北市文化基金會執行長',
      '台灣文創產業聯盟理事',
    ],
    email: 'lin@monument.gov.tw',
    linkedin: '#',
  },
  {
    name: '黃文博',
    title: '理事',
    role: '理事',
    photo: landingViewImage,
    description: '歷史學者，專精於台灣史研究與文獻整理，為古蹟歷史研究提供學術支持。',
    education: '國立台灣大學歷史學系博士',
    expertise: ['台灣史', '文獻研究', '口述歷史'],
    experience: [
      '中央研究院台灣史研究所研究員',
      '國立台灣大學歷史學系兼任教授',
      '台灣史學會常務理事',
    ],
    email: 'huang@monument.gov.tw',
    linkedin: '#',
  },
  {
    name: '劉美惠',
    title: '理事',
    role: '理事',
    photo: landingViewImage,
    description: '財務管理專家，負責古蹟管理處的財務規劃與預算管理。',
    education: '國立政治大學會計學系碩士',
    expertise: ['財務管理', '會計', '預算規劃'],
    experience: [
      '會計師事務所合夥人',
      '文化部財務管理顧問',
      '非營利組織財務管理專家',
    ],
    email: 'liu@monument.gov.tw',
    linkedin: '#',
  },
]

const mockBoardStructure = [
  {
    title: '理事長',
    description: '負責理事會整體運作與決策',
    icon: 'mdi-account-tie',
    color: 'primary',
    count: 1,
    unit: '人',
  },
  {
    title: '常務理事',
    description: '協助理事長處理日常事務',
    icon: 'mdi-account-group',
    color: 'success',
    count: 3,
    unit: '人',
  },
  {
    title: '一般理事',
    description: '參與重大決策與監督管理',
    icon: 'mdi-account-multiple',
    color: 'info',
    count: 8,
    unit: '人',
  },
]

const mockMeetingSchedule = [
  {
    date: '2024-01-15',
    title: '第一季理事會會議',
    description: '討論年度工作計畫與預算分配',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'primary',
  },
  {
    date: '2024-04-15',
    title: '第二季理事會會議',
    description: '檢討第一季執行成果與調整計畫',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'success',
  },
  {
    date: '2024-07-15',
    title: '第三季理事會會議',
    description: '中期檢討與下半年重點工作',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'info',
  },
  {
    date: '2024-10-15',
    title: '第四季理事會會議',
    description: '年度總結與下年度規劃',
    time: '14:00-16:00',
    location: '古蹟管理處會議室',
    icon: 'mdi-calendar',
    color: 'warning',
  },
]

/**
 * 模擬從後端 API 獲取 board members 資料
 * @returns {Promise<Array>} Board members 資料陣列
 */
export async function fetchBoardMembers () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve(mockBoardMembers)
}

/**
 * 模擬從後端 API 獲取 board structure 資料
 * @returns {Promise<Array>} Board structure 資料陣列
 */
export async function fetchBoardStructure () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve(mockBoardStructure)
}

/**
 * 模擬從後端 API 獲取 meeting schedule 資料
 * @returns {Promise<Array>} Meeting schedule 資料陣列
 */
export async function fetchMeetingSchedule () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve(mockMeetingSchedule)
}

/**
 * 模擬從後端 API 獲取所有理事會資料
 * @returns {Promise<Object>} 包含 boardMembers、boardStructure 和 meetingSchedule 的物件
 */
export async function fetchDirectorsData () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve({
    boardMembers: mockBoardMembers,
    boardStructure: mockBoardStructure,
    meetingSchedule: mockMeetingSchedule,
  })
}

