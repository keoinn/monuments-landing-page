<script setup>
  import { onMounted, ref } from 'vue'
  import { supabase } from '@/lib/supabaseClient'

  const instruments = ref([])

  async function getInstruments () {
    const { data } = await supabase.from('instruments').select()
    instruments.value = data
    console.log(data)
  }

  onMounted(() => {
    getInstruments()
  })
</script>

<template>
  <ul>
    <li v-for="instrument in instruments" :key="instrument.id">
      {{ instrument.name }}
    </li>
  </ul>
</template>
