<script setup>
  import { ref, watch, onMounted } from 'vue'
  import { QuillEditor } from '@vueup/vue-quill'
  import '@vueup/vue-quill/dist/vue-quill.snow.css'

  const props = defineProps({
    modelValue: {
      type: String,
      default: '',
    },
    placeholder: {
      type: String,
      default: '請輸入內容...',
    },
    height: {
      type: String,
      default: '400px',
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  })

  const emit = defineEmits(['update:modelValue', 'change'])

  const editorContent = ref(props.modelValue)

  // 監聽外部 modelValue 變化
  watch(() => props.modelValue, (newValue) => {
    if (newValue !== editorContent.value) {
      editorContent.value = newValue
    }
  })

  // 監聽編輯器內容變化
  watch(editorContent, (newValue) => {
    emit('update:modelValue', newValue)
    emit('change', newValue)
  })

  // Quill 編輯器配置
  const editorOptions = {
    theme: 'snow',
    modules: {
      toolbar: [
        [{ header: [1, 2, 3, 4, 5, 6, false] }],
        [{ font: [] }],
        [{ size: [] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ color: [] }, { background: [] }],
        [{ script: 'sub' }, { script: 'super' }],
        [{ list: 'ordered' }, { list: 'bullet' }],
        [{ indent: '-1' }, { indent: '+1' }],
        [{ direction: 'rtl' }],
        [{ align: [] }],
        ['link', 'image', 'video'],
        ['blockquote', 'code-block'],
        ['clean'],
      ],
    },
    placeholder: props.placeholder,
  }

  // 獲取純文字內容（不含 HTML 標籤）
  function getText () {
    return editorContent.value.replace(/<[^>]*>/g, '').trim()
  }

  // 獲取 HTML 內容
  function getHTML () {
    return editorContent.value
  }

  // 清空內容
  function clear () {
    editorContent.value = ''
  }

  // 設置內容
  function setContent (content) {
    editorContent.value = content
  }

  // 暴露方法給父組件
  defineExpose({
    getText,
    getHTML,
    clear,
    setContent,
  })
</script>

<template>
  <div class="rich-text-editor">
    <QuillEditor
      v-model:content="editorContent"
      :options="editorOptions"
      :disabled="disabled"
      content-type="html"
      :style="{ height: height }"
      class="quill-editor"
    />
  </div>
</template>

<style scoped lang="scss">
.rich-text-editor {
  width: 100%;

  :deep(.quill-editor) {
    .ql-container {
      font-family: 'Noto Sans TC', 'Roboto', sans-serif;
      font-size: 16px;
      line-height: 1.6;
    }

    .ql-editor {
      min-height: v-bind(height);
      padding: 16px;
    }

    .ql-toolbar {
      border-top-left-radius: 4px;
      border-top-right-radius: 4px;
      border-bottom: 1px solid rgba(0, 0, 0, 0.12);
      padding: 12px;
      background-color: #fafafa;
    }

    .ql-container {
      border-bottom-left-radius: 4px;
      border-bottom-right-radius: 4px;
    }

    // 確保編輯器在禁用狀態下的樣式
    &.ql-disabled {
      .ql-editor {
        background-color: rgba(0, 0, 0, 0.05);
        cursor: not-allowed;
      }
    }
  }
}
</style>
