RegisterNetEvent('bandas:abrirMenu')
AddEventHandler('bandas:abrirMenu', function(bandasData)
    local menu = {
        id = 'menu_bandas',
        title = 'Gestión de Bandas',
        options = {
            {
                title = '🆕 Crear Nueva Banda',
                description = 'Crea una nueva banda',
                event = 'bandas:crearBandaMenu'
            },
            {
                title = '🗑️ Borrar Banda',
                description = 'Elimina una banda existente',
                event = 'bandas:borrarBandaMenu'
            },
            {
                title = '✏️ Editar Banda',
                description = 'Modifica una banda existente',
                event = 'bandas:editarBandaMenu',
                args = bandasData
            }
        }
    }
    lib.registerContext(menu)
    lib.showContext('menu_bandas')
end)

-- CREAR BANDAS
RegisterNetEvent('bandas:crearBandaMenw')
AddEventHandler('bandas:crearBandaMenu', function()
    local input = lib.inputDialog('Crear Banda', {
        {type = 'input', label = 'Nombre de la Banda', required = true},
        {type = 'input', label = 'Líder (License ID)', required = true},
        {type = 'input', label = 'Rangos (separados por comas)', required = true}
    })
    
    if input and input[1] and input[2] and input[3] then
        local nombreBanda = input[1]
        local liderLicense = input[2]
        local rangos = {}

        for rango in string.gmatch(input[3], "[^,]+") do
            rangos[rango] = ""
        end
        rangos['Líder'] = liderLicense

        TriggerServerEvent('bandas:crear', nombreBanda, liderLicense, rangos)
    else
        TriggerEvent('okokNotify:Alert', "Error", "Debes llenar todos los campos", 5000, "error")
    end
end)

-- BORRAR BANDAS
RegisterNetEvent('bandas:borrarBandaMenu')
AddEventHandler('bandas:borrarBandaMenu', function()
    TriggerServerEvent('bandas:solicitarBandasBorrar')
end)

RegisterNetEvent('bandas:mostrarBorrarBandaMenu')
AddEventHandler('bandas:mostrarBorrarBandaMenu', function(bandasData)
    if not bandasData or type(bandasData) ~= "table" or #bandasData == 0 then
        TriggerEvent('okokNotify:Alert', "Error", "No hay bandas disponibles para eliminar", 5000, "error")
        return
    end
    
    local options = {}
    for _, banda in ipairs(bandasData) do
        table.insert(options, {
            title = banda.nombre,
            description = 'Líder: ' .. banda.lider,
            event = 'bandas:borrarBandaConfirm',
            args = banda.nombre
        })
    end
    
    lib.registerContext({
        id = 'borrar_banda',
        title = 'Eliminar Banda',
        options = options
    })
    lib.showContext('borrar_banda')
end)

RegisterNetEvent('bandas:borrarBandaConfirm')
AddEventHandler('bandas:borrarBandaConfirm', function(nombreBanda)
    local confirm = lib.inputDialog('Confirmar Eliminación', {
        {type = 'input', label = 'Escribe "CONFIRMAR" para eliminar la banda ' .. nombreBanda, required = true}
    })
    
    if confirm and confirm[1] and confirm[1]:upper() == "CONFIRMAR" then
        TriggerServerEvent('bandas:borrar', nombreBanda)
    else
        TriggerEvent('okokNotify:Alert', "Cancelado", "No se eliminó la banda", 5000, "info")
    end
end)

-- EDITAR BANDAS
RegisterNetEvent('bandas:abrirMenu')
AddEventHandler('bandas:abrirMenu', function()
    TriggerServerEvent('bandas:solicitarBandasEditar')
end) 

RegisterNetEvent('bandas:editarBandaMenu')
AddEventHandler('bandas:editarBandaMenu', function(bandasData)
    if not bandasData or type(bandasData) ~= "table" or #bandasData == 0 then
        TriggerEvent('okokNotify:Alert', "Error", "No hay bandas disponibles para editar", 5000, "error")
        return
    end
    
    local options = {}
    for _, banda in ipairs(bandasData) do
        table.insert(options, {
            title = banda.nombre,
            description = 'Líder: ' .. banda.lider,
            event = 'bandas:editarBandaSeleccionada',
            args = banda
        })
    end
    
    lib.registerContext({
        id = 'editar_banda',
        title = 'Editar Banda',
        options = options
    })
    lib.showContext('editar_banda')
end)

RegisterNetEvent('bandas:editarBandaSeleccionada')
AddEventHandler('bandas:editarBandaSeleccionada', function(banda)
    local rangosArray = {}
    for rango, _ in pairs(banda.rangos) do
        table.insert(rangosArray, rango)
    end 

    local rangosString = table.concat(rangosArray, ", ")

    print("[DEBUG CLIENT] Banda seleccionada: " .. banda.nombre .. " - Rangos recibidos: " .. json.encode(banda.rangos)) -- 🚀 Depuración

    local input = lib.inputDialog('Editar Banda', {
        {type = 'input', label = 'Nuevo Nombre de la Banda', default = banda.nombre, required = true},
        {type = 'input', label = 'Nuevo Líder (License ID)', default = banda.lider, required = true},
        {type = 'input', label = 'Rangos (separados por comas)', default = rangosString, required = true}
    })
    
    if input and input[1] and input[2] and input[3] then
        local nuevoNombre = input[1]
        local nuevoLider = input[2]
        local nuevosRangos = {}
        -- Convertir la cadena de texto a tabla de rangos
        for rango in string.gmatch(input[3], "[^,]+") do
            nuevosRangos[rango] = ""
        end
        TriggerServerEvent('bandas:editar', banda.nombre, nuevoNombre, nuevoLider, nuevosRangos)
    else
        TriggerEvent('okokNotify:Alert', "Error", "Debes llenar todos los campos", 5000, "error")
    end
end)


RegisterNetEvent('bandas:actualizarPanel')
AddEventHandler('bandas:actualizarPanel', function()
    TriggerServerEvent('panelbandas')
end)