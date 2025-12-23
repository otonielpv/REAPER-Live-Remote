/**
 * api.js - Capa de acceso a REAPER Web API (SOLO HTTP)
 * 
 * Versión simplificada que solo usa HTTP para:
 * - Leer datos (markers, regions, tracks)
 * - Saltar a marcadores/regiones (seekTo)
 * - Controlar mixer (volumen, pan, mute)
 * - Comunicarse con smooth_seeking_control_v3.lua
 * 
 * Los saltos "al compás" y "al final" se manejan directamente desde REAPER
 * mediante el script Lua que monitorea ExtState.
 */

import * as state from './state.js';

// Configuración de la API
const config = {
  baseURL: window.location.origin, // TEMPORAL: IP fija para pruebas
  username: '', // Se carga desde localStorage
  password: '', // Se carga desde localStorage
  useMock: window.MOCK === true, // Activar modo mock con window.MOCK = true
};

// Mock data para desarrollo sin REAPER
let mockData = null;

/**
 * Inicializar la API
 */
export async function init() {
  if (config.useMock) {
    console.log('🔧 Modo MOCK activado - usando datos de prueba');
    try {
      const response = await fetch('../tests/mock-api.json');
      mockData = await response.json();
      console.log('✅ Mock data cargada:', mockData);
    } catch (error) {
      console.error('❌ Error cargando mock data:', error);
    }
  } else {
    console.log('🌐 Conectando a REAPER en:', config.baseURL);
    // Cargar credenciales desde localStorage
    config.username = localStorage.getItem('reaper_username') || '';
    config.password = localStorage.getItem('reaper_password') || '';
  }
}

/**
 * Hacer petición HTTP a REAPER
 */
async function makeRequest(endpoint) {
  if (config.useMock) {
    // Modo mock: retornar datos simulados
    await new Promise(resolve => setTimeout(resolve, 100)); // Simular latencia
    return mockData;
  }

  const headers = {};
  if (config.username && config.password) {
    headers['Authorization'] = 'Basic ' + btoa(config.username + ':' + config.password);
  }

  try {
    console.log(`🔌 HTTP Request: ${config.baseURL}${endpoint}`);
    
    const response = await fetch(config.baseURL + endpoint, { 
      headers,
      cache: 'no-cache',
      mode: 'cors'
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const text = await response.text();
    console.log(`📡 HTTP Response (${text.length} chars)`);
    
    return text;
  } catch (error) {
    console.error('❌ Error en petición a REAPER:', endpoint, error);
    throw error;
  }
}

// ==============================================================
// LECTURA DE DATOS
// ==============================================================

/**
 * Obtener todos los marcadores
 * @returns {Promise<Array<{id: number, name: string, pos: number}>>}
 */
export async function getMarkers() {
  if (config.useMock) {
    await init();
    return mockData.markers;
  }

  const response = await makeRequest('/_/MARKER');
  
  // Parsear respuesta de REAPER
  // Formato: MARKER\t[NOMBRE]\t[ID]\t[POSICION]\t[FLAGS]
  const markers = [];
  const lines = response.split('\n');
  
  for (const line of lines) {
    if (line.startsWith('MARKER\t')) {
      const parts = line.split('\t');
      if (parts.length >= 4) {
        markers.push({
          id: parseInt(parts[2]),
          name: parts[1],
          pos: parseFloat(parts[3])
        });
      }
    }
  }
  
  console.log(`✅ Cargados ${markers.length} marcadores`);
  return markers;
}

/**
 * Obtener todas las regiones
 * @returns {Promise<Array<{id: number, name: string, start: number, end: number}>>}
 */
export async function getRegions() {
  if (config.useMock) {
    await init();
    return mockData.regions;
  }

  const response = await makeRequest('/_/REGION');
  
  // Parsear respuesta de REAPER
  // Formato: REGION\t[NOMBRE]\t[ID]\t[START]\t[END]\t[FLAGS]
  const regions = [];
  const lines = response.split('\n');
  
  for (const line of lines) {
    if (line.startsWith('REGION\t')) {
      const parts = line.split('\t');
      if (parts.length >= 5) {
        regions.push({
          id: parseInt(parts[2]),
          name: parts[1],
          start: parseFloat(parts[3]),
          end: parseFloat(parts[4])
        });
      }
    }
  }
  
  console.log(`✅ Cargadas ${regions.length} regiones`);
  return regions;
}

/**
 * Obtener lista de pistas
 * @returns {Promise<Array<{id: number, name: string, vol: number, pan: number, mute: boolean}>>}
 */
export async function getTracks() {
  if (config.useMock) {
    await init();
    return mockData.tracks;
  }

  const response = await makeRequest('/_/TRACK');
  
  // Parsear respuesta de REAPER
  // Formato: TRACK\t[INDEX]\t[NAME]\t[FLAGS]\t[VOLUME]\t[PAN]\t...
  const tracks = [];
  const lines = response.split('\n');
  
  for (const line of lines) {
    if (line.startsWith('TRACK\t')) {
      const parts = line.split('\t');
      if (parts.length >= 6) {
        const trackIndex = parseInt(parts[1]);
        const trackName = parts[2];
        const flags = parseInt(parts[3]);
        const volume = parseFloat(parts[4]);
        const pan = parseFloat(parts[5]);
        
        // Flags: bit 3 = muted
        const isMuted = (flags & (1 << 3)) !== 0;
        
        // Saltar MASTER (index 0)
        if (trackIndex === 0) continue;
        
        // Convertir volumen REAPER (0-4) a fader (0-1)
        let faderValue;
        if (volume <= 0.0001) {
          faderValue = 0;
        } else if (volume <= 1.0) {
          // De 0-1 REAPER a 0-0.716 fader
          faderValue = Math.sqrt(volume) * 0.716;
        } else {
          // De 1-4 REAPER a 0.716-1 fader
          faderValue = 0.716 + ((volume - 1) / 3) * (1 - 0.716);
        }
        
        tracks.push({
          id: trackIndex,
          name: trackName,
          vol: faderValue,
          pan: pan,
          mute: isMuted,
          isVisible: true  // Por defecto, todas las pistas son visibles
        });
      }
    }
  }
  
  console.log(`✅ Cargadas ${tracks.length} pistas`);
  return tracks;
}

/**
 * Obtener estado de reproducción actual
 * @returns {Promise<{isPlaying: boolean, pos: number}>}
 */
export async function getPlayState() {
  if (config.useMock) {
    await init();
    return mockData.playState;
  }

  const response = await makeRequest('/_/TRANSPORT');
  
  // Parsear TRANSPORT
  // Formato: TRANSPORT\t[PLAY_STATE]\t[POSITION_SECONDS]\t...
  const lines = response.split('\n');
  let isPlaying = false;
  let pos = 0.0;
  
  for (const line of lines) {
    if (line.startsWith('TRANSPORT\t')) {
      const parts = line.split('\t');
      if (parts.length >= 3) {
        // 0=stopped, 1=playing, 2=paused, 5=recording
        isPlaying = parseInt(parts[1]) === 1;
        pos = parseFloat(parts[2]);
      }
      break;
    }
  }
  
  return { isPlaying, pos };
}

// ==============================================================
// TRANSPORTE
// ==============================================================

/**
 * Iniciar reproducción
 */
export async function play() {
  if (config.useMock) {
    console.log('▶️ MOCK: Play');
    if (mockData) mockData.playState.isPlaying = true;
    return;
  }

  console.log('▶️ Enviando comando PLAY...');
  await makeRequest('/_/1007;TRANSPORT'); // Comando 1007 = Play
  console.log('✅ Play ejecutado');
}

/**
 * Detener reproducción
 */
export async function stop() {
  if (config.useMock) {
    console.log('⏹️ MOCK: Stop');
    if (mockData) mockData.playState.isPlaying = false;
    return;
  }

  console.log('⏹️ Enviando comando STOP...');
  await makeRequest('/_/40667;TRANSPORT'); // Comando 40667 = Stop
  console.log('✅ Stop ejecutado');
}

/**
 * Buscar a una posición específica
 * @param {number} seconds - Posición en segundos
 */
export async function seekTo(seconds) {
  if (config.useMock) {
    console.log(`⏩ MOCK: Seek to ${seconds}s`);
    if (mockData) mockData.playState.pos = seconds;
    return;
  }

  console.log(`⏩ SEEK a ${seconds}s...`);
  await makeRequest(`/_/SET/POS/${seconds};TRANSPORT`);
  console.log(`✅ SEEK completado`);
}

// ==============================================================
// SALTOS A MARCADORES/REGIONES
// ==============================================================

/**
 * Saltar a un marcador (inmediato)
 * Usa seekTo directo a la posición del marcador (sin límite de cantidad)
 * @param {number} markerId - ID del marcador
 */
export async function jumpToMarker(markerId) {
  if (config.useMock) {
    console.log(`🎯 MOCK: Jump to marker ${markerId}`);
    const marker = mockData.markers.find(m => m.id === markerId);
    if (marker) await seekTo(marker.pos);
    return;
  }

  console.log(`🎯 Saltando a marcador ${markerId}...`);
  
  // Obtener el marcador
  const markers = await getMarkers();
  const marker = markers.find(m => m.id === markerId);
  
  if (!marker) {
    console.warn(`⚠️ Marcador ${markerId} no encontrado`);
    return;
  }
  
  console.log(`📍 Marcador encontrado: "${marker.name}" @ ${marker.pos}s`);
  
  // Si el modo es diferido (bar o region-end), usar la lógica de Lua
  if (state.state.jumpMode === 'bar' || state.state.jumpMode === 'region-end') {
    return await requestDeferredJump(marker.pos);
  }

  // Usar seekTo directo (funciona para cualquier cantidad de marcadores)
  await seekTo(marker.pos);
  console.log(`✅ Salto completado`);
}

/**
 * Saltar a una región (inmediato)
 * @param {number} regionId - ID de la región
 */
export async function jumpToRegion(regionId) {
  if (config.useMock) {
    console.log(`🎯 MOCK: Jump to region ${regionId}`);
    const region = mockData.regions.find(r => r.id === regionId);
    if (region) {
      if (state.state.jumpMode === 'bar' || state.state.jumpMode === 'region-end') {
        return await requestDeferredJump(region.start);
      }
      await seekTo(region.start);
    }
    return;
  }

  console.log(`🎯 Saltando a región ${regionId}...`);
  
  const regions = await getRegions();
  const region = regions.find(r => r.id === regionId);
  
  if (!region) {
    console.warn(`⚠️ Región ${regionId} no encontrada`);
    return;
  }
  
  console.log(`📍 Región encontrada: "${region.name}" @ ${region.start}s`);

  // Si el modo es diferido (bar o region-end), usar la lógica de Lua
  if (state.state.jumpMode === 'bar' || state.state.jumpMode === 'region-end') {
    return await requestDeferredJump(region.start);
  }

  await seekTo(region.start);
  console.log(`✅ Salto completado`);
}

/**
 * Solicitar un salto diferido manejado por Lua (Fluent Jump)
 * Esto evita el "locked seek" de REAPER y permite cancelaciones sin ruidos.
 * 
 * @param {number} targetPos - Posición destino en segundos
 * @returns {Promise<boolean>}
 */
export async function requestDeferredJump(targetPos) {
  if (config.useMock) {
    console.log(`🚀 MOCK: Request deferred jump to ${targetPos}s`);
    return true;
  }

  console.log(`🚀 Solicitando salto diferido a ${targetPos}s...`);

  try {
    const SMOOTH_CMD = state.state.smoothSeekingScriptCmd;
    if (!SMOOTH_CMD) {
      console.warn('⚠️ Script Lua no configurado, cayendo a seek inmediato');
      return await seekTo(targetPos);
    }

    // 1. Establecer posición destino
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/deferred_jump_pos/${targetPos}`);
    
    // 2. Establecer acción para el script
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/smooth_seeking_action/request_jump`);
    
    // 3. Ejecutar script
    await makeRequest(`/_/${SMOOTH_CMD}`);
    
    console.log('✅ Solicitud de salto diferido enviada a Lua');
    return true;
  } catch (error) {
    console.error('❌ Error solicitando salto diferido:', error);
    return await seekTo(targetPos); // Fallback a inmediato
  }
}

/**
 * Saltar a una sección
 * Las secciones son MARCADORES
 * @param {number} sectionId - ID del marcador (sección)
 */
export async function jumpToSection(sectionId) {
  return await jumpToMarker(sectionId);
}

// ==============================================================
// COMUNICACIÓN CON SCRIPT SMOOTH SEEKING
// ==============================================================

/**
 * Cancelar un salto programado (modo bar o region-end)
 * Fuerza el modo a "immediate" para desactivar smooth seeking
 * @returns {Promise<boolean>}
 */
export async function cancelScheduledJump() {
  if (config.useMock) {
    console.log('🚫 MOCK: Cancelar salto programado');
    return true;
  }

  console.log('🚫 Cancelando salto programado...');
  
  try {
    const SMOOTH_CMD = state.state.smoothSeekingScriptCmd;
    
    if (!SMOOTH_CMD) {
      console.log('⚠️ Script no configurado, no hay saltos que cancelar');
      return true;
    }
    
    // PASO 1: Establecer acción específica de cancelación
    console.log('  → Escribiendo ExtState: smooth_seeking_action = cancel');
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/smooth_seeking_action/cancel`);
    
    // PASO 2: También poner el modo en immediate por si acaso
    console.log('  → Escribiendo ExtState: jump_mode = immediate');
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/jump_mode/immediate`);
    
    // PASO 3: Ejecutar script
    console.log('  → Ejecutando script');
    await makeRequest(`/_/${SMOOTH_CMD}`);
    
    console.log('✅ Salto cancelado (smooth seeking desactivado)');
    return true;
    
  } catch (error) {
    console.error('❌ Error cancelando salto:', error);
    return false;
  }
}

/**
 * Configurar modo de salto en REAPER vía ExtState + ejecutar script Lua
 * 
 * @param {string} jumpMode - "immediate" | "bar" | "region-end"
 * @param {number} barCount - Número de compases (solo para modo "bar")
 * @returns {Promise<boolean>} - true si se configuró correctamente
 */
export async function configureJumpMode(jumpMode, barCount = 1) {
  if (config.useMock) {
    console.log(`⚙️ MOCK: Configure jump mode: ${jumpMode}, bars: ${barCount}`);
    return true;
  }

  console.log(`⚙️ Configurando modo de salto: ${jumpMode}, compases: ${barCount}`);
  
  try {
    // Verificar que el script esté configurado
    const SMOOTH_CMD = state.state.smoothSeekingScriptCmd;
    
    if (!SMOOTH_CMD) {
      const msg = '⚠️ Script Lua no configurado.\n\n' +
                  'Para usar modos "Al compás" y "Al finalizar":\n' +
                  '1. Actions → Show action list\n' +
                  '2. New action... → Load ReaScript...\n' +
                  '3. Selecciona smooth_seeking_control_v3.lua\n' +
                  '4. Copia el Command ID\n' +
                  '5. Edita webroot/js/state.js y pega el Command ID\n\n' +
                  'El modo "Inmediato" seguirá funcionando sin el script.';
      
      console.warn('⚠️ smoothSeekingScriptCmd no configurado en state.js');
      console.warn('⚠️ Registra smooth_seeking_control_v3.lua y añade el Command ID');
      
      // Si es modo inmediato, no es necesario el script
      if (jumpMode === 'immediate') {
        console.log('✅ Modo inmediato: no requiere script Lua');
        return true;
      }
      
      // Para otros modos, mostrar error
      alert(msg);
      return false;
    }
    
    // PASO 1: Establecer parámetros en ExtState
    console.log(`  → Escribiendo ExtState: jump_mode = ${jumpMode}`);
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/jump_mode/${jumpMode}`);
    
    if (jumpMode === 'bar') {
      console.log(`  → Escribiendo ExtState: bar_count = ${barCount}`);
      await makeRequest(`/_/SET/EXTSTATE/LiveRemote/bar_count/${barCount}`);
    }
    
    // PASO 2: Establecer acción para el script
    console.log(`  → Escribiendo ExtState: smooth_seeking_action = auto_config`);
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/smooth_seeking_action/auto_config`);
    
    // PASO 3: Ejecutar script smooth_seeking_control_v3.lua
    console.log(`  → Ejecutando script: ${SMOOTH_CMD}`);
    await makeRequest(`/_/${SMOOTH_CMD}`);
    
    console.log(`✅ REAPER configurado para modo: ${jumpMode}`);
    return true;
    
  } catch (error) {
    console.error('❌ Error configurando REAPER:', error);
    alert(`Error al configurar REAPER: ${error.message}\n\nVerifica que el script esté registrado correctamente.`);
    return false;
  }
}

/**
 * Obtener estado actual de smooth seeking desde REAPER
 * Nota: Requiere ejecutar el script con acción "status" primero
 * 
 * @returns {Promise<{enabled: boolean, mode: string, measures: number}>}
 */
export async function getSmoothSeekingStatus() {
  if (config.useMock) {
    return { enabled: true, mode: 'measures', measures: 1 };
  }

  try {
    // Solicitar estado
    await makeRequest(`/_/SET/EXTSTATE/LiveRemote/smooth_seeking_action/status`);
    
    const SMOOTH_CMD = state.state.smoothSeekingScriptCmd;
    if (!SMOOTH_CMD) {
      console.warn('⚠️ smoothSeekingScriptCmd no configurado');
      return { enabled: false, mode: 'measures', measures: 0 };
    }
    
    await makeRequest(`/_/${SMOOTH_CMD}`);
    
    // El script Lua escribe el resultado en ExtState, pero la Web API
    // estándar de REAPER no tiene GET de ExtState
    // Solución: confiar en los valores locales de state.js
    
    console.warn('⚠️ Lectura de estado desde REAPER no disponible en Web API estándar');
    return { 
      enabled: state.state.jumpMode !== 'immediate',
      mode: state.state.jumpMode === 'bar' ? 'measures' : 'marker/region',
      measures: state.state.barCount || 1
    };
    
  } catch (error) {
    console.error('❌ Error obteniendo estado:', error);
    return { enabled: false, mode: 'measures', measures: 0 };
  }
}

// ==============================================================
// MIXER
// ==============================================================

/**
 * Establecer volumen de una pista
 * @param {number} id - ID de la pista (1-based)
 * @param {number} value0to1 - Volumen del fader (0.0 a 1.0)
 */
export async function setTrackVol(id, value0to1) {
  if (config.useMock) {
    console.log(`🔊 MOCK: Set track ${id} vol to ${value0to1.toFixed(3)}`);
    if (mockData) {
      const track = mockData.tracks.find(t => t.id === id);
      if (track) track.vol = value0to1;
    }
    return;
  }

  // Convertir fader (0-1) a volumen REAPER (0-4)
  let reaperVol;
  if (value0to1 <= 0.0001) {
    reaperVol = 0; // Silencio total
  } else if (value0to1 < 0.716) {
    // 0-0.716 → 0-1 (de -inf a 0dB, logarítmico)
    reaperVol = Math.pow(value0to1 / 0.716, 2);
  } else {
    // 0.716-1.0 → 1-4 (de 0dB a +12dB, lineal)
    reaperVol = 1 + ((value0to1 - 0.716) / (1 - 0.716)) * 3;
  }
  
  await makeRequest(`/_/SET/TRACK/${id}/VOL/${reaperVol.toFixed(6)}`);
}

/**
 * Establecer panorama de una pista
 * @param {number} id - ID de la pista
 * @param {number} valueNeg1to1 - Pan (-1.0 a 1.0)
 */
export async function setTrackPan(id, valueNeg1to1) {
  if (config.useMock) {
    console.log(`🎚️ MOCK: Set track ${id} pan to ${valueNeg1to1.toFixed(3)}`);
    if (mockData) {
      const track = mockData.tracks.find(t => t.id === id);
      if (track) track.pan = valueNeg1to1;
    }
    return;
  }

  await makeRequest(`/_/SET/TRACK/${id}/PAN/${valueNeg1to1.toFixed(6)}`);
}

/**
 * Activar/desactivar mute de una pista
 * @param {number} id - ID de la pista
 * @param {boolean} muted - True para mutear
 */
export async function setTrackMute(id, muted) {
  if (config.useMock) {
    console.log(`🔇 MOCK: Set track ${id} mute to ${muted}`);
    if (mockData) {
      const track = mockData.tracks.find(t => t.id === id);
      if (track) track.mute = muted;
    }
    return;
  }

  const muteValue = muted ? 1 : 0;
  await makeRequest(`/_/SET/TRACK/${id}/MUTE/${muteValue}`);
}

// ==============================================================
// CONFIGURACIÓN
// ==============================================================

/**
 * Guardar credenciales
 * @param {string} username 
 * @param {string} password 
 */
export function saveCredentials(username, password) {
  config.username = username;
  config.password = password;
  localStorage.setItem('reaper_username', username);
  localStorage.setItem('reaper_password', password);
}

/**
 * Obtener configuración actual
 */
export function getConfig() {
  return { ...config };
}

// ==============================================================
// POLLING PERIÓDICO
// ==============================================================

let pollingInterval = null;
let pollingCallbacks = {
  onTracksUpdate: null,
  onPlayStateUpdate: null
};

/**
 * Iniciar polling periódico para sincronizar estado
 * @param {Object} callbacks - { onTracksUpdate, onPlayStateUpdate }
 * @param {number} intervalMs - Intervalo en milisegundos (default: 500ms)
 */
export function startPolling(callbacks = {}, intervalMs = 500) {
  if (pollingInterval) {
    console.warn('⚠️ Polling ya está activo');
    return;
  }
  
  pollingCallbacks = callbacks;
  
  console.log(`🔄 Iniciando polling cada ${intervalMs}ms`);
  
  pollingInterval = setInterval(async () => {
    try {
      // Actualizar pistas si hay callback
      if (pollingCallbacks.onTracksUpdate) {
        const tracks = await getTracks();
        pollingCallbacks.onTracksUpdate(tracks);
      }
      
      // Actualizar estado de reproducción si hay callback
      if (pollingCallbacks.onPlayStateUpdate) {
        const playState = await getPlayState();
        pollingCallbacks.onPlayStateUpdate(playState);
      }
    } catch (error) {
      console.error('❌ Error en polling:', error);
    }
  }, intervalMs);
}

/**
 * Detener polling periódico
 */
export function stopPolling() {
  if (pollingInterval) {
    console.log('⏹️ Deteniendo polling');
    clearInterval(pollingInterval);
    pollingInterval = null;
  }
}

/**
 * Verificar si el polling está activo
 * @returns {boolean}
 */
export function isPolling() {
  return pollingInterval !== null;
}

// ==============================================================
// INICIALIZACIÓN
// ==============================================================

// Inicializar al cargar
init().catch(error => console.error('Error inicializando API:', error));
