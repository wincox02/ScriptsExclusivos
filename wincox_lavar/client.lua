ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local abriolavar = false
local blipentrega = nil
local blipamarillo = nil
local trabajo = false

--local idcamionspawneado = 0

--Citizen.CreateThread(function()
--    while true do
--        ESX.TriggerServerCallback('obteneridcamionactivo', function(idcamion)
--            idcamionspawneado = idcamion
--        end)
--        Citizen.Wait(1000)
--    end
--end)

Citizen.CreateThread(function()
    while blipentrega == nil do
        blipentrega = AddBlipForCoord(Config.destino.x, Config.destino.y, Config.destino.z - 1)
        SetBlipSprite(blipentrega, 67)
        SetBlipDisplay(blipentrega, 4)
        SetBlipScale(blipentrega, 1.0)
        SetBlipColour(blipentrega, 1)
        SetBlipAsShortRange(blipentrega, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Entrega Lavado Dinero")
        EndTextCommandSetBlipName(blipentrega)
    end
end)

Citizen.CreateThread(function() --validamos pos
    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))
        Citizen.Wait(1)
        if GetDistanceBetweenCoords(coords, Config.punto.x, Config.punto.y, Config.punto.z - 1, true) < 10 then --dibujar punto para compra
            DrawMarker(1, Config.punto.x, Config.punto.y, Config.punto.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0,
                102, 102, 204,
                100,
                false, true, 2, false, false, false, false)
        end
        if not abriolavar then
            if GetDistanceBetweenCoords(coords, Config.punto.x, Config.punto.y, Config.punto.z, true) < 1.2 then --sugerencia y abrir menu al presionar
                SetTextComponentFormat('STRING')
                AddTextComponentString("Pulsa E para lavar dinero")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                if IsControlJustPressed(0, 38) then --si aprieta la E se cambia abrio tienda
                    abrirlavar()
                    abriolavar = true
                end
            end
        end
        --print(GetVehiclePedIsIn(PlayerPedId(), false))
        --print("idcamionspawneado: "..idcamionspawneado)
        --print("GetVehiclePedIsIn(PlayerPedId(), false): "..GetVehiclePedIsIn(PlayerPedId(), false))
        --print(GetEntityModel(GetVehiclePedIsIn(PlayerPedId())))
        if GetDistanceBetweenCoords(coords, Config.destino.x, Config.destino.y, Config.destino.z - 1, true) < 10 and IsPedInAnyVehicle(PlayerPedId(), false) and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) == 1747439474 then
            DrawMarker(1, Config.destino.x, Config.destino.y, Config.destino.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5,
                1.0,
                102, 102, 204,
                100,
                false, true, 2, false, false, false, false)
            if GetDistanceBetweenCoords(coords, Config.destino.x, Config.destino.y, Config.destino.z - 1, true) < 5 then
                SetTextComponentFormat('STRING')
                AddTextComponentString("Pulsa E para dejar el furgon")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                if IsControlJustPressed(0, 38) then --si aprieta la E entrega el furgon
                    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                    ESX.Game.DeleteVehicle(vehicle)
                    TriggerServerEvent('finalizarcamion', GetPlayerServerId(PlayerId()))
                    trabajo = false
                    Citizen.Wait(2000)
                    RemoveBlip(blipamarillo)
                end
            end
        end
    end
end)


function successmsg(msg)
    TriggerEvent("pNotify:SetQueueMax", "center", 2)
    TriggerEvent("pNotify:SendNotification", {
        text = msg,
        type = "success",
        timeout = 3500,
        layout = "centerRight",
        queue = "center"
    })
end

function errormsg(msg)
    TriggerEvent("pNotify:SetQueueMax", "center", 2)
    TriggerEvent("pNotify:SendNotification", {
        text = msg,
        type = "error",
        timeout = 3000,
        layout = "centerRight",
        queue = "center"
    })
end

local cantidadcamion = 0

function abrirlavar()
    local inicio = {}
    table.insert(inicio, { label = "Lavar la ropa ahora (Max: " .. Config.Maximo .. ")", value = 'lavarahora' })
    ESX.TriggerServerCallback('obtenercantidaddelavados', function(lavadostotales)
        -- print("lavadostotales:  " .. lavadostotales)
        if lavadostotales >= 3 then
            table.insert(inicio, { label = "Obtener Camion de lavados ", value = 'trabajocamion' })
        end

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'inicio',
            {
                title    = "LAVADORA",
                align    = 'bottom-right',
                elements = inicio,
            },
            function(data, menuinicio)
                if data.current.value == 'lavarahora' then
                    ESX.UI.Menu.Open(
                        'dialog', GetCurrentResourceName(), 'cantidadalavar',
                        {
                            title = "Cantidad a lavar",
                        },
                        function(data2, menu)
                            menu.close()
                            local cantidad = tonumber(data2.value)
                            if cantidad > 0 then
                                -- print("id:  " .. GetPlayerServerId(PlayerId()))
                                TriggerServerEvent('lavarguita', GetPlayerServerId(PlayerId()), cantidad)
                            else
                                TriggerEvent('chat:addMessage', { args = { '^1LAVADOR', "Cantidad invalida" } })
                            end
                        end,
                        function(data2, menu)
                            abriolavar = false
                            menu.close()
                        end)
                end


                if data.current.value == 'trabajocamion' then
                    ESX.TriggerServerCallback('obtenerlavadosdia', function(cantidadlavados)
                        -- print("cantidadlavados:  " .. cantidadlavados)
                        if cantidadlavados == 0 then
                            ESX.TriggerServerCallback('cantidadpolisdispo', function(polis)
                                if polis >= Config.polisnecesarios then
                                    ESX.UI.Menu.Open(
                                        'dialog', GetCurrentResourceName(), 'cantidadalavar',
                                        {
                                            title = "Cantidad a lavar",
                                        },
                                        function(data2, menu)
                                            menu.close()
                                            cantidadcamion = tonumber(data2.value)
                                            if cantidadcamion > 0 then
                                                ESX.TriggerServerCallback('hayencargosenciudad',
                                                    function(encargosenciudad)
                                                        if not encargosenciudad then
                                                            ESX.TriggerServerCallback('obtenerplataennegro',
                                                                function(plata)
                                                                    if plata >= cantidadcamion then
                                                                        if not trabajo then
                                                                            successmsg(
                                                                                "Lleva este camion a el punto del gps que te he marcado (cuidado con que te roben y la Guardia Civil)")
                                                                            trabajo = true
                                                                            trabajocamion()
                                                                            menu.close()
                                                                        else
                                                                            menu.close()
                                                                            errormsg("Ya estas en un encargo")
                                                                        end
                                                                    else
                                                                        menu.close()
                                                                        errormsg("No tienes suficiente dinero")
                                                                    end
                                                                end, GetPlayerServerId(PlayerId()))
                                                        else
                                                            TriggerEvent('chat:addMessage',
                                                                {
                                                                    args = { '^1LAVADOR',
                                                                        "Ya hay alguien lavando en la ciudad" }
                                                                })
                                                        end
                                                    end)
                                            else
                                                TriggerEvent('chat:addMessage',
                                                    { args = { '^1LAVADOR', "Cantidad invalida" } })
                                            end
                                        end,
                                        function(data2, menu)
                                            --abriolavar = false
                                            menu.close()
                                        end)
                                else
                                    TriggerEvent('chat:addMessage',
                                        {
                                            args = { '^1LAVADOR',
                                                "No hay polis suficientes. Cantidad necesaria: " ..
                                                Config.polisnecesarios }
                                        })
                                end
                            end, GetPlayerServerId(PlayerId()))
                        else
                            TriggerEvent('chat:addMessage',
                                { args = { '^1LAVADOR', "Ya lavaste por hoy, relajate un poco" } })
                        end
                    end, GetPlayerServerId(PlayerId()))
                end
            end,
            function(data, menu)
                abriolavar = false
                menu.close() --menu inicio
            end
        )
    end, GetPlayerServerId(PlayerId()))
end

local plate = nil
local spawned_car = nil
local blip = nil
local gps = true

function trabajocamion()
    spawn_car()
    blipamarillo = AddBlipForCoord(Config.destino.x, Config.destino.y, Config.destino.z - 1)
    SetBlipRoute(blipamarillo, true)
    Citizen.Wait(1200)
    TriggerServerEvent('empiezatrabajocamion', GetPlayerServerId(PlayerId()), plate, spawned_car, cantidadcamion)
    mandarcoords()
end

function mandarcoords()
    Citizen.CreateThread(function()
        while trabajo do
            local coords = GetEntityCoords(spawned_car)
            TriggerServerEvent('agarrarcoords', coords)
            if coords.x == 0.0 and coords.y == 0.0 and coords.z == 0.0 then
                TriggerServerEvent('terminotrabajomal')
            end
            Citizen.Wait(15000)
        end
    end)
end

RegisterNetEvent('eliminarblip')
AddEventHandler('eliminarblip', function()
    RemoveBlip(blip)
end)

function spawn_car()
    Citizen.Wait(0)

    local vehicle = GetHashKey('Stockade')

    RequestModel(vehicle)

    while not HasModelLoaded(vehicle) do
        Wait(1)
    end
    spawned_car = CreateVehicle(vehicle, Config.spawn.x, Config.spawn.y, Config.spawn.z, Config.spawn.r, -996.786,
        25.1887, true, false)

    plate = "WIN " .. math.random(100, 900)
    --Citizen.Trace(plate)
    SetVehicleNumberPlateText(spawned_car, plate)
    SetVehicleOnGroundProperly(spawned_car)
    SetVehicleLivery(spawned_car, 2)
    SetModelAsNoLongerNeeded(vehicle)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
    TriggerEvent("advancedFuel:setEssence", 100, GetVehicleNumberPlateText(spawned_car),
        GetDisplayNameFromVehicleModel(GetEntityModel(spawned_car)))
end

RegisterNetEvent('mostrarcoordenadas')
AddEventHandler('mostrarcoordenadas', function(coords)
    if coords.x == 0.0 and coords.y == 0.0 and coords.z == 0.0 then
        RemoveBlip(blip)
    else
        RemoveBlip(blip)
        blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 67)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        ESX.TriggerServerCallback('obtenerplayertrabajo', function(job)
            if job == 'police' and gps and not trabajo then
                SetBlipRoute(blip, true)
                TriggerEvent('chat:addMessage',
                    { args = { '^1LAVADOR', "Hay una persona lavando dinero. Posicion marcada en GPS" } })
            end
        end, GetPlayerServerId(PlayerId()))
    end
end)

RegisterNetEvent('alternargps')
AddEventHandler('alternargps', function()
    if gps then
        TriggerEvent('chat:addMessage', { args = { '^1LAVADOR', "GPS Desactivado" } })
        gps = false
    else
        TriggerEvent('chat:addMessage', { args = { '^1LAVADOR', "GPS Activado" } })
        gps = true
    end
end)
