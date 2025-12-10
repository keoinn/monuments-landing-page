/**
 * Mock API for fetching history data
 * 模擬從後端 API 獲取歷史資料
 */

import landingViewImage from '@/assets/img/landing-view.webp'

// 模擬 API 延遲時間（毫秒）
const API_DELAY = 500

// Mock 資料
const mockTimelineEvents = [
  {
    year: '1820',
    title: '古蹟建造',
    description: '這座古蹟始建於清朝道光年間，最初作為地方官員的辦公場所，見證了當時的政治與社會變遷。建築風格融合了傳統中式建築與當時的時代特色。',
    icon: 'mdi-home',
    color: 'primary',
    image: landingViewImage,
  },
  {
    year: '1895',
    title: '日治時期',
    description: '進入日治時期後，建築物被重新規劃使用，成為重要的行政中心。在此期間，建築物經歷了部分改建，但仍保持原有的基本結構。',
    icon: 'mdi-flag',
    color: 'success',
    image: null,
  },
  {
    year: '1945',
    title: '戰後重建',
    description: '第二次世界大戰結束後，建築物在戰火中受損，經過精心修復後重新開放。這個時期標誌著古蹟保護意識的萌芽。',
    icon: 'mdi-hammer-wrench',
    color: 'warning',
    image: null,
  },
  {
    year: '1985',
    title: '列為古蹟',
    description: '正式被政府列為歷史古蹟，開始受到法律保護。這標誌著古蹟保護工作進入新的階段，也為後續的修復與維護奠定了基礎。',
    icon: 'mdi-shield-star',
    color: 'info',
    image: null,
  },
  {
    year: '2000',
    title: '全面修復',
    description: '進行了全面的修復工程，採用傳統工法與現代技術相結合的方式，確保古蹟的結構安全與歷史風貌的完整性。',
    icon: 'mdi-tools',
    color: 'error',
    image: null,
  },
]

const mockHistoricalSignificance = [
  {
    title: '建築藝術',
    description: '展現了清朝中後期的建築特色，融合了傳統工藝與時代美學，是研究當時建築技術的重要實例。',
    icon: 'mdi-palette',
    color: 'primary',
  },
  {
    title: '歷史見證',
    description: '見證了從清朝到現代的重要歷史變遷，承載了豐富的歷史記憶與文化內涵。',
    icon: 'mdi-book-open',
    color: 'success',
  },
  {
    title: '文化傳承',
    description: '作為重要的文化載體，傳承了當地的歷史文化，是後代了解過去的重要窗口。',
    icon: 'mdi-account-group',
    color: 'info',
  },
]

/**
 * 模擬從後端 API 獲取 timeline events 資料
 * @returns {Promise<Array>} Timeline events 資料陣列
 */
export async function fetchTimelineEvents () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve(mockTimelineEvents)
}

/**
 * 模擬從後端 API 獲取 historical significance 資料
 * @returns {Promise<Array>} Historical significance 資料陣列
 */
export async function fetchHistoricalSignificance () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve(mockHistoricalSignificance)
}

/**
 * 模擬從後端 API 獲取所有歷史資料
 * @returns {Promise<Object>} 包含 timelineEvents 和 historicalSignificance 的物件
 */
export async function fetchHistoryData () {
  // 模擬 API 延遲
  await new Promise(resolve => setTimeout(resolve, API_DELAY))

  // 返回模擬資料
  return Promise.resolve({
    timelineEvents: mockTimelineEvents,
    historicalSignificance: mockHistoricalSignificance,
  })
}

