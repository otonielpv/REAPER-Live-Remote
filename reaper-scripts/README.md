# REAPER Scripts para Live Remote

Scripts Lua para REAPER que extienden la funcionalidad de la aplicación web, especialmente para **saltos musicales perfectos** sin romper el tempo.

---

## 📦 Scripts Disponibles

### 🎵 `smooth_seeking_control.lua` ⭐ NUEVO

Controla las opciones nativas de **Smooth Seeking** de REAPER desde la Web API.

**Características**:
- ✅ Activar/desactivar Smooth Seeking
- ✅ Configurar "Play to end of X measures before seeking"
- ✅ Leer estado actual de la configuración
- ✅ Control vía HTTP (ExtState + Command)

**Requisitos**:
- SWS Extension (obligatorio)

**Instalación**:
1. Actions → Show action list
2. New action → Load ReaScript
3. Seleccionar este archivo
4. Copiar el Command ID generado
5. Configurar en `webroot/js/state.js`

**Uso desde Web API**:
```javascript
// Activar smooth seeking con 1 compás de espera
await api.configureSmoothSeeking(true, 1);
```

Ver: `docs/smooth-seeking-setup.md` para guía completa.

---

### 🎯 `quantized_jump.lua` ⭐ NUEVO

Realiza saltos cuantizados musicalmente (al beat/compás) con smooth seeking integrado.

**Características**:
- ✅ Cuantización a: beat, compás, 2 compases, 4 compases
- ✅ Saltos tanto a marcadores como regiones
- ✅ Usa Smooth Seeking de REAPER para transiciones perfectas
- ✅ Sin glitches ni desincronización

**Requisitos**:
- SWS Extension (recomendado, no obligatorio)
- `scheduled_jump_monitor.lua` corriendo en background

**Instalación**:
1. Actions → Show action list
2. New action → Load ReaScript
3. Seleccionar este archivo
4. Copiar el Command ID
5. Configurar en `webroot/js/state.js`

**Uso desde Web API**:
```javascript
// Saltar al próximo compás con smooth seeking
await api.jumpToSectionQuantized(sectionId, 'bar', true);
```

---

### ⏱️ `scheduled_jump_monitor.lua` ⭐ NUEVO

Monitor en background que ejecuta saltos programados con precisión de ~5ms.

**Características**:
- ✅ Polling de alta frecuencia (5ms)
- ✅ Ejecución exacta en el momento calculado
- ✅ Restauración automática de configuración
- ✅ Corre continuamente en background

**Instalación**:
1. Actions → Show action list
2. New action → Load ReaScript
3. Seleccionar este archivo
4. **RIGHT-CLICK** sobre el script
5. Seleccionar `Run script in background` ⚠️ IMPORTANTE
6. Verificar indicador verde en la lista

**Este script debe estar corriendo siempre que uses la app.**

---

### 🔀 `add_region_crossfades.lua`

Añade crossfades automáticos de 50ms en los bordes de todas las regiones.

**Qué hace:** Añade crossfades automáticos de 50ms a todos los bordes de las regiones.

**Cuándo usar:** ANTES del directo, durante la preparación del proyecto.

**Cómo usar:**
1. Abre tu proyecto en REAPER
2. `Actions → Show action list` (o `Shift + ?`)
3. `New action... → Load ReaScript...`
4. Navega a `c:\Repos\Reaper\reaper-scripts\add_region_crossfades.lua`
5. Click en `Run` para ejecutar
6. Verás en la consola cuántos crossfades se crearon
7. **¡Guarda el proyecto!** (`Ctrl + S`)

**Resultado:** Los items de audio en los bordes de cada región tendrán fade in/out automáticos de 50ms.

**Ventajas:**
- ✅ No requiere modificar el código web
- ✅ Los crossfades se guardan en el proyecto
- ✅ Funciona con la Web API normal (HTTP)
- ✅ Transiciones suaves estilo Ableton Live

**Ajustes:**
- Para cambiar la duración del fade, edita la línea 10:
  ```lua
  local CROSSFADE_MS = 50  -- Cambia a 30, 100, etc.
  ```

---

### 2. `smooth_region_jump.lua` - Salto suave dinámico (EXPERIMENTAL)

**Qué hace:** Intenta hacer un crossfade en tiempo real al saltar entre regiones.

**Estado:** En desarrollo. REAPER no tiene API nativa para crossfades en tiempo real durante reproducción.

**Limitaciones:**
- Requiere SWS/S&M extension
- No funciona bien con la Web API
- Más complejo de integrar

**Recomendación:** Usa `add_region_crossfades.lua` en su lugar.

---

## 🎼 Flujo de trabajo recomendado

### Preparación del proyecto (una vez):

1. **Organiza tu timeline:**
   - Marcadores = inicio de canciones
   - Regiones = secciones (Intro, Verso, Coro, etc.)
   - Separa canciones con pequeño espacio

2. **Ejecuta `add_region_crossfades.lua`:**
   - Esto añade fades automáticos
   - Se ejecuta UNA vez
   - Los fades se guardan en el proyecto

3. **Ajusta manualmente si es necesario:**
   - Algunos items pueden necesitar fades más largos/cortos
   - Edita a mano en REAPER arrastrando los fades

4. **Guarda el proyecto**

5. **Habilita el servidor web:**
   - `Preferences → Control/OSC/web`
   - `Enable web interface`
   - Establece contraseña

### Durante el directo:

- La web app hace saltos con `seekTo()` (HTTP)
- REAPER reproduce los fades pre-configurados automáticamente
- Transiciones suaves sin procesamiento adicional

---

## 🔧 Ajustar duración de crossfades

### Para crossfades de 30ms (más rápidos):
```lua
local CROSSFADE_MS = 30
```

### Para crossfades de 100ms (más suaves):
```lua
local CROSSFADE_MS = 100
```

### Ableton Live usa ~50ms por defecto
```lua
local CROSSFADE_MS = 50  -- Ya configurado
```

---

## 🎵 Tipos de fade en REAPER

Al editar manualmente los fades, REAPER ofrece varias curvas:

- **0 = Linear** (usado por el script) - Transición lineal
- **1 = Slow Start/End** - Aceleración suave
- **2 = Fast Start** - Inicio rápido, fin suave
- **3 = Fast End** - Inicio suave, fin rápido
- **4 = Bezier** - Curva personalizable

Para cambiar en el script, edita:
```lua
reaper.SetMediaItemInfo_Value(item, "C_FADEINSHAPE", 0)  -- 0=Linear, 1=Slow, etc.
```

---

## 🚨 Troubleshooting

### "No se crearon crossfades"
- Verifica que tienes items de audio (no MIDI) en las regiones
- Asegúrate de que los items están alineados con los bordes de las regiones
- Revisa la consola de REAPER para ver mensajes de debug

### "Los crossfades suenan raros"
- Prueba con duraciones más cortas (30ms) o más largas (100ms)
- Cambia la curva del fade (Linear → Slow Start/End)
- Ajusta manualmente algunos fades en REAPER

### "Las transiciones siguen siendo bruscas"
- Asegúrate de guardar el proyecto después de ejecutar el script
- Verifica que REAPER está reproduciendo los fades (zoom in en los items)
- Comprueba que no hay automatización de volumen que interfiera

---

## 📚 Referencias

- [REAPER ReaScript API](https://www.reaper.fm/sdk/reascript/reascripthelp.html)
- [SWS Extension](https://www.sws-extension.org/)
- [REAPER Web Interface](https://www.reaper.fm/guides/RemoteControlGuide.pdf)

---

## 💡 Ideas futuras

- Script para crear "hotcues" (marcadores + regiones combinados)
- Automatización de volumen pre-programada para transiciones complejas
- Detección automática de puntos óptimos para crossfades
- Integración con marcadores de tempo para crossfades adaptativos
