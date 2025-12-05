<script setup>
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
</script>

<template>
  <div style="max-width: 600px; margin: 2rem auto; font-family: sans-serif;">
    <h1>Useless Snappy Chat</h1>
    
    <div 
      ref="chatContainer"
      style="border: 1px solid #ccc; padding: 1rem; height: 300px; overflow-y: auto; margin-bottom: 1rem;"
    >
      <div v-for="(msg, i) in conversation" :key="i" :style="{ textAlign: msg.role === 'User' ? 'right' : 'left' }">
        <strong>{{ msg.role }}:</strong> {{ msg.text }}
      </div>
      <div v-if="pending"><em>Thinking of an excuse...</em></div>
    </div>

    <form @submit.prevent="sendMessage">
      <input 
        v-model="input" 
        placeholder="Ask a question..." 
        style="width: 80%; padding: 0.5rem;" 
        :disabled="pending"
      />
      <button type="submit" style="width: 18%; padding: 0.5rem;" :disabled="pending">
        Send
      </button>
    </form>
  </div>
</template>