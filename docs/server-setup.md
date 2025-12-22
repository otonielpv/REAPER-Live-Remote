# 🎯 Configuración del Servidor Web en REAPER

Esta es la **configuración final** necesaria para que la aplicación funcione.

---

## 📍 Dónde encontrar la configuración

1. Abre **REAPER**
2. Ve al menú: **Options → Preferences** (o presiona `Ctrl + P`)
3. En el árbol de la izquierda, busca: **Control/OSC/Web**

---

## ⚙️ Configuración recomendada

```
┌─────────────────────────────────────────────────────┐
│  Control/OSC/Web                                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ☑ Enable web interface                            │
│                                                     │
│  Web interface                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ Port:     8080                               │  │
│  │ Username: admin          (opcional)          │  │
│  │ Password: ************   (opcional)          │  │
│  │                                              │  │
│  │ ☐ Allow remote control                       │  │
│  │ ☐ Restrict to local network                  │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│                   [   OK   ]  [ Cancel ]            │
└─────────────────────────────────────────────────────┘
```

---

## 🔐 ¿Debo usar usuario y contraseña?

### ✅ SÍ, si:
- Tocas en lugares públicos (bares, festivales)
- Quieres evitar que otras personas accedan
- Tu red WiFi no es segura

### ❌ NO es necesario si:
- Solo tú tienes acceso a tu red WiFi
- Estás ensayando en casa
- Prefieres acceso rápido sin autenticación

**Recomendación**: Usa contraseña siempre, es más seguro.

---

## 🌐 Configuración de red

### Opción 1: Solo red local (RECOMENDADA)

```
☑ Restrict to local network
```

Esto hace que REAPER solo escuche en tu red local (192.168.x.x).

### Opción 2: Acceso remoto

```
☑ Allow remote control
```

⚠️ **Cuidado**: Esto permite acceso desde internet si tu router lo permite.  
Solo activar si sabes lo que haces.

---

## 📱 ¿Cómo conectar desde la tablet?

Una vez activado el servidor:

1. **Asegúrate de que tablet y PC están en la misma WiFi**

2. **Encuentra tu IP local** (el instalador te la mostró):
   - Abre CMD en Windows
   - Ejecuta: `ipconfig`
   - Busca "IPv4 Address" → será algo como `192.168.1.100`

3. **En la tablet**, abre el navegador y ve a:
   ```
   http://192.168.1.100:8080
   ```
   (Reemplaza `192.168.1.100` con tu IP real)

4. Si configuraste usuario/contraseña, introdúcelos

5. **¡Listo!** Verás la lista de canciones

---

## 🐛 Solución de problemas

### ❌ "No puedo conectar desde la tablet"

**Prueba esto:**

1. **Verifica que el servidor está activo**
   - En REAPER, ve a `View → Monitoring → Show web interface status`
   - Debe decir: "Web interface running on port 8080"

2. **Prueba desde el mismo PC**
   - Abre un navegador en el PC
   - Ve a: `http://localhost:8080`
   - Si funciona → el problema es la red
   - Si no funciona → el servidor no está activo

3. **Verifica el firewall de Windows**
   - Busca "Firewall" en el menú inicio
   - Ve a "Permitir una aplicación a través de Firewall de Windows"
   - Busca "REAPER" y asegúrate de que está permitido en "Red privada"

4. **Verifica que tablet y PC están en la MISMA red**
   - Abre ajustes WiFi en ambos dispositivos
   - Deben estar conectados al mismo nombre de red

---

### ❌ "Pide usuario y contraseña pero no los recuerdo"

1. Ve a **Preferences → Control/OSC/Web**
2. Borra los campos de usuario y contraseña
3. Haz clic en **OK**
4. Recarga la página en la tablet

---

### ❌ "El puerto 8080 ya está en uso"

Si otra aplicación usa el puerto 8080:

1. Cambia el puerto a otro número (ej: `8081`, `8082`, etc.)
2. Haz clic en **OK**
3. Conecta desde la tablet usando el nuevo puerto:
   ```
   http://192.168.1.100:8081
   ```

---

## ✅ Verificación final

Si todo está bien, deberías ver:

- ✅ En REAPER: "Web interface running on port 8080"
- ✅ En el navegador del PC: La app funciona en `http://localhost:8080`
- ✅ En la tablet: La app funciona en `http://TU-IP:8080`

Si ves las 3 marcas verdes, **¡estás listo para tocar!** 🎸

---

**¿Necesitas más ayuda?** → Consulta el [README.md](README.md) o abre un Issue en GitHub.
