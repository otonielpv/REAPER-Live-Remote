# Reaper Live Remote - Frontend

Este directorio contiene todos los archivos del frontend que deben copiarse a la carpeta `reaper_www_root` de REAPER.

## 📁 Contenido

- `index.html` - Selector de canciones
- `song.html` - Detalle de canción (secciones y mezcla)
- `demo.html` - Página de demostración con modo MOCK
- `css/app.css` - Estilos completos
- `js/` - Módulos JavaScript
  - `api.js` - Capa de acceso a REAPER Web API
  - `state.js` - Estado global de la aplicación
  - `ui.js` - Renderizado de interfaz
  - `utils.js` - Funciones de utilidad

## 🚀 Despliegue

Desde la raíz del proyecto, ejecuta:

```powershell
.\deploy.ps1
```

O manualmente:

```powershell
Copy-Item -Recurse * "$env:APPDATA\REAPER\reaper_www_root\"
```

## 🧪 Modo Demo

Para probar sin REAPER, abre `demo.html` directamente o con un servidor local:

```powershell
python -m http.server 8000
```

Luego abre `http://localhost:8000/demo.html`

## 📖 Documentación

Consulta el README principal en la raíz del proyecto para más información.
