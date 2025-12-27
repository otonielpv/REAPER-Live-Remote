/**
 * ui.js - Funciones de renderizado de interfaz
 * 
 * Funciones para generar HTML y manejar eventos de UI
 */

import * as api from './api.js';
import * as state from './state.js';
import * as utils from './utils.js';
import * as i18n from './i18n.js';

/**
 * Renderizar lista de canciones en un contenedor
 * @param {Element} container 
 * @param {Array} markers 
 */
export function renderSongList(container, markers) {
  container.innerHTML = '';
  
  if (!markers || markers.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <p>${i18n.t('no_songs_found')}</p>
        <p class="hint">${i18n.t('add_markers')}</p>
      </div>
    `;
    return;
  }
  
  const sortedMarkers = utils.sortByPos(markers);
  
  sortedMarkers.forEach((marker, index) => {
    const songCard = createSongCard(marker, index + 1);
    container.appendChild(songCard);
  });
}

/**
 * Crear tarjeta de canción
 * @param {object} marker 
 * @param {number} number 
 * @returns {Element}
 */
function createSongCard(marker, number) {
  const card = document.createElement('button');
  card.className = 'song-card';
  card.setAttribute('data-song-id', marker.id);
  
  card.innerHTML = `
    <div class="song-number">${number}</div>
    <div class="song-name">${utils.escapeHtml(marker.name)}</div>
    <div class="song-time">${utils.formatTime(marker.pos)}</div>
  `;
  
  card.addEventListener('click', () => {
    navigateToSong(marker.id);
  });
  
  return card;
}

/**
 * Navegar a la página de detalle de canción
 * @param {number} songId 
 */
function navigateToSong(songId) {
  window.location.href = `song.html?songId=${songId}`;
}

/**
 * Renderizar secciones de una canción
 * @param {Element} container 
 * @param {Array} regions 
 */
/**
 * Renderizar lista de secciones
 * Las secciones son MARCADORES
 * @param {Element} container 
 * @param {Array} sections - Array de marcadores {id, name, pos}
 */
export function renderSections(container, sections) {
  container.innerHTML = '';
  
  if (!sections || sections.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <p>${i18n.t('no_sections_found')}</p>
        <p class="hint">${i18n.t('add_markers_sections')}</p>
      </div>
    `;
    return;
  }
  
  sections.forEach(section => {
    const sectionBtn = createSectionButton(section);
    container.appendChild(sectionBtn);
  });
}

/**
 * Crear botón de sección
 * @param {object} section - Marcador {id, name, pos}
 * @returns {Element}
 */
function createSectionButton(section) {
  const btn = document.createElement('button');
  btn.className = 'section-btn';
  
  // Si esta sección es la que está pendiente de salto, añadir clase
  if (section.id === state.getPendingSectionId()) {
    btn.classList.add('pending');
  }
  
  btn.setAttribute('data-section-id', section.id);
  
  btn.innerHTML = `
    <div class="section-name">${utils.escapeHtml(section.name)}</div>
  `;
  
  btn.addEventListener('click', async () => {
    // Obtener el modo actual desde el estado en el momento del click
    const currentJumpMode = state.state.jumpMode;
    console.log(`🔘 Botón clickeado - modo: "${currentJumpMode}"`);
    await handleSectionClick(section.id, currentJumpMode);
  });
  
  return btn;
}

/**
 * Manejar clic en sección
 * @param {number} sectionId - ID del marcador (sección)
 * @param {string} jumpMode 
 */
async function handleSectionClick(sectionId, jumpMode) {
  console.log(`🖱️ Click en sección ${sectionId}, modo: ${jumpMode}`);
  
  try {
    // Actualizar estado
    state.setCurrentRegion(sectionId);
    
    // Ejecutar salto según modo
    if (jumpMode === 'bar') {
      console.log('📍 Salto al compás...');
      setPendingSection(sectionId);
      await api.jumpToSection(sectionId); // El script Lua gestiona el timing
    } else if (jumpMode === 'region-end') {
      console.log('📍 Salto al final de región...');
      setPendingSection(sectionId);
      await api.jumpToSection(sectionId); // El script Lua gestiona el timing
    } else {
      console.log('📍 Salto inmediato...');
      await api.jumpToSection(sectionId);
      highlightActiveSection(sectionId);
    }
    
    console.log('✅ Salto completado');
    
  } catch (error) {
    console.error('❌ Error:', error);
    alert(`${i18n.t('jump_error')}: ${error.message}`);
  }
}

/**
 * Marcar sección como pendiente (esperando salto programado)
 * @param {number} sectionId 
 */
export function setPendingSection(sectionId) {
  // Actualizar estado persistente
  state.setPendingSectionId(sectionId);
  
  // Quitar pending anterior
  document.querySelectorAll('.section-btn.pending').forEach(btn => {
    btn.classList.remove('pending');
  });
  
  // Añadir pending a la seleccionada
  if (sectionId !== null && sectionId !== undefined) {
    const pendingBtn = document.querySelector(`.section-btn[data-section-id="${sectionId}"]`);
    if (pendingBtn) {
      pendingBtn.classList.add('pending');
      console.log(`🟠 Sección ${sectionId} marcada como pendiente`);
    }
  }
}

/**
 * Resaltar sección activa
 * @param {number} sectionId 
 */
export function highlightActiveSection(sectionId) {
  // Si la sección que se activa es la que estaba pendiente, limpiar el estado pendiente
  if (sectionId !== null && sectionId === state.getPendingSectionId()) {
    state.setPendingSectionId(null);
  }

  // Quitar active anterior de todos los botones
  document.querySelectorAll('.section-btn.active').forEach(btn => {
    btn.classList.remove('active');
  });
  
  // Si no hay nada pendiente en el estado, asegurar que no haya clases pending en el DOM
  if (!state.getPendingSectionId()) {
    document.querySelectorAll('.section-btn.pending').forEach(btn => {
      btn.classList.remove('pending');
    });
  }
  
  // Añadir resaltado a la actual
  if (sectionId !== null && sectionId !== undefined) {
    const activeBtn = document.querySelector(`.section-btn[data-section-id="${sectionId}"]`);
    if (activeBtn) {
      activeBtn.classList.add('active');
    }
  }
}

/**
 * Renderizar controles de transporte
 * @param {Element} container 
 */
export function renderTransport(container) {
  container.innerHTML = `
    <button id="btn-play" class="transport-btn" title="Play">
      <span class="icon">▶️</span>
    </button>
    <button id="btn-stop" class="transport-btn" title="Stop">
      <span class="icon">⏹️</span>
    </button>
    <button id="btn-goto-start" class="transport-btn" title="Ir al inicio de canción">
      <span class="icon">⏮️</span>
    </button>
  `;
  
  // Event listeners
  document.getElementById('btn-play').addEventListener('click', async () => {
    console.log('🖱️ Click en botón Play detectado');
    try {
      await api.play();
      console.log('✅ Play ejecutado');
      updateTransportState(true);
    } catch (error) {
      console.error('❌ Error en play:', error);
      alert(`${i18n.t('play_error')}: ${error.message}`);
    }
  });
  
  document.getElementById('btn-stop').addEventListener('click', async () => {
    console.log('🖱️ Click en botón Stop detectado');
    try {
      await api.stop();
      console.log('✅ Stop ejecutado');
      updateTransportState(false);
    } catch (error) {
      console.error('❌ Error en stop:', error);
      alert(`${i18n.t('stop_error')}: ${error.message}`);
    }
  });
  
  document.getElementById('btn-goto-start').addEventListener('click', async () => {
    console.log('🖱️ Click en botón Ir al inicio detectado');
    try {
      await goToSongStart();
      console.log('✅ Ir al inicio ejecutado');
    } catch (error) {
      console.error('❌ Error en goto start:', error);
      alert(`Error: ${error.message}`);
    }
  });
}

/**
 * Actualizar estado visual del transporte
 * @param {boolean} isPlaying 
 */
function updateTransportState(isPlaying) {
  const playBtn = document.getElementById('btn-play');
  if (playBtn) {
    utils.toggleClass(playBtn, 'active', isPlaying);
  }
}

/**
 * Ir al inicio de la canción actual
 */
async function goToSongStart() {
  const currentSong = state.getCurrentSong();
  if (currentSong) {
    await api.seekTo(currentSong.pos);
  }
}

/**
 * Renderizar toggle de modo de salto
 * @param {Element} container 
 * @param {string} currentMode 
 */
export function renderJumpModeToggle(container, currentMode) {
  container.innerHTML = `
    <div class="jump-mode-toggle">
      <label>Modo de salto:</label>
      <div class="toggle-buttons">
        <button class="toggle-btn ${currentMode === 'immediate' ? 'active' : ''}" data-mode="immediate">
          Inmediato
        </button>
        <button class="toggle-btn ${currentMode === 'bar' ? 'active' : ''}" data-mode="bar">
          Al compás
        </button>
        <button class="toggle-btn ${currentMode === 'region-end' ? 'active' : ''}" data-mode="region-end">
          Al finalizar
        </button>
      </div>
    </div>
  `;
  
  // Event listeners
  container.querySelectorAll('.toggle-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const mode = btn.getAttribute('data-mode');
      state.setJumpMode(mode);
      
      // Actualizar UI
      container.querySelectorAll('.toggle-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      // Auto-configurar REAPER cuando se cambia el modo
      console.log(`🔧 Modo cambiado a: ${mode}, configurando REAPER...`);
      await api.configureJumpMode(mode, state.state.barCount);
    });
  });
}

/**
 * Renderizar opciones de mezcla
 * @param {Element} container 
 */
export function renderMixerOptions(container) {
  const barCount = state.state.barCount || 1;
  
  container.innerHTML = `
    <div class="mixer-options">
      <label class="bar-count-label">
        <span>🎵 Esperar compases (modo "Al compás"):</span>
        <select id="bar-count-select">
          <option value="1" ${barCount === 1 ? 'selected' : ''}>1 compás</option>
          <option value="2" ${barCount === 2 ? 'selected' : ''}>2 compases</option>
          <option value="4" ${barCount === 4 ? 'selected' : ''}>4 compases</option>
          <option value="8" ${barCount === 8 ? 'selected' : ''}>8 compases</option>
          <option value="16" ${barCount === 16 ? 'selected' : ''}>16 compases</option>
        </select>
      </label>
    </div>
  `;
  
  // Event listener
  const select = container.querySelector('#bar-count-select');
  select.addEventListener('change', async (e) => {
    const count = parseInt(e.target.value);
    state.setBarCount(count);
    console.log(`🎵 Compases cambiados a: ${count}`);
    
    // Si estamos en modo "bar", reconfigurar REAPER inmediatamente
    if (state.state.jumpMode === 'bar') {
      console.log('  → Reconfigurando REAPER con nuevo valor...');
      await api.configureJumpMode('bar', count);
    }
  });
}

/**
 * Renderizar faders de mezcla
 * @param {Element} container 
 * @param {Array} tracks 
 */
export function renderMixerFaders(container, tracks) {
  container.innerHTML = '';
  
  if (!tracks || tracks.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <p>No se encontraron pistas</p>
      </div>
    `;
    return;
  }
  
  // Filtrar pistas visibles
  const visibleTracks = tracks.filter(t => t.isVisible);
  
  visibleTracks.forEach(track => {
    const fader = createFader(track);
    container.appendChild(fader);
  });
}

/**
 * Crear fader de pista
 * @param {object} track 
 * @returns {Element}
 */
function createFader(track) {
  const fader = document.createElement('div');
  fader.className = 'fader';
  fader.setAttribute('data-track-id', track.id);
  
  fader.innerHTML = `
    <div class="fader-header">
      <button class="mute-btn ${track.mute ? 'active' : ''}" data-track-id="${track.id}">
        M
      </button>
      <div class="track-name">${utils.escapeHtml(utils.truncate(track.name, 12))}</div>
    </div>
    
    <div class="fader-controls">
      <input type="range" 
             class="volume-slider" 
             min="0" max="1" step="0.01" 
             value="${track.vol}"
             data-track-id="${track.id}"
             orient="vertical">
      <div class="volume-value">${utils.formatVolumeDb(track.vol)}</div>
    </div>
    
    <div class="pan-control">
      <input type="range" 
             class="pan-slider" 
             min="-1" max="1" step="0.01" 
             value="${track.pan}"
             data-track-id="${track.id}">
      <div class="pan-value">${utils.formatPan(track.pan)}</div>
    </div>
  `;
  
  // Event listeners
  const muteBtn = fader.querySelector('.mute-btn');
  muteBtn.addEventListener('click', async () => {
    const newMuteState = !muteBtn.classList.contains('active');
    await api.setTrackMute(track.id, newMuteState);
    utils.toggleClass(muteBtn, 'active', newMuteState);
  });
  
  // Control de volumen
  const volSlider = fader.querySelector('.volume-slider');
  const volValue = fader.querySelector('.volume-value');
  
  let lastVolValue = null;
  let volTimerId = null;
  
  const sendVolChange = async (value) => {
    try {
      await api.setTrackVol(track.id, parseFloat(value));
      lastVolValue = value;
    } catch (error) {
      console.error('Error ajustando volumen:', error);
    }
  };
  
  volSlider.addEventListener('input', (e) => {
    let value = parseFloat(e.target.value);
    
    // Snap a 0dB (0.716 en el fader)
    const zeroDB = 0.716;
    const snapRange = 0.03; // ±3% de snap
    
    if (Math.abs(value - zeroDB) < snapRange) {
      value = zeroDB;
      e.target.value = value;
    }
    
    // Actualizar UI inmediatamente
    volValue.textContent = utils.formatVolumeDb(value);
    
    // Enviar a REAPER con throttle, pero asegurar el último valor
    clearTimeout(volTimerId);
    
    // Si ha pasado tiempo suficiente desde el último envío, enviar ahora
    const now = Date.now();
    if (!volSlider.lastSendTime || (now - volSlider.lastSendTime) > 100) {
      sendVolChange(value);
      volSlider.lastSendTime = now;
    } else {
      // Si no, programar para enviar después
      volTimerId = setTimeout(() => {
        sendVolChange(value);
        volSlider.lastSendTime = Date.now();
      }, 100);
    }
  });
  
  // Asegurar que el último valor se envíe cuando se suelta el fader
  volSlider.addEventListener('change', (e) => {
    const value = parseFloat(e.target.value);
    if (value !== lastVolValue) {
      clearTimeout(volTimerId);
      sendVolChange(value);
    }
  });
  
  // Control de panorama
  const panSlider = fader.querySelector('.pan-slider');
  const panValue = fader.querySelector('.pan-value');
  
  let lastPanValue = null;
  let panTimerId = null;
  
  const sendPanChange = async (value) => {
    try {
      await api.setTrackPan(track.id, parseFloat(value));
      lastPanValue = value;
    } catch (error) {
      console.error('Error ajustando pan:', error);
    }
  };
  
  panSlider.addEventListener('input', (e) => {
    let value = parseFloat(e.target.value);
    
    // Snap al centro (0.0)
    const snapRange = 0.08; // ±8% de snap
    
    if (Math.abs(value) < snapRange) {
      value = 0.0;
      e.target.value = value;
    }
    
    // Actualizar UI inmediatamente
    panValue.textContent = utils.formatPan(value);
    
    // Enviar a REAPER con throttle, pero asegurar el último valor
    clearTimeout(panTimerId);
    
    // Si ha pasado tiempo suficiente desde el último envío, enviar ahora
    const now = Date.now();
    if (!panSlider.lastSendTime || (now - panSlider.lastSendTime) > 100) {
      sendPanChange(value);
      panSlider.lastSendTime = now;
    } else {
      // Si no, programar para enviar después
      panTimerId = setTimeout(() => {
        sendPanChange(value);
        panSlider.lastSendTime = Date.now();
      }, 100);
    }
  });
  
  // Asegurar que el último valor se envíe cuando se suelta el fader
  panSlider.addEventListener('change', (e) => {
    const value = parseFloat(e.target.value);
    if (value !== lastPanValue) {
      clearTimeout(panTimerId);
      sendPanChange(value);
    }
  });
  
  return fader;
}

/**
 * Actualizar valores de faders existentes sin recrearlos
 * @param {Array} tracks - Array de pistas con valores actualizados
 */
export function updateMixerFaders(tracks) {
  if (!tracks || tracks.length === 0) return;
  
  tracks.forEach(track => {
    const faderEl = document.querySelector(`.fader[data-track-id="${track.id}"]`);
    if (!faderEl) return;
    
    // Actualizar volumen (solo si el usuario no está interactuando)
    const volSlider = faderEl.querySelector('.volume-slider');
    const volValue = faderEl.querySelector('.volume-value');
    
    if (volSlider && !volSlider.matches(':active')) {
      const currentVal = parseFloat(volSlider.value);
      const newVal = track.vol;
      
      // Solo actualizar si hay diferencia significativa (evitar micro-cambios)
      if (Math.abs(currentVal - newVal) > 0.01) {
        volSlider.value = newVal;
        volValue.textContent = utils.formatVolumeDb(newVal);
      }
    }
    
    // Actualizar pan (solo si el usuario no está interactuando)
    const panSlider = faderEl.querySelector('.pan-slider');
    const panValue = faderEl.querySelector('.pan-value');
    
    if (panSlider && !panSlider.matches(':active')) {
      const currentVal = parseFloat(panSlider.value);
      const newVal = track.pan;
      
      // Solo actualizar si hay diferencia significativa
      if (Math.abs(currentVal - newVal) > 0.01) {
        panSlider.value = newVal;
        panValue.textContent = utils.formatPan(newVal);
      }
    }
    
    // Actualizar mute
    const muteBtn = faderEl.querySelector('.mute-btn');
    if (muteBtn) {
      const isMuted = track.mute;
      if (muteBtn.classList.contains('active') !== isMuted) {
        utils.toggleClass(muteBtn, 'active', isMuted);
      }
    }
  });
}

/**
 * Mostrar mensaje de error
 * @param {string} message 
 */
export function showError(message) {
  // TODO: Implementar toast o modal de error
  console.error(message);
  alert(message);
}

/**
 * Mostrar indicador de carga
 * @param {Element} container 
 */
export function showLoading(container) {
  container.innerHTML = `
    <div class="loading">
      <div class="spinner"></div>
      <p>Cargando...</p>
    </div>
  `;
}

console.log('✅ UI cargado');
