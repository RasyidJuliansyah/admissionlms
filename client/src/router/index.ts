import { createRouter, createWebHistory } from 'vue-router'

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'beranda',
      component: () => import('@/pages/BerandaPage.vue'),
    },
  ],
})
