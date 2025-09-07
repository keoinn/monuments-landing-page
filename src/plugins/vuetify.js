/**
 * plugins/vuetify.js
 *
 * Framework documentation: https://vuetifyjs.com`
 */

// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Composables
import { createVuetify } from 'vuetify'

// https://vuetifyjs.com/en/introduction/why-vuetify/#feature-guides
export default createVuetify({
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#2E1065', // 深紫羅蘭色
          secondary: '#4A148C', // 極深紫羅蘭色
          accent: '#6A1B9A', // 深紫羅蘭色
          error: '#f44336',
          warning: '#ff9800',
          info: '#2196f3',
          success: '#4caf50',
        },
      },
    },
  },
  icons: {
    defaultSet: 'mdi',
    sets: {
      mdi: {
        component: 'mdi',
      },
    },
  },
})
