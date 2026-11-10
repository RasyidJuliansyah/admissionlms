import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

import App from './App.vue'
import { router } from './router'

import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import './styles/main.css'

const vuetify = createVuetify({
  components,
  directives,
  icons: { defaultSet: 'mdi' },
})

createApp(App).use(createPinia()).use(router).use(vuetify).mount('#app')
