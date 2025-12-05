<template>
  <div class="snake-game">
    <div ref="canvasContainer" class="canvas-container"></div>
    <button v-if="gameOver" @click="resetGame" class="reset-btn">Recommencer</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import { useEventListener } from '@vueuse/core'

const canvasContainer = ref<HTMLDivElement | null>(null)
const score = ref(0)
const gameOver = ref(false)

// Configuration du jeu
const GRID_SIZE = 20
const CELL_SIZE = 1
const GAME_SPEED = 150

// Variables Three.js
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let snakeMeshes: THREE.Mesh[] = []
let foodMesh: THREE.Mesh
let snakeEyes: THREE.Group | null = null
let snakeTongue: THREE.Mesh | null = null
let direction = { x: 1, y: 0 }
let nextDirection = { x: 1, y: 0 }
let snakeBody: { x: number; y: number }[] = []
let gameLoopInterval: number | null = null

// Matériaux réutilisables
let snakeHeadMaterial: THREE.MeshPhongMaterial
let snakeBodyMaterial: THREE.MeshPhongMaterial
let foodMaterial: THREE.MeshPhongMaterial
let borderMaterial: THREE.MeshPhongMaterial

// Initialisation de la scène
const initScene = () => {
  if (!canvasContainer.value) return

  // Scène
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x0a0a1a)
  scene.fog = new THREE.Fog(0x0a0a1a, 20, 50)

  // Caméra avec meilleure perspective
  camera = new THREE.PerspectiveCamera(
    60,
    canvasContainer.value.clientWidth / canvasContainer.value.clientHeight,
    0.1,
    100
  )
  camera.position.set(GRID_SIZE / 2, GRID_SIZE / 2 - 8, GRID_SIZE + 5)
  camera.lookAt(GRID_SIZE / 2, GRID_SIZE / 2, 0)

  // Renderer avec ombres
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false })
  renderer.setSize(canvasContainer.value.clientWidth, canvasContainer.value.clientHeight)
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  canvasContainer.value.appendChild(renderer.domElement)

  // Lumières améliorées
  const ambientLight = new THREE.AmbientLight(0x404060, 0.5)
  scene.add(ambientLight)

  const mainLight = new THREE.DirectionalLight(0xffffff, 1.2)
  mainLight.position.set(GRID_SIZE / 2 + 10, GRID_SIZE / 2 - 10, 20)
  mainLight.castShadow = true
  mainLight.shadow.camera.left = -GRID_SIZE
  mainLight.shadow.camera.right = GRID_SIZE
  mainLight.shadow.camera.top = GRID_SIZE
  mainLight.shadow.camera.bottom = -GRID_SIZE
  mainLight.shadow.mapSize.width = 2048
  mainLight.shadow.mapSize.height = 2048
  scene.add(mainLight)

  const fillLight = new THREE.DirectionalLight(0x6666ff, 0.4)
  fillLight.position.set(-10, -5, 10)
  scene.add(fillLight)

  // Matériaux
  snakeHeadMaterial = new THREE.MeshPhongMaterial({
    color: 0x00ff88,
    emissive: 0x00aa44,
    emissiveIntensity: 0.3,
    shininess: 80
  })

  snakeBodyMaterial = new THREE.MeshPhongMaterial({
    color: 0x00cc66,
    emissive: 0x008833,
    emissiveIntensity: 0.2,
    shininess: 60
  })

  foodMaterial = new THREE.MeshPhongMaterial({
    color: 0xff3366,
    emissive: 0xff1144,
    emissiveIntensity: 0.6,
    shininess: 100
  })

  borderMaterial = new THREE.MeshPhongMaterial({
    color: 0x1a3366,
    emissive: 0x0a1a44,
    emissiveIntensity: 0.3
  })

  // Sol avec grille
  createGround()

  // Bordures
  createBorders()

  // Initialisation du serpent
  snakeBody = [
    { x: 5, y: 10 },
    { x: 4, y: 10 },
    { x: 3, y: 10 }
  ]
  createSnake()

  // Nourriture
  createFood()
}

const createGround = () => {
  // Sol principal
  const groundGeometry = new THREE.PlaneGeometry(GRID_SIZE, GRID_SIZE)
  const groundMaterial = new THREE.MeshPhongMaterial({
    color: 0x151530,
    shininess: 10
  })
  const ground = new THREE.Mesh(groundGeometry, groundMaterial)
  ground.position.set(GRID_SIZE / 2 - 0.5, GRID_SIZE / 2 - 0.5, -0.1)
  ground.receiveShadow = true
  scene.add(ground)

  // Grille
  const gridGroup = new THREE.Group()
  const lineMaterial = new THREE.LineBasicMaterial({ color: 0x2a2a4a, opacity: 0.5, transparent: true })

  for (let i = 0; i <= GRID_SIZE; i++) {
    // Lignes verticales
    const vGeometry = new THREE.BufferGeometry().setFromPoints([
      new THREE.Vector3(i - 0.5, -0.5, 0),
      new THREE.Vector3(i - 0.5, GRID_SIZE - 0.5, 0)
    ])
    const vLine = new THREE.Line(vGeometry, lineMaterial)
    gridGroup.add(vLine)

    // Lignes horizontales
    const hGeometry = new THREE.BufferGeometry().setFromPoints([
      new THREE.Vector3(-0.5, i - 0.5, 0),
      new THREE.Vector3(GRID_SIZE - 0.5, i - 0.5, 0)
    ])
    const hLine = new THREE.Line(hGeometry, lineMaterial)
    gridGroup.add(hLine)
  }

  scene.add(gridGroup)
}

const createBorders = () => {
  // Murs verticaux (plus hauts et à l'extérieur de la grille)
  const wallHeight = 1.5
  const wallThickness = 0.3

  // Bordure haut (horizontal)
  const topGeometry = new THREE.BoxGeometry(GRID_SIZE + wallThickness * 2, wallThickness, wallHeight)
  const topBorder = new THREE.Mesh(topGeometry, borderMaterial)
  topBorder.position.set(GRID_SIZE / 2 - 0.5, -0.5 - wallThickness / 2, wallHeight / 2)
  topBorder.castShadow = true
  topBorder.receiveShadow = true
  scene.add(topBorder)

  // Bordure bas (horizontal)
  const bottomBorder = new THREE.Mesh(topGeometry, borderMaterial)
  bottomBorder.position.set(GRID_SIZE / 2 - 0.5, GRID_SIZE - 0.5 + wallThickness / 2, wallHeight / 2)
  bottomBorder.castShadow = true
  bottomBorder.receiveShadow = true
  scene.add(bottomBorder)

  // Bordure gauche (vertical)
  const sideGeometry = new THREE.BoxGeometry(wallThickness, GRID_SIZE, wallHeight)
  const leftBorder = new THREE.Mesh(sideGeometry, borderMaterial)
  leftBorder.position.set(-0.5 - wallThickness / 2, GRID_SIZE / 2 - 0.5, wallHeight / 2)
  leftBorder.castShadow = true
  leftBorder.receiveShadow = true
  scene.add(leftBorder)

  // Bordure droite (vertical)
  const rightBorder = new THREE.Mesh(sideGeometry, borderMaterial)
  rightBorder.position.set(GRID_SIZE - 0.5 + wallThickness / 2, GRID_SIZE / 2 - 0.5, wallHeight / 2)
  rightBorder.castShadow = true
  rightBorder.receiveShadow = true
  scene.add(rightBorder)
}

const createSnakeDetails = (headMesh: THREE.Mesh, direction: { x: number; y: number }) => {
  // Nettoyer les anciens détails
  if (snakeEyes) {
    scene.remove(snakeEyes)
    snakeEyes.traverse((child) => {
      if (child instanceof THREE.Mesh) {
        child.geometry.dispose()
      }
    })
  }
  if (snakeTongue) {
    scene.remove(snakeTongue)
    snakeTongue.geometry.dispose()
  }

  // Groupe pour les yeux
  snakeEyes = new THREE.Group()

  // Matériau pour les yeux (blanc)
  const eyeMaterial = new THREE.MeshPhongMaterial({
    color: 0xffffff,
    emissive: 0xaaaaaa,
    emissiveIntensity: 0.2
  })

  // Matériau pour la langue (rouge)
  const tongueMaterial = new THREE.MeshPhongMaterial({
    color: 0xff0000,
    emissive: 0xaa0000,
    emissiveIntensity: 0.3
  })

  // Taille des yeux (pixel art - petits cubes)
  const eyeSize = 0.22
  const eyeGeometry = new THREE.BoxGeometry(eyeSize, eyeSize, eyeSize)

  // Calculer l'orientation de la tête
  let eyeOffset1 = { x: 0, y: 0 }
  let eyeOffset2 = { x: 0, y: 0 }
  let tongueOffset = { x: 0, y: 0 }
  let tongueRotation = 0

  if (direction.x === 1) {
    // Droite
    eyeOffset1 = { x: 0.35, y: 0.2 }
    eyeOffset2 = { x: 0.35, y: -0.2 }
    tongueOffset = { x: 0.5, y: 0 }
    tongueRotation = 0
  } else if (direction.x === -1) {
    // Gauche
    eyeOffset1 = { x: -0.35, y: 0.2 }
    eyeOffset2 = { x: -0.35, y: -0.2 }
    tongueOffset = { x: -0.5, y: 0 }
    tongueRotation = Math.PI
  } else if (direction.y === 1) {
    // Haut
    eyeOffset1 = { x: 0.2, y: 0.35 }
    eyeOffset2 = { x: -0.2, y: 0.35 }
    tongueOffset = { x: 0, y: 0.5 }
    tongueRotation = -Math.PI / 2
  } else if (direction.y === -1) {
    // Bas
    eyeOffset1 = { x: 0.2, y: -0.35 }
    eyeOffset2 = { x: -0.2, y: -0.35 }
    tongueOffset = { x: 0, y: -0.5 }
    tongueRotation = Math.PI / 2
  }

  // Créer les deux yeux
  const eye1 = new THREE.Mesh(eyeGeometry, eyeMaterial)
  eye1.position.set(
    headMesh.position.x + eyeOffset1.x,
    headMesh.position.y + eyeOffset1.y,
    headMesh.position.z + 0.2
  )
  snakeEyes.add(eye1)

  const eye2 = new THREE.Mesh(eyeGeometry, eyeMaterial)
  eye2.position.set(
    headMesh.position.x + eyeOffset2.x,
    headMesh.position.y + eyeOffset2.y,
    headMesh.position.z + 0.2
  )
  snakeEyes.add(eye2)

  // Créer la langue (petite et en forme de pixel art)
  const tongueGeometry = new THREE.BoxGeometry(0.35, 0.15, 0.12)
  snakeTongue = new THREE.Mesh(tongueGeometry, tongueMaterial)
  snakeTongue.position.set(
    headMesh.position.x + tongueOffset.x,
    headMesh.position.y + tongueOffset.y,
    headMesh.position.z - 0.1
  )
  snakeTongue.rotation.z = tongueRotation

  scene.add(snakeEyes)
  scene.add(snakeTongue)
}

const createSnake = () => {
  // Nettoyer l'ancien serpent
  snakeMeshes.forEach(mesh => {
    scene.remove(mesh)
    mesh.geometry.dispose()
  })
  snakeMeshes = []

  let headMesh: THREE.Mesh | null = null

  snakeBody.forEach((segment, index) => {
    const isHead = index === 0

    let geometry: THREE.BufferGeometry
    if (isHead) {
      // Tête rétro - simple cube sans subdivision
      geometry = new THREE.BoxGeometry(0.9, 0.9, 0.7)
    } else {
      // Corps standard
      geometry = new THREE.BoxGeometry(0.8, 0.8, 0.5)
    }

    const material = isHead ? snakeHeadMaterial : snakeBodyMaterial
    const mesh = new THREE.Mesh(geometry, material)
    const zPosition = isHead ? 0.35 : 0.25
    mesh.position.set(segment.x, segment.y, zPosition)
    mesh.castShadow = true
    mesh.receiveShadow = true

    scene.add(mesh)
    snakeMeshes.push(mesh)

    if (isHead) {
      headMesh = mesh
    }
  })

  // Ajouter les détails à la tête
  if (headMesh) {
    createSnakeDetails(headMesh, direction)
  }
}

const createFood = () => {
  if (foodMesh) {
    scene.remove(foodMesh)
    foodMesh.geometry.dispose()
  }

  const geometry = new THREE.IcosahedronGeometry(0.35, 1)
  foodMesh = new THREE.Mesh(geometry, foodMaterial)
  foodMesh.castShadow = true
  foodMesh.receiveShadow = true

  // Positionner la nourriture aléatoirement
  let foodPosition: { x: number; y: number }
  do {
    foodPosition = {
      x: Math.floor(Math.random() * GRID_SIZE),
      y: Math.floor(Math.random() * GRID_SIZE)
    }
  } while (snakeBody.some(segment => segment.x === foodPosition.x && segment.y === foodPosition.y))

  foodMesh.position.set(foodPosition.x, foodPosition.y, 0.3)
  scene.add(foodMesh)
}

const updateGame = () => {
  if (gameOver.value) return

  // Mettre à jour la direction
  direction = { ...nextDirection }

  // Calculer la nouvelle position de la tête
  const currentHead = snakeBody[0]
  if (!currentHead) return

  const head = {
    x: currentHead.x + direction.x,
    y: currentHead.y + direction.y
  }

  // Vérifier les collisions avec les murs
  if (head.x < 0 || head.x >= GRID_SIZE || head.y < 0 || head.y >= GRID_SIZE) {
    endGame()
    return
  }

  // Vérifier les collisions avec le corps
  if (snakeBody.some(segment => segment.x === head.x && segment.y === head.y)) {
    endGame()
    return
  }

  // Ajouter la nouvelle tête
  snakeBody.unshift(head)

  // Vérifier si le serpent mange la nourriture
  if (head.x === Math.floor(foodMesh.position.x) && head.y === Math.floor(foodMesh.position.y)) {
    score.value += 10
    createFood()
  } else {
    // Retirer la queue
    snakeBody.pop()
  }

  // Recréer le serpent avec les nouvelles positions
  createSnake()
}

const handleKeyPress = (event: KeyboardEvent) => {
  if (gameOver.value) return

  switch (event.key) {
    case 'ArrowUp':
      if (direction.y === 0) nextDirection = { x: 0, y: 1 }
      event.preventDefault()
      break
    case 'ArrowDown':
      if (direction.y === 0) nextDirection = { x: 0, y: -1 }
      event.preventDefault()
      break
    case 'ArrowLeft':
      if (direction.x === 0) nextDirection = { x: -1, y: 0 }
      event.preventDefault()
      break
    case 'ArrowRight':
      if (direction.x === 0) nextDirection = { x: 1, y: 0 }
      event.preventDefault()
      break
  }
}

const endGame = () => {
  gameOver.value = true
  if (gameLoopInterval) {
    clearInterval(gameLoopInterval)
    gameLoopInterval = null
  }
}

const resetGame = () => {
  gameOver.value = false
  score.value = 0
  direction = { x: 1, y: 0 }
  nextDirection = { x: 1, y: 0 }

  snakeBody = [
    { x: 5, y: 10 },
    { x: 4, y: 10 },
    { x: 3, y: 10 }
  ]

  createSnake()
  createFood()

  if (gameLoopInterval) {
    clearInterval(gameLoopInterval)
  }
  gameLoopInterval = window.setInterval(updateGame, GAME_SPEED)
}

const animate = () => {
  requestAnimationFrame(animate)

  // Animation de la nourriture
  if (foodMesh) {
    foodMesh.rotation.x += 0.02
    foodMesh.rotation.y += 0.03
    foodMesh.position.z = 0.3 + Math.sin(Date.now() * 0.003) * 0.1
  }

  // Animation subtile des segments du serpent
  snakeMeshes.forEach((mesh, index) => {
    mesh.position.z = 0.25 + Math.sin(Date.now() * 0.002 + index * 0.1) * 0.02
  })

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
  gameLoopInterval = window.setInterval(updateGame, GAME_SPEED)

  useEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (gameLoopInterval) {
    clearInterval(gameLoopInterval)
  }
  if (renderer) {
    renderer.dispose()
  }

  // Nettoyer les géométries et matériaux
  snakeMeshes.forEach(mesh => {
    mesh.geometry.dispose()
  })
  if (foodMesh) {
    foodMesh.geometry.dispose()
  }
  if (snakeEyes) {
    snakeEyes.traverse((child) => {
      if (child instanceof THREE.Mesh) {
        child.geometry.dispose()
      }
    })
  }
  if (snakeTongue) {
    snakeTongue.geometry.dispose()
  }
})

// Gestion des touches du clavier
useEventListener('keydown', handleKeyPress)
</script>

<style scoped>
.snake-game {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}

.canvas-container {
  width: 100%;
  height: 100%;
}

.reset-btn {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 1rem 2rem;
  font-size: 1.5rem;
  background: rgba(0, 255, 136, 0.9);
  border: none;
  border-radius: 12px;
  color: #0a0a1a;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 20px rgba(0, 255, 136, 0.5);
  font-weight: 700;
  z-index: 100;
}

.reset-btn:hover {
  transform: translate(-50%, -50%) scale(1.05);
  box-shadow: 0 6px 30px rgba(0, 255, 136, 0.7);
  background: rgba(0, 255, 136, 1);
}

.reset-btn:active {
  transform: translate(-50%, -50%) scale(0.98);
}
</style>
