<script setup>
  import { ref, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import RichTextEditor from '@/components/RichTextEditor.vue'

  // 使用 admin layout
  defineOptions({
    layout: 'admin',
  })

  const router = useRouter()
  const authStore = useAuthStore()

  // 編輯器內容
  const editorContent = ref('')
  const editorRef = ref(null)

  // 預設內容（用於測試）
  const defaultContent = `
    <h1>歡迎使用富文本編輯器</h1>
    <p>這是一個功能完整的富文本編輯器，支援以下功能：</p>
    <ul>
      <li><strong>文字格式</strong>：粗體、斜體、底線、刪除線</li>
      <li><strong>標題</strong>：H1 到 H6</li>
      <li><strong>列表</strong>：有序列表和無序列表</li>
      <li><strong>對齊</strong>：左對齊、居中、右對齊</li>
      <li><strong>連結和圖片</strong>：插入連結和圖片</li>
      <li><strong>顏色</strong>：文字顏色和背景顏色</li>
    </ul>
    <p>請在下方編輯器中進行測試！</p>
    <blockquote>
      <p>這是一個引用區塊的範例。</p>
    </blockquote>
  `

  // 載入預設內容
  function loadDefaultContent () {
    editorContent.value = defaultContent
  }

  // 清空內容
  function clearContent () {
    if (editorRef.value) {
      editorRef.value.clear()
    }
  }

  // 獲取純文字
  function getTextContent () {
    if (editorRef.value) {
      const text = editorRef.value.getText()
      alert(`純文字內容：\n\n${text}`)
    }
  }

  // 獲取 HTML
  function getHTMLContent () {
    if (editorRef.value) {
      const html = editorRef.value.getHTML()
      alert(`HTML 內容：\n\n${html}`)
    }
  }

  // 複製 HTML 到剪貼板
  async function copyHTML () {
    if (editorRef.value) {
      const html = editorRef.value.getHTML()
      try {
        await navigator.clipboard.writeText(html)
        alert('HTML 內容已複製到剪貼板！')
      } catch (err) {
        console.error('複製失敗:', err)
        alert('複製失敗，請手動複製')
      }
    }
  }

  // 元件掛載時初始化認證（路由守衛已經處理了認證檢查）
  onMounted(async () => {
    // 路由守衛已經處理了認證檢查，這裡只需要確保認證狀態已初始化
    if (!authStore.user && !authStore.loading) {
      await authStore.initAuth()
    }
  })
</script>

<template>
  <v-container class="py-8">
    <!-- 頁面標題 -->
    <div class="d-flex align-center justify-space-between mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          富文本編輯器測試
        </h1>
        <p class="text-body-2 text-medium-emphasis">
          測試 RichTextEditor 組件的各項功能
        </p>
      </div>
      <v-btn
        color="primary"
        prepend-icon="mdi-arrow-left"
        variant="outlined"
        @click="router.push('/admin')"
      >
        返回管理後台
      </v-btn>
    </div>

    <!-- 操作按鈕 -->
    <v-card class="mb-4" elevation="2">
      <v-card-text>
        <div class="d-flex flex-wrap gap-2">
          <v-btn
            color="primary"
            prepend-icon="mdi-content-save"
            @click="loadDefaultContent"
          >
            載入預設內容
          </v-btn>
          <v-btn
            color="warning"
            prepend-icon="mdi-eraser"
            @click="clearContent"
          >
            清空內容
          </v-btn>
          <v-btn
            color="info"
            prepend-icon="mdi-text"
            @click="getTextContent"
          >
            獲取純文字
          </v-btn>
          <v-btn
            color="info"
            prepend-icon="mdi-code-tags"
            @click="getHTMLContent"
          >
            獲取 HTML
          </v-btn>
          <v-btn
            color="success"
            prepend-icon="mdi-content-copy"
            @click="copyHTML"
          >
            複製 HTML
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <!-- 編輯器 -->
    <v-card elevation="2">
      <v-card-title class="d-flex align-center">
        <v-icon class="mr-2" icon="mdi-text-box" />
        富文本編輯器
      </v-card-title>
      <v-divider />
      <v-card-text class="pa-4">
        <RichTextEditor
          ref="editorRef"
          v-model="editorContent"
          placeholder="請在此輸入內容..."
          height="500px"
        />
      </v-card-text>
    </v-card>

    <!-- 內容預覽 -->
    <v-card class="mt-4" elevation="2">
      <v-card-title class="d-flex align-center">
        <v-icon class="mr-2" icon="mdi-eye" />
        內容預覽
      </v-card-title>
      <v-divider />
      <v-card-text class="pa-4">
        <div
          v-if="editorContent"
          class="content-preview"
          v-html="editorContent"
        />
        <div
          v-else
          class="text-medium-emphasis text-center py-8"
        >
          目前沒有內容，請在編輯器中輸入內容
        </div>
      </v-card-text>
    </v-card>

    <!-- HTML 原始碼顯示 -->
    <v-card class="mt-4" elevation="2">
      <v-card-title class="d-flex align-center">
        <v-icon class="mr-2" icon="mdi-code-braces" />
        HTML 原始碼
      </v-card-title>
      <v-divider />
      <v-card-text class="pa-4">
        <v-textarea
          :model-value="editorContent"
          readonly
          variant="outlined"
          rows="10"
          class="font-monospace"
          style="font-family: 'Courier New', monospace; font-size: 12px;"
        />
      </v-card-text>
    </v-card>

    <!-- 統計資訊 -->
    <v-card class="mt-4" elevation="2">
      <v-card-title class="d-flex align-center">
        <v-icon class="mr-2" icon="mdi-information" />
        統計資訊
      </v-card-title>
      <v-divider />
      <v-card-text>
        <v-row>
          <v-col cols="12" md="4">
            <div class="text-caption text-medium-emphasis mb-1">
              字元數（含 HTML）
            </div>
            <div class="text-h6">
              {{ editorContent.length }}
            </div>
          </v-col>
          <v-col cols="12" md="4">
            <div class="text-caption text-medium-emphasis mb-1">
              純文字字元數
            </div>
            <div class="text-h6">
              {{ editorContent.replace(/<[^>]*>/g, '').length }}
            </div>
          </v-col>
          <v-col cols="12" md="4">
            <div class="text-caption text-medium-emphasis mb-1">
              是否為空
            </div>
            <div class="text-h6">
              <v-chip
                :color="editorContent.trim() ? 'success' : 'error'"
                size="small"
                variant="tonal"
              >
                {{ editorContent.trim() ? '否' : '是' }}
              </v-chip>
            </div>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<style scoped lang="scss">
.content-preview {
  min-height: 100px;
  padding: 16px;
  border: 1px solid rgba(0, 0, 0, 0.12);
  border-radius: 4px;
  background-color: #fafafa;

  // 確保預覽內容的樣式正確
  :deep(h1),
  :deep(h2),
  :deep(h3),
  :deep(h4),
  :deep(h5),
  :deep(h6) {
    margin-top: 1em;
    margin-bottom: 0.5em;
    font-weight: bold;
  }

  :deep(p) {
    margin-bottom: 1em;
    line-height: 1.6;
  }

  :deep(ul),
  :deep(ol) {
    margin-left: 2em;
    margin-bottom: 1em;
  }

  :deep(li) {
    margin-bottom: 0.5em;
  }

  :deep(blockquote) {
    border-left: 4px solid #1976d2;
    padding-left: 16px;
    margin: 16px 0;
    color: #666;
    font-style: italic;
  }

  :deep(img) {
    max-width: 100%;
    height: auto;
    border-radius: 4px;
    margin: 16px 0;
  }

  :deep(a) {
    color: #1976d2;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
