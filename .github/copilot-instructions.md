📦 Estructura del repo
reaper-live-remote/
├─ README.md
├─ /webroot              # Copiar esto a la carpeta web de REAPER (reaper_www_root)
│  ├─ index.html         # Vista “selector de canciones”
│  ├─ song.html          # Vista “detalle de canción” (tabs Secciones/Mezcla)
│  ├─ css/
│  │  └─ app.css
│  ├─ js/
│  │  ├─ api.js          # Capa de acceso a REAPER Web API (HTTP)
│  │  ├─ state.js        # Estado global (canción actual, región actual, modo salto…)
│  │  ├─ ui.js           # Render de UI y listeners
│  │  └─ utils.js        # Helpers (ordenar, formatear, throttle…)
│  └─ assets/
│     └─ icons.svg
├─ /docs
│  ├─ mapping.md         # Mapear endpoints REAPER → funciones api.js
│  ├─ timeline-naming.md # Reglas de nombrado y cómo preparar el proyecto
│  └─ deploy.md          # Cómo copiar/servir en REAPER
└─ /tests
   └─ mock-api.json      # Mock para desarrollo sin REAPER

🎯 Objetivo funcional (MVP)

Vista 1 – Selector de canción

Lista de canciones (extraídas de marcadores).

Al tocar una canción → navegar a song.html?songId=….

Vista 2 – Detalle de canción

Tabs: Secciones (regiones dentro de la canción) y Mezcla.

Secciones: botones grandes con los nombres reales de las regiones.

Modo de salto: Inmediato / Al final del compás (toggle fijo arriba).

Mezcla: faders simples por pista visibles en la canción (volumen, mute, pan).

Botones de transporte: Play / Stop / Volver a inicio de canción.

Reglas de timeline en REAPER

Marcadores para inicio de canción (solo el nombre de la canción).

Regiones con nombres sin prefijo (“Intro”, “Verso”, “Coro”, “Puente”, “Final”…).

Tempo definido por marcador de tempo justo antes de cada canción (opcional).

Canciones separadas por un pequeño espacio.

🧠 Lógica clave

Descubrir canciones: leer todos los marcadores (orden por posición).

Agrupar secciones: para una canción Ck, tomar todas las regiones cuyo inicio esté entre el marcador Ck y el siguiente marcador Ck+1 (o fin del proyecto si no hay siguiente).

Salto “al compás”: si el modo es “compás”, programar el salto para el próximo “bar line” usando el tempo actual. (Si la API no da compás exacto, aproximar: escuchar posición y tempo y ejecutar al cambio de compás; si no es fiable, ofrecer también “al final de región” como segunda opción más segura).

Mezcla: listar pistas del proyecto; para MVP, mostrar solo pistas audibles (no master, no hidden) y limitar a, p.ej., 8–12 por página (scroll/paginación simple). Siempre incluir Click y Guía si existen por nombre.

🔌 Capa API (sin casarte con endpoints)

No pongas URLs rígidas en código fuente. Crea funciones abstractas; luego mapea a los endpoints reales de REAPER en docs/mapping.md.

js/api.js (firmas sugeridas):

export async function getMarkers();            // -> [{id, name, pos}]
export async function getRegions();            // -> [{id, name, start, end}]
export async function getTempoAt(posSec);      // -> {bpm, sigNum, sigDen} (si disponible)
export async function play();                  
export async function stop();                  
export async function seekTo(seconds);         
export async function jumpToRegion(regionId);  // salto inmediato
export async function scheduleJump(atBarLine, regionId); // salto “al compás” (si se implementa)
export async function getTracks();             // -> [{id, name, vol, pan, mute, isVisible}]
export async function setTrackVol(id, value0to1);
export async function setTrackPan(id, valueNeg1to1);
export async function setTrackMute(id, bool);
export async function getPlayState();          // -> {isPlaying, pos, currentRegionId?}


Nota: en docs/mapping.md documentas cómo cada función llama a la API Web de REAPER (paths, query params, etc.) para que tú (o Copilot) lo conecten correctamente según tu versión. Mientras tanto, tests/mock-api.json te permite trabajar “en seco”.

🧩 Estado y navegación

js/state.js

export const state = {
  markers: [], regions: [], tracks: [],
  currentSongId: null,     // id de marcador
  currentRegionId: null,
  jumpMode: 'immediate',   // 'immediate' | 'bar'
};


index.html carga markers y pinta canciones.
song.html recibe songId por querystring, calcula regiones pertenecientes y muestra tabs.

🎨 UI minimalista (tablet-first)

Tipografía grande, botones de 2-3 columnas (grid) para secciones.

Toggle de Modo de salto arriba (persistir en localStorage).

Faders verticales grandes con Mute encima y etiqueta debajo.

Paleta simple (fondo oscuro, botones claros).

Sin vumetros en MVP (añadible luego).

🔐 Seguridad y despliegue

Servir desde el servidor web de REAPER (copiar /webroot a reaper_www_root).

Activar contraseña del servidor web de REAPER.

Tablet y portátil en la misma red (router dedicado en vivo si es posible).

🧪 Testing checklist (club de fallos reales de directo)

Carga con proyecto real (4–5 canciones).

Cambiar de canción rápido, sin glitches.

Saltos inmediatos y “al compás” con click activo.

Pérdida de WiFi → reconexión del front sin recargar proyecto.

Subir/bajar volumen de click y guía sin “saltos”.

Nombres largos de canciones y secciones → truncado elegante.

🪜 Roadmap por hitos (issues para crear)

Hito 0 – Infra

 Repo + licencias + /webroot scaffolding

 Mock API para desarrollo offline

Hito 1 – Descubrimiento

 api.js: getMarkers, getRegions

 state.js + utils: ordenar por posición, agrupar regiones por canción

 index.html: render de lista de canciones

Hito 2 – Detalle de canción (Secciones)

 song.html + ui.js: tabs

 Render botones de secciones

 Modo salto toggle (immediate/bar)

 jumpToRegion funcional

Hito 3 – Transporte básico

 Play/Stop/Seek al inicio de canción

 Indicador “sonando/parado”

Hito 4 – Mezcla

 api.js: getTracks, setTrackVol/Pan/Mute

 UI faders sencillos + Mute

 Scroll/paginación si >12 pistas

Hito 5 – Pulido

 Estilos táctiles (áreas grandes, focus visible)

 Persistencia de preferencias (modo salto)

 Página “Ajustes” mínima (IP, puerto, contraseña)

Hito 6 – Opcionales

 “Saltar al final de región”

 Colores por sección (intro/verso/coro…)

 Layout horizontal/vertical

 Guardar/recuperar snapshots de mezcla

💬 Prompts listos para Copilot

Crear scaffolding UI

Crea webroot/index.html minimal con una lista de canciones. Importa js/state.js, js/api.js, js/ui.js. En ui.js agrega una función renderSongList(container, markers) que pinta botones grandes y navega a song.html?songId=... al pulsar.

Capa de estado y utilidades

Implementa js/state.js con un objeto state exportado y funciones para set/get. Implementa js/utils.js con sortByPos, groupRegionsBySong(markers, regions), y getRegionsForSong(songId) que usa el grouping.

Detalle de canción con tabs

Crea webroot/song.html con dos tabs (“Secciones”, “Mezcla”). Detecta songId desde location.search. Carga markers y regions, calcula las regiones de la canción seleccionada y píntalas como botones grandes en la pestaña “Secciones”.

Modo de salto

Implementa en state.js la propiedad jumpMode (‘immediate’|‘bar’). En song.html, añade un toggle que cambia este modo y lo guarda en localStorage. Cuando se pulse una sección, si jumpMode === 'immediate' llama a api.jumpToRegion(id); si ‘bar’, llama a api.scheduleJump(true, id) (por ahora puede simularse si el endpoint no existe).

Transporte

Añade botones Play/Stop/“Ir al inicio de canción”. “Ir al inicio” debe usar la posición del marcador de esa canción (seekTo(marker.pos)).

Mezcla básica

En la pestaña “Mezcla”, llama a api.getTracks() y renderiza faders verticales (input range). Cada fader ajusta en input (throttle 50–100ms) el volumen con api.setTrackVol(track.id, value); añade botón Mute y control Pan.

Mock API para desarrollo

Crea tests/mock-api.json con arrays de markers, regions y tracks de ejemplo. En api.js, si window.MOCK === true, responde desde ese JSON. Añade un flag en index.html para activar MOCK.

Estilos

En css/app.css, define layout táctil: grid 2–3 columnas para secciones, botones 64–80px de alto, faders grandes, tema oscuro.

📝 README (resumen para Devs)

Incluye:

Qué problema resuelve

Cómo desplegar (copiar /webroot a reaper_www_root)

Cómo configurar REAPER (Preferencias → Control/OSC/Web → habilitar servidor)

Cómo conectar desde la tablet (misma red, IP:puerto)

Cómo preparar el proyecto (marcadores = canciones, regiones = secciones, tempo por canción)

Variables de entorno/opciones (IP/puerto/password si se necesitan)

Limitaciones conocidas y TODOs