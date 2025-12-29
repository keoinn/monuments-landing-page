<template>
  <v-footer
    app
    height="40"
  >
    <a
      v-for="item in items"
      :key="item.title"
      class="d-inline-block mx-2 social-link text-decoration-none"
      :href="item.href"
      rel="noopener noreferrer"
      target="_blank"
      :title="item.title"
    >
      <v-icon
        class="mr-1"
        :icon="item.icon"
        size="24"
      />
      <span class="social-link-text">{{ item.title }}</span>
    </a>

    <div
      class="text-caption text-disabled"
      style="position: absolute; right: 16px;"
    >
      &copy; 2024-{{ (new Date()).getFullYear() }} <span class="d-none d-sm-inline-block">Yavik Tech</span>
      —
      <a
        class="text-decoration-none on-surface"
        href="https://vuetifyjs.com/about/licensing/"
        rel="noopener noreferrer"
        target="_blank"
      >
        MIT License
      </a>
    </div>
  </v-footer>
</template>

<script setup>
  const items = ref([
    {
      title: '青錢萬選-萬選居',
      icon: `mdi-facebook`,
      href: 'https://www.facebook.com/profile.php?id=100064501097860',
    },
  ])
  const _items_dev = ref([
    {
      title: 'Vuetify Documentation',
      icon: `$vuetify`,
      href: 'https://vuetifyjs.com/',
    },
    {
      title: 'Vuetify Support',
      icon: 'mdi-shield-star-outline',
      href: 'https://support.vuetifyjs.com/',
    },
    {
      title: 'Vuetify X',
      icon: ['M2.04875 3.00002L9.77052 13.3248L1.99998 21.7192H3.74882L10.5519 14.3697L16.0486 21.7192H22L13.8437 10.8137L21.0765 3.00002H19.3277L13.0624 9.76874L8.0001 3.00002H2.04875ZM4.62054 4.28821H7.35461L19.4278 20.4308H16.6937L4.62054 4.28821Z'],
      href: 'https://x.com/vuetifyjs',
    },
    {
      title: 'Vuetify GitHub',
      icon: `mdi-github`,
      href: 'https://github.com/vuetifyjs/vuetify',
    },
    {
      title: 'Vuetify Discord',
      icon: ['M22,24L16.75,19L17.38,21H4.5A2.5,2.5 0 0,1 2,18.5V3.5A2.5,2.5 0 0,1 4.5,1H19.5A2.5,2.5 0 0,1 22,3.5V24M12,6.8C9.32,6.8 7.44,7.95 7.44,7.95C8.47,7.03 10.27,6.5 10.27,6.5L10.1,6.33C8.41,6.36 6.88,7.53 6.88,7.53C5.16,11.12 5.27,14.22 5.27,14.22C6.67,16.03 8.75,15.9 8.75,15.9L9.46,15C8.21,14.73 7.42,13.62 7.42,13.62C7.42,13.62 9.3,14.9 12,14.9C14.7,14.9 16.58,13.62 16.58,13.62C16.58,13.62 15.79,14.73 14.54,15L15.25,15.9C15.25,15.9 17.33,16.03 18.73,14.22C18.73,14.22 18.84,11.12 17.12,7.53C17.12,7.53 15.59,6.36 13.9,6.33L13.73,6.5C13.73,6.5 15.53,7.03 16.56,7.95C16.56,7.95 14.68,6.8 12,6.8M9.93,10.59C10.58,10.59 11.11,11.16 11.1,11.86C11.1,12.55 10.58,13.13 9.93,13.13C9.29,13.13 8.77,12.55 8.77,11.86C8.77,11.16 9.28,10.59 9.93,10.59M14.1,10.59C14.75,10.59 15.27,11.16 15.27,11.86C15.27,12.55 14.75,13.13 14.1,13.13C13.46,13.13 12.94,12.55 12.94,11.86C12.94,11.16 13.45,10.59 14.1,10.59Z'],
      href: 'https://community.vuetifyjs.com/',
    },
    {
      title: 'Vuetify Reddit',
      icon: `mdi-reddit`,
      href: 'https://reddit.com/r/vuetifyjs',
    },
  ])
</script>
<style scoped lang="sass">
  .social-link
    color: #1976d2
    text-decoration: none
    transition: .2s ease-in-out

    &:hover
      color: #1565c0
      text-decoration: none

    :deep(.v-icon)
      color: #1976d2
      transition: .2s ease-in-out

    &:hover :deep(.v-icon)
      color: #1565c0

  .social-link-text
    font-size: 16px
    color: #1976d2
    transition: .2s ease-in-out

  .social-link:hover .social-link-text
    color: #1565c0
</style>
