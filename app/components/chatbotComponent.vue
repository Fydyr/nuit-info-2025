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
    console.error('Chat API error:', err)  // For debugging
    conversation.value.push({ role: 'System', text: 'Snappy has uninstalled system32.dll (Error).' })
  } finally {
    pending.value = false
  }
}

// Optional: Auto-scroll to bottom on new messages
const chatContainer = ref(null)
watch(conversation, () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight
    }
  })
})

const lastSnappyMessage = computed(() => {
  if (pending.value) {
    return 'Thinking of an excuse...';
  }
  // Find the last message that is not from the 'User'
  const lastBotMessage = [...conversation.value].reverse().find(msg => msg.role !== 'User');
  return lastBotMessage ? lastBotMessage.text : 'Ask me something!';
})
</script>

<template>
  <div class="snappy-chat-container">
    <div class="snappy-character-area">
      <div class="speech-bubble">
        {{ lastSnappyMessage }}
      </div>
      <img 
        src="https://placehold.co/150x150/orange/white?text=Snappy" 
        alt="Snappy the chatbot" 
        class="snappy-image"
      />
    </div>

    <form @submit.prevent="sendMessage" class="message-form">
      <input 
        v-model="input" 
        placeholder="Ask a question..." 
        :disabled="pending"
      />
      <button type="submit" :disabled="pending">
        Send
      </button>
    </form>
  </div>
</template>

<style scoped>
.snappy-chat-container {
  max-width: 600px;
  margin: 2rem auto;
  font-family: sans-serif;
  text-align: center;
}

.snappy-character-area {
  position: relative;
  display: inline-block;
  margin-top: 2rem;
  margin-bottom: 1.5rem;
}

.snappy-image {
  border-radius: 50%;
  border: 3px solid #ccc;
}

.speech-bubble {
  position: absolute;
  bottom: 160px; /* Position above the image */
  left: 50%;
  transform: translateX(-50%);
  background-color: #f0f0f0;
  border: 1px solid #ccc;
  border-radius: 10px;
  padding: 1rem;
  min-width: 200px;
  max-width: 300px;
  min-height: 50px;
}

.message-form {
  display: flex;
  gap: 1%;
}
.message-form input {
  width: 80%;
  padding: 0.5rem;
}
.message-form button {
  width: 19%;
  padding: 0.5rem;
}
</style>