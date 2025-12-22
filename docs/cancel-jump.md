# Cancelar Saltos Programados

## 📌 Descripción

Cuando estás en modo **"Al compás"** o **"Al finalizar"**, los saltos no son instantáneos: REAPER espera al siguiente compás o al final de la región actual antes de saltar. Si te das cuenta de que te equivocaste al seleccionar una sección, **ahora puedes cancelar el salto** antes de que ocurra.

## 🎯 Cómo funciona

### 1. **Salto Programado**
Cuando seleccionas una sección en modo "Al compás" o "Al finalizar":
- La sección aparece marcada con estado **"pendiente"** (color naranja/amarillo)
- Aparece un botón grande rojo: **🚫 CANCELAR SALTO**
- El botón tiene una animación pulsante para llamar tu atención

### 2. **Cancelar el Salto**
Si cambias de opinión:
- Toca el botón **🚫 CANCELAR SALTO**
- El salto se cancela inmediatamente
- La marca de "pendiente" desaparece
- El botón de cancelar se oculta
- Recibes confirmación visual ("✓ Cancelado")

### 3. **Salto Completado**
Si no cancelas y el salto se ejecuta:
- La app detecta automáticamente que llegaste a la sección destino
- El botón de cancelar desaparece automáticamente
- La sección se marca como "activa" (color verde/azul)

## 🔧 Cómo se implementa

### En REAPER
La cancelación funciona **desactivando temporalmente el smooth seeking**:
```
1. Pulsas "Cancelar"
2. La app envía comando a REAPER para poner modo = "immediate"
3. El script Lua ejecuta: smoothseek = 0 (OFF)
4. Cualquier salto programado se descarta
5. El modo vuelve a su configuración original cuando seleccionas otra sección
```

### En el código
**Estado (`state.js`):**
```javascript
state.pendingJump = { sectionId: 5, mode: 'bar' }
```

**API (`api.js`):**
```javascript
await api.cancelScheduledJump()
// → Configura jump_mode=immediate en ExtState
// → Ejecuta smooth_seeking_control_v3.lua
// → REAPER: smoothseek = 0 (OFF)
```

**UI (`ui.js`):**
```javascript
ui.handleCancelJump()
// → Llama a cancelScheduledJump()
// → Limpia estado pendiente
// → Oculta botón de cancelar
```

## 📱 Interfaz de Usuario

### Botón de Cancelar
- **Ubicación**: Entre Transporte y Tabs
- **Visibilidad**: Solo visible cuando hay un salto pendiente
- **Color**: Rojo intenso con bordes blancos
- **Animación**: Efecto de pulso para destacar
- **Tamaño**: Grande (60px altura) para fácil toque

### Estados Visuales de Secciones
1. **Normal**: Color base (gris)
2. **Pendiente** (naranja): Salto programado, esperando ejecución
3. **Activa** (verde/azul): Sección en reproducción actual

## 🎭 Casos de Uso

### Caso 1: Error al seleccionar
```
Usuario: "Quiero ir al Coro"
[Toca botón "Verso" por error]
[Aparece "VERSO" pendiente + botón CANCELAR]
Usuario: "¡No! Era el Coro"
[Toca CANCELAR]
[Marca pendiente desaparece]
[Toca "Coro" correctamente]
```

### Caso 2: Cambio de planes
```
Modo: "Al compás" (1 compás)
[Toca "Puente"]
[Esperando al siguiente compás...]
Usuario: "Mejor repetimos el Coro"
[Toca CANCELAR]
[Toca "Coro"]
```

### Caso 3: Salto completado normalmente
```
[Toca "Final"]
[Botón CANCELAR visible]
[Espera 1 compás...]
[Salto ejecutado → llegada a "Final"]
[App detecta llegada]
[Botón CANCELAR desaparece automáticamente]
```

## ⚙️ Requisitos

- **Script Lua**: `smooth_seeking_control_v3.lua` debe estar registrado
- **SWS Extension**: Necesaria para modificar `smoothseek`
- **Command ID**: Configurado en `state.js`

### Sin Script
Si no tienes el script configurado:
- Modo "Inmediato": Funciona normal (no hay saltos que cancelar)
- Modo "Al compás"/"Al finalizar": **No funcionan** (muestra alerta para instalar script)

## 🐛 Debugging

### Consola del navegador
```javascript
// Ver estado de salto pendiente
state.getPendingJump()  
// → {sectionId: 5, mode: 'bar'} o null

// Cancelar manualmente
await api.cancelScheduledJump()

// Ver configuración del script
state.state.smoothSeekingScriptCmd
// → '_RS...' o null
```

### Consola de REAPER
El script Lua escribe en la consola cuando:
- Se configura smooth seeking
- Se recibe comando de cancelación
- Hay errores de configuración

## 🎨 Personalización

### Cambiar color del botón
En `app.css`:
```css
.cancel-jump-btn {
  background-color: var(--color-danger);  /* Cambiar color base */
}
```

### Cambiar animación
```css
@keyframes pulse-cancel {
  /* Modificar la animación de pulso */
}
```

### Cambiar posición
En `song.html`:
```html
<!-- Mover <div class="cancel-jump-container"> -->
<!-- donde prefieras -->
```

## 📝 Notas

1. **Performance**: La cancelación es prácticamente instantánea (< 100ms en red local)
2. **Múltiples saltos**: Solo puede haber un salto pendiente a la vez
3. **Modo Inmediato**: No muestra botón de cancelar (saltos instantáneos)
4. **Offline**: En modo MOCK, la cancelación se simula localmente

## 🚀 Mejoras Futuras (Opcional)

- [ ] Sonido de confirmación al cancelar
- [ ] Atajo de teclado para cancelar (ESC)
- [ ] Confirmación visual más elaborada (toast notification)
- [ ] Historial de últimos saltos (deshacer)
- [ ] Cancelar con doble-tap en sección actual
