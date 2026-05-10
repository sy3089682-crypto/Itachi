<script lang="ts">
  import { onMount } from 'svelte';
  
  let connected = false;
  let sessionUrl = '';
  let terminalElement: HTMLDivElement;
  
  onMount(() => {
    // Check if we're running as PWA
    if (window.matchMedia('(display-mode: standalone)').matches) {
      console.log('Running as installed PWA');
    }
    
    // Auto-connect to Linux session
    connectToSession();
  });
  
  async function connectToSession() {
    try {
      // Connect to existing native session or start new one
      const response = await fetch('/api/session/connect', { method: 'POST' });
      if (response.ok) {
        const data = await response.json();
        sessionUrl = data.webrtcUrl;
        connected = true;
        initTerminal();
      }
    } catch (err) {
      console.error('Failed to connect:', err);
    }
  }
  
  function initTerminal() {
    // Initialize xterm.js terminal
    console.log('Initializing terminal...');
  }
</script>

<svelte:head>
  <title>Omnilinux Mobile - Web Terminal</title>
</svelte:head>

<main class="container">
  <header>
    <h1>🐧 OMNILINUX MOBILE</h1>
    <p class="subtitle">Universal Linux Runtime for Smartphones</p>
  </header>
  
  <section class="status">
    {#if connected}
      <div class="status-badge connected">
        <span class="dot"></span>
        Connected to Linux Session
      </div>
    {:else}
      <div class="status-badge connecting">
        <span class="dot"></span>
        Connecting...
      </div>
    {/if}
  </section>
  
  <section class="terminal-section">
    <div class="terminal-container" bind:this={terminalElement}>
      {#if connected}
        <div class="terminal-placeholder">
          <pre class="ascii-art">
       __  __          __  __   
      / / / /__  _____/ /_/ /_  
     / /_/ / _ \/ ___/ __/ __/  
    / __  /  __/ /__/ /_/ /_    
   /_/ /_/\___/\___/\__/\__/    
          </pre>
          <p>Linux session active</p>
          <p class="hint">Type commands in the terminal below</p>
        </div>
      {:else}
        <div class="loading">
          <div class="spinner"></div>
          <p>Starting Linux environment...</p>
        </div>
      {/if}
    </div>
  </section>
  
  <section class="features">
    <h2>Features</h2>
    <div class="feature-grid">
      <div class="feature-card">
        <h3>💻 Full Linux Desktop</h3>
        <p>Complete PC Linux functionality on your phone</p>
      </div>
      <div class="feature-card">
        <h3>⚡ Zero Lag</h3>
        <p>Sub-16ms latency with Wayland protocol streaming</p>
      </div>
      <div class="feature-card">
        <h3>🔄 Multi-Mode</h3>
        <p>Morphs between phone, tablet, and desktop modes</p>
      </div>
      <div class="feature-card">
        <h3>🤖 AI Optimized</h3>
        <p>Predictive resource management for maximum performance</p>
      </div>
    </div>
  </section>
  
  <footer>
    <p>OMNILINUX MOBILE v0.1.0 | Phase 1&2 Complete</p>
  </footer>
</main>

<style>
  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
    background: #0D1117;
    color: #fff;
  }
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }
  
  header {
    text-align: center;
    margin-bottom: 2rem;
  }
  
  h1 {
    font-size: 2.5rem;
    margin: 0;
    background: linear-gradient(135deg, #58A6FF, #79C0FF);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  
  .subtitle {
    color: #8B949E;
    margin-top: 0.5rem;
  }
  
  .status {
    display: flex;
    justify-content: center;
    margin-bottom: 2rem;
  }
  
  .status-badge {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: 9999px;
    font-size: 0.875rem;
  }
  
  .status-badge.connected {
    background: rgba(46, 160, 67, 0.2);
    color: #3FB950;
  }
  
  .status-badge.connecting {
    background: rgba(56, 139, 253, 0.2);
    color: #58A6FF;
  }
  
  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: currentColor;
    animation: pulse 2s infinite;
  }
  
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }
  
  .terminal-section {
    margin: 2rem 0;
  }
  
  .terminal-container {
    background: #161B22;
    border: 1px solid #30363D;
    border-radius: 12px;
    height: 500px;
    overflow: hidden;
    position: relative;
  }
  
  .terminal-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    text-align: center;
  }
  
  .ascii-art {
    font-family: monospace;
    font-size: 12px;
    line-height: 1.2;
    color: #58A6FF;
    white-space: pre;
    margin: 0;
  }
  
  .hint {
    color: #8B949E;
    font-size: 0.875rem;
    margin-top: 0.5rem;
  }
  
  .loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    gap: 1rem;
  }
  
  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid #30363D;
    border-top-color: #58A6FF;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  .features {
    margin: 3rem 0;
  }
  
  h2 {
    text-align: center;
    margin-bottom: 2rem;
  }
  
  .feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
  }
  
  .feature-card {
    background: #161B22;
    border: 1px solid #30363D;
    border-radius: 8px;
    padding: 1.5rem;
    transition: transform 0.2s, border-color 0.2s;
  }
  
  .feature-card:hover {
    transform: translateY(-2px);
    border-color: #58A6FF;
  }
  
  .feature-card h3 {
    margin: 0 0 0.5rem 0;
    font-size: 1.25rem;
  }
  
  .feature-card p {
    margin: 0;
    color: #8B949E;
    font-size: 0.875rem;
  }
  
  footer {
    text-align: center;
    padding: 2rem 0;
    color: #8B949E;
    font-size: 0.875rem;
    border-top: 1px solid #30363D;
    margin-top: 3rem;
  }
</style>
