/**
 * state.js - Estado global de la aplicación
 * 
 * Mantiene el estado de la sesión actual: canciones, regiones, pistas,
 * canción actual, región actual, modo de salto, etc.
 */

export const state = {
  // Datos cargados desde REAPER
  markers: [],        // Lista de marcadores (secciones)
  regions: [],        // Lista de regiones (canciones)
  tracks: [],         // Lista de pistas
  
  // Estado de navegación
  currentSongId: null,     // ID de la región de la canción actual
  currentRegionId: null,   // ID del marcador actual
  
  // Preferencias de usuario
  jumpMode: 'immediate',   // 'immediate' | 'bar' | 'region-end'
  barCount: 1,             // Cantidad de compases a esperar (modo 'bar')
  
  // ============================================================
  // CONFIGURACIÓN DEL SCRIPT LUA (REQUERIDO PARA MODOS AVANZADOS)
  // ============================================================
  // 
  // PASO 1: Registrar el script en REAPER
  //   1. Actions → Show action list (Shift + /)
  //   2. New action... → Load ReaScript...
  //   3. Navega a: reaper-scripts/smooth_seeking_control_v3.lua
  //   4. Selecciona el archivo
  //
  // PASO 2: Copiar el Command ID
  //   - El script aparecerá en la lista con un Command ID
  //   - Ejemplo: _RS7D3C92BC953A9A4AAC2BC1AA93CFD9A7A62BB028
  //   - Copia ese ID completo
  //
  // PASO 3: Pegar aquí (reemplazar null)
  //   - Pega el Command ID entre comillas simples
  //   - Ejemplo: smoothSeekingScriptCmd: '_RS7D3C92BC953A9A4AAC2BC1AA93CFD9A7A62BB028',
  //
  // SIN ESTE SCRIPT: Solo funcionará modo "Inmediato"
  // CON ESTE SCRIPT: Funcionan todos los modos (Inmediato, Al compás, Al finalizar)
  //
  smoothSeekingScriptCmd: null,  // ← PEGAR TU COMMAND ID AQUÍ
  // ============================================================
  
  // Estado de reproducción
  isPlaying: false,
  currentPos: 0.0,
  
  // Salto programado
  pendingJump: null,  // {sectionId, mode} si hay un salto pendiente
  
  // Agrupación calculada (canciones → secciones)
  // Regiones = Canciones
  // Marcadores = Secciones
  songSections: new Map(),  // Map<songId, marker[]>
};

/**
 * Establecer marcadores (secciones)
 * @param {Array} markers 
 */
export function setMarkers(markers) {
  state.markers = markers || [];
  recalculateSongSections();
}

/**
 * Establecer regiones (canciones)
 * @param {Array} regions 
 */
export function setRegions(regions) {
  state.regions = regions || [];
  recalculateSongSections();
}

/**
 * Establecer pistas
 * @param {Array} tracks 
 */
export function setTracks(tracks) {
  state.tracks = tracks || [];
}

/**
 * Establecer canción actual
 * @param {number} songId 
 */
export function setCurrentSong(songId) {
  state.currentSongId = songId;
}

/**
 * Establecer región actual
 * @param {number} regionId 
 */
export function setCurrentRegion(regionId) {
  state.currentRegionId = regionId;
}

/**
 * Establecer salto pendiente
 * @param {number|null} sectionId 
 * @param {string} mode 
 */
export function setPendingJump(sectionId, mode) {
  if (sectionId === null) {
    state.pendingJump = null;
  } else {
    state.pendingJump = { sectionId, mode };
  }
}

/**
 * Obtener salto pendiente
 * @returns {{sectionId: number, mode: string}|null}
 */
export function getPendingJump() {
  return state.pendingJump;
}

/**
 * Establecer modo de salto
 * @param {string} mode - 'immediate' | 'bar' | 'region-end'
 */
export function setJumpMode(mode) {
  if (['immediate', 'bar', 'region-end'].includes(mode)) {
    state.jumpMode = mode;
    // Persistir en localStorage
    localStorage.setItem('reaper_jump_mode', mode);
  }
}

/**
 * Establecer cantidad de compases a esperar
 * @param {number} count 
 */
export function setBarCount(count) {
  state.barCount = count;
  localStorage.setItem('reaper_bar_count', count.toString());
}

/**
 * Cargar preferencias desde localStorage
 */
export function loadPreferences() {
  const jumpMode = localStorage.getItem('reaper_jump_mode');
  if (jumpMode) {
    state.jumpMode = jumpMode;
  }
  
  const barCount = localStorage.getItem('reaper_bar_count');
  if (barCount !== null) {
    state.barCount = parseInt(barCount);
  }
  
  // Cargar Command ID del script si está configurado
  const scriptCmd = localStorage.getItem('reaper_smooth_seeking_script_cmd');
  if (scriptCmd) {
    state.smoothSeekingScriptCmd = scriptCmd;
  }
}

/**
 * Actualizar estado de reproducción
 * @param {boolean} isPlaying 
 * @param {number} pos 
 */
export function updatePlayState(isPlaying, pos) {
  state.isPlaying = isPlaying;
  state.currentPos = pos;
}

/**
 * Recalcular agrupación de secciones por canción
 * REGIONES = Canciones
 * MARCADORES = Secciones
 */
export function recalculateSongSections() {
  state.songSections.clear();
  
  if (state.regions.length === 0 || state.markers.length === 0) {
    return;
  }
  
  // Ordenar regiones (canciones) por posición
  const sortedRegions = [...state.regions].sort((a, b) => a.start - b.start);
  
  // Para cada región (canción), encontrar marcadores (secciones) dentro de ella
  sortedRegions.forEach((region) => {
    const startPos = region.start;
    const endPos = region.end;
    
    // Filtrar marcadores que están dentro de esta región
    const sections = state.markers.filter(marker => 
      marker.pos >= startPos && marker.pos < endPos
    );
    
    // Ordenar por posición
    sections.sort((a, b) => a.pos - b.pos);
    
    state.songSections.set(region.id, sections);
  });
  
  console.log('📊 Canciones (regiones):', state.regions.length, 
              'Total secciones (marcadores):', state.markers.length);
}

/**
 * Obtener secciones de una canción específica
 * @param {number} songId 
 * @returns {Array}
 */
export function getSectionsForSong(songId) {
  return state.songSections.get(songId) || [];
}

/**
 * Obtener lista de canciones
 * Las canciones son REGIONES
 * @returns {Array<{id, name, pos}>}
 */
export function getSongs() {
  return state.regions.map(r => ({
    id: r.id,
    name: r.name,
    pos: r.start
  })).sort((a, b) => a.pos - b.pos);
}

/**
 * Obtener canción actual
 * @returns {object|null}
 */
export function getCurrentSong() {
  const region = state.regions.find(r => r.id === state.currentSongId);
  return region ? { id: region.id, name: region.name, pos: region.start } : null;
}

/**
 * Obtener sección actual
 * @returns {object|null}
 */
export function getCurrentSection() {
  return state.markers.find(m => m.id === state.currentRegionId) || null;
}

/**
 * Obtener canción en una posición específica
 * @param {number} pos - Posición en segundos
 * @returns {object|null}
 */
export function getSongAtPosition(pos) {
  return state.regions.find(r => pos >= r.start && pos < r.end) || null;
}

/**
 * Obtener toda la información del estado
 * @returns {object}
 */
export function getState() {
  return {
    ...state,
    songSections: Array.from(state.songSections.entries())
  };
}

// Cargar preferencias al iniciar
loadPreferences();
