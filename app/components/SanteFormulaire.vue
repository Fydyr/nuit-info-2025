<script setup>
import { ref } from 'vue';

const emit = defineEmits(['profil-valide']);

const profil = ref({
  niveau: '',
  sports: [],
  objectif: '',
  // Nouvelles données
  taille: null,
  poids: null,
  age: null
});

const validerProfil = () => {
  // Validation plus stricte incluant les nouvelles données
  if (
    profil.value.niveau && 
    profil.value.objectif && 
    profil.value.sports.length > 0 &&
    profil.value.taille &&
    profil.value.poids
  ) {
    emit('profil-valide', profil.value);
  } else {
    alert("Veuillez remplir toutes les données (y compris taille et poids) !");
  }
};
</script>

<template>
  <div class="etape-container">
    <h3>📝 Niveau 1 : Profil & Hardware Humain</h3>
    <p class="intro">Calibrons vos données biométriques avant l'overclocking.</p>

    <form @submit.prevent="validerProfil">
      
      <div class="question-bloc">
        <label class="question-label">1. Données Système (Biométrie)</label>
        <div class="inputs-grid">
          <div class="input-wrapper">
            <label>Taille (cm)</label>
            <input type="number" v-model="profil.taille" placeholder="175" min="100" max="250">
          </div>
          <div class="input-wrapper">
            <label>Poids (kg)</label>
            <input type="number" v-model="profil.poids" placeholder="70" min="30" max="200">
          </div>
          <div class="input-wrapper">
            <label>Âge (ans)</label>
            <input type="number" v-model="profil.age" placeholder="20" min="10" max="99">
          </div>
        </div>
      </div>

      <div class="question-bloc">
        <label class="question-label">2. Niveau de charge actuel</label>
        <div class="choix-grid">
          <label class="radio-card">
            <input type="radio" value="debutant" v-model="profil.niveau">
            <span>Mode Éco (Débutant)</span>
          </label>
          <label class="radio-card">
            <input type="radio" value="intermediaire" v-model="profil.niveau">
            <span>Usage Normal (Actif)</span>
          </label>
          <label class="radio-card">
            <input type="radio" value="avance" v-model="profil.niveau">
            <span>Mode Turbo (Sportif)</span>
          </label>
        </div>
      </div>

      <div class="question-bloc">
        <label class="question-label">3. Vos drivers installés (Sports)</label>
        <div class="checkbox-group">
          <label><input type="checkbox" value="natation" v-model="profil.sports"> Natation 🏊</label>
          <label><input type="checkbox" value="escalade" v-model="profil.sports"> Escalade 🧗</label>
          <label><input type="checkbox" value="course" v-model="profil.sports"> Running / Trail 🏃</label>
          <label><input type="checkbox" value="musculation" v-model="profil.sports"> Musculation 🏋️</label>
          <label><input type="checkbox" value="tennis" v-model="profil.sports"> Tennis / Badminton 🎾</label>
          <label><input type="checkbox" value="combat" v-model="profil.sports"> Sports de combat 🥋</label>
          <label><input type="checkbox" value="esport" v-model="profil.sports"> E-Sport / Gaming 🎮</label>
        </div>
      </div>

      <div class="question-bloc">
        <label class="question-label">4. Objectif de la mise à jour</label>
        <select v-model="profil.objectif" class="full-select">
          <option disabled value="">-- Sélectionnez --</option>
          <option value="force">Performance (Gagner en puissance)</option>
          <option value="souplesse">Maintenance (Réduire les bugs/douleurs)</option>
          <option value="endurance">Refroidissement (Cardio & Endurance)</option>
        </select>
      </div>

      <button type="submit" class="btn-action">Compiler le Programme</button>
    </form>
  </div>
</template>

<style scoped>
.intro { color: #666; font-size: 0.9rem; margin-bottom: 20px; }
.question-bloc { margin-bottom: 20px; text-align: left; border-bottom: 1px solid #eee; padding-bottom: 15px; }
.question-label { display: block; margin-bottom: 10px; font-weight: bold; color: #2c3e50; }

/* Styles Inputs Biométrie */
.inputs-grid { display: flex; gap: 15px; }
.input-wrapper { flex: 1; }
.input-wrapper label { display: block; font-size: 0.8rem; color: #666; margin-bottom: 5px; }
.input-wrapper input { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }

/* Reste des styles identiques... */
.choix-grid { display: flex; gap: 10px; flex-wrap: wrap; }
.radio-card { flex: 1; border: 1px solid #ddd; padding: 10px; border-radius: 5px; cursor: pointer; text-align: center; font-size: 0.8rem; transition: all 0.2s; display: flex; align-items: center; justify-content: center;}
.radio-card:hover { background: #f0fdf4; border-color: #42b983; }
.checkbox-group { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.full-select { width: 100%; padding: 10px; border-radius: 5px; border: 1px solid #ccc; }
.btn-action { background-color: #42b983; color: white; padding: 12px 20px; border: none; border-radius: 5px; cursor: pointer; width: 100%; font-size: 1rem; font-weight: bold; margin-top: 10px; }
.btn-action:hover { background-color: #3aa876; }
</style>