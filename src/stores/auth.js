// Utilities
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabaseClient'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    session: null,
    userMetaInfo: null, // 儲存 user_meta_info 的完整資料
    loading: false,
    error: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    isAdmin: (state) => {
      if (!state.userMetaInfo) return false
      return state.userMetaInfo.role === 'admin'
    },
    userName: (state) => {
      // 優先使用 user_meta_info 的 full_name，其次使用 user_metadata.name，最後使用 email 前綴
      if (state.userMetaInfo?.full_name) {
        return state.userMetaInfo.full_name
      }
      if (state.user?.user_metadata?.name) {
        return state.user.user_metadata.name
      }
      if (state.user?.email) {
        return state.user.email.split('@')[0]
      }
      return '用戶'
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

        // 如果有 user，載入 user_meta_info
        if (this.user) {
          await this.loadUserMetaInfo(this.user)
        } else {
          this.userMetaInfo = null
        }
        
        // 監聽認證狀態變化
        supabase.auth.onAuthStateChange(async (_event, session) => {
          this.session = session
          this.user = session?.user ?? null

          // 當認證狀態變化時，同步載入 user_meta_info
          if (this.user) {
            await this.loadUserMetaInfo(this.user)
          } else {
            this.userMetaInfo = null
          }
        })
      } catch (error) {
        console.error('初始化認證失敗:', error)
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    /**
     * 載入並確保 user_meta_info 中有對應的使用者資料
     * - 若不存在，會自動以預設值建立一筆（full_name 預設空字串，role 預設 'user'）
     * - 載入後會將資料存到 store 的 userMetaInfo
     */
    async loadUserMetaInfo (user) {
      if (!user) {
        this.userMetaInfo = null
        return
      }

      try {
        // 先查詢是否已存在
        const { data, error } = await supabase
          .from('user_meta_info')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle()

        if (error) {
          console.error('查詢 user_meta_info 失敗:', error)
          this.userMetaInfo = null
          return
        }

        // 如果不存在，建立一筆預設資料
        if (!data) {
          const fullName = user.user_metadata?.name || user.email?.split('@')[0] || ''

          const { data: newData, error: insertError } = await supabase
            .from('user_meta_info')
            .insert({
              user_id: user.id,
              full_name: fullName,
              role: 'user',
            })
            .select()
            .single()

          if (insertError) {
            console.error('建立 user_meta_info 失敗:', insertError)
            this.userMetaInfo = null
            return
          }

          // 將新建立的資料存到 store
          this.userMetaInfo = newData
        } else {
          // 將查詢到的資料存到 store
          this.userMetaInfo = data
        }
      } catch (error) {
        console.error('loadUserMetaInfo 執行失敗:', error)
        this.userMetaInfo = null
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

        // 載入 user_meta_info 並存到 store
        await this.loadUserMetaInfo(data.user)

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
        this.userMetaInfo = null

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

        // 註冊成功後，如果有回傳 user，載入並建立對應的 meta_info
        if (data.user) {
          await this.loadUserMetaInfo(data.user)
        }

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

