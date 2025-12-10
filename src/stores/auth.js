// Utilities
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabaseClient'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    session: null,
    loading: false,
    error: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    isAdmin: (state) => {
      if (!state.user) return false
      return state.user.user_metadata?.role === 'admin'
    },
  },

  actions: {
    /**
     * 初始化認證狀態（檢查現有 session）
     */
    async initAuth () {
      try {
        this.loading = true
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) throw error
        
        this.session = session
        this.user = session?.user ?? null
        
        // 監聽認證狀態變化
        supabase.auth.onAuthStateChange((_event, session) => {
          this.session = session
          this.user = session?.user ?? null
        })
      } catch (error) {
        console.error('初始化認證失敗:', error)
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    /**
     * 登入
     * @param {string} email - 電子郵件
     * @param {string} password - 密碼
     */
    async signIn (email, password) {
      try {
        this.loading = true
        this.error = null

        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })

        if (error) throw error

        this.session = data.session
        this.user = data.user

        return { success: true, user: data.user }
      } catch (error) {
        console.error('登入失敗:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    /**
     * 登出
     */
    async signOut () {
      try {
        this.loading = true
        this.error = null

        const { error } = await supabase.auth.signOut()

        if (error) throw error

        this.session = null
        this.user = null

        return { success: true }
      } catch (error) {
        console.error('登出失敗:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    /**
     * 註冊新用戶
     * @param {string} email - 電子郵件
     * @param {string} password - 密碼
     * @param {Object} metadata - 用戶元資料（可選）
     */
    async signUp (email, password, metadata = {}) {
      try {
        this.loading = true
        this.error = null

        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: metadata,
            emailRedirectTo: `${window.location.origin}/admin`,
          },
        })

        if (error) throw error

        return { success: true, user: data.user, needsEmailConfirmation: !data.session }
      } catch (error) {
        console.error('註冊失敗:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    /**
     * 重設密碼（發送重設密碼郵件）
     * @param {string} email - 電子郵件
     */
    async resetPassword (email) {
      try {
        this.loading = true
        this.error = null

        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          redirectTo: `${window.location.origin}/admin/reset-password`,
        })

        if (error) throw error

        return { success: true }
      } catch (error) {
        console.error('重設密碼失敗:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },
  },
})

