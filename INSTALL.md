# 🚀 Guía de Instalación Rápida

Esta guía te llevará paso a paso para instalar **REAPER Live Remote** en menos de 5 minutos.

---

## 📋 Requisitos previos

Antes de empezar, asegúrate de tener:

- ✅ **REAPER** instalado (v6.0 o superior) - [Descargar](https://www.reaper.fm)
- ✅ **Windows** (7/8/10/11)
- ✅ Una **tablet o smartphone** con navegador

---

## 🎯 Instalación automática (RECOMENDADO)

### Opción 1: Un solo clic

1. **Haz doble clic en:**
   ```
   install.bat
   ```

2. **Sigue las instrucciones en pantalla**
   - El instalador te preguntará si quieres instalar SWS Extension
   - Te guiará para registrar el script en REAPER
   - Copiará automáticamente todos los archivos

3. **¡Listo!** El instalador te mostrará tu IP para conectar desde la tablet

---

### Opción 2: PowerShell (más control)

1. **Abre PowerShell** en la carpeta del proyecto:
   - Shift + Click derecho en la carpeta
   - Selecciona "Abrir ventana de PowerShell aquí"

2. **Ejecuta:**
   ```powershell
   .\install.ps1
   ```

3. **Sigue las instrucciones en pantalla**

---

## 🔧 Configurar servidor web en REAPER

Después de ejecutar el instalador, solo falta un paso:

### 1. Abre REAPER

### 2. Ve a Preferencias
   - Menú: **Options → Preferences** (Ctrl+P)

### 3. Busca la sección "Control/OSC/Web"
   - En el árbol de la izquierda

### 4. Activa el servidor web
   ```
   ☑ Enable web interface
   ```

### 5. Configura:
   - **Port**: `8080`
   - **Username**: `admin` (opcional, recomendado)
   - **Password**: `tu_contraseña` (opcional, recomendado)

### 6. Haz clic en **OK**

---

## 📱 Conectar desde tu tablet

### 1. Asegúrate de que tu tablet y PC están en la **misma red WiFi**

### 2. En tu tablet, abre el navegador

### 3. Ve a la dirección que te mostró el instalador:
   ```
   http://192.168.X.X:8080
   ```
   *(Reemplaza X.X con la IP de tu PC)*

### 4. Si configuraste usuario/contraseña, introdúcelos

### 5. **¡Listo!** 🎉

---

## 🔍 ¿Cómo encontrar mi IP?

Si no recuerda tu IP local:

### Windows:
1. Abre **CMD** (Símbolo del sistema)
2. Ejecuta: `ipconfig`
3. Busca **"IPv4 Address"** bajo tu adaptador WiFi
4. Será algo como: `192.168.1.100`

---

## ❓ Problemas comunes

### ❌ "No se puede conectar a REAPER"

**Solución:**
1. Verifica que REAPER esté abierto
2. Verifica que activaste "Enable web interface" en Preferences
3. Asegúrate de que tablet y PC están en la misma red WiFi
4. Prueba abrir `http://localhost:8080` en el PC primero

---

### ❌ "Error al ejecutar install.bat"

**Solución:**
1. Haz clic derecho en `install.bat`
2. Selecciona **"Ejecutar como administrador"**

---

### ❌ "No aparecen las canciones"

**Solución:**
1. Asegúrate de tener **regiones** en tu proyecto REAPER
2. Guarda tu proyecto: `Ctrl + S`
3. Recarga la página web

---

## 📚 Siguiente paso

Una vez instalado, consulta el **README.md** para aprender:

- Cómo preparar tu proyecto REAPER
- Cómo usar los 3 modos de salto
- Cómo controlar la mezcla
- Trucos y consejos para directos

---

## 🆘 ¿Necesitas ayuda?

- 📖 Lee el **README.md** completo
- 🐛 Abre un **Issue** en GitHub
- 📧 Contacta al desarrollador

---

**¡Disfruta tocando en vivo!** 🎸

---

## 📦 Instalación manual (Mac/Linux o usuarios avanzados)

Si prefieres instalar manualmente o usas Mac/Linux:

### 1. Instalar SWS Extension (opcional)

- Descarga desde: https://www.sws-extension.org
- Instala siguiendo las instrucciones para tu sistema operativo
- Reinicia REAPER

### 2. Copiar archivos web

```bash
# Mac/Linux
cp -r webroot/* ~/Library/Application\ Support/REAPER/reaper_www_root/
```

```powershell
# Windows (PowerShell)
Copy-Item -Path webroot\* -Destination "$env:APPDATA\REAPER\reaper_www_root\" -Recurse -Force
```

### 3. Copiar script Lua

```bash
# Mac/Linux
cp reaper-scripts/smooth_seeking_control_v3.lua ~/Library/Application\ Support/REAPER/Scripts/
```

```powershell
# Windows (PowerShell)
Copy-Item -Path reaper-scripts\smooth_seeking_control_v3.lua -Destination "$env:APPDATA\REAPER\Scripts\" -Force
```

### 4. Registrar script en REAPER

1. En REAPER: **Actions → Show action list** (Shift + /)
2. Clic en **New action... → Load ReaScript...**
3. Selecciona: `Scripts/smooth_seeking_control_v3.lua`
4. **Copia el Command ID** (ejemplo: `_RS7D3C92BC...`)

### 5. Configurar Command ID

Edita el archivo `state.js`:

```bash
# Ubicación del archivo:
# Windows: %APPDATA%\REAPER\reaper_www_root\js\state.js
# Mac: ~/Library/Application Support/REAPER/reaper_www_root/js/state.js
```

Busca la línea:
```javascript
smoothSeekingScriptCmd: null,
```

Reemplaza `null` con tu Command ID:
```javascript
smoothSeekingScriptCmd: '_RS7D3C92BC...',
```

### 6. Configurar servidor web en REAPER

1. **Preferences → Control/OSC/Web**
2. Marca: **☑ Enable web interface**
3. Puerto: `8080`
4. Usuario/Contraseña: (opcional)
5. Clic en **OK**

### 7. Conectar desde tablet

- Encuentra tu IP local:
  - Mac: `ifconfig | grep "inet " | grep -v 127.0.0.1`
  - Linux: `ip addr show | grep "inet "`
- En tu tablet, ve a: `http://TU-IP:8080`

---

**¡Listo!** 🎉
