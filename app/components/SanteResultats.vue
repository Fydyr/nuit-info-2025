<script setup>
import { computed } from 'vue';

const props = defineProps({
  profil: Object
});

// Calcul de l'IMC
const imc = computed(() => {
  if (props.profil.taille && props.profil.poids) {
    const tailleM = props.profil.taille / 100;
    return (props.profil.poids / (tailleM * tailleM)).toFixed(1);
  }
  return 'N/A';
});

// Logique : Quel exercice IT pour quel profil ?
const contenu = computed(() => {
  const { sports, objectif } = props.profil;

  // CAS 1 : Force / Muscu (Tour PC)
  if (objectif === 'force' || sports.includes('musculation') || sports.includes('combat')) {
    return {
      titre: "Le 'Goblet Squat' Tour PC",
      instructions: [
        "Matériel : Une Tour PC (moyen tour ou grand tour).",
        "Prise : Serrez la tour contre votre poitrine.",
        "Mouvement : Descendez en squat (dos droit).",
        "Sécurité : Vérifiez que les câbles sont débranchés !",
        "Repetitions : 3 séries de 12."
      ],
      imageAlt: "Squat avec charge",
      emoji: "🖥️🦵",
      // Mapping Decathlon
      produitDecat: "Kettlebell",
      queryDecat: "kettlebell" 
    };
  }
  
  // CAS 2 : Épaules (Laptops)
  else if (sports.includes('natation') || sports.includes('escalade') || sports.includes('tennis')) {
    return {
      titre: "L'Élévation Latérale 'Dual Screen'",
      instructions: [
        "Matériel : Deux Laptops (ou deux écrans légers).",
        "Position : Debout, un laptop fermé dans chaque main.",
        "Mouvement : Levez les bras sur les côtés (ailes d'avion).",
        "Contrôle : Redescendez doucement.",
        "Focus : Renforcement des deltoïdes."
      ],
      imageAlt: "Élévations latérales",
      emoji: "💻🙆‍♂️",
      // Mapping Decathlon
      produitDecat: "Haltères Fitness",
      queryDecat: "halteres"
    };
  }

  // CAS 3 : Gainage (Clavier)
  else if (sports.includes('esport') || objectif === 'souplesse') {
    return {
      titre: "La Planche 'No-Touch Keyboard'",
      instructions: [
        "Matériel : Votre clavier mécanique.",
        "Position : En planche face au sol.",
        "Défi : Nez à 2cm de la touche 'Espace' sans toucher.",
        "Durée : Tenez tant que la mise à jour Windows tourne.",
        "Bénéfice : Ceinture abdominale en béton."
      ],
      imageAlt: "Gainage planche",
      emoji: "⌨️💪",
      // Mapping Decathlon
      produitDecat: "Tapis de Yoga Confort",
      queryDecat: "tapis+yoga"
    };
  }

  // CAS PAR DÉFAUT : Dips (Chaise)
  else {
    return {
      titre: "Les Dips sur Chaise Gaming",
      instructions: [
        "Matériel : Une chaise de bureau (calée contre un mur !).",
        "Position : Mains sur le bord, jambes tendues.",
        "Mouvement : Fléchissez les bras.",
        "Remontée : Poussez fort (git push --force).",
        "Cible : Triceps et Pectoraux."
      ],
      imageAlt: "Dips musculation",
      emoji: "🪑🔥",
      // Mapping Decathlon
      produitDecat: "Sangles de suspension (DST)",
      queryDecat: "sangles+suspension"
    };
  }
});

// NIVEAU 4 : Fonction qui génère le lien Decathlon
// C'est l'équivalent moderne et Vue.js de la fonction toJson fournie
const lienDecathlon = computed(() => {
  const baseUrl = "https://www.decathlon.fr/search?Ntt=";
  const keyword = contenu.value.queryDecat;
  
  // On encode l'URL proprement comme demandé dans la logique JS
  return baseUrl + encodeURIComponent(keyword);
});

</script>

<template>
  <div class="etape-container">
    <h3>🛠️ Votre Programme "Hardware Training"</h3>
    
    <div class="profil-recap">
      <strong>Données :</strong> {{ profil.taille }}cm / {{ profil.poids }}kg (IMC: {{ imc }}) <br>
      <strong>Sports :</strong> {{ profil.sports.join(', ') }}
    </div>

    <div class="resultat-card">
      <h4>{{ contenu.titre }}</h4>
      
      <div class="illustration-zone">
        <span class="gros-emoji">{{ contenu.emoji }}</span>
        <p class="legende">Visualisation : {{ contenu.imageAlt }}</p>
      </div>

      <div class="instructions-bloc">
        <h5>Algorithme du mouvement :</h5>
        <ul>
          <li v-for="(instruction, index) in contenu.instructions" :key="index">
            > {{ instruction }}
          </li>
        </ul>
      </div>

      <div class="decathlon-box">
        <div class="deca-logo">DECATHLON <span class="partner-badge">PARTNER</span></div>
        <p>Pas envie d'abîmer votre matériel informatique ?</p>
        <p>Utilisez plutôt : <strong>{{ contenu.produitDecat }}</strong></p>
        
        <a :href="lienDecathlon" target="_blank" class="btn-decathlon">
          Acheter {{ contenu.produitDecat }} 🛒
        </a>
      </div>
      
      <button @click="$emit('reset')" class="btn-reset">↺ Reboot (Refaire le profil)</button>
    </div>
  </div>
</template>

<style scoped>
.profil-recap { background: #2c3e50; color: #fff; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 0.85rem; text-align: left;}
.resultat-card { background: #fff; padding: 20px; border-radius: 8px; border: 2px solid #2c3e50; box-shadow: 5px 5px 0px rgba(0,0,0,0.1); }
.illustration-zone { background: #f0f4c3; border: 2px dashed #afb42b; padding: 20px; text-align: center; border-radius: 8px; margin-bottom: 15px; }
.gros-emoji { font-size: 4rem; display: block; margin-bottom: 5px; }

.instructions-bloc h5 { margin: 0 0 10px 0; font-family: 'Courier New', monospace; font-weight: bold; }
.instructions-bloc ul { text-align: left; padding-left: 0; list-style: none; font-family: 'Courier New', monospace; color: #333; }
.instructions-bloc li { margin-bottom: 8px; padding-left: 10px; border-left: 3px solid #42b983; background: #f1f1f1; padding: 5px; }

/* Styles pour le Niveau 4 - Decathlon */
.decathlon-box {
  margin-top: 20px;
  background-color: #0082c3; /* Bleu Decathlon */
  color: white;
  padding: 15px;
  border-radius: 5px;
  text-align: center;
}
.deca-logo { font-weight: 900; font-style: italic; font-size: 1.2rem; margin-bottom: 10px; letter-spacing: 1px; }
.partner-badge { background: white; color: #0082c3; font-size: 0.6rem; padding: 2px 5px; border-radius: 3px; vertical-align: middle; font-style: normal; margin-left: 5px; }
.decathlon-box p { margin: 5px 0; font-size: 0.9rem; }

.btn-decathlon {
  display: inline-block;
  margin-top: 10px;
  background: #ffea28; /* Jaune Decathlon */
  color: #333;
  font-weight: bold;
  text-decoration: none;
  padding: 10px 20px;
  border-radius: 3px;
  transition: transform 0.2s;
}
.btn-decathlon:hover { transform: scale(1.05); }

.btn-reset { margin-top: 20px; background: #e74c3c; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%;}
.btn-reset:hover { background: #c0392b; }
</style>