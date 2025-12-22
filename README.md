# 🎸 REAPER Live Remote

**Control remoto táctil para REAPER durante directos en vivo**

Diseñada para músicos que tocan con backing tracks, esta aplicación web te permite controlar REAPER desde una tablet sin tocar el portátil en el escenario.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![REAPER](https://img.shields.io/badge/REAPER-6.0%2B-orange.svg)

---

## 🎯 ¿Por qué usar esto?

Si tocas en directo con REAPER y necesitas:

- ✅ **Cambiar de canción** rápidamente entre temas
- ✅ **Saltar entre secciones** (intro, verso, coro, puente) sin tocar el teclado
- ✅ **Ajustar mezcla** (volumen de click, guía, backing tracks)
- ✅ **Control táctil** desde una tablet en el escenario

**Entonces esta aplicación es para ti.**

---

## ✨ Características principales

### 🎵 Navegación de canciones y secciones
- Lista todas las canciones de tu proyecto REAPER
- Botones grandes táctiles para cada sección (intro, verso, coro, etc.)
- Navegación rápida e intuitiva

### ⏱️ 3 modos de salto musical
1. **Inmediato**: Salto instantáneo (ideal para ensayos)
2. **Al compás**: Espera 1/2/4/8/16 compases antes de saltar (mantiene el timing en vivo)
3. **Al finalizar**: Espera al final de la sección actual antes de cambiar

### 🎛️ Control de mezcla en tiempo real
- Faders de volumen, pan y mute por pista
- **Sincronización automática**: los cambios en REAPER se reflejan en la web en tiempo real
- Diseñados para tablets (grandes, fáciles de usar en el escenario)
- Ajusta click, guía y backing tracks al vuelo

### 🎮 Controles de transporte
- Play/Stop
- Ir al inicio de la canción actual
- Todo accesible desde la interfaz táctil

### 🌐 Simple y sin complicaciones
- Solo HTTP, sin configuración compleja
- Funciona en cualquier navegador moderno
- Tablet y PC en la misma WiFi = listo para tocar

---

## ⚡ Inicio rápido

**¿Primera vez?** Solo 3 pasos:

1. **Ejecuta el instalador:**
   ```
   Doble clic en: install.bat
   ```
   
2. **Sigue las instrucciones** (el instalador te guía paso a paso)

3. **Configura el servidor web en REAPER:**
   - `Preferences → Control/OSC/Web`
   - Marca: `☑ Enable web interface`
   - Puerto: `8080`

**¿Quieres verificar que todo está bien?**

```powershell
.\verify-install.ps1
```

**📚 Más ayuda:** Ver [INSTALL.md](INSTALL.md) para guía detallada con capturas.

---

## 📸 Screenshots

_(Próximamente)_

---

## 🚀 Instalación ultra-rápida

### ⚡ Instalador automático (RECOMENDADO)

**Solo para Windows. Instala TODO automáticamente en 2 minutos.**

#### Opción 1: Doble clic (más fácil)

```
1. Haz doble clic en: install.bat
2. Sigue las instrucciones en pantalla
3. ¡Listo!
```

#### Opción 2: PowerShell (más control)

```powershell
.\install.ps1
```

El instalador automático hace TODO por ti:
- ✅ Verifica que REAPER esté instalado
- ✅ Te ayuda a instalar SWS Extension (si no la tienes)
- ✅ Copia el script Lua a la carpeta correcta
- ✅ Copia la interfaz web a REAPER
- ✅ Te guía para registrar el script y obtener el Command ID
- ✅ Configura automáticamente el Command ID en el código
- ✅ Te muestra tu IP local para conectar desde la tablet

**👉 Ver guía detallada con capturas: [INSTALL.md](INSTALL.md)**

---

### 📋 Requisitos previos

- **REAPER** v6.0 o superior ([descargar](https://www.reaper.fm))
- **Windows** 7/8/10/11 (para el instalador automático)
- Tablet y PC en la **misma red WiFi**
- Navegador moderno (Chrome, Safari, Firefox, Edge)

> 💡 **Nota**: SWS Extension se puede instalar automáticamente durante la instalación.

---

### 🔧 Último paso: Configurar servidor web

Después de ejecutar el instalador, solo necesitas:

1. Abre **REAPER**
2. Ve a **Preferences → Control/OSC/Web** (Ctrl+P)
3. Marca: **☑ Enable web interface**
4. Configura:
   - **Puerto**: `8080`
   - **Usuario/Contraseña**: (opcional, recomendado)
5. Haz clic en **OK**

**¡Listo!** Ahora abre tu tablet y ve a `http://TU-IP:8080`

---

### 🍎 Instalación en Mac/Linux

Si usas Mac o Linux, puedes instalar manualmente:

**Ver guía completa: [INSTALL.md](INSTALL.md#instalación-manual)**

---

## 🎼 Cómo preparar tu proyecto REAPER

La aplicación necesita que organices tu timeline de esta manera:

### Estructura: Regiones = Canciones, Marcadores = Secciones

```
Timeline de REAPER:

[Región: "Canción 1"]  (0:00 - 3:00)
├─ 0:00  [Marcador] Intro
├─ 0:30  [Marcador] Verso
├─ 1:00  [Marcador] Coro
├─ 1:30  [Marcador] Verso 2
├─ 2:00  [Marcador] Coro
└─ 2:30  [Marcador] Final

[Región: "Canción 2"]  (3:00 - 6:00)
├─ 3:00  [Marcador] Intro
├─ 3:30  [Marcador] Verso
└─ 5:00  [Marcador] Coro
```

### Pasos para configurar:

1. **Crear Regiones para cada canción completa**
   - Selecciona el rango de tiempo de la canción
   - Clic derecho en timeline → "Insert region from time selection"
   - Nombra la región con el nombre de la canción

2. **Crear Marcadores para cada sección dentro de la canción**
   - Coloca el cursor al inicio de cada sección
   - Presiona `Shift + M` (o clic derecho → "Insert marker")
   - Usa nombres descriptivos: "Intro", "Verso", "Coro", "Puente", "Solo", "Final"

3. **Verificar en Region/Marker Manager**
   - `View → Region/Marker Manager`
   - Asegúrate de que los marcadores están **dentro** de las regiones correctas

---

## 🎮 Cómo usar

### Vista principal: Lista de canciones

1. Verás todas las canciones de tu proyecto (regiones)
2. Toca una canción para abrir sus secciones

### Vista de canción

**Pestaña "Secciones":**
- Botones grandes para cada sección de la canción
- Toca un botón para saltar a esa sección
- Selector de **Modo de salto** arriba:
  - **Inmediato**: Salto instantáneo
  - **Al compás**: Espera X compases (selector de 1/2/4/8/16)
  - **Al finalizar**: Espera al final de la sección actual

**Pestaña "Mezcla":**
- Faders verticales para ajustar volumen de cada pista
- Botón **M** para mute/unmute
- Control de **Pan** (L/R)

**Controles de transporte:**
- ▶️ **Play**
- ⏹️ **Stop**
- ⏮️ **Ir al inicio** de la canción

---

## 📖 Modos de salto explicados

### 🏃 Modo "Inmediato"
- **Cuándo usar**: Ensayos, pruebas de sonido
- **Comportamiento**: Salto instantáneo, sin esperas
- **Nota**: Puede romper el tempo si está sonando

### 🎵 Modo "Al compás"
- **Cuándo usar**: Actuaciones en vivo, mantener timing perfecto
- **Comportamiento**: Reproduce X compases más, luego salta en el siguiente beat
- **Configurable**: 1, 2, 4, 8 o 16 compases
- **Ideal para**: Mantener el groove durante el show

**Ejemplo** (con 1 compás):
```
Estás en "Verso" - Compás 10, beat 3
→ Tocas "Coro"
→ Termina de reproducir el compás 10 (beat 4)
→ Al llegar al compás 11 → salta a "Coro"
```

### 🎭 Modo "Al finalizar"
- **Cuándo usar**: Transiciones largas, intros, finales elaborados
- **Comportamiento**: Reproduce hasta el final de la sección/región actual, luego salta
- **Ideal para**: Transiciones naturales sin cortes bruscos

---

## 🛠️ Estructura del proyecto

```
reaper-live-remote/
├── 📄 README.md              # Este archivo - Guía principal
├── 📄 INSTALL.md             # Guía de instalación detallada
├── 📄 LICENSE                # Licencia MIT
├── 📦 package.json           # Configuración del proyecto
│
├── 🚀 Instaladores (¡USA ESTOS!)
│   ├── install.bat           # Instalador automático (doble clic)
│   ├── install.ps1           # Instalador PowerShell (completo)
│   ├── verify-install.ps1    # Verificar que todo está bien
│   ├── deploy.bat            # Solo copiar archivos (simple)
│   └── deploy.ps1            # Solo copiar archivos (PowerShell)
│
├── 🌐 webroot/               # Frontend (se copia a reaper_www_root)
│   ├── index.html            # Vista principal (lista de canciones)
│   ├── song.html             # Vista de detalle (secciones/mezcla)
│   ├── demo.html             # Demo sin REAPER
│   ├── css/app.css           # Estilos
│   └── js/
│       ├── api.js            # Comunicación con REAPER
│       ├── state.js          # Estado global
│       ├── ui.js             # Renderizado de UI
│       └── utils.js          # Utilidades
│
├── 🎼 reaper-scripts/        # Scripts Lua para REAPER
│   ├── smooth_seeking_control_v3.lua  # Control de saltos avanzados
│   ├── README.md             # Documentación de scripts
│   └── SCRIPTS-GUIDE.md      # Guía detallada
│
├── 📚 docs/                  # Documentación técnica
│   ├── mapping.md            # Mapeo de API REAPER
│   ├── deploy.md             # Guía de despliegue completa
│   └── server-setup.md       # 🆕 Configuración del servidor web
│
└── 🧪 tests/
    └── mock-api.json         # Datos de prueba
```

---

## 🐛 Solución de problemas

### ❓ ¿Algo no funciona?

**Ejecuta el verificador:**
```powershell
.\verify-install.ps1
```

Este script comprueba automáticamente:
- ✅ Archivos web instalados correctamente
- ✅ Script Lua registrado
- ✅ SWS Extension instalada
- ✅ Command ID configurado
- ✅ Servidor web activo
- ✅ IP local para conectar

---

### ❌ No se puede conectar a REAPER

**Verifica:**
- ✅ El servidor web esté activado en Preferences
- ✅ Tablet y PC están en la misma red WiFi
- ✅ Prueba abrir `http://localhost:8080` en el PC primero
- ✅ Firewall de Windows permite REAPER en red privada

### ❌ No aparecen canciones

**Verifica:**
- ✅ El proyecto tiene **regiones** (no solo marcadores)
- ✅ Guarda el proyecto: `Ctrl + S`
- ✅ Recarga la página web

### ❌ No aparecen secciones

**Verifica:**
- ✅ Hay **marcadores dentro de cada región**
- ✅ Abre `View → Region/Marker Manager` para verificar
- ✅ Los marcadores están en el rango temporal correcto

### ❌ Modo "al compás" no funciona

**Verifica:**
- ✅ Registraste `smooth_seeking_control_v3.lua`
- ✅ Copiaste el Command ID correcto a `state.js`
- ✅ Tienes SWS Extension instalada

### ❌ Faders no responden

**Verifica:**
- ✅ Usuario/contraseña correctos (si los configuraste)
- ✅ Las pistas están visibles en REAPER
- ✅ Revisa la consola del navegador (F12) para errores

---

## 🧪 Modo demo (sin REAPER)

Para probar la aplicación sin tener REAPER instalado:

1. Abre `webroot/demo.html` en tu navegador
2. O sirve con un servidor local:
   ```bash
   cd webroot
   python -m http.server 8000
   # Luego abre: http://localhost:8000/demo.html
   ```

La aplicación usará datos simulados de `tests/mock-api.json`.

---

## 📚 Documentación adicional

### 🚀 Instalación y configuración
- **[INSTALL.md](INSTALL.md)** - Guía de instalación paso a paso con capturas
- **[WELCOME.md](WELCOME.md)** - Introducción rápida al proyecto
- **[SCRIPTS-INFO.md](SCRIPTS-INFO.md)** - Explicación de cada script de instalación
- **[docs/server-setup.md](docs/server-setup.md)** - Configurar servidor web en REAPER (con troubleshooting)

### 📖 Uso y desarrollo
- **[docs/mapping.md](docs/mapping.md)** - Endpoints HTTP de REAPER y funciones de la API
- **[docs/deploy.md](docs/deploy.md)** - Guía de despliegue completa
- **[reaper-scripts/README.md](reaper-scripts/README.md)** - Documentación de scripts Lua
- **[reaper-scripts/SCRIPTS-GUIDE.md](reaper-scripts/SCRIPTS-GUIDE.md)** - Guía detallada de scripts

---

## 🚧 Limitaciones conocidas

- Requiere conexión activa a REAPER (no funciona offline)
- Latencia HTTP de ~50-200ms (aceptable para la mayoría de casos)
- Máximo ~20 pistas visibles sin scroll
- Polling del mezclador cada 500ms (suficiente para uso en vivo)
- Sin vumetros en tiempo real (futuro)

---

## 🎯 Roadmap

- [x] ~~Sincronización automática del mezclador con REAPER~~
- [ ] Colores personalizables por tipo de sección
- [ ] Guardar/recuperar snapshots de mezcla
- [ ] Reconexión automática tras pérdida de WiFi

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si encuentras un bug o tienes una idea:

1. Abre un **Issue** describiendo el problema/mejora
2. Haz **fork** del repositorio
3. Crea una **rama** para tu feature: `git checkout -b feature/nueva-funcionalidad`
4. Haz **commit** de tus cambios: `git commit -m 'Añadir nueva funcionalidad'`
5. Haz **push**: `git push origin feature/nueva-funcionalidad`
6. Abre un **Pull Request**

---

## 📜 Licencia

Este proyecto está bajo la licencia **MIT**. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- Inspirado en las necesidades reales de músicos en directo
- Construido con las herramientas estándar de REAPER
- Gracias a la comunidad de REAPER por la documentación y soporte

---

## 📞 Contacto

Si tienes preguntas o sugerencias, abre un Issue en GitHub.

---
