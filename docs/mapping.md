# Mapeo de API REAPER → Funciones JavaScript# Mapeo de API REAPER → Funciones JavaScript



Este documento mapea las funciones de `api.js` a los endpoints HTTP de la REAPER Web API.Este documento mapea las funciones abstractas de `api.js` a los endpoints reales de la REAPER Web API y mensajes OSC.



## 🌐 Comunicación HTTP## 🔗 Modos de Comunicación



La aplicación usa **HTTP únicamente** para comunicarse con REAPER a través de su servidor web integrado.La aplicación soporta **dos modos de comunicación** con REAPER:



## 📍 Configuración del Proyecto### 1. **HTTP (Web API)**

- **Uso**: Lectura de datos (marcadores, regiones, pistas, estado)

### Estructura del Timeline:- **Ventajas**: No requiere configuración adicional, estándar de REAPER

- **Desventajas**: Latencia mayor (~50-200ms), no ideal para tiempo real

- **Regiones** = Canciones completas

- **Marcadores** = Secciones dentro de cada canción (Intro, Verso, Coro, etc.)### 2. **OSC (Open Sound Control)**

- **Uso**: Acciones en tiempo real (play, stop, faders, saltos)

Ejemplo:- **Ventajas**: Latencia ultra-baja (<10ms), ideal para control en vivo

```- **Desventajas**: Requiere bridge WebSocket↔UDP OSC

Timeline REAPER:

├── Region "Canción 1" (0:00 - 3:00)## 🎛️ OSC: Configuración Requerida

│   ├── Marker "Intro" (0:00)

│   ├── Marker "Verso" (0:30)Para usar OSC necesitas un **bridge WebSocket → OSC UDP** porque los navegadores no pueden enviar/recibir UDP directamente.

│   ├── Marker "Coro" (1:00)

│   └── Marker "Final" (2:30)### Opciones de Bridge:

├── Region "Canción 2" (3:30 - 6:00)

│   ├── Marker "Intro" (3:30)#### **Opción 1: Script Node.js simple** (Recomendado)

│   ├── Marker "Verso" (4:00)```javascript

│   └── Marker "Coro" (4:30)// osc-bridge.js

```const WebSocket = require('ws');

const osc = require('osc');

## 🔗 URL Base

const wss = new WebSocket.Server({ port: 8081 });

```const oscPort = new osc.UDPPort({

http://[IP]:[PORT]/  localAddress: "0.0.0.0",

```  localPort: 57121,

Ejemplo: `http://localhost:8080/` (mismo origen que la web app)  remoteAddress: "127.0.0.1",

  remotePort: 8000  // Puerto OSC de REAPER

## 📋 Endpoints HTTP de REAPER});



### Marcadores y RegionesoscPort.open();



#### `GET /_/MARKERS`wss.on('connection', (ws) => {

Obtener todos los marcadores (secciones).  console.log('Cliente conectado');

  

**Response format**:  ws.on('message', (data) => {

```    const msg = JSON.parse(data);

0	Intro	10.5    oscPort.send(msg);

1	Verso	25.3  });

2	Coro	45.8  

```  oscPort.on('message', (msg) => {

Cada línea: `id TAB nombre TAB posición_segundos`    ws.send(JSON.stringify(msg));

  });

#### `GET /_/REGIONS`});

Obtener todas las regiones (canciones).```



**Response format**:Instalar: `npm install ws osc`  

```Ejecutar: `node osc-bridge.js`

0	Canción 1	0.0	180.0

1	Canción 2	210.0	360.0#### **Opción 2: ReaLearn (Plugin de REAPER)**

```ReaLearn incluye bridge OSC↔WebSocket integrado. Ver documentación de ReaLearn.

Cada línea: `id TAB nombre TAB inicio_segundos TAB fin_segundos`

#### **Opción 3: Script Lua/Python en REAPER**

### TransportCrear un script que escuche WebSocket y reenvíe a OSC UDP interno.



#### `GET /_/1007`### Configurar OSC en REAPER:

Play/Stop toggle (Command ID 1007).1. `Preferences → Control/OSC/Web → Add`

2. `Mode: OSC (Open Sound Control)`

#### `GET /_/1016`3. `Local listen port: 8000` (o el que uses)

Stop (Command ID 1016).4. `Pattern config: Default.ReaperOSC`



#### `GET /_/SET/POS/{seconds}`## 📍 Endpoints HTTP

Saltar a posición en segundos.

### URL Base

**Ejemplo**: `/_/SET/POS/45.5` → Salta a 45.5 segundos```

http://[IP]:[PORT]/

#### `GET /_/PLAYSTATE````

Obtener estado de reproducción.Ejemplo: `http://192.168.1.100:8080/`



**Response format**:### GET `/_/TRANSPORT`

```Control de transporte.

1	45.5

```**Query params**:

Formato: `isPlaying(0/1) TAB posición_segundos`- `play` - Iniciar reproducción

- `stop` - Detener reproducción

### Pistas- `pause` - Pausar/reanudar

- `rewind` - Ir al inicio

#### `GET /_/TRACKS`- `forward` - Ir al final

Obtener todas las pistas.

### GET `/_/SETPLAYPOS/[tiempo]`

**Response format**:Buscar a una posición específica (en segundos).

```

1	Click	0.75	0.0	0	0### GET `/_/MARKER`

2	Guía	0.80	0.0	0	0Obtener información de marcadores.

3	Drums	1.00	0.0	0	0

```**Response**: Lista de marcadores con índice, posición y nombre.

Formato: `id TAB nombre TAB volumen TAB pan TAB mute(0/1) TAB solo(0/1)`

### GET `/_/REGION`

#### `GET /_/SET/TRACK/{id}/VOL/{value}`Obtener información de regiones.

Establecer volumen de pista (escala 0.0 - 4.0, donde 1.0 = 0dB).

**Response**: Lista de regiones con índice, inicio, fin y nombre.

**Ejemplo**: `/_/SET/TRACK/1/VOL/0.75`

### GET `/_/TRACK/[id]/VOLUME/[valor]`

#### `GET /_/SET/TRACK/{id}/PAN/{value}`Establecer volumen de una pista.

Establecer pan de pista (-1.0 a 1.0, donde 0 = centro).

**Parámetros**:

**Ejemplo**: `/_/SET/TRACK/2/PAN/-0.5`- `id`: Índice de la pista (1-based)

- `valor`: Volumen en formato de REAPER (0.0 - 2.0, donde 1.0 = 0dB)

#### `GET /_/SET/TRACK/{id}/MUTE/{value}`

Establecer mute (0 = unmute, 1 = mute).### GET `/_/TRACK/[id]/PAN/[valor]`

Establecer panorama de una pista.

**Ejemplo**: `/_/SET/TRACK/3/MUTE/1`

**Parámetros**:

### ExtState (para scripts Lua)- `id`: Índice de la pista (1-based)

- `valor`: Pan (-1.0 a 1.0, donde 0 = centro)

#### `GET /_/SET/EXTSTATE/{section}/{key}/{value}`

Establecer ExtState para comunicación con scripts.### GET `/_/TRACK/[id]/MUTE/[estado]`

Activar/desactivar mute de una pista.

**Ejemplo**: `/_/SET/EXTSTATE/LiveRemote/jump_mode/bar`

**Parámetros**:

#### `GET /_/GET/EXTSTATE/{section}/{key}`- `id`: Índice de la pista (1-based)

Leer ExtState (si es necesario).- `estado`: 1 = mute, 0 = unmute



### Comandos Personalizados### GET `/_/BEATPOS`

Obtener posición actual en beats y tempo.

#### `GET /_/{commandId}`

Ejecutar cualquier comando de REAPER por su ID.**Response**: Información de tempo y posición en compases.



**Ejemplos**:## 🗺️ Mapeo de Funciones

- `/_/_RS7A3B9C...` → Ejecutar script registrado

- `/_/40161` → Ir a marcador 1### `getMarkers()`

- `/_/40162` → Ir a marcador 2**Método**: HTTP (solo lectura)

```javascript

## 🗺️ Mapeo de Funciones JavaScript// Endpoint: GET /_/MARKER

// Procesar la respuesta para extraer: id, name, pos

### Lectura de Datos```



#### `getMarkers()`### `getRegions()`

```javascript**Método**: HTTP (solo lectura)

// Endpoint: GET /_/MARKERS```javascript

// Procesar respuesta línea por línea// Endpoint: GET /_/REGION

// Retornar: [{id, name, pos}, ...]// Procesar la respuesta para extraer: id, name, start, end

``````



#### `getRegions()`### `getTempoAt(posSec)`

```javascript**Método**: HTTP (solo lectura)

// Endpoint: GET /_/REGIONS```javascript

// Procesar respuesta línea por línea// Endpoint: GET /_/BEATPOS

// Retornar: [{id, name, start, end}, ...]// Opción: Establecer posición primero con SETPLAYPOS, luego leer BEATPOS

```// Extraer: bpm, sigNum, sigDen

```

#### `getTracks()`

```javascript### `play()`

// Endpoint: GET /_/TRACKS**Método**: OSC (preferido) con fallback HTTP

// Procesar respuesta línea por línea

// Retornar: [{id, name, vol, pan, mute, solo}, ...]**OSC**:

``````javascript

// Mensaje: /play

#### `getPlayState()`// Sin argumentos

```javascript```

// Endpoint: GET /_/PLAYSTATE

// Retornar: {isPlaying, pos}**HTTP fallback**:

``````javascript

// Endpoint: GET /_/1007;TRANSPORT

### Transport// Comando 1007 = Play

```

#### `play()`

```javascript### `stop()`

// Endpoint: GET /_/1007**Método**: OSC (preferido) con fallback HTTP

// Comando: Transport: Play/stop

```**OSC**:

```javascript

#### `stop()`// Mensaje: /stop

```javascript// Sin argumentos

// Endpoint: GET /_/1016```

// Comando: Transport: Stop

```**HTTP fallback**:

```javascript

#### `seekTo(seconds)`// Endpoint: GET /_/40667;TRANSPORT

```javascript// Comando 40667 = Stop

// Endpoint: GET /_/SET/POS/${seconds}```

```

### `seekTo(seconds)`

### Saltos a Secciones**Método**: OSC (preferido) con fallback HTTP



#### `jumpToSection(markerId)`**OSC**:

```javascript```javascript

// 1. Buscar marker en state.markers por ID// Mensaje: /time

// 2. Llamar seekTo(marker.pos)// Args: [float seconds]

// Smooth seeking se encarga del timing según modo configurado```

```

**HTTP fallback**:

#### `scheduleJump(atBarLine, markerId)````javascript

```javascript// Endpoint: GET /_/SET/POS/[seconds];TRANSPORT

// En modo "bar", smooth seeking espera automáticamente```

// Simplemente llamar jumpToSection(markerId)

// REAPER esperará X compases según smoothseekmeas### `jumpToRegion(regionId)`

```**Método**: OSC (preferido) con fallback seekTo



#### `scheduleJumpAtRegionEnd(markerId)`**OSC**:

```javascript```javascript

// En modo "region-end", smooth seeking espera automáticamente// Mensaje: /region/[N]

// Simplemente llamar jumpToSection(markerId)// N = índice de región (1-based, ordenadas por posición)

// REAPER esperará al final de región/próximo marker// Args: ninguno o [int N]

``````



### Saltos a Canciones**Fallback**:

```javascript

#### `jumpToSong(regionId)`// 1. Obtener región por ID

```javascript// 2. Llamar a seekTo(region.start)

// 1. Buscar region en state.regions por ID```

// 2. Llamar seekTo(region.start)

```### `jumpToMarker(markerId)`

**Método**: OSC (preferido) > HTTP comando directo > seekTo

### Mixer

**OSC** (más rápido):

#### `setTrackVol(trackId, value0to1)````javascript

```javascript// Mensaje: /marker/[N]

// Convertir value (0-1) a escala REAPER (0-4)// N = índice del marcador (1-based, ordenados por posición)

// reaperVol = value * 4.0// Args: ninguno o [int N]

// Endpoint: GET /_/SET/TRACK/${trackId}/VOL/${reaperVol}```

```

**HTTP comando directo** (solo primeros 10):

#### `setTrackPan(trackId, valueNeg1to1)````javascript

```javascript// Para marcadores 1-10: GET /_/[commandId]

// Valor directo (-1 a 1)//    - 40161 = Go to marker 01

// Endpoint: GET /_/SET/TRACK/${trackId}/PAN/${valueNeg1to1}//    - 40162 = Go to marker 02

```//    - ...

//    - 40170 = Go to marker 10

#### `setTrackMute(trackId, muted)````

```javascript

// Convertir boolean a 0/1**Fallback seekTo**:

// Endpoint: GET /_/SET/TRACK/${trackId}/MUTE/${muted ? 1 : 0}```javascript

```// Si está fuera de rango o falla, usar seekTo(marker.pos)

```

### Auto-Configuración Smooth Seeking

### `scheduleJump(atBarLine, regionId)`

#### `autoConfigureReaperForJumpMode(jumpMode)`**Método**: Mixto (polling HTTP de tempo + OSC/HTTP para salto)

```javascript```javascript

// 1. SET/EXTSTATE/LiveRemote/jump_mode/${jumpMode}// Implementación compleja:

// 2. Si jumpMode === 'bar': SET/EXTSTATE/LiveRemote/bar_count/${barCount}// 1. Obtener tempo actual con getTempoAt() [HTTP]

// 3. SET/EXTSTATE/LiveRemote/smooth_seeking_action/auto_config// 2. Calcular siguiente línea de compás

// 4. Ejecutar: /_/${smoothSeekingScriptCmd}// 3. Poll cada 10ms para detectar cambio de compás [HTTP]

//    (Command ID del script smooth_seeking_control_v3.lua)// 4. Ejecutar jumpToSection() con OSC/HTTP en el momento calculado

``````



## 🔐 Autenticación### `getTracks()`

**Método**: HTTP (solo lectura)

Si el servidor web de REAPER tiene contraseña:```javascript

// Endpoint: GET /_/TRACK (sin parámetros)

```javascript// Procesar respuesta para extraer: id, name, vol, pan, mute, isVisible

const headers = {};```

if (username && password) {

  headers['Authorization'] = 'Basic ' + btoa(username + ':' + password);### `setTrackVol(id, value0to1)`

}**Método**: OSC (preferido) con fallback HTTP



fetch(url, { headers });**OSC**:

``````javascript

// Mensaje: /track/[N]/volume

## 📊 Formato de Respuestas// Args: [float 0.0-1.0] donde 1.0 = 0dB

// Nota: Convertir de escala fader (0-4) a OSC (0-1): oscVol = reaperVol / 4.0

Todas las respuestas HTTP de REAPER son **texto plano** con formato **TSV** (Tab-Separated Values).```



**Ejemplo de parsing**:**HTTP fallback**:

```javascript```javascript

const data = await makeRequest('/_/MARKERS');// Endpoint: GET /_/SET/TRACK/[id]/VOL/[valor]

const lines = data.trim().split('\n');// Convertir value0to1 a escala REAPER (0-4.0 o -inf a +12dB)

```

for (const line of lines) {

  const parts = line.split('\t');### `setTrackPan(id, valueNeg1to1)`

  const marker = {**Método**: OSC (preferido) con fallback HTTP

    id: parseInt(parts[0]),

    name: parts[1],**OSC**:

    pos: parseFloat(parts[2])```javascript

  };// Mensaje: /track/[N]/pan

}// Args: [float -1.0 a 1.0]

``````



## ⚡ Optimizaciones**HTTP fallback**:

```javascript

### Throttling en Faders// Endpoint: GET /_/SET/TRACK/[id]/PAN/[valueNeg1to1]

Los faders implementan throttling (50-100ms) para evitar spam de peticiones HTTP:```



```javascript### `setTrackMute(id, bool)`

// En ui.js**Método**: OSC (preferido) con fallback HTTP

const throttledSetVol = throttle((id, val) => {

  api.setTrackVol(id, val);**OSC**:

}, 50);```javascript

```// Mensaje: /track/[N]/mute

// Args: [int 0 o 1]

### Cache de Datos```

Los markers, regions y tracks se cargan una vez al inicio y se cachean en `state.js`. Solo se recargan si el usuario hace refresh explícito.

**HTTP fallback**:

## 🧪 Testing```javascript

// Endpoint: GET /_/TRACK/[id]/MUTE/[1 o 0]

### Mock Mode```

Para desarrollo sin REAPER:

### `getPlayState()`

```javascript**Método**: HTTP (solo lectura)

// En index.html```javascript

window.MOCK = true;// Endpoint: GET /_/TRANSPORT (parsear respuesta)

```// Endpoint: GET /_/BEATPOS (para posición actual)

// Combinar para obtener: isPlaying, pos, currentRegionId

La app usa datos de `tests/mock-api.json` en lugar de llamadas HTTP reales.// currentRegionId requiere comparar pos con regiones cargadas

```

## ⚠️ Notas Importantes

## 📋 Mensajes OSC Estándar de REAPER

1. **Índices**: REAPER usa índices **1-based** para pistas (la primera pista es 1, no 0).

### Transporte

2. **CORS**: El servidor web de REAPER permite CORS automáticamente.| Mensaje | Descripción | Argumentos |

|---------|-------------|------------|

3. **Puerto por defecto**: `8080` (configurable en Preferences → Control/OSC/Web).| `/play` | Iniciar reproducción | ninguno |

| `/stop` | Detener reproducción | ninguno |

4. **Latencia**: HTTP tiene ~50-200ms de latencia. Es aceptable para control de faders y saltos, pero no para timing crítico (smooth seeking lo compensa).| `/pause` | Pausar/reanudar | ninguno |

| `/record` | Iniciar/detener grabación | ninguno |

5. **No hay feedback automático**: Debes hacer polling si necesitas actualizaciones en tiempo real (ej: posición de reproducción cada 200ms).| `/rewind` | Ir al inicio del proyecto | ninguno |

| `/forward` | Ir al final del proyecto | ninguno |

## 🔄 Ejemplo Completo

### Posición

```javascript| Mensaje | Descripción | Argumentos |

// Conectar y cargar datos|---------|-------------|------------|

await api.init();| `/time` | Ir a tiempo | `f` (segundos) |

const regions = await api.getRegions();  // Canciones| `/time/str` | Ir a tiempo (string) | `s` (formato tiempo) |

const markers = await api.getMarkers();  // Secciones| `/beat` | Ir a beat | `f` (beat) |

| `/measure` | Ir a compás | `f` (compás) |

// Configurar modo de salto

await api.autoConfigureReaperForJumpMode('bar');### Marcadores/Regiones

| Mensaje | Descripción | Argumentos |

// Saltar a una sección|---------|-------------|------------|

await api.jumpToSection(markerId);  // REAPER esperará 1 compás| `/marker/[n]` | Ir al marcador N | `i` (índice 1-based) |

| `/marker/next` | Ir al siguiente marcador | ninguno |

// Control de mixer| `/marker/prev` | Ir al marcador anterior | ninguno |

await api.setTrackVol(1, 0.75);  // Click al 75%| `/region/[n]` | Ir a región N | `i` (índice 1-based) |

await api.setTrackMute(2, true);  // Mutear guía| `/region/next` | Ir a siguiente región | ninguno |

```| `/region/prev` | Ir a región anterior | ninguno |



## 📚 Referencias### Pistas

| Mensaje | Descripción | Argumentos |

- [REAPER Web Interface Documentation](https://www.reaper.fm/sdk/webrc/)|---------|-------------|------------|

- Documentación interna: `Help → Web interface API` en REAPER| `/track/[n]/volume` | Volumen de pista N | `f` (0.0-1.0, 1.0=0dB) |

| `/track/[n]/pan` | Pan de pista N | `f` (-1.0 a 1.0) |

---| `/track/[n]/mute` | Mute de pista N | `i` (0 o 1) |

| `/track/[n]/solo` | Solo de pista N | `i` (0 o 1) |

**Última actualización**: Configuración simplificada HTTP-only, sin OSC| `/track/[n]/select` | Seleccionar pista N | `i` (0 o 1) |

| `/track/[n]/recarm` | Rec arm de pista N | `i` (0 o 1) |

### Master
| Mensaje | Descripción | Argumentos |
|---------|-------------|------------|
| `/master/volume` | Volumen master | `f` (0.0-1.0) |
| `/master/pan` | Pan master | `f` (-1.0 a 1.0) |
| `/master/mute` | Mute master | `i` (0 o 1) |

### Feedback (REAPER → Cliente)
| Mensaje | Descripción | Argumentos |
|---------|-------------|------------|
| `/time` | Tiempo actual | `f` (segundos) |
| `/beat` | Beat actual | `f` |
| `/track/[n]/volume` | Feedback de volumen | `f` |
| `/track/[n]/vu` | VU meters | `f f` (L R) |
| `/track/[n]/mute` | Feedback de mute | `i` |
| `/transport/play` | Estado de reproducción | `i` (0 o 1) |

**Nota**: `n` = número de pista (1-based), `f` = float, `i` = integer, `s` = string

## ⚙️ Configuración de la Aplicación

### Activar/Desactivar OSC
1. Abre `settings.html` desde el botón ⚙️ en la app
2. Activa el toggle "Activar OSC"
3. Ingresa la URL del WebSocket bridge: `ws://[IP]:[PUERTO]`
4. Haz clic en "Guardar y Conectar"
5. Prueba la conexión con el botón "🧪 Probar Conexión"

### Fallback Automático
Si OSC falla o está desconectado, la aplicación usa HTTP automáticamente. Esto asegura que la app siempre funcione, aunque con mayor latencia.

## 🎯 Ventajas de OSC vs HTTP

| Característica | HTTP | OSC |
|----------------|------|-----|
| **Latencia** | 50-200ms | <10ms |
| **Ideal para** | Lectura de datos | Control en tiempo real |
| **Setup** | Nativo en REAPER | Requiere bridge |
| **Faders** | Laggy | Suave y instantáneo |
| **Play/Stop** | Noticeable delay | Instantáneo |
| **Saltos** | Aceptable | Ultra-rápido |
| **Feedback** | Polling | Bidireccional (tiempo real) |

## 🔧 Troubleshooting

### OSC no conecta
1. Verifica que el bridge esté corriendo
2. Verifica IP y puerto correcto
3. Verifica firewall (permitir puerto WebSocket)
4. Verifica que REAPER tenga OSC habilitado en Preferences

### Latencia en faders
- **Si usas HTTP**: Normal, considera usar OSC
- **Si usas OSC**: Verifica red (WiFi vs Ethernet, latencia de red)

### Saltos no funcionan
- Verifica que marcadores/regiones existan
- Revisa consola del navegador (F12) para ver logs
- Prueba deshabilitando comandos directos en Configuración

## ⚠️ Notas Importantes

1. **Autenticación HTTP**: Todas las peticiones HTTP incluyen autenticación básica si está configurada.

2. **CORS**: El servidor web de REAPER permite CORS, pero verifica la configuración si hay problemas.

3. **Índices**: Las pistas usan índices 1-based en REAPER (la primera pista es 1, no 0).

4. **Throttling**: OSC no requiere throttling, pero HTTP sí (implementado en faders con 50-100ms).

5. **Polling HTTP**: Para estado en tiempo real (posición, play/stop), se hace polling cada 200-500ms cuando se usa solo HTTP.

6. **OSC Feedback**: Si configuras feedback en REAPER, la app puede recibir actualizaciones en tiempo real de volumen, posición, etc.

## 🔄 Ejemplo de Petición con Fetch

```javascript
async function makeRequest(endpoint) {
  const baseURL = 'http://192.168.1.100:8080';
  const username = 'user';  // Si está configurado
  const password = 'pass';  // Si está configurado
  
  const headers = {};
  if (username && password) {
    headers['Authorization'] = 'Basic ' + btoa(username + ':' + password);
  }
  
  const response = await fetch(baseURL + endpoint, { headers });
  return await response.text();
}
```

## 📚 Referencias

- [REAPER Web Interface Documentation](https://www.reaper.fm/sdk/webrc/)
- Documentación interna: Ver en REAPER → Help → Web interface API

---

**TODO**: Completar detalles específicos una vez se pruebe con REAPER real.
