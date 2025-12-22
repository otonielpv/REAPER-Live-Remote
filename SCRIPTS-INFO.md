# 🚀 Scripts de Instalación

Esta carpeta contiene varios scripts para facilitar la instalación de REAPER Live Remote.

---

## 📋 ¿Qué script debo usar?

### 🏆 **Recomendado: install.bat**

```
Haz doble clic: install.bat
```

**Características:**
- ✅ Instalación completamente automática
- ✅ Verifica que REAPER esté instalado
- ✅ Ayuda a instalar SWS Extension
- ✅ Registra el script Lua automáticamente
- ✅ Configura el Command ID en el código
- ✅ Muestra tu IP local para conectar
- ✅ **No requiere conocimientos técnicos**

**Cuándo usar:** Primera instalación o reinstalación completa.

---

## 📦 Scripts disponibles

### 1. install.bat
**Instalador automático (más fácil)**

```cmd
install.bat
```

- Para usuarios sin conocimientos técnicos
- Doble clic y listo
- Hace TODO por ti

---

### 2. install.ps1
**Instalador PowerShell (más control)**

```powershell
.\install.ps1
```

**Opciones avanzadas:**
```powershell
# Saltar instalación de SWS
.\install.ps1 -SkipSWS
```

- Igual que `install.bat` pero con más opciones
- Para usuarios que prefieren PowerShell
- Más mensajes de debug

---

### 3. verify-install.ps1
**Verificador de instalación**

```powershell
.\verify-install.ps1
```

**Verifica:**
- ✅ Archivos web instalados
- ✅ Script Lua copiado
- ✅ SWS Extension instalada
- ✅ Command ID configurado
- ✅ Servidor web activo
- ✅ IP local

**Cuándo usar:** Después de instalar, para verificar que todo está OK.

---

### 4. deploy.bat / deploy.ps1
**Solo copiar archivos (simple)**

```cmd
deploy.bat
```

```powershell
.\deploy.ps1
```

**Hace:**
- Copia archivos web a `reaper_www_root`
- Crea backup si ya existe una instalación
- Muestra tu IP local

**NO hace:**
- No instala SWS
- No registra scripts
- No configura Command ID

**Cuándo usar:** 
- Actualización rápida de archivos web
- Ya tienes todo configurado
- Solo quieres copiar cambios

---

## 🔄 Flujo de trabajo recomendado

### Primera vez:
```
1. install.bat  → Instalación completa
2. verify-install.ps1 → Verificar que todo está OK
3. Configurar servidor web en REAPER
4. ¡Listo!
```

### Actualización:
```
1. deploy.bat → Copiar archivos nuevos
2. verify-install.ps1 → Verificar (opcional)
```

---

## 🆘 Solución de problemas

### ❌ "Error al ejecutar install.bat"

**Solución:**
1. Haz clic derecho en `install.bat`
2. Selecciona **"Ejecutar como administrador"**

---

### ❌ "PowerShell no puede ejecutar scripts"

**Error típico:**
```
install.ps1 cannot be loaded because running scripts is disabled
```

**Solución:**
1. Abre PowerShell como administrador
2. Ejecuta:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Confirma con `Y`
4. Intenta de nuevo

---

### ❌ "No se encuentra REAPER"

**Verifica:**
- ✅ REAPER está instalado
- ✅ La carpeta `%APPDATA%\REAPER` existe

Si instalaste REAPER en una ubicación personalizada, el instalador podría no encontrarlo. Instala manualmente siguiendo [INSTALL.md](../INSTALL.md).

---

## 📚 Más información

- **[INSTALL.md](../INSTALL.md)** - Guía de instalación completa
- **[README.md](../README.md)** - Documentación principal
- **[docs/server-setup.md](../docs/server-setup.md)** - Configurar servidor web

---

## 💡 Tips

### Para desarrolladores:

Si estás modificando el código y quieres probar cambios rápidamente:

```powershell
# Solo copiar archivos web (sin reinstalar todo)
.\deploy.ps1
```

### Para usuarios avanzados:

Si quieres ver exactamente qué hace cada script:

```powershell
# Ver el código del instalador
Get-Content install.ps1 | more
```

---

**¿Necesitas ayuda?** → Abre un issue en GitHub o consulta la documentación completa.
