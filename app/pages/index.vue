<script setup>
import { ref } from 'vue';
// Importation des composants que nous venons de créer
import SanteFormulaire from '../components/SanteFormulaire.vue';
import SanteResultats from '../components/SanteResultats.vue';

// État du widget
const etape = ref(1); // 1 = Quiz, 2 = Résultats
const profilUtilisateur = ref(null);

// Fonction appelée quand le formulaire (Niveau 1) est validé
const traiterProfil = (donneesProfil) => {
  profilUtilisateur.value = donneesProfil;
  etape.value = 2; // On passe à l'affichage des résultats
};

// Fonction pour recommencer
const recommencer = () => {
  profilUtilisateur.value = null;
  etape.value = 1;
};
</script>

<template>
  <div class="page-container">
    <h1>Défi : CTO de Votre Santé Posturale</h1>
    
    <div class="widget-sante">
      
      <div class="widget-header">
        <h2>Prévention des Blessures</h2>
        <span class="badge">Mode: {{ etape === 1 ? 'Profilage' : 'Conseils' }}</span>
      </div>

      <div class="widget-content">
        <SanteFormulaire 
          v-if="etape === 1" 
          @profil-valide="traiterProfil" 
        />

        <SanteResultats 
          v-else 
          :profil="profilUtilisateur" 
          @reset="recommencer" 
        />
      </div>

    </div>
  </div>
</template>

<style>
/* Style global de la page */
.page-container {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  text-align: center;
}

/* Style du Widget (Cadre) */
.widget-sante {
  border: 2px solid #2c3e50;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  margin-top: 30px;
  background-color: white;
}

.widget-header {
  background-color: #2c3e50;
  color: white;
  padding: 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.widget-header h2 { margin: 0; font-size: 1.2rem; }

.badge {
  background-color: #e74c3c;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.widget-content { padding: 25px; }
</style>