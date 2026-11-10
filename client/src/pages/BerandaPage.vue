<script setup lang="ts">
import { onMounted, ref } from 'vue'

const status = ref<string>('memeriksa...')
const versi = ref<string>('-')

onMounted(async () => {
  try {
    const res = await fetch('/api/health')
    const data = await res.json()
    status.value = data.status
    versi.value = data.version ?? '-'
  } catch {
    status.value = 'backend tidak terjangkau'
  }
})
</script>

<template>
  <v-container class="py-12">
    <v-card max-width="480" class="mx-auto">
      <v-card-title>AdmissionLMS</v-card-title>
      <v-card-text>
        <div class="flex justify-between">
          <span>Status backend</span>
          <strong>{{ status }}</strong>
        </div>
        <div class="flex justify-between">
          <span>Versi image</span>
          <strong>{{ versi }}</strong>
        </div>
      </v-card-text>
    </v-card>
  </v-container>
</template>
