<template>
    <img :src="currentImage" @click="toggleButton" id="button" alt="button" />

    <transition name="fade">
        <div v-if="showParchment" class="parchment-overlay" @click="closeParchment">
            <img src="../assets/img/scroll.png" class="parchment" alt="Parchemin" />
        </div>
    </transition>
</template>

<style>
    .parchment-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
        cursor: pointer;
    }
    
    .parchment {
        width: 100vw;
        height: 100vh;
        object-fit: contain;
        cursor: default;
    }

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

img {
    cursor: pointer;
    transition: transform 0.1s;
    height: 200px;
    width: 200px;
}

img:active {
    transform: scale(0.95);
}
</style>

<script>
export default {
    data() {
        return {
            isClicked: false,
            showParchment: false
        }
    },
    computed: {
        currentImage() {
            return this.isClicked 
                ? new URL('../assets/img/pressed_button.png', import.meta.url).href
                : new URL('../assets/img/button.png', import.meta.url).href;
        }
    },
    methods: {
        toggleButton() {
            this.isClicked = true;
            
            // Retour automatique après 200ms
            setTimeout(() => {
                this.isClicked = false;
                // Afficher le parchemin après l'animation du bouton
                this.showParchment = true;
            }, 200);
        },
        closeParchment() {
            this.showParchment = false;
        }
    }
}
</script>