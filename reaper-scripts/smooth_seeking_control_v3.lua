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
-- - LiveRemote/smooth_seeking_action: "enable", "disable", "toggle", "auto_config", "status", "request_jump", "cancel"
-- - LiveRemote/jump_mode: "immediate", "bar", "region-end"
-- - LiveRemote/deferred_jump_pos: posición destino en segundos
-- - LiveRemote/bar_count: número de compases a esperar

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
-- LÓGICA DE SALTO DIFERIDO (FLUENT JUMP)
-- ==============================================================

function get_trigger_time(jump_mode, bar_count)
  local current_pos = reaper.GetPlayPosition()
  if not reaper.GetPlayState() == 1 then -- Si no está en play, usar cursor de edición
    current_pos = reaper.GetCursorPosition()
  end

  if jump_mode == "bar" then
    -- Calcular el inicio del compás objetivo
    local _, measures, _, _, _ = reaper.TimeMap2_timeToBeats(0, current_pos)
    local trigger_measure = measures + (bar_count or 1)
    return reaper.TimeMap2_beatsToTime(0, 0, trigger_measure)
    
  elseif jump_mode == "region-end" then
    -- Encontrar el final de la región actual
    local _, region_idx = reaper.GetLastMarkerAndCurRegion(0, current_pos)
    if region_idx ~= -1 then
      local _, _, _, region_end, _, _ = reaper.EnumProjectMarkers3(0, region_idx)
      return region_end
    end
  end
  
  return nil
end

function monitor_loop()
  -- Verificar si se ha cancelado
  local action = reaper.GetExtState("LiveRemote", "smooth_seeking_action")
  if action == "cancel" then
    msg("🚫 Monitoreo cancelado por el usuario")
    reaper.DeleteExtState("LiveRemote", "deferred_jump_pos", false)
    reaper.DeleteExtState("LiveRemote", "trigger_time", false)
    reaper.DeleteExtState("LiveRemote", "lua_monitoring", false)
    reaper.DeleteExtState("LiveRemote", "smooth_seeking_action", false)
    return
  end

  local target_pos_str = reaper.GetExtState("LiveRemote", "deferred_jump_pos")
  local trigger_time_str = reaper.GetExtState("LiveRemote", "trigger_time")
  
  if target_pos_str == "" or trigger_time_str == "" then
    reaper.DeleteExtState("LiveRemote", "lua_monitoring", false)
    return
  end
  
  local target_pos = tonumber(target_pos_str)
  local trigger_time = tonumber(trigger_time_str)
  
  -- Si REAPER se detiene, cancelar el monitoreo
  if reaper.GetPlayState() == 0 then
    msg("⏹️ Monitoreo detenido porque REAPER se paró")
    reaper.DeleteExtState("LiveRemote", "deferred_jump_pos", false)
    reaper.DeleteExtState("LiveRemote", "trigger_time", false)
    reaper.DeleteExtState("LiveRemote", "lua_monitoring", false)
    return
  end

  local current_pos = reaper.GetPlayPosition()
  
  -- Umbral de disparo (150ms antes para asegurar que REAPER procese el seek a tiempo)
  local threshold = 0.150 
  
  if current_pos >= (trigger_time - threshold) then
    msg("🚀 Disparando salto a " .. target_pos .. "s (Trigger: " .. trigger_time .. "s)")
    
    -- Realizar el salto (seekplay = true para que el cursor de reproducción salte)
    reaper.SetEditCurPos(target_pos, true, true)
    
    -- Limpiar estado
    reaper.DeleteExtState("LiveRemote", "deferred_jump_pos", false)
    reaper.DeleteExtState("LiveRemote", "trigger_time", false)
    reaper.DeleteExtState("LiveRemote", "lua_monitoring", false)
  else
    -- Seguir monitoreando
    reaper.defer(monitor_loop)
  end
end

function start_deferred_jump()
  local jump_mode = reaper.GetExtState("LiveRemote", "jump_mode")
  local bar_count = tonumber(reaper.GetExtState("LiveRemote", "bar_count")) or 1
  
  local trigger_time = get_trigger_time(jump_mode, bar_count)
  
  if trigger_time then
    reaper.SetExtState("LiveRemote", "trigger_time", tostring(trigger_time), false)
    
    -- Iniciar bucle si no está activo
    local is_running = reaper.GetExtState("LiveRemote", "lua_monitoring")
    if is_running ~= "1" then
      reaper.SetExtState("LiveRemote", "lua_monitoring", "1", false)
      monitor_loop()
    end
  else
    error_msg("No se pudo calcular el tiempo de disparo")
  end
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
  -- NOTA: Ahora usamos el método "Fluent" (Lua monitorea y salta)
  -- por lo que desactivamos el smooth seeking interno de REAPER para evitar ruidos al cancelar.
  
  if jump_mode == "immediate" or jump_mode == "bar" or jump_mode == "region-end" then
    -- Desactivamos el smooth seeking interno de REAPER.
    -- El salto lo gestionará este script de forma diferida si es necesario.
    setSmoothSeekState(false, false)
    setSmoothSeekMeasures(0)
    msg("🔧 Modo " .. jump_mode .. " configurado (Smooth Seek interno OFF)")
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
    
  elseif action == "request_jump" then
    -- NUEVO: Salto diferido manejado por Lua para evitar "locked seek"
    start_deferred_jump()

  elseif action == "cancel" then
    -- CANCELAR SALTO: Limpiar estado de diferido y también smooth seeking de REAPER
    msg("🚫 Cancelando salto programado...")
    
    -- 1. Limpiar estado de Lua (el monitor_loop lo detectará y se detendrá)
    reaper.DeleteExtState("LiveRemote", "deferred_jump_pos", false)
    reaper.DeleteExtState("LiveRemote", "trigger_time", false)
    
    -- 2. Desactivar smooth seeking interno de REAPER por si acaso estaba activo
    setSmoothSeekState(false, false)
    setSmoothSeekMeasures(0)
    
    -- 3. Forzar un micro-seek a la posición actual para limpiar el buffer de REAPER
    local cur_pos = reaper.GetPlayPosition()
    reaper.SetEditCurPos(cur_pos, false, false)
    
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
