ESX.RegisterServerCallback("wcrp-ods:obtenerBanda", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        exports.oxmysql:fetch("SELECT banda, es_lider FROM users WHERE identifier = @identifier", {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if result[1] then
                cb(result[1].banda, result[1].es_lider == 1)
            else
                cb(nil, false)
            end
        end)
    end
end)

RegisterNetEvent("wcrp-ods:asignarBanda")
AddEventHandler("wcrp-ods:asignarBanda", function(targetPlayer, banda)
    local xPlayer = ESX.GetPlayerFromId(targetPlayer)
    if xPlayer then
        exports.oxmysql:execute("UPDATE users SET banda = @banda WHERE identifier = @identifier", {
            ['@banda'] = banda,
            ['@identifier'] = xPlayer.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent("okokNotify:Alert", targetPlayer, "Banda", "Has sido asignado a la banda "..banda, 5000, "success")
            end
        end)
    end
end)

RegisterCommand("panelods", function()
    ESX.TriggerServerCallback("wcrp-ods:obtenerBanda", function(banda, esLider)
        if banda then
            TriggerEvent("wcrp-ods:abrirPanelBanda", banda, esLider)
        else
            TriggerEvent("okokNotify:Alert", "Error", "No perteneces a ninguna banda.", 5000, "error")
        end
    end)
end, false)