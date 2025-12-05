<script setup>
import { computed } from 'vue';
const input = ref('')
const conversation = ref([])
const pending = ref(false)

async function sendMessage() {
  const trimmedInput = input.value.trim()
  if (!trimmedInput) return;
  
  // Add user message to UI
  conversation.value.push({ role: 'User', text: trimmedInput })
  const messageToSend = trimmedInput
  input.value = ''
  pending.value = true

  try {
    const { reply } = await $fetch('/api/chat', {
      method: 'POST',
      body: { message: messageToSend }
    })
    conversation.value.push({ role: 'Snappy', text: reply })
  } catch (err) {
    console.error('Chat API error:', err)
    conversation.value.push({ role: 'System', text: 'Snappy a désinstallé system32.dll (Erreur).' })
  } finally {
    pending.value = false
  }
}

const lastSnappyMessage = computed(() => {
  if (pending.value) {
    return 'Je cherche une excuse...';
  }
  // Find the last message that is not from the 'User'
  const lastBotMessage = [...conversation.value].reverse().find(msg => msg.role !== 'User');
  return lastBotMessage ? lastBotMessage.text : 'Pose-moi une question !';
})
</script>

<template>
  <div class="snappy-chat-container">
    <div class="snappy-character-area">
      <div class="speech-bubble">
        {{ lastSnappyMessage }}
      </div>
      <img 
        src="/assets/img/Snappy_retro.png" 
        alt="Snappy le chatbot" 
        class="snappy-image"
      />
    </div>

    <form @submit.prevent="sendMessage" class="message-form">
      <input 
        v-model="input" 
        placeholder="Pose une question..." 
        :disabled="pending"
      />
      <button type="submit" :disabled="pending">
        Envoyer
      </button>
    </form>
  </div>
</template>

<style scoped>
.snappy-chat-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  max-width: 350px;
  font-family: 'Courier New', Courier, monospace; /* Retro font */
  text-align: center;
  z-index: 1000; /* Ensure it's on top of other content like footers */
}

.snappy-character-area {
  position: relative;
  display: inline-block;
  margin-top: 0.5rem;
  margin-bottom: 0; /* Lower the image further */
}

.snappy-image {
  width: 230px;
  height: auto;
  display: block;
}

.speech-bubble {
  position: absolute;
  bottom: 185px; /* Position above the image */
  left: 50%;
  transform: translateX(-50%);
  background-color: #f0f0f0;
  border: 2px solid #a0a0a0;
  border-radius: 4px; /* More squared-off */
  padding: 0.75rem;
  min-width: 160px;
  max-width: 260px;
  min-height: 40px;
  font-size: 1rem;
}

.message-form {
  display: flex;
  gap: 1%;
}
.message-form input {
  width: 80%;
  padding: 0.5rem;
  border: 2px solid #a0a0a0;
  border-radius: 0;
  font-size: 1rem;
}
.message-form button {
  width: 28%;
  padding: 0.5rem;
  border: 2px solid #a0a0a0;
  border-radius: 0;
  background-color: #e0e0e0;
  cursor: pointer;
  font-size: 1rem;
}
</style>