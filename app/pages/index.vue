<script setup>
import { ref } from 'vue';
import SanteWidget from '../components/SanteWidget.vue';
import contentComponent from '../components/chatbotComponent.vue';
import HiddenSnakeComponent from '../components/HiddenSnakeComponent.vue';

const isPanelOpen = ref(false);

function togglePanel() {
  isPanelOpen.value = !isPanelOpen.value;
}
</script>

<template>
  <div>
    <contentComponent />
    <HiddenSnakeComponent />

    <div class="side-panel" :class="{ 'is-open': isPanelOpen }">
      <button @click="togglePanel" class="panel-toggle">
        <span v-if="isPanelOpen">&gt;</span>
        <span v-else>&lt;</span>
      </button>
      <div class="panel-content">
        <h1>Défi : CTO de Votre Santé Posturale</h1>
        <SanteWidget />
      </div>
    </div>
    <FooterComponent />
  </div>
</template>
<style>
/* Style global de la page */
.page-container { /* This class is no longer used in the template, but I'll leave it in case other parts of your app use it. */
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  padding: 20px;
  text-align: center;
}

.side-panel {
  position: fixed;
  top: 0;
  right: 0;
  height: 100vh;
  width: 350px;
  background-color: #f8f9fa;
  box-shadow: -2px 0 5px rgba(0,0,0,0.1);
  transform: translateX(100%);
  transition: transform 0.3s ease-in-out;
  z-index: 1000;
}

.side-panel.is-open {
  transform: translateX(0);
}

.panel-content {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  padding: 20px;
  text-align: center;
  height: 100%;
  overflow-y: auto;
}

.panel-toggle {
  position: absolute;
  top: 50%;
  left: -30px; /* Position it just outside the panel */
  transform: translateY(-50%);
  width: 30px;
  height: 60px;
  background-color: #007bff;
  color: white;
  border: none;
  cursor: pointer;
  border-radius: 5px 0 0 5px;
  font-size: 20px;
  line-height: 60px;
}
</style>
