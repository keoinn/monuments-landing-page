/**
 * Mock API for fetching features data
 * 模擬從後端 API 獲取 features 資料
 */

// 模擬 API 延遲時間（毫秒）
const API_DELAY = 500

// Mock 資料
const mockFeaturesData = [
  {
    title: '歷史沿革',
    description: '探索古蹟的建造背景、歷史變遷與文化意義',
    icon: 'mdi-history',
    color: 'primary',
    to: '/history',
  },
  {
    title: '組織架構',
    description: '了解古蹟管理組織的結構與運作方式',
    icon: 'mdi-account-group',
    color: 'success',
    to: '/organization',
  },
  {
    title: '委員會務',
    description: '查看理事會成員與相關公務資訊',
    icon: 'mdi-account-tie',
    color: 'info',
    to: '/directors',
  },
  {
    title: '公務資訊',
    description: '瀏覽古蹟相關的公務公告與重要資訊',
    icon: 'mdi-file-document',
    color: 'warning',
    to: '/public-affairs',
  },
  {
    title: '最新公告',
    description: '掌握古蹟管理處的最新公告與消息',
    icon: 'mdi-bullhorn',
    color: 'error',
    to: '/announcements',
  },
]

/**
 * 模擬從後端 API 獲取 features 資料
 * @returns {Promise<Array>} Features 資料陣列
 */
export async function fetchFeatures() {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 模擬可能的錯誤情況（可選，用於測試錯誤處理）
  // if (Math.random() < 0.1) {
  //   throw new Error('API 請求失敗')
  // }

  // 返回模擬資料
  return Promise.resolve(mockFeaturesData)
}

/**
 * 模擬從後端 API 獲取單個 feature 資料
 * @param {string} title - Feature 標題
 * @returns {Promise<Object|null>} Feature 資料或 null
 */
export async function fetchFeatureByTitle(title) {
  await new Promise(resolve => setTimeout(resolve, API_DELAY))
  
  const feature = mockFeaturesData.find(f => f.title === title)
  return Promise.resolve(feature || null)
}

