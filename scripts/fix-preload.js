#!/usr/bin/env node

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// 讀取 dist/index.html
const indexPath = path.join(__dirname, '../dist/index.html')

if (fs.existsSync(indexPath)) {
  let html = fs.readFileSync(indexPath, 'utf8')

  // 移除有問題的 preload 標籤（只移除沒有正確 as 屬性的）
  html = html.replace(/<link[^>]*rel="preload"[^>]*materialdesignicons[^>]*(?!as=)[^>]*>/gi, '')

  // 移除空的 type 屬性
  html = html.replace(/type=""/g, '')
  html = html.replace(/type=''/g, '')

  // 確保 Material Design Icons 字體正確載入
  if (!html.includes('@mdi/font/css/materialdesignicons.css')) {
    console.log('⚠️  Material Design Icons CSS 未找到')
  }

  // 寫回檔案
  fs.writeFileSync(indexPath, html)

  console.log('✅ 已修正 preload 標籤問題')
} else {
  console.log('❌ dist/index.html 不存在')
}
