-- Smooth Seeking Control V3 for REAPER Live Remote
-- ACTUALIZADO con documentación oficial de variables
--
-- VARIABLES REALES (documentación oficial):
-- ✅ smoothseek = bitfield (bits 1 y 2)
--    Bit 1 (valor 1): Smooth seeking ON/OFF
--    Bit 2 (valor 2): Modo (0=measures, 1=marker/region)
-- ✅ smoothseekmeas = 0-2147483647 (número de compases)
--
-- CONFIGURACIÓN:
-- 1. Actions → Show action list
-- 2. New action → Load ReaScript
-- 3. Seleccionar este archivo
-- 4. Copiar el Command ID que aparece
-- 5. Usar ese ID para llamar desde Web API
--
-- PARÁMETROS (via ExtState):
-- - LiveRemote/smooth_seeking_action: "enable", "disable", "toggle", "auto_config", "status"
-- - LiveRemote/jump_mode: "immediate", "bar", "region-end"

-- Solo mostrar errores
local SILENT_MODE = true

function msg(m)
  if not SILENT_MODE then
    reaper.ShowConsoleMsg(tostring(m) .. "\n")
  end
end

function error_msg(m)
  reaper.ShowConsoleMsg("❌ ERROR: " .. tostring(m) .. "\n")
end

-- ==============================================================
-- FUNCIONES DE ACCESO A CONFIGURACIÓN DE REAPER
-- ==============================================================

function hasSWS()
  return reaper.SNM_GetIntConfigVar ~= nil
end

function getSmoothSeekState()
  -- smoothseek es un bitfield:
  -- Bit 1 (valor 1): Smooth seeking enabled
  -- Bit 2 (valor 2): Modo (0=measures, 1=marker/region)
  
  if not hasSWS() then
    error_msg("SWS Extension requerida")
    return nil, nil
  end
  
  local smoothseek = reaper.SNM_GetIntConfigVar("smoothseek", -1)
  if smoothseek == -1 then
    error_msg("No se pudo leer 'smoothseek'")
    return nil, nil
  end
  
  local enabled = (smoothseek & 1) ~= 0  -- Bit 1
  local use_markers = (smoothseek & 2) ~= 0  -- Bit 2
  
  return enabled, use_markers
end

function setSmoothSeekState(enable, use_markers)
  -- Construir bitfield:
  -- Bit 1 = enable (0 o 1)
  -- Bit 2 = use_markers (0 o 2)
  -- SIN MENSAJES para evitar spam
  
  if not hasSWS() then
    return false
  end
  
  local value = 0
  if enable then
    value = value | 1  -- Set bit 1
  end
  if use_markers then
    value = value | 2  -- Set bit 2
  end
  
  local success = reaper.SNM_SetIntConfigVar("smoothseek", value)
  return success
end

function getSmoothSeekMeasures()
  -- smoothseekmeas = número de compases (0 a 2147483647)
  
  if not hasSWS() then
    error_msg("SWS Extension requerida")
    return nil
  end
  
  local measures = reaper.SNM_GetIntConfigVar("smoothseekmeas", -1)
  if measures == -1 then
    error_msg("No se pudo leer 'smoothseekmeas'")
    return nil
  end
  
  return measures
end

function setSmoothSeekMeasures(measures)
  -- Establecer cuántos compases reproducir antes de hacer seek
  -- SIN MENSAJES para evitar spam
  
  if not hasSWS() then
    return false
  end
  
  if measures < 0 or measures > 99 then
    return false
  end
  
  local success = reaper.SNM_SetIntConfigVar("smoothseekmeas", measures)
  return success
end

function autoConfigureForJumpMode(jump_mode)
  -- Configuración automática según el modo de salto de la web app
  -- SIN MENSAJES para evitar spam en la consola
  
  if jump_mode == "immediate" then
    -- MODO INMEDIATO:
    -- - Smooth seeking OFF
    -- - Measures = 0 (por si acaso)
    setSmoothSeekState(false, false)  -- OFF, modo measures
    setSmoothSeekMeasures(0)
    
  elseif jump_mode == "bar" then
    -- MODO AL COMPÁS:
    -- - Smooth seeking ON
    -- - Modo = measures (bit 2 = 0)
    -- - Measures = configurado por usuario
    
    -- Leer preferencia del usuario
    local bar_count_str = reaper.GetExtState("LiveRemote", "bar_count")
    local bar_count = tonumber(bar_count_str) or 1
    
    setSmoothSeekState(true, false)  -- ON, modo measures
    setSmoothSeekMeasures(bar_count)
    
  elseif jump_mode == "region-end" then
    -- MODO AL FINAL:
    -- - Smooth seeking ON
    -- - Modo = marker/region (bit 2 = 1)
    -- - Measures = 1 (mínimo)
    setSmoothSeekState(true, true)  -- ON, modo marker/region
    setSmoothSeekMeasures(1)
    
  else
    error_msg("Modo desconocido: " .. jump_mode)
    return false
  end
  
  return true
end

-- ==============================================================
-- LÓGICA PRINCIPAL
-- ==============================================================

function main()
  -- Verificar SWS
  if not hasSWS() then
    error_msg("SWS Extension NO encontrada - Instalar desde https://www.sws-extension.org/")
    return
  end
  
  -- Leer acción solicitada desde ExtState
  local action = reaper.GetExtState("LiveRemote", "smooth_seeking_action")
  
  if action == "" then
    -- Sin acción, salir silenciosamente
    return
  end
  
  -- Procesar acción
  if action == "enable" then
    local _, use_markers = getSmoothSeekState()
    setSmoothSeekState(true, use_markers or false)
    
  elseif action == "disable" then
    local _, use_markers = getSmoothSeekState()
    setSmoothSeekState(false, use_markers or false)
    
  elseif action == "toggle" then
    local enabled, use_markers = getSmoothSeekState()
    if enabled ~= nil then
      setSmoothSeekState(not enabled, use_markers or false)
    else
      error_msg("No se pudo leer estado actual")
    end
    
  elseif action == "auto_config" then
    -- AUTO-CONFIGURACIÓN según modo de salto
    local jump_mode = reaper.GetExtState("LiveRemote", "jump_mode")
    
    if jump_mode == "" then
      error_msg("Debe especificar 'jump_mode' (immediate, bar, region-end)")
      return
    end
    
    autoConfigureForJumpMode(jump_mode)
    
  elseif action == "status" then
    -- Mostrar estado y guardarlo en ExtState para que la web pueda leerlo
    local enabled, use_markers = getSmoothSeekState()
    local measures = getSmoothSeekMeasures()
    
    if enabled ~= nil then
      reaper.SetExtState("LiveRemote", "smooth_seeking_enabled", enabled and "1" or "0", false)
      reaper.SetExtState("LiveRemote", "smooth_seeking_use_markers", use_markers and "1" or "0", false)
    end
    
    if measures ~= nil then
      reaper.SetExtState("LiveRemote", "smooth_seeking_measures_current", tostring(measures), false)
    end
    
  else
    error_msg("Acción desconocida: " .. action .. " (válidas: enable, disable, toggle, auto_config, status)")
  end
  
  -- Limpiar ExtState después de ejecutar
  reaper.DeleteExtState("LiveRemote", "smooth_seeking_action", false)
end

-- Ejecutar
main()
