<template>
  <div class="nokia-container">
    <div ref="canvasContainer" class="canvas-container"></div>
    <div ref="snakeContainer" class="snake-hidden">
      <SnakeComponent />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const canvasContainer = ref<HTMLDivElement | null>(null)
const snakeContainer = ref<HTMLDivElement | null>(null)

// Variables Three.js
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let nokia: THREE.Group
let animationId: number | undefined
let screenMesh: THREE.Mesh
let snakeTexture: THREE.Texture
let raycaster: THREE.Raycaster
let mouse: THREE.Vector2

// Boutons interactifs
let upButton: THREE.Mesh
let downButton: THREE.Mesh
let leftButton: THREE.Mesh
let rightButton: THREE.Mesh
let resetButton: THREE.Mesh
let endCallButton: THREE.Mesh

// Couleurs du Nokia 3310 (bleu foncé classique)
const NOKIA_BLUE = 0x1a3d5c
const NOKIA_DARK = 0x0f2438
const SCREEN_GREEN = 0x9fbc3f
const BUTTON_GREEN = 0x22c55e
const BUTTON_RED = 0xef4444

// Initialisation de la scène
const initScene = () => {
  if (!canvasContainer.value) return

  // Scène
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x1a1a2e)

  // Raycaster pour la détection des clics
  raycaster = new THREE.Raycaster()
  mouse = new THREE.Vector2()

  // Caméra
  camera = new THREE.PerspectiveCamera(
    45,
    canvasContainer.value.clientWidth / canvasContainer.value.clientHeight,
    0.1,
    1000
  )
  camera.position.set(0, 3, 25)
  camera.lookAt(0, 3, 0)

  // Renderer
  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(canvasContainer.value.clientWidth, canvasContainer.value.clientHeight)
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  canvasContainer.value.appendChild(renderer.domElement)

  // Lumières
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6)
  scene.add(ambientLight)

  const mainLight = new THREE.DirectionalLight(0xffffff, 0.8)
  mainLight.position.set(10, 15, 10)
  mainLight.castShadow = true
  mainLight.shadow.mapSize.width = 2048
  mainLight.shadow.mapSize.height = 2048
  scene.add(mainLight)

  const fillLight = new THREE.DirectionalLight(0x6699ff, 0.4)
  fillLight.position.set(-10, 5, -5)
  scene.add(fillLight)

  // Créer le Nokia 3310
  createNokia3310()
}

const createNokia3310 = () => {
  nokia = new THREE.Group()

  // Dimensions du téléphone
  const phoneWidth = 8
  const phoneHeight = 18
  const phoneDepth = 3.2

  // Corps principal du téléphone (avant)
  const frontGeometry = new THREE.BoxGeometry(phoneWidth, phoneHeight, phoneDepth * 0.4)
  const frontMaterial = new THREE.MeshPhongMaterial({
    color: NOKIA_BLUE,
    shininess: 40
  })
  const front = new THREE.Mesh(frontGeometry, frontMaterial)
  front.position.z = phoneDepth * 0.3
  front.castShadow = true
  front.receiveShadow = true
  nokia.add(front)

  // Dos du téléphone (légèrement bombé)
  const backGeometry = new THREE.BoxGeometry(phoneWidth * 0.95, phoneHeight * 0.95, phoneDepth * 0.6)
  const backMaterial = new THREE.MeshPhongMaterial({
    color: NOKIA_DARK,
    shininess: 20
  })
  const back = new THREE.Mesh(backGeometry, backMaterial)
  back.position.z = -phoneDepth * 0.3
  back.castShadow = true
  back.receiveShadow = true
  nokia.add(back)

  // Écran LCD
  createScreen()

  // Boutons
  createButtons()

  // Logo Nokia
  createLogo()

  // Antenne
  createAntenna()

  // Détails supplémentaires
  createDetails()

  scene.add(nokia)
}

const createScreen = () => {
  const screenWidth = 7.2
  const screenHeight = 5.7
  const screenDepth = 0.15

  // Zone d'écran enfoncée
  const screenAreaGeometry = new THREE.BoxGeometry(screenWidth + 0.6, screenHeight + 0.6, 0.3)
  const screenAreaMaterial = new THREE.MeshPhongMaterial({
    color: 0x0d1f31,
    shininess: 10
  })
  const screenArea = new THREE.Mesh(screenAreaGeometry, screenAreaMaterial)
  screenArea.position.set(0, 4, 1.4)
  nokia.add(screenArea)

  // Cadre intérieur de l'écran
  const innerFrameGeometry = new THREE.BoxGeometry(screenWidth + 0.2, screenHeight + 0.2, 0.1)
  const innerFrameMaterial = new THREE.MeshPhongMaterial({
    color: 0x1a1a1a,
    shininess: 5
  })
  const innerFrame = new THREE.Mesh(innerFrameGeometry, innerFrameMaterial)
  innerFrame.position.set(0, 4, 1.52)
  nokia.add(innerFrame)

  // Écran LCD (vert classique) - on crée une texture canvas pour afficher le Snake
  const screenGeometry = new THREE.PlaneGeometry(screenWidth, screenHeight)
  const screenMaterial = new THREE.MeshBasicMaterial({
    color: 0xffffff,
    toneMapped: false
  })
  screenMesh = new THREE.Mesh(screenGeometry, screenMaterial)
  screenMesh.position.set(0, 4, 1.65)
  nokia.add(screenMesh)
}

const createButtons = () => {
  // Zone des boutons de navigation
  const navZoneGeometry = new THREE.BoxGeometry(2.2, 2.2, 0.15)
  const navZoneMaterial = new THREE.MeshPhongMaterial({
    color: 0x2a4a6a,
    shininess: 30
  })
  const navZone = new THREE.Mesh(navZoneGeometry, navZoneMaterial)
  navZone.position.set(0, -0.5, 1.45)
  nokia.add(navZone)

  // Pad directionnel (forme en croix)
  const buttonRadius = 0.35
  const buttonHeight = 0.16
  const buttonGeometry = new THREE.CylinderGeometry(buttonRadius, buttonRadius, buttonHeight, 16)

  // Centre (bouton de sélection / reset)
  const resetButtonMaterial = new THREE.MeshPhongMaterial({
    color: 0x4a5568,
    shininess: 60
  })
  resetButton = new THREE.Mesh(buttonGeometry, resetButtonMaterial)
  resetButton.position.set(0, -0.5, 1.6)
  resetButton.rotation.x = Math.PI / 2
  resetButton.castShadow = true
  resetButton.userData = { type: 'reset' }
  nokia.add(resetButton)

  // Haut
  const upButtonMaterial = new THREE.MeshPhongMaterial({
    color: 0x4a5568,
    shininess: 60
  })
  upButton = new THREE.Mesh(buttonGeometry, upButtonMaterial)
  upButton.position.set(0, 0.3, 1.6)
  upButton.rotation.x = Math.PI / 2
  upButton.castShadow = true
  upButton.userData = { type: 'up' }
  nokia.add(upButton)

  // Bas
  const downButtonMaterial = new THREE.MeshPhongMaterial({
    color: 0x4a5568,
    shininess: 60
  })
  downButton = new THREE.Mesh(buttonGeometry, downButtonMaterial)
  downButton.position.set(0, -1.3, 1.6)
  downButton.rotation.x = Math.PI / 2
  downButton.castShadow = true
  downButton.userData = { type: 'down' }
  nokia.add(downButton)

  // Gauche
  const leftButtonMaterial = new THREE.MeshPhongMaterial({
    color: 0x4a5568,
    shininess: 60
  })
  leftButton = new THREE.Mesh(buttonGeometry, leftButtonMaterial)
  leftButton.position.set(-0.8, -0.5, 1.6)
  leftButton.rotation.x = Math.PI / 2
  leftButton.castShadow = true
  leftButton.userData = { type: 'left' }
  nokia.add(leftButton)

  // Droite
  const rightButtonMaterial = new THREE.MeshPhongMaterial({
    color: 0x4a5568,
    shininess: 60
  })
  rightButton = new THREE.Mesh(buttonGeometry, rightButtonMaterial)
  rightButton.position.set(0.8, -0.5, 1.6)
  rightButton.rotation.x = Math.PI / 2
  rightButton.castShadow = true
  rightButton.userData = { type: 'right' }
  nokia.add(rightButton)

  // Boutons softkey (Menu/Sélect)
  const softKeyGeometry = new THREE.BoxGeometry(1.3, 0.25, 0.1)
  const softKeyMaterial = new THREE.MeshPhongMaterial({
    color: 0x555555,
    shininess: 50
  })

  const leftSoftKey = new THREE.Mesh(softKeyGeometry, softKeyMaterial)
  leftSoftKey.position.set(-1.2, 1.8, 1.58)
  leftSoftKey.castShadow = true
  nokia.add(leftSoftKey)

  const rightSoftKey = new THREE.Mesh(softKeyGeometry, softKeyMaterial)
  rightSoftKey.position.set(1.2, 1.8, 1.58)
  rightSoftKey.castShadow = true
  nokia.add(rightSoftKey)

  // Clavier numérique (3x4 grid)
  const keyWidth = 1.2
  const keyHeight = 0.65
  const keyDepth = 0.12
  const keyGeometry = new THREE.BoxGeometry(keyWidth, keyHeight, keyDepth)
  const keyMaterial = new THREE.MeshPhongMaterial({
    color: 0x3d4756,
    shininess: 50
  })

  const keyLayout = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    ['*', 0, '#']
  ]

  keyLayout.forEach((row, rowIndex) => {
    row.forEach((_, colIndex) => {
      const key = new THREE.Mesh(keyGeometry, keyMaterial)
      const x = (colIndex - 1) * 1.4
      const y = -2.2 - rowIndex * 0.9
      key.position.set(x, y, 1.58)
      key.castShadow = true
      nokia.add(key)

      // Petit relief sur la touche
      const reliefGeometry = new THREE.BoxGeometry(keyWidth * 0.8, keyHeight * 0.7, 0.03)
      const reliefMaterial = new THREE.MeshPhongMaterial({
        color: 0x4a5568,
        shininess: 60
      })
      const relief = new THREE.Mesh(reliefGeometry, reliefMaterial)
      relief.position.set(x, y, 1.65)
      nokia.add(relief)
    })
  })

  // Bouton d'appel (vert)
  const callButtonGeometry = new THREE.BoxGeometry(1.4, 0.5, 0.15)
  const callButtonMaterial = new THREE.MeshPhongMaterial({
    color: BUTTON_GREEN,
    emissive: BUTTON_GREEN,
    emissiveIntensity: 0.3,
    shininess: 70
  })
  const callButton = new THREE.Mesh(callButtonGeometry, callButtonMaterial)
  callButton.position.set(-1.2, -5.8, 1.6)
  callButton.castShadow = true
  nokia.add(callButton)
  // Bouton de fin d'appel (rouge)
  const endCallButtonMaterial = new THREE.MeshPhongMaterial({
    color: BUTTON_RED,
    emissive: BUTTON_RED,
    emissiveIntensity: 0.3,
    shininess: 70
  })
  endCallButton = new THREE.Mesh(callButtonGeometry, endCallButtonMaterial)
  endCallButton.position.set(1.2, -5.8, 1.6)
  endCallButton.castShadow = true
  nokia.add(endCallButton)
  nokia.add(endCallButton)
}

const createLogo = () => {
  // Logo "NOKIA" en relief
  const logoGeometry = new THREE.BoxGeometry(2.5, 0.4, 0.08)
  const logoMaterial = new THREE.MeshPhongMaterial({
    color: 0xe0e0e0,
    shininess: 100
  })
  const logo = new THREE.Mesh(logoGeometry, logoMaterial)
  logo.position.set(0, 6.2, 1.58)
  logo.castShadow = true
  nokia.add(logo)

  // Texte "NOKIA" simplifié avec des barres
  const letterGeometry = new THREE.BoxGeometry(0.15, 0.25, 0.05)
  const letterMaterial = new THREE.MeshPhongMaterial({
    color: 0x2a4a6a,
    shininess: 50
  })

  const letterPositions = [-0.8, -0.4, 0, 0.4, 0.8]
  letterPositions.forEach(x => {
    const letter = new THREE.Mesh(letterGeometry, letterMaterial)
    letter.position.set(x, 6.2, 1.63)
    nokia.add(letter)
  })
}

const createAntenna = () => {
  // Base de l'antenne
  const baseRadius = 0.15
  const baseHeight = 0.3
  const baseGeometry = new THREE.CylinderGeometry(baseRadius, baseRadius * 1.2, baseHeight, 12)
  const antennaMaterial = new THREE.MeshPhongMaterial({
    color: 0x2a2a2a,
    shininess: 80
  })
  const base = new THREE.Mesh(baseGeometry, antennaMaterial)
  base.position.set(-3.2, 8.5, 0.3)
  base.castShadow = true
  nokia.add(base)

  // Antenne rétractable (sortie)
  const antennaRadius = 0.09
  const antennaHeight = 4
  const antennaGeometry = new THREE.CylinderGeometry(antennaRadius, antennaRadius, antennaHeight, 12)
  const antennaShaftMaterial = new THREE.MeshPhongMaterial({
    color: 0x666666,
    shininess: 100
  })
  const antenna = new THREE.Mesh(antennaGeometry, antennaShaftMaterial)
  antenna.position.set(-3.2, 10.8, 0.3)
  antenna.castShadow = true
  nokia.add(antenna)

  // Segments de l'antenne (lignes)
  for (let i = 0; i < 4; i++) {
    const ringGeometry = new THREE.TorusGeometry(antennaRadius * 1.1, 0.02, 8, 12)
    const ring = new THREE.Mesh(ringGeometry, antennaMaterial)
    ring.position.set(-3.2, 9.3 + i * 0.75, 0.3)
    ring.rotation.x = Math.PI / 2
    nokia.add(ring)
  }

  // Bout de l'antenne
  const tipGeometry = new THREE.ConeGeometry(antennaRadius * 1.3, 0.5, 12)
  const tip = new THREE.Mesh(tipGeometry, antennaMaterial)
  tip.position.set(-3.2, 13.05, 0.3)
  tip.castShadow = true
  nokia.add(tip)
}

const createDetails = () => {
  // Zone du haut-parleur (enfoncée)
  const speakerZoneGeometry = new THREE.BoxGeometry(2, 0.4, 0.1)
  const speakerZoneMaterial = new THREE.MeshPhongMaterial({
    color: 0x0d1f31,
    shininess: 10
  })
  const speakerZone = new THREE.Mesh(speakerZoneGeometry, speakerZoneMaterial)
  speakerZone.position.set(0, 5.5, 1.4)
  nokia.add(speakerZone)

  // Grille du haut-parleur avec trous
  const holeRadius = 0.06
  const holeGeometry = new THREE.CircleGeometry(holeRadius, 8)
  const holeMaterial = new THREE.MeshBasicMaterial({ color: 0x000000 })

  // Grille en lignes
  for (let row = 0; row < 2; row++) {
    for (let col = -4; col <= 4; col++) {
      const hole = new THREE.Mesh(holeGeometry, holeMaterial)
      hole.position.set(col * 0.22, 5.5 + row * 0.15 - 0.08, 1.48)
      nokia.add(hole)
    }
  }

  // LED d'indicateur (en haut à droite de l'écran)
  const ledGeometry = new THREE.CircleGeometry(0.08, 12)
  const ledMaterial = new THREE.MeshPhongMaterial({
    color: 0x00ff00,
    emissive: 0x00ff00,
    emissiveIntensity: 0.6,
    transparent: true,
    opacity: 0.8
  })
  const led = new THREE.Mesh(ledGeometry, ledMaterial)
  led.position.set(2, 5.6, 1.52)
  nokia.add(led)

  // Marques d'usure/détails sur les côtés
  const sideDetailGeometry = new THREE.BoxGeometry(0.1, 10, 0.15)
  const sideDetailMaterial = new THREE.MeshPhongMaterial({
    color: 0x1a3050,
    shininess: 20
  })

  const leftDetail = new THREE.Mesh(sideDetailGeometry, sideDetailMaterial)
  leftDetail.position.set(-3.05, 0, 1.4)
  nokia.add(leftDetail)

  const rightDetail = new THREE.Mesh(sideDetailGeometry, sideDetailMaterial)
  rightDetail.position.set(3.05, 0, 1.4)
  nokia.add(rightDetail)
}

const updateSnakeTexture = () => {
  if (!snakeContainer.value) return

  // Trouver le canvas du Snake dans le container
  const snakeCanvas = snakeContainer.value.querySelector('canvas')
  if (snakeCanvas && screenMesh) {
    // Créer ou mettre à jour la texture à partir du canvas du Snake
    if (!snakeTexture) {
      snakeTexture = new THREE.CanvasTexture(snakeCanvas)
      snakeTexture.minFilter = THREE.NearestFilter
      snakeTexture.magFilter = THREE.NearestFilter
      snakeTexture.colorSpace = THREE.SRGBColorSpace

      // Appliquer la texture à l'écran
      if (screenMesh.material instanceof THREE.MeshBasicMaterial) {
        screenMesh.material.map = snakeTexture
        screenMesh.material.color.set(0xffffff)
        screenMesh.material.needsUpdate = true
      }
    } else {
      snakeTexture.needsUpdate = true
    }
  }
}

const handleMouseMove = (event: MouseEvent) => {
  if (!canvasContainer.value) return

  // Calculer les coordonnées normalisées de la souris
  const rect = canvasContainer.value.getBoundingClientRect()
  mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

  // Mettre à jour le raycaster
  raycaster.setFromCamera(mouse, camera)

  // Vérifier les intersections avec les boutons
  const intersects = raycaster.intersectObjects([upButton, downButton, leftButton, rightButton, resetButton])

  // Réinitialiser tous les boutons
  const allButtons = [upButton, downButton, leftButton, rightButton, resetButton]
  allButtons.forEach(button => {
    if (button.material instanceof THREE.MeshPhongMaterial) {
      if (button === resetButton) {
        button.material.emissive.setHex(0x000000)
        button.material.emissiveIntensity = 0
      } else if (button === endCallButton) {
        button.material.emissive.setHex(BUTTON_RED)
        button.material.emissiveIntensity = 0.3
      } else {
        button.material.emissive.setHex(0x000000)
        button.material.emissiveIntensity = 0
      }
    }
  })

  // Changer l'apparence du bouton survolé
  if (intersects.length > 0) {
    const hoveredButton = intersects[0]?.object as THREE.Mesh
    if (hoveredButton.material instanceof THREE.MeshPhongMaterial) {
      if (hoveredButton === resetButton) {
        hoveredButton.material.emissive.setHex(0x00ff00)
        hoveredButton.material.emissiveIntensity = 0.5
      } else {
        hoveredButton.material.emissive.setHex(0x3366ff)
        hoveredButton.material.emissiveIntensity = 0.4
      }
    }
    if (canvasContainer.value) {
      canvasContainer.value.style.cursor = 'pointer'
    }
  } else {
    if (canvasContainer.value) {
      canvasContainer.value.style.cursor = 'default'
    }
  }
}

const handleClick = (event: MouseEvent) => {
  if (!canvasContainer.value) return

  // Calculer les coordonnées normalisées de la souris
  const rect = canvasContainer.value.getBoundingClientRect()
  mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

  // Mettre à jour le raycaster
  raycaster.setFromCamera(mouse, camera)

  // Vérifier les intersections avec les boutons
  const intersects = raycaster.intersectObjects([upButton, downButton, leftButton, rightButton, resetButton])

  if (intersects.length > 0) {
    const clickedButton = intersects[0]?.object as THREE.Mesh
    const buttonType = clickedButton.userData?.type

    // Effet visuel de clic
    if (clickedButton.material instanceof THREE.MeshPhongMaterial) {
      const originalColor = clickedButton.material.color.getHex()
      clickedButton.material.color.setHex(0xffffff)
      setTimeout(() => {
        if (clickedButton.material instanceof THREE.MeshPhongMaterial) {
          clickedButton.material.color.setHex(originalColor)
        }
      }, 100)
    }

    // Simuler l'appui sur une touche du clavier
    let keyEvent: KeyboardEvent | null = null

    switch (buttonType) {
      case 'up':
        keyEvent = new KeyboardEvent('keydown', { key: 'ArrowUp' })
        break
      case 'down':
        keyEvent = new KeyboardEvent('keydown', { key: 'ArrowDown' })
        break
      case 'left':
        keyEvent = new KeyboardEvent('keydown', { key: 'ArrowLeft' })
        break
      case 'right':
        keyEvent = new KeyboardEvent('keydown', { key: 'ArrowRight' })
        break
      case 'reset':
        // Trouver le bouton de reset dans le Snake component
        if (snakeContainer.value) {
          const resetBtn = snakeContainer.value.querySelector('button')
          if (resetBtn) {
            resetBtn.click()
          }
        }
        break
    }

    if (keyEvent) {
      window.dispatchEvent(keyEvent)
    }
  }
}

const animate = () => {
  animationId = requestAnimationFrame(animate)

  // Mettre à jour la texture du Snake
  updateSnakeTexture()

  renderer.render(scene, camera)
}

const handleResize = () => {
  if (!canvasContainer.value) return

  camera.aspect = canvasContainer.value.clientWidth / canvasContainer.value.clientHeight
  camera.updateProjectionMatrix()
  renderer.setSize(canvasContainer.value.clientWidth, canvasContainer.value.clientHeight)
}

onMounted(() => {
  initScene()
  animate()
  window.addEventListener('resize', handleResize)
  if (canvasContainer.value) {
    canvasContainer.value.addEventListener('click', handleClick)
    canvasContainer.value.addEventListener('mousemove', handleMouseMove)
  }
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  if (renderer) {
    renderer.dispose()
  }
  if (snakeTexture) {
    snakeTexture.dispose()
  }
  window.removeEventListener('resize', handleResize)
  if (canvasContainer.value) {
    canvasContainer.value.removeEventListener('click', handleClick)
    canvasContainer.value.removeEventListener('mousemove', handleMouseMove)
  }

  // Nettoyer la scène
  if (scene) {
    scene.traverse((object) => {
      if (object instanceof THREE.Mesh) {
        object.geometry.dispose()
        if (Array.isArray(object.material)) {
          object.material.forEach(material => material.dispose())
        } else {
          object.material.dispose()
        }
      }
    })
  }
})
</script>

<style scoped>
.nokia-container {
  width: 100%;
  height: 100vh;
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}

.canvas-container {
  width: 100%;
  height: 100%;
}

.snake-hidden {
  position: absolute;
  top: -9999px;
  left: -9999px;
  width: 1440px;
  height: 1140px;
  pointer-events: none;
  visibility: hidden;
}

.snake-hidden :deep(.snake-game) {
  width: 100%;
  height: 100%;
}

.snake-hidden :deep(.canvas-container) {
  width: 100%;
  height: 100%;
}

.snake-hidden :deep(canvas) {
  image-rendering: pixelated;
  image-rendering: -moz-crisp-edges;
  image-rendering: crisp-edges;
}
</style>
