--wincox#2959

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('comandogivecar')
AddEventHandler('comandogivecar', function(args)
    local id = tonumber(args[1])
    local modelo = args[2]
    local playerPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(playerPed)
    ESX.Game.SpawnVehicle(modelo, coords, 50, function(vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        local newPlate     = GeneratePlate()
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate
        SetVehicleNumberPlateText(vehicle, newPlate)
        TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', id, vehicleProps)

        ESX.ShowNotification('Vehiculo comprado')
    end)

    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true)
end)


RegisterNetEvent('comandodebug')
AddEventHandler('comandodebug', function(args)
    print("desbugueando...")
    ESX.UI.Menu.CloseAll()
end)


RegisterNetEvent('enviardm')
AddEventHandler('enviardm', function (emisor, mensaje)
    TriggerEvent('chat:addMessage', {args = { '^1'..emisor..'^2 Mensaje Privado:', mensaje }})
end)

RegisterNetEvent('comandorepairauto')
AddEventHandler('comandorepairauto', function(args)
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)

    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

        local vehicle = nil

        if IsPedInAnyVehicle(playerPed, false) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
        else
            vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end

        if DoesEntityExist(vehicle) then
            TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
            Citizen.CreateThread(function()
                Citizen.Wait(1)
                SetVehicleFixed(vehicle)
                SetVehicleDeformationFixed(vehicle)
                SetVehicleUndriveable(vehicle, false)
                SetVehicleEngineOn(vehicle, true, true)
                ClearPedTasksImmediately(playerPed)
                ESX.ShowNotification("vehiculo reparado")
                TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
            end)
        end
    end
end)