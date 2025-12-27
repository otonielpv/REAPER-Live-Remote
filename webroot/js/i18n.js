/**
 * i18n.js - Internationalization module
 */

let translations = {};

// Detect language: Spanish if starts with 'es', else English
const lang = navigator.language.startsWith('es') ? 'es' : 'en';

/**
 * Load translations for the detected language
 */
async function loadTranslations() {
  try {
    const response = await fetch(`locales/${lang}.json`);
    translations = await response.json();
  } catch (error) {
    console.error('Error loading translations:', error);
    // Fallback to English
    const response = await fetch('locales/en.json');
    translations = await response.json();
  }
}

/**
 * Translate a key
 * @param {string} key
 * @returns {string}
 */
export function t(key) {
  return translations[key] || key;
}

/**
 * Initialize i18n
 */
export async function initI18n() {
  await loadTranslations();
  // Update all elements with data-i18n attribute
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (key) {
      el.textContent = t(key);
    }
  });
  // Update title attributes
  document.querySelectorAll('[data-i18n-title]').forEach(el => {
    const key = el.getAttribute('data-i18n-title');
    if (key) {
      el.setAttribute('title', t(key));
    }
  });
}

// Load translations on module load
loadTranslations();