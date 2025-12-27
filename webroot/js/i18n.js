/**
 * i18n.js - Internationalization module
 */

let translations = {};
let currentLang = null;

/**
 * Get current language
 * @returns {string} 'en' or 'es'
 */
function getLang() {
  // 1. Check localStorage first
  const saved = localStorage.getItem('app-language');
  if (saved && (saved === 'en' || saved === 'es')) {
    return saved;
  }
  // 2. Detect from navigator
  const detected = navigator.language.startsWith('es') ? 'es' : 'en';
  return detected;
}

/**
 * Load translations for the specified language
 */
async function loadTranslations(lang = null) {
  const langToLoad = lang || getLang();
  currentLang = langToLoad;
  
  try {
    const response = await fetch(`locales/${langToLoad}.json`);
    translations = await response.json();
    console.log(`🌐 Translations loaded: ${langToLoad}`);
  } catch (error) {
    console.error('Error loading translations:', error);
    // Fallback to English
    const response = await fetch('locales/en.json');
    translations = await response.json();
    currentLang = 'en';
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
 * Get current language
 * @returns {string} 'en' or 'es'
 */
export function getCurrentLang() {
  return currentLang || getLang();
}

/**
 * Update all UI elements with translations
 */
function updateAllTranslations() {
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

/**
 * Change language and update UI
 * @param {string} lang 'en' or 'es'
 * @param {Function} onLanguageChange - Callback to re-render components
 */
export async function setLanguage(lang, onLanguageChange = null) {
  if (lang !== 'en' && lang !== 'es') {
    console.error('Invalid language:', lang);
    return;
  }
  
  // Save to localStorage
  localStorage.setItem('app-language', lang);
  
  // Load translations
  await loadTranslations(lang);
  
  // Update UI
  updateAllTranslations();
  
  // Update button
  updateLanguageButton();
  
  // Call callback to re-render dynamic components
  if (onLanguageChange && typeof onLanguageChange === 'function') {
    onLanguageChange();
  }
  
  console.log(`✅ Language changed to: ${lang}`);
}

/**
 * Initialize i18n
 */
export async function initI18n() {
  await loadTranslations();
  updateAllTranslations();
  updateLanguageButton();
  console.log(`🌐 i18n initialized with language: ${getCurrentLang()}`);
}

/**
 * Update language toggle button text
 */
function updateLanguageButton() {
  const btn = document.getElementById('btn-lang-toggle');
  if (!btn) return;
  
  const currentLang = getCurrentLang();
  const nextLang = currentLang === 'es' ? 'EN' : 'ES';
  btn.textContent = nextLang;
  btn.title = `Switch to ${nextLang}`;
}

/**
 * Export function to update button after language change
 */
export function updateLangButtonUI() {
  updateLanguageButton();
}