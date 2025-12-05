<script setup>
import SanteWidget from '../components/SanteWidget.vue';
import contentComponent from '../components/chatbotComponent.vue';
import HiddenSnakeComponent from '../components/HiddenSnakeComponent.vue';
</script>

<template>
  <div>
    <HiddenSnakeComponent />
    <contentComponent />
    <div class="page-container">
      <h1>Défi : CTO de Votre Santé Posturale</h1>
      
      <SanteWidget />
      
    </div>
  </div>
</template>
<style>
/* Style global de la page */
.page-container {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  padding: 20px;
  text-align: center;
}
</style>
