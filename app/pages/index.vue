<script setup>
import SanteWidget from '../components/SanteWidget.vue';
</script>

<template>
  <div class="page-container">
    <h1>Défi : CTO de Votre Santé Posturale</h1>
    
    <SanteWidget />
    
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
    <contentComponent></contentComponent>
    <footerComponent></footerComponent>
    <div>
        <HiddenSnakeComponent />
    </div>
</template>
