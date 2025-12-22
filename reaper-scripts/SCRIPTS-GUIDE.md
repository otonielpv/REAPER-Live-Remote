# 📁 Scripts de REAPER - Guía Rápida

## ✅ Scripts que SÍ debes usar:

### 🎯 **`smooth_seeking_control_v3.lua`** ⭐ PRINCIPAL
**Usar para**: Control completo de smooth seeking desde la web app

**Funciones**:
- ✅ Activa/desactiva smooth seeking
- ✅ Cambia modo measures/markers (bitfield)
- ✅ Configura número de compases
- ✅ Auto-configuración por jump mode
- ✅ Sin mensajes molestos

**Setup**:
```
1. Actions → Load ReaScript → smooth_seeking_control_v3.lua
2. Copiar Command ID
3. Pegar en webroot/js/state.js → smoothSeekingScriptCmd
```

---

### 🧪 **`test_bitfields.lua`**
**Usar para**: Verificar que las variables funcionan correctamente

**Cuándo ejecutar**: Una vez después de registrar el V3

**Tests**:
- ✅ Leer estado
- ✅ Activar smooth + modo measures
- ✅ Activar smooth + modo markers
- ✅ Configurar compases
- ✅ Desactivar smooth
- ✅ Restaurar estado original

---

## ❌ Scripts que NO necesitas (obsoletos):

### `quantize_jump.lua`
**Estado**: ❌ Obsoleto  
**Por qué**: Era un intento anterior, funcionalidad integrada en V3

### `smooth_region_jump.lua`
**Estado**: ❌ Obsoleto  
**Por qué**: Era otro intento anterior, funcionalidad integrada en V3

### `smooth_seeking_control.lua` (V1)
**Estado**: ❌ Obsoleto  
**Por qué**: Usaba variables incorrectas (playendmeas, seekplay)

### `smooth_seeking_control_v2.lua`
**Estado**: ❌ Obsoleto  
**Por qué**: No controlaba el bit 2 (modo measures/markers)

### `smooth_seeking_simple.lua`
**Estado**: ❌ Obsoleto  
**Por qué**: Solo hacía toggle, no configuraba compases ni modo

### `test_*.lua` (excepto test_bitfields)
**Estado**: ❌ Obsoletos  
**Por qué**: Testean funcionalidad que ya no existe

### `diagnose_config_vars.lua`
**Estado**: ✅ Completado (ya no necesario)  
**Por qué**: Ya encontramos las variables correctas

---

## 🗑️ Limpieza Recomendada

Puedes borrar estos archivos:

```
reaper-scripts/
  ❌ quantize_jump.lua
  ❌ smooth_region_jump.lua
  ❌ smooth_seeking_control.lua
  ❌ smooth_seeking_control_v2.lua
  ❌ smooth_seeking_simple.lua
  ❌ test_all_config.lua
  ❌ test_smooth_seeking_enable.lua
  ❌ test_smooth_seeking_disable.lua
  ❌ test_play_end_measures.lua
  ❌ test_seek_play_options.lua
  ❌ test_correct_variables.lua
  ❌ diagnose_config_vars.lua (opcional, para referencia histórica)
```

**Mantener solo**:
```
reaper-scripts/
  ✅ smooth_seeking_control_v3.lua  ← USAR ESTE
  ✅ test_bitfields.lua              ← Para testing
  ✅ add_region_crossfades.lua       ← Otro script útil
  ✅ README.md                       ← Documentación
```

---

## 🎮 Cómo Funciona Ahora

### 1. Usuario cambia modo de salto en la web
```
Usuario selecciona: "Al compás"
       ↓
ui.js detecta cambio
       ↓
Llama a api.autoConfigureReaperForJumpMode('bar')
       ↓
Configura ExtState: jump_mode=bar, bar_count=2
       ↓
Ejecuta smooth_seeking_control_v3.lua
       ↓
Script configura REAPER:
  - smoothseek = 1 (bit 1: ON, bit 2: measures)
  - smoothseekmeas = 2
       ↓
✅ REAPER listo para saltos al compás
```

### 2. Usuario hace clic en sección
```
Usuario pulsa "Coro"
       ↓
ui.js llama a handleSectionClick()
       ↓
NO reconfigura REAPER (ya está configurado)
       ↓
Ejecuta salto directo según modo
       ↓
✅ Salto inmediato sin mensajes
```

---

## 🔧 Diferencias Clave V3

| Feature | V1/V2 | V3 |
|---------|-------|-----|
| **Variables** | Incorrectas | ✅ Correctas (docs oficiales) |
| **Bitfield** | ❌ | ✅ 2 bits (enabled + mode) |
| **Modo measures** | ❌ Manual | ✅ Automático |
| **Modo markers** | ❌ Manual | ✅ Automático |
| **Compases dinámicos** | ❌ | ✅ Desde barCount |
| **Mensajes** | Muchos | ✅ Ninguno |
| **Config al cambiar modo** | ❌ En cada clic | ✅ Solo al cambiar |

---

## 📋 Checklist Post-Limpieza

- [ ] V3 registrado en REAPER Actions
- [ ] Command ID en state.js
- [ ] test_bitfields.lua ejecutado (todos PASS)
- [ ] Scripts obsoletos borrados
- [ ] Probado cambio de modo en web app
- [ ] Probado cambio de compases
- [ ] Verificado que NO hay mensajes molestos

---

**¡Ahora sí, todo limpio y funcionando!** 🎉
