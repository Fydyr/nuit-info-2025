<template>
  <div class="hidden-snake-container">
    <!-- Petit snake caché en haut à gauche -->
    <div
      class="hidden-snake"
      :class="{ 'peek': isPeeking }"
      @click="openSnakeGame"
    >
      <svg
        width="80"
        height="80"
        viewBox="0 0 80 80"
        xmlns="http://www.w3.org/2000/svg"
        class="snake-svg"
      >
        <!-- Tête du snake -->
        <rect x="20" y="20" width="20" height="20" fill="#00ff88" class="snake-head" />

        <!-- Yeux -->
        <rect x="24" y="24" width="4" height="4" fill="#ffffff" />
        <rect x="32" y="24" width="4" height="4" fill="#ffffff" />

        <!-- Pupilles -->
        <rect x="26" y="26" width="2" height="2" fill="#000000" />
        <rect x="34" y="26" width="2" height="2" fill="#000000" />

        <!-- Langue (qui sort quand le snake peek) -->
        <rect x="40" y="28" width="8" height="2" fill="#ff0000" class="tongue" />

        <!-- Corps du snake (segments qui sortent progressivement) -->
        <rect x="0" y="20" width="20" height="20" fill="#00cc66" class="snake-body segment-1" />
        <rect x="-20" y="20" width="20" height="20" fill="#00aa55" class="snake-body segment-2" />
        <rect x="-40" y="20" width="20" height="20" fill="#008844" class="snake-body segment-3" />
      </svg>

    </div>

    <!-- Modal du jeu Snake avec Nokia -->
    <Teleport to="body">
      <div v-if="showGame" class="game-modal" @click.self="closeGame">
        <div class="modal-content">
          <button class="close-btn" @click="closeGame">✕</button>
          <Nokia3310Component />
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const isPeeking = ref(false)
const showGame = ref(false)
let peekTimeout: number | null = null
let hideTimeout: number | null = null

// Le snake sort sa tête aléatoirement
const startPeeking = () => {
  // Nettoyer les timeouts existants
  if (peekTimeout) clearTimeout(peekTimeout)
  if (hideTimeout) clearTimeout(hideTimeout)

  const schedulePeek = () => {
    // Sort la tête entre 3 et 8 secondes
    const nextPeekTime = Math.random() * 5000 + 3000

    peekTimeout = window.setTimeout(() => {
      // Ne pas sortir si le jeu est ouvert
      if (showGame.value) {
        schedulePeek() // Relance le cycle
        return
      }

      isPeeking.value = true

      // Reste visible pendant 2-4 secondes
      const visibleTime = Math.random() * 2000 + 2000

      hideTimeout = window.setTimeout(() => {
        isPeeking.value = false
        schedulePeek() // Relance le cycle
      }, visibleTime)
    }, nextPeekTime)
  }

  // Premier peek après 2 secondes
  schedulePeek()
}

const openSnakeGame = () => {
  showGame.value = true
  // Cacher le snake immédiatement
  isPeeking.value = false
  // Arrêter tous les timeouts en cours
  if (peekTimeout) clearTimeout(peekTimeout)
  if (hideTimeout) clearTimeout(hideTimeout)
}

const closeGame = () => {
  showGame.value = false
  // Relancer les animations
  startPeeking()
}

onMounted(() => {
  startPeeking()
})

onUnmounted(() => {
  if (peekTimeout) clearTimeout(peekTimeout)
  if (hideTimeout) clearTimeout(hideTimeout)
})
</script>

<style scoped>
.hidden-snake-container {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 9999;
  pointer-events: none;
}

.hidden-snake {
  position: absolute;
  top: -60px; /* Caché par défaut */
  left: -60px;
  width: 80px;
  height: 80px;
  cursor: pointer;
  transition: all 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
  pointer-events: all;
  filter: drop-shadow(0 2px 8px rgba(0, 255, 136, 0.3));
}

.hidden-snake.peek {
  top: -20px;
  left: -20px;
  animation: wiggle 0.5s ease-in-out infinite;
}

.hidden-snake:hover {
  transform: scale(1.1);
  filter: drop-shadow(0 4px 16px rgba(0, 255, 136, 0.6));
}

.snake-svg {
  width: 100%;
  height: 100%;
}

.snake-head {
  transition: all 0.3s ease;
}

.tongue {
  opacity: 0;
  transform-origin: left center;
  transition: all 0.3s ease;
}

.peek .tongue {
  opacity: 1;
  animation: tongue-flick 0.6s ease-in-out infinite;
}

.snake-body {
  transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

.hidden-snake:not(.peek) .snake-body {
  transform: translateX(-100px);
}

.peek .segment-1 {
  transition-delay: 0.1s;
}

.peek .segment-2 {
  transition-delay: 0.2s;
}

.peek .segment-3 {
  transition-delay: 0.3s;
}

/* Animation de la langue */
@keyframes tongue-flick {
  0%, 100% {
    transform: scaleX(1);
  }
  50% {
    transform: scaleX(1.3);
  }
}

/* Animation de tremblement */
@keyframes wiggle {
  0%, 100% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(-3deg);
  }
  75% {
    transform: rotate(3deg);
  }
}

/* Modal du jeu */
.game-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-content {
  position: relative;
  width: 90vw;
  height: 90vh;
  max-width: 1400px;
  max-height: 900px;
  background: #1a1a2e;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 255, 136, 0.3);
  animation: slideUp 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@keyframes slideUp {
  from {
    transform: translateY(100px) scale(0.9);
    opacity: 0;
  }
  to {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}

.close-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 40px;
  height: 40px;
  background: rgba(255, 51, 102, 0.9);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 24px;
  cursor: pointer;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(255, 51, 102, 0.4);
}

.close-btn:hover {
  background: rgba(255, 51, 102, 1);
  transform: scale(1.1) rotate(90deg);
  box-shadow: 0 6px 20px rgba(255, 51, 102, 0.6);
}

.close-btn:active {
  transform: scale(0.95) rotate(90deg);
}

/* Style pour le Nokia à l'intérieur de la modal */
.modal-content :deep(.nokia-container) {
  width: 100%;
  height: 100%;
  border-radius: 20px;
}
</style>
