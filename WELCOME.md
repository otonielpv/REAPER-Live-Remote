# 👋 Bienvenido a REAPER Live Remote

¡Gracias por usar REAPER Live Remote! Esta herramienta está diseñada para músicos que tocan en vivo con backing tracks.

---

## 🚀 ¿Primera instalación?

**Instalación automática en 2 minutos:**

```
Haz doble clic en:  install.bat
```

El instalador hará TODO automáticamente:
- ✅ Instalará SWS Extension (si no la tienes)
- ✅ Copiará todos los archivos necesarios
- ✅ Configurará el script automáticamente
- ✅ Te guiará paso a paso

---

## 📖 Documentación

- **[README.md](README.md)** - Guía completa de uso
- **[INSTALL.md](INSTALL.md)** - Instrucciones de instalación detalladas
- **[docs/server-setup.md](docs/server-setup.md)** - Configurar servidor web en REAPER

---

## ✅ Verificar instalación

¿Ya instalaste pero algo no funciona?

```powershell
.\verify-install.ps1
```

Este script verifica que todo esté correctamente configurado.

---

## 🎮 Usar la aplicación

Una vez instalado:

1. **Abre REAPER** con tu proyecto
2. **Asegúrate de tener**:
   - Regiones (= canciones)
   - Marcadores (= secciones)
3. **Conecta desde tu tablet** a: `http://TU-IP:8080`
4. **¡Empieza a tocar!** 🎸

---

## 🐛 ¿Problemas?

### No puedo conectar desde la tablet

1. Verifica que el servidor web esté activo en REAPER:
   - `Preferences → Control/OSC/Web → Enable web interface`
2. Asegúrate de que tablet y PC están en la misma WiFi
3. Ejecuta `.\verify-install.ps1` para diagnosticar

### Los modos de salto avanzados no funcionan

1. Verifica que instalaste SWS Extension
2. Asegúrate de que registraste el script Lua
3. Comprueba que el Command ID está configurado en `state.js`

### No aparecen canciones/secciones

1. Verifica que tienes **regiones** en tu proyecto (no solo marcadores)
2. Los **marcadores** deben estar **dentro** de las regiones
3. Guarda el proyecto y recarga la página

---

## 📚 Más información

- **Issues**: [Abre un issue en GitHub](https://github.com/TU-USUARIO/reaper-live-remote/issues)
- **Contribuir**: Ver sección "Contribuir" en README.md
- **Licencia**: MIT - Libre para usar y modificar

---

## 🎸 ¡Disfruta tocando en vivo!

Este proyecto está hecho con ❤️ para músicos que quieren concentrarse en tocar, no en configurar software.

Si te resulta útil, ¡compártelo con otros músicos! ⭐

---

**Quick Links:**
- [Instalar](INSTALL.md)
- [Documentación completa](README.md)
- [Configurar servidor web](docs/server-setup.md)
- [Verificar instalación](verify-install.ps1)
