# 🚀 Guía de Despliegue

Cómo poner Reaper Live Remote en producción para usar en directos.

## 📋 Requisitos Previos

### Hardware
- **Portátil/PC** con REAPER instalado
- **Tablet** (iPad, Android, o tablet Windows)
- **Router WiFi** dedicado (recomendado para directos) o red local confiable

### Software
- REAPER 6.0 o superior (con Web Interface habilitado)
- Navegador web moderno en la tablet (Chrome, Safari, Edge, Firefox)

## 🔧 Paso 1: Configurar REAPER

### 1.1 Habilitar Web Interface

1. Abre REAPER
2. Ve a **Options → Preferences** (o `Ctrl+P`)
3. En el árbol de la izquierda, ve a: **Control/OSC/Web**
4. Marca la casilla **"Enable web interface"**

### 1.2 Configurar Puerto y Contraseña

Dentro de la misma sección:

- **Port**: Usa `8080` (o cualquier puerto libre)
- **Username**: (opcional) Define un usuario (ej: `admin`)
- **Password**: **⚠️ IMPORTANTE** - Establece una contraseña segura
- **Default web interface**: Deja vacío o apunta a la carpeta de Reaper Live Remote
- **Allow access from**: Puedes dejarlo en "Any IP" o restringir a tu red local (192.168.x.x)

### 1.3 Configurar carpeta web root

REAPER busca archivos web en:
```
Windows: %APPDATA%\REAPER\reaper_www_root\
macOS: ~/Library/Application Support/REAPER/reaper_www_root/
Linux: ~/.config/REAPER/reaper_www_root/
```

Copia los archivos de `webroot/` a esa carpeta (ver Paso 2).

### 1.4 Reiniciar servidor (si está activo)

Si REAPER ya estaba abierto:
- Desmarca y vuelve a marcar "Enable web interface"
- O reinicia REAPER

## 📂 Paso 2: Copiar Archivos Web

### Método A: PowerShell (Windows)

```powershell
# Define rutas
$source = "C:\Repos\Reaper\webroot"
$destination = "$env:APPDATA\REAPER\reaper_www_root"

# Crea carpeta si no existe
New-Item -ItemType Directory -Force -Path $destination

# Copia archivos
Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force

Write-Host "✅ Archivos copiados a: $destination"
```

### Método B: Manual

1. Abre el explorador de archivos
2. Navega a `%APPDATA%\REAPER\reaper_www_root\`
   - Si no existe, créala
3. Copia todo el contenido de `webroot\` dentro de esa carpeta
4. Deberías tener:
   ```
   reaper_www_root/
   ├─ index.html
   ├─ song.html
   ├─ css/
   ├─ js/
   └─ assets/
   ```

### macOS / Linux

```bash
# macOS
cp -R webroot/* ~/Library/Application\ Support/REAPER/reaper_www_root/

# Linux
cp -R webroot/* ~/.config/REAPER/reaper_www_root/
```

## 🌐 Paso 3: Conectar la Tablet

### 3.1 Conectar a la misma red

**Opción A: Red local existente**
- Conecta portátil y tablet a la misma red WiFi

**Opción B: Router dedicado (recomendado para directos)**
- Usa un router portátil
- Conecta solo portátil y tablet
- Evita interferencias de otros dispositivos

### 3.2 Obtener IP del portátil

**Windows (PowerShell):**
```powershell
ipconfig
# Busca "IPv4 Address" de tu adaptador WiFi
# Ejemplo: 192.168.1.100
```

**macOS/Linux:**
```bash
ifconfig
# O más simple:
ifconfig | grep "inet "
```

### 3.3 Abrir en el navegador de la tablet

1. Abre el navegador (Chrome/Safari recomendados)
2. Escribe la URL:
   ```
   http://[IP_DEL_PORTATIL]:8080
   ```
   Ejemplo: `http://192.168.1.100:8080`

3. **Autenticación**:
   - Introduce usuario y contraseña configurados en REAPER
   - Marca "Recordar" para no tener que introducirlo cada vez

4. Deberías ver la pantalla de selección de canciones

### 3.4 Añadir a pantalla de inicio (opcional)

**iPad/iPhone (Safari):**
1. Toca el botón de compartir
2. "Añadir a pantalla de inicio"
3. Ahora puedes abrirlo como una app

**Android (Chrome):**
1. Menú → "Añadir a pantalla de inicio"
2. O Chrome mostrará automáticamente el banner "Instalar app"

## 🔒 Paso 4: Seguridad

### Recomendaciones para directos

1. **Contraseña fuerte**: No uses contraseñas simples
2. **Red dedicada**: Usa un router solo para el directo
3. **Sin Internet**: El router no necesita conexión a Internet
4. **IP fija**: Configura IP estática en el portátil para que no cambie

### Configurar IP estática (Windows)

1. Panel de control → Red e Internet → Centro de redes
2. Click en tu adaptador WiFi → Propiedades
3. Protocolo de Internet versión 4 (TCP/IPv4) → Propiedades
4. Marca "Usar la siguiente dirección IP":
   - IP: `192.168.1.100` (o la que prefieras)
   - Máscara: `255.255.255.0`
   - Puerta de enlace: `192.168.1.1` (IP del router)

## 🧪 Paso 5: Probar Antes del Directo

### Checklist de pruebas

- [ ] Abrir proyecto de prueba con 2-3 canciones preparadas
- [ ] Verificar que aparecen todas las canciones en index.html
- [ ] Tocar una canción y ver las secciones correctas
- [ ] Probar salto inmediato entre secciones
- [ ] Probar salto "al compás" (si está implementado)
- [ ] Verificar botones Play/Stop
- [ ] Ajustar volúmenes de Click y Guía
- [ ] Probar con proyecto completo del directo
- [ ] Simular pérdida de conexión (apagar/encender WiFi)
- [ ] Verificar latencia aceptable (debe responder <500ms)

### Solución de problemas comunes

**No carga la página**
- ✅ Verifica que REAPER está abierto y Web Interface habilitado
- ✅ Comprueba la IP del portátil (puede haber cambiado)
- ✅ Verifica que el puerto 8080 no esté bloqueado por firewall

**Aparece pero no hay canciones**
- ✅ Verifica que el proyecto tiene marcadores (canciones)
- ✅ Abre la consola del navegador (F12) y mira errores
- ✅ Verifica que los archivos se copiaron correctamente

**Latencia alta (>1 segundo)**
- ✅ Verifica calidad de la señal WiFi
- ✅ Acerca la tablet al router
- ✅ Desconecta otros dispositivos de la red
- ✅ Usa un router de 5GHz si está disponible

**Los cambios no funcionan (play/stop/volumen)**
- ✅ Verifica la autenticación (usuario/contraseña)
- ✅ Mira la consola del navegador para ver errores de API
- ✅ Verifica que REAPER responde (prueba abrir http://IP:8080 en el portátil)

## 📱 Paso 6: Optimización para Tablet

### Configuración del navegador

**iPad:**
- Safari → Ajustes → "Solicitar sitio de escritorio" → Desactivado
- Mantén pantalla encendida durante el uso
- Modo "No molestar" activado

**Android:**
- Chrome → Configuración → Sitios web → Zoom de página → 100%
- Configuración → Pantalla → Tiempo antes de que la pantalla se apague → 30 min

### Rendimiento

- Cierra otras apps en la tablet
- Activa modo avión + solo WiFi (evita notificaciones)
- Carga completa de batería antes del directo
- Ten cargador a mano por si acaso

## 🔄 Actualizar la App

Cuando hagas cambios en el código:

1. Modifica archivos en `webroot/`
2. Copia de nuevo a `reaper_www_root/` (ver Paso 2)
3. En la tablet, recarga la página (`Ctrl+R` o pull-to-refresh)
4. Si no se ven cambios, borra caché del navegador

## 🎸 Setup para Directo Real

### Orden recomendado de preparación

1. Día anterior:
   - Proyecto REAPER preparado con marcadores y regiones
   - App actualizada y copiada
   - Probar en casa con la tablet

2. En el local (antes de la prueba de sonido):
   - Montar router dedicado y conectar portátil
   - Anotar IP del portátil (por si acaso)
   - Conectar tablet y probar conexión
   - Dejar tablet cargándose

3. Durante la prueba de sonido:
   - Prueba completa: cambiar canciones, ajustar volúmenes
   - Verificar que todo responde bien
   - Colocar tablet en posición accesible (pie de micro, mesa...)

4. Durante el directo:
   - Tablet cerca del líder/director musical
   - REAPER en modo reproducción (no edición)
   - Portátil con pantalla apagada (opcional) para ahorrar batería

## 📞 Soporte

Si encuentras problemas:
1. Revisa los logs en la consola del navegador (F12 en la tablet si es posible)
2. Verifica que REAPER responde directamente: abre `http://IP:8080` en el portátil
3. Consulta `docs/mapping.md` para detalles de la API

---

**¡Listo para el directo! 🎉**
