<script setup>
import { ref } from 'vue';

const isPanelOpen = ref(false);

function togglePanel() {
  isPanelOpen.value = !isPanelOpen.value;
}
</script>

<template>
  <div class="page-wrapper">
    <HiddenSnakeComponent />

    <div class="main-content">
      <contentComponent />
    </div>
    <ChatbotComponent></ChatbotComponent>

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

.page-wrapper {
  position: relative;
  padding-right: 40px; /* Add padding to prevent content from hiding under the collapsed panel's button */
  transition: padding-right 0.3s ease-in-out;
}

.side-panel {
  position: fixed;
  top: 0;
  right: 0;
  height: 100vh;
  width: 350px;
  background-color: #f8f9fa;
  box-shadow: -2px 0 5px rgba(0,0,0,0.1);
  transform: translateX(100%); /* Hide panel completely off-screen */
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
