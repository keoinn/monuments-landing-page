/**
 * 角色顯示輔助函數
 * 將 role 值轉換為中文顯示文字
 */

/**
 * 取得角色的中文顯示文字
 * @param {string} role - 角色值（'user' 或 'admin'）
 * @returns {string} 中文顯示文字
 */
export function getRoleDisplayText (role) {
  if (!role) return '編輯者'
  
  const roleMap = {
    user: '編輯者',
    admin: '管理員',
  }
  
  return roleMap[role] || role
}

/**
 * 取得所有角色選項（用於下拉選單）
 * @returns {Array} 角色選項陣列
 */
export function getRoleOptions () {
  return [
    { value: 'user', text: '編輯者' },
    { value: 'admin', text: '管理員' },
  ]
}
