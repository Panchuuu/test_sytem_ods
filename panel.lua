RegisterNetEvent("wcrp-ods:abrirPanelBanda")
AddEventHandler("wcrp-ods:abrirPanelBanda", function(banda, esLider)
    if esLider then
        lib.registerContext({
            id = 'panel_ods',
            title = "Gestión de Banda: "..banda,
            options = {
                { title = "Invitar Miembro", event = "wcrp-ods:invitarMiembro" },
                { title = "Expulsar Miembro", event = "wcrp-ods:expulsarMiembro" },
                { title = "Ajustar Salario", event = "wcrp-ods:ajustarSalario" },
                { title = "Depositar Dinero", event = "wcrp-ods:depositarDinero" },
                { title = "Retirar Dinero", event = "wcrp-ods:retirarDinero" }
            }
        })
        lib.showContext("panel_ods")
    else
        TriggerEvent("okokNotify:Alert", "Error", "No eres el líder de esta banda.", 5000, "error")
    end
end)