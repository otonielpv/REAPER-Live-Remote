/**
 * utils.js - Funciones de utilidad
 * 
 * Helpers para ordenar, formatear, agrupar, throttle, etc.
 */

/**
 * Ordenar array por propiedad 'pos' (posición)
 * @param {Array} items 
 * @returns {Array}
 */
export function sortByPos(items) {
  return [...items].sort((a, b) => a.pos - b.pos);
}

/**
 * Agrupar regiones por canción
 * @param {Array} markers - Marcadores (canciones)
 * @param {Array} regions - Regiones (secciones)
 * @returns {Map} Map<markerId, regions[]>
 */
export function groupRegionsBySong(markers, regions) {
  const grouped = new Map();
  
  if (!markers || !regions || markers.length === 0) {
    return grouped;
  }
  
  // Ordenar marcadores por posición
  const sortedMarkers = sortByPos(markers);
  
  sortedMarkers.forEach((marker, index) => {
    const nextMarker = sortedMarkers[index + 1];
    const startPos = marker.pos;
    const endPos = nextMarker ? nextMarker.pos : Infinity;
    
    // Filtrar regiones en el rango de esta canción
    const songRegions = regions.filter(region => 
      region.start >= startPos && region.start < endPos
    );
    
    // Ordenar por posición
    songRegions.sort((a, b) => a.start - b.start);
    
    grouped.set(marker.id, songRegions);
  });
  
  return grouped;
}

/**
 * Formatear tiempo en segundos a MM:SS
 * @param {number} seconds 
 * @returns {string}
 */
export function formatTime(seconds) {
  if (isNaN(seconds) || seconds < 0) return '0:00';
  
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

/**
 * Formatear tiempo en segundos a HH:MM:SS (para tiempos largos)
 * @param {number} seconds 
 * @returns {string}
 */
export function formatTimeLong(seconds) {
  if (isNaN(seconds) || seconds < 0) return '0:00:00';
  
  const hours = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);
  
  if (hours > 0) {
    return `${hours}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

/**
 * Formatear valor de volumen (0-1 del fader) a dB
 * @param {number} faderValue - Valor del fader (0-1)
 * @returns {string}
 */
export function formatVolumeDb(faderValue) {
  if (faderValue <= 0.0001) return '-∞ dB';
  
  // Convertir valor del fader a volumen REAPER
  let reaperVol;
  if (faderValue < 0.716) {
    // Rango -inf a 0dB
    reaperVol = Math.pow(faderValue / 0.716, 2);
  } else {
    // Rango 0dB a +12dB
    reaperVol = 1 + ((faderValue - 0.716) / (1 - 0.716)) * 3;
  }
  
  // Convertir volumen REAPER a dB
  const db = 20 * Math.log10(reaperVol);
  
  // Formatear
  if (Math.abs(db) < 0.1) return '0.0 dB'; // Exactamente 0dB
  if (db > 0) return `+${db.toFixed(1)} dB`;
  return `${db.toFixed(1)} dB`;
}

/**
 * Formatear valor de panorama (-1 a 1) a L/R
 * @param {number} valueNeg1to1 
 * @returns {string}
 */
export function formatPan(valueNeg1to1) {
  if (Math.abs(valueNeg1to1) < 0.01) return 'C'; // Centro
  
  const percent = Math.abs(valueNeg1to1 * 100).toFixed(0);
  
  if (valueNeg1to1 < 0) return `${percent}L`;
  return `${percent}R`;
}

/**
 * Truncar texto largo
 * @param {string} text 
 * @param {number} maxLength 
 * @returns {string}
 */
export function truncate(text, maxLength = 20) {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength - 1) + '…';
}

/**
 * Throttle: limitar frecuencia de llamadas a una función
 * @param {Function} func - Función a throttlear
 * @param {number} limit - Tiempo mínimo entre llamadas (ms)
 * @returns {Function}
 */
export function throttle(func, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

/**
 * Debounce: retrasar llamada hasta que pasen N ms sin nuevas llamadas
 * @param {Function} func - Función a debouncear
 * @param {number} delay - Tiempo de espera (ms)
 * @returns {Function}
 */
export function debounce(func, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
}

/**
 * Obtener parámetro de query string
 * @param {string} name 
 * @returns {string|null}
 */
export function getQueryParam(name) {
  const params = new URLSearchParams(window.location.search);
  return params.get(name);
}

/**
 * Establecer parámetro de query string (sin recargar página)
 * @param {string} name 
 * @param {string} value 
 */
export function setQueryParam(name, value) {
  const url = new URL(window.location);
  url.searchParams.set(name, value);
  window.history.replaceState({}, '', url);
}

/**
 * Validar que un objeto tenga propiedades requeridas
 * @param {object} obj 
 * @param {Array<string>} requiredProps 
 * @returns {boolean}
 */
export function hasRequiredProps(obj, requiredProps) {
  return requiredProps.every(prop => obj.hasOwnProperty(prop));
}

/**
 * Calcular tiempo hasta el próximo compás
 * @param {number} currentPos - Posición actual en segundos
 * @param {number} bpm - Tempo en BPM
 * @param {number} sigNum - Numerador del compás (ej: 4 en 4/4)
 * @param {number} sigDen - Denominador del compás (ej: 4 en 4/4)
 * @returns {number} - Segundos hasta el próximo compás
 */
export function timeToNextBar(currentPos, bpm, sigNum = 4, sigDen = 4) {
  // Duración de un beat en segundos
  const beatDuration = 60.0 / bpm;
  
  // Duración de un compás en segundos
  const barDuration = beatDuration * sigNum;
  
  // Posición dentro del compás actual
  const posInBar = currentPos % barDuration;
  
  // Tiempo restante hasta el próximo compás
  return barDuration - posInBar;
}

/**
 * Generar ID único simple
 * @returns {string}
 */
export function generateId() {
  return `id-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Escapar HTML para evitar XSS
 * @param {string} str 
 * @returns {string}
 */
export function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

/**
 * Crear elemento DOM con atributos y contenido
 * @param {string} tag 
 * @param {object} attrs 
 * @param {string|Element} content 
 * @returns {Element}
 */
export function createElement(tag, attrs = {}, content = '') {
  const el = document.createElement(tag);
  
  Object.entries(attrs).forEach(([key, value]) => {
    if (key === 'className') {
      el.className = value;
    } else if (key.startsWith('data-')) {
      el.setAttribute(key, value);
    } else {
      el[key] = value;
    }
  });
  
  if (typeof content === 'string') {
    el.textContent = content;
  } else if (content instanceof Element) {
    el.appendChild(content);
  }
  
  return el;
}

/**
 * Detectar si es dispositivo táctil
 * @returns {boolean}
 */
export function isTouchDevice() {
  return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
}

/**
 * Detectar si es tablet (ancho mayor a 600px)
 * @returns {boolean}
 */
export function isTablet() {
  return window.innerWidth >= 600;
}

/**
 * Agregar clase CSS si condición es true
 * @param {Element} element 
 * @param {string} className 
 * @param {boolean} condition 
 */
export function toggleClass(element, className, condition) {
  if (condition) {
    element.classList.add(className);
  } else {
    element.classList.remove(className);
  }
}

/**
 * Esperar N milisegundos
 * @param {number} ms 
 * @returns {Promise}
 */
export function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Convertir volumen lineal (0-1) a dB
 * @param {number} linear 
 * @returns {number}
 */
export function linearToDb(linear) {
  if (linear <= 0) return -Infinity;
  return 20 * Math.log10(linear);
}

/**
 * Convertir dB a volumen lineal (0-1)
 * @param {number} db 
 * @returns {number}
 */
export function dbToLinear(db) {
  if (db === -Infinity) return 0;
  return Math.pow(10, db / 20);
}

console.log('✅ Utils cargado');
