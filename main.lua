ESX = exports['es_extended']:getSharedObject()
local Bandas = {}

local Bandas = {}

CreateThread(function()
    exports.oxmysql:execute("SELECT * FROM bandas", {}, function(result)
        for _, banda in ipairs(result) do
            Bandas[banda.nombre] = {
                nombre = banda.nombre,
                lider = banda.lider,
                miembros = json.decode(banda.miembros) or {},
                rangos = json.decode(banda.rangos) or {}
            }
        end
    end)
end)

RegisterCommand('panelbandas', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        local bandasData = {}
        for nombre, datos in pairs(Bandas) do
            table.insert(bandasData, {
                nombre = nombre,
                lider = datos.lider,
                miembros = #datos.miembros,
                rangos = datos.rangos
            })
        end
        TriggerClientEvent('bandas:abrirMenu', source, bandasData)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Error", "No tienes permisos", 5000, "error")
    end
end, false)

-- CREAR BANDAS
RegisterNetEvent('bandas:crear')
AddEventHandler('bandas:crear', function(nombreBanda, liderLicense, rangos)


    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= 'admin' then
        TriggerClientEvent('okokNotify:Alert', source, "INFO-WCRP", "No tienes permisos para crear OD's", 5000, "error")
        return
    end

    if Bandas[nombreBanda] then
        TriggerClientEvent('okokNotify:Alert', source, "INFO-WCRP", "El nombre de la OD ya existe", 5000, "error")
        return
    end

    Bandas[nombreBanda] = {
        nombre = nombreBanda,
        lider = liderLicense,
        miembros = {},
        rangos = rangos or { ['Líder'] = liderLicense }
    }

    exports.oxmysql:execute(
        "INSERT INTO bandas (nombre, lider, miembros, rangos) VALUES (?, ?, ?, ?)",
        {nombreBanda, liderLicense, json.encode({}), json.encode(rangos or { ['Líder'] = liderLicense })},
        function(affectedRows)
            if affectedRows > 0 then
                if source then
                    TriggerClientEvent('okokNotify:Alert', source, "INFO-WCRP", "Banda creada correctamente: " .. nombreBanda, 5000, "success")
                end
            else
                TriggerClientEvent('okokNotify:Alert', source, "INFO-WCRP", "Error al crear la banda", 5000, "error")
            end
        end
    )

end)

-- BORRAR BANDAS
RegisterNetEvent('bandas:solicitarBandasBorrar')
AddEventHandler('bandas:solicitarBandasBorrar', function()
    local src = source
    local bandasData = {}
    for nombre, datos in pairs(Bandas) do
        table.insert(bandasData, {
            nombre = nombre,
            lider = datos.lider
        })
    end
    TriggerClientEvent('bandas:mostrarBorrarBandaMenu', src, bandasData)
end)

RegisterNetEvent('bandas:borrar')
AddEventHandler('bandas:borrar', function(nombreBanda)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getGroup() ~= 'admin' then
        TriggerClientEvent('okokNotify:Alert', src, "Error", "No tienes permisos para eliminar bandas", 5000, "error")
        return
    end
    
    if not Bandas[nombreBanda] then
        TriggerClientEvent('okokNotify:Alert', src, "Error", "La banda no existe", 5000, "error")
        return
    end
    
    Bandas[nombreBanda] = nil

    exports.oxmysql:execute("DELETE FROM bandas WHERE nombre = ?", {nombreBanda})
    
    TriggerClientEvent('okokNotify:Alert', src, "Éxito", "Banda eliminada correctamente", 5000, "success")
    TriggerClientEvent('bandas:actualizarPanel', -1)
end)


-- EDITAR
RegisterNetEvent('bandas:solicitarBandasEditar')
AddEventHandler('bandas:solicitarBandasEditar', function()
    local bandasData = {}

    for nombre, datos in pairs(Bandas) do
        local rangosLista = {}

        -- Verificar si los rangos existen y son una tabla
        if datos.rangos and type(datos.rangos) == "table" then
            for rango, _ in pairs(datos.rangos) do
                table.insert(rangosLista, rango)
            end
        end

        print("[DEBUG SERVER] Banda: " .. nombre .. " - Rangos: " .. json.encode(rangosLista)) -- 🚀 Depuración

        table.insert(bandasData, {
            nombre = nombre,
            lider = datos.lider,
            rangos = rangosLista
        })
    end

    TriggerClientEvent('bandas:mostrarEditarBandaMenu', source, bandasData)
end)

RegisterNetEvent('bandas:editar')
AddEventHandler('bandas:editar', function(nombreActual, nuevoNombre, nuevoLider, nuevosRangos)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        TriggerClientEvent('okokNotify:Alert', source, "Error", "No tienes permisos para editar bandas", 5000, "error")
        return
    end
    
    if not Bandas[nombreActual] then
        TriggerClientEvent('okokNotify:Alert', source, "Error", "La banda no existe", 5000, "error")
        return
    end
    
    Bandas[nuevoNombre] = {
        nombre = nuevoNombre,
        lider = nuevoLider,
        miembros = Bandas[nombreActual].miembros,
        rangos = nuevosRangos
    }
    Bandas[nombreActual] = nil

    exports.oxmysql:execute(
        "UPDATE bandas SET nombre = ?, lider = ?, rangos = ? WHERE nombre = ?",
        {nuevoNombre, nuevoLider, json.encode(nuevosRangos), nombreActual}
    )

    
    TriggerClientEvent('okokNotify:Alert', source, "Éxito", "Banda editada correctamente", 5000, "success")
    TriggerClientEvent('bandas:actualizarPanel', -1)
end)
