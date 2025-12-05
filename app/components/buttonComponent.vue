<template>
    <!-- Boutons qui apparaissent progressivement à des positions aléatoires -->
    <transition name="slide-up">
        <img
            v-if="currentStep >= 0"
            :src="getButtonImage(0)"
            @click="toggleButton(0)"
            class="button random-position"
            :style="buttonPositions[0]"
            alt="button 1"
        />
    </transition>

    <transition name="slide-up">
        <img
            v-if="currentStep >= 1"
            :src="getButtonImage(1)"
            @click="toggleButton(1)"
            class="button random-position"
            :style="buttonPositions[1]"
            alt="button 2"
        />
    </transition>

    <transition name="slide-up">
        <img
            v-if="currentStep >= 2"
            :src="getButtonImage(2)"
            @click="toggleButton(2)"
            class="button random-position"
            :style="buttonPositions[2]"
            alt="button 3"
        />
    </transition>

    <transition name="slide-up">
        <img
            v-if="currentStep >= 3"
            :src="getButtonImage(3)"
            @click="toggleButton(3)"
            class="button random-position"
            :style="buttonPositions[3]"
            alt="button 4"
        />
    </transition>

    <!-- Parchemin avec transition -->
    <transition name="fade">
        <div v-if="showParchment" class="parchment-overlay" @click="closeParchment">
            <div class="parchment-container">
                <img src="../assets/img/scroll.png" class="parchment" alt="Parchemin" />
                <div class="parchment-text" @click.stop>
                    {{ currentParchmentText }}
                </div>
            </div>
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

.parchment-container {
    position: relative;
    width: 100vw;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.parchment {
    width: 100vw;
    height: 100vh;
    object-fit: contain;
    cursor: default;
}

.parchment-text {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 40%;
    max-width: 400px;
    max-height: 50vh;
    overflow-y: auto;
    padding: 20px;
    font-family: 'Georgia', serif;
    font-size: 18px;
    font-weight: bold;
    line-height: 1.6;
    color: #3e2723;
    text-align: center;
    pointer-events: auto;
    cursor: default;
    white-space: pre-line;
}

/* Scrollbar personnalisée pour le texte du parchemin */
.parchment-text::-webkit-scrollbar {
    width: 8px;
}

.parchment-text::-webkit-scrollbar-track {
    background: rgba(139, 69, 19, 0.1);
    border-radius: 10px;
}

.parchment-text::-webkit-scrollbar-thumb {
    background: rgba(139, 69, 19, 0.5);
    border-radius: 10px;
}

.parchment-text::-webkit-scrollbar-thumb:hover {
    background: rgba(139, 69, 19, 0.7);
}

/* Animation fade pour le parchemin */
.fade-enter-active,
.fade-leave-active {
    transition: opacity 1s;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

/* Animation slide-up pour les boutons */
.slide-up-enter-active {
    transition: all 0.6s ease-out;
}

.slide-up-enter-from {
    opacity: 0;
    transform: translateY(50px) scale(0.8);
}

.button {
    cursor: pointer;
    transition: transform 0.1s;
    height: 200px;
    width: 200px;
}

.button:active {
    transform: scale(0.95) !important;
}

.random-position {
    position: fixed;
    z-index: 100;
}
</style>

<script>
export default {
    data() {
        return {
            currentStep: 0, // Étape actuelle (0 = premier bouton visible)
            clickedButtons: [false, false, false, false], // État de chaque bouton
            showParchment: false,
            buttonPositions: [], // Positions aléatoires des boutons
            currentParchmentIndex: 0, // Index du parchemin actuel
            parchmentTexts: [
                "Bonnes Pratiques NIRD\nParchemin I : Logiciels Libres\n\nDans notre quête d'un numérique plus responsable, il est essentiel de privilégier les logiciels libres plutôt que leurs équivalents propriétaires. Cette démarche participe activement à la réduction de notre impact numérique tout en garantissant notre liberté digitale.\n\nConcrètement, cela signifie remplacer Microsoft Office par LibreOffice pour vos documents bureautiques, opter pour Firefox plutôt que Chrome pour naviguer sur Internet, choisir GIMP à la place de Photoshop pour vos retouches d'images, ou encore préférer VLC pour lire vos fichiers multimédias.\n\nCes alternatives libres présentent de nombreux avantages : elles sont entièrement gratuites, leur code source est transparent et vérifiable par tous, elles respectent davantage votre vie privée en ne collectant pas vos données personnelles, et en les utilisant, vous contribuez à soutenir une communauté mondiale de développeurs engagés pour un numérique éthique et accessible à tous.",

                "Bonnes Pratiques NIRD\nParchemin II : Système d'Exploitation Libre\n\nL'adoption d'un système d'exploitation libre comme Linux représente un choix majeur pour réduire notre empreinte numérique. Contrairement à Windows, Linux offre un bien meilleur respect de votre vie privée en n'effectuant aucune collecte de données personnelles à votre insu.\n\nCe choix permet également de prolonger considérablement la durée de vie de vos appareils grâce à une meilleure optimisation des ressources système. Là où Windows ralentit et devient obsolète, Linux continue de fonctionner efficacement même sur des machines anciennes.\n\nLa sécurité est renforcée grâce à des mises à jour régulières et une architecture plus robuste face aux menaces. De plus, Linux est totalement gratuit, sans aucune licence à payer, et offre une personnalisation complète de votre environnement de travail.\n\nPour débuter, tournez-vous vers des distributions accessibles comme Ubuntu, Linux Mint, Debian ou Fedora qui proposent des interfaces conviviales et une large communauté d'entraide.",

                "Bonnes Pratiques NIRD\nParchemin III : Prolonger la Vie des Machines\n\nPlutôt que de jeter un ordinateur qui ne répond plus à vos besoins actuels, il est possible de lui donner une seconde vie en le transformant pour d'autres usages. Un ancien ordinateur portable peut devenir un excellent serveur domestique, hébergeant vos fichiers personnels ou vos sites web.\n\nVous pouvez également créer votre propre machine de stockage en réseau, communément appelée NAS, pour centraliser et sauvegarder toutes vos données familiales. Une autre option consiste à dédier cette machine à des tâches spécifiques comme un poste de traitement de texte, un centre multimédia avec Kodi pour gérer votre bibliothèque de films et musiques, ou encore un serveur de jeux rétro pour revivre les classiques du gaming.\n\nL'installation d'une distribution Linux légère comme Lubuntu ou Xubuntu permet de redonner une véritable seconde jeunesse à des machines que l'on croyait bonnes pour la casse. C'est un geste écologique fort qui évite la production de nouveaux appareils et réduit considérablement nos déchets électroniques.",

                "Bonnes Pratiques NIRD\nParchemin IV : Partage et Don\n\nLorsqu'un ordinateur ne vous est vraiment plus d'aucune utilité, le don représente une alternative responsable bien plus vertueuse que la mise au rebut. De nombreuses associations caritatives comme Emmaüs ou le Secours Populaire acceptent volontiers les dons de matériel informatique pour équiper des personnes dans le besoin.\n\nLes établissements scolaires, centres sociaux, espaces de co-working et FabLabs sont également en demande constante d'équipements pour leurs activités pédagogiques et leurs ateliers. Des plateformes en ligne comme Donnons.org ou Geev facilitent grandement la mise en relation entre donateurs et bénéficiaires.\n\nAvant de donner votre matériel, veillez à effacer soigneusement toutes vos données personnelles pour protéger votre vie privée. Réinstallez ensuite un système d'exploitation propre et fonctionnel, de préférence Linux pour garantir sa longévité. Enfin, vérifiez le bon fonctionnement général de la machine pour que votre don soit réellement utile.\n\nEnsemble, en adoptant ces pratiques de don et de partage, nous réduisons les montagnes de déchets électroniques et promouvons un numérique véritablement responsable et solidaire."
            ]
        }
    },
    computed: {
        currentParchmentText() {
            return this.parchmentTexts[this.currentParchmentIndex] || '';
        }
    },
    mounted() {
        // Générer des positions aléatoires pour chaque bouton
        this.generateRandomPositions();

        // Regénérer les positions si la fenêtre est redimensionnée
        window.addEventListener('resize', this.generateRandomPositions);
    },
    beforeUnmount() {
        window.removeEventListener('resize', this.generateRandomPositions);
    },
    methods: {
        generateRandomPositions() {
            const positions = [];
            const buttonSize = 200; // Taille du bouton (200px)
            const padding = 50; // Marge minimum par rapport aux bords

            // Zone du chatbot (en bas à droite)
            const chatbotZone = {
                top: window.innerHeight - 400, // Zone du chatbot + marge (image + bulle + form)
                left: window.innerWidth - 400, // Zone du chatbot + marge
                width: 400,
                height: 400
            };

            for (let i = 0; i < 4; i++) {
                let position;
                let attempts = 0;
                let validPosition = false;

                // Essayer de trouver une position qui ne chevauche pas les autres boutons
                while (!validPosition && attempts < 100) {
                    const top = Math.random() * (window.innerHeight - buttonSize - padding * 2) + padding;
                    const left = Math.random() * (window.innerWidth - buttonSize - padding * 2) + padding;

                    position = {
                        top: `${top}px`,
                        left: `${left}px`
                    };

                    // Vérifier si cette position ne chevauche PAS la zone du chatbot
                    const overlapsChatbot = (
                        top < chatbotZone.top + chatbotZone.height &&
                        top + buttonSize > chatbotZone.top &&
                        left < chatbotZone.left + chatbotZone.width &&
                        left + buttonSize > chatbotZone.left
                    );

                    if (overlapsChatbot) {
                        validPosition = false;
                        attempts++;
                        continue;
                    }

                    // Vérifier si cette position chevauche les positions existantes
                    validPosition = true;
                    for (let j = 0; j < positions.length; j++) {
                        const existingTop = parseFloat(positions[j].top);
                        const existingLeft = parseFloat(positions[j].left);

                        const distance = Math.sqrt(
                            Math.pow(top - existingTop, 2) +
                            Math.pow(left - existingLeft, 2)
                        );

                        // Si la distance est trop petite, essayer une nouvelle position
                        if (distance < buttonSize + 50) {
                            validPosition = false;
                            break;
                        }
                    }

                    attempts++;
                }

                positions.push(position);
            }

            this.buttonPositions = positions;
        },
        getButtonImage(index) {
            // Retourne l'image du bouton (pressé ou normal)
            return this.clickedButtons[index]
                ? new URL('../assets/img/pressed_button.png', import.meta.url).href
                : new URL('../assets/img/button.png', import.meta.url).href;
        },
        toggleButton(index) {
            // Permettre de cliquer sur tous les boutons visibles (jusqu'à currentStep)
            if (index > this.currentStep) return;

            // Marquer le bouton comme cliqué
            this.clickedButtons[index] = true;

            // Définir le texte du parchemin correspondant
            this.currentParchmentIndex = index;

            // Retour automatique après 200ms
            setTimeout(() => {
                this.clickedButtons[index] = false;
                // Afficher le parchemin après l'animation du bouton
                this.showParchment = true;
            }, 200);
        },
        closeParchment() {
            this.showParchment = false;

            // Passer à l'étape suivante seulement si on vient de cliquer sur le dernier bouton
            if (this.currentParchmentIndex === this.currentStep && this.currentStep < 3) {
                setTimeout(() => {
                    this.currentStep++;
                }, 300); // Petit délai pour une transition plus fluide
            }
        }
    }
}
</script>