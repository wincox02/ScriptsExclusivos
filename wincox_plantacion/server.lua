ESX = nil
ESX = exports['es_extended']:getSharedObject()

-- cambiar que la mejora sea de cada planta.
local Plantaciones = {
    [1] = {
        {
            idplanta = 1,
            porcentajeAgua = 100,
            porcentajeCrecimiento = 1
        },
        {
            idplanta = 2,
            porcentajeAgua = 80,
            porcentajeCrecimiento = 25
        },
        {
            idplanta = 3,
            porcentajeAgua = 80,
            porcentajeCrecimiento = 50
        },
        -- {
        --     idplanta = 4,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 75
        -- },
        -- {
        --     idplanta = 5,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 10
        -- },
        -- {
        --     idplanta = 6,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 10
        -- },
        -- {
        --     idplanta = 7,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 10
        -- },
        -- {
        --     idplanta = 8,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 10
        -- },
        -- {
        --     idplanta = 9,
        --     porcentajeAgua = 80,
        --     porcentajeCrecimiento = 10
        -- }
    },
    [2] = {
        {
            idplanta = 1,
            porcentajeAgua = 10,
            porcentajeCrecimiento = 10
        },
        {
            idplanta = 2,
            porcentajeAgua = 10,
            porcentajeCrecimiento = 10
        }
    }
}
local Mejoras = {
    [1] = {
        tieneAgua = true,
        tieneCrecimiento = true
    },
    [2] = {
        tieneAgua = false,
        tieneCrecimiento = false
    }
}
local Integrantes = {
    [1] = {
        '1a8435356a766c25acd7181f330638eb2aabd2ed'
    },
    [2] = {
        '1a8435356a766c25acd7181f330638eb2aabd2edd'
    }
}


-----------------------------------------------BD------------------------------------------------------------------
-- local Plantaciones = {}
-- local Mejoras = {}
-- local Integrantes = {}

-- local results = nil
-- while results == nil do
--     if GetResourceState("oxmysql") == "started" then
--         results = MySQL.Sync.fetchAll('SELECT * FROM wincox_plantacion', {})
--         if results and #results > 0 then
--             local result = results[1]
--             Plantaciones = json.decode(result.Plantaciones)
--             Mejoras = json.decode(result.Mejoras)
--             Integrantes = json.decode(result.Integrantes)
--         else
--             print('No se encontraron datos para ninguna mafia.')
--         end
--     end
--     Citizen.Wait(100)
-- end

-- --funcion para guardar en la bd las cosas
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(6000)
--         MySQL.update(
--             'UPDATE wincox_plantacion SET Plantaciones = ?, Mejoras = ?, Integrantes = ? WHERE id = ?',
--             { json.encode(Plantaciones), json.encode(Mejoras), json.encode(Integrantes), 1 },
--             function(rowsChanged)
--             end)
--     end
-- end)

-----------------------------------------------------------------------------------------------------------------


--funcion para aumentar porcentajes y restar agua
Citizen.CreateThread(function()
    while true do
        for idmafia, plantas in pairs(Plantaciones) do
            for i = 1, #plantas, 1 do
                if not Mejoras[idmafia].tieneAgua then
                    if not (plantas[i].porcentajeCrecimiento == 100) then
                        if plantas[i].porcentajeAgua <= 0.1 then
                            plantas[i].porcentajeAgua = 0
                            if (plantas[i].porcentajeCrecimiento - (Config.velocidadCrecimiento * Config.penalidadAgua)) < 0 then
                                plantas[i].porcentajeCrecimiento = 0
                            else
                                plantas[i].porcentajeCrecimiento = plantas[i].porcentajeCrecimiento -
                                    (Config.velocidadCrecimiento * Config.penalidadAgua)
                            end
                        else
                            if (plantas[i].porcentajeAgua - Config.velocidadPerdidaAgua) < 0 then
                                plantas[i].porcentajeAgua = 0
                            else
                                plantas[i].porcentajeAgua = plantas[i].porcentajeAgua - Config.velocidadPerdidaAgua
                            end
                        end
                    end
                else
                    plantas[i].porcentajeAgua = 100
                end
                if not Mejoras[idmafia].tieneCrecimiento then
                    if plantas[i].porcentajeCrecimiento < 100 then
                        if plantas[i].porcentajeCrecimiento + Config.velocidadCrecimiento >= 100 then
                            plantas[i].porcentajeCrecimiento = 100
                        else
                            if not (plantas[i].porcentajeAgua <= 0.1) then
                                plantas[i].porcentajeCrecimiento = plantas[i].porcentajeCrecimiento + Config
                                    .velocidadCrecimiento
                            end
                        end
                    end
                else
                    if plantas[i].porcentajeCrecimiento < 100 then
                        if plantas[i].porcentajeCrecimiento + (Config.velocidadCrecimiento * Config.boostCrecimiento) >= 100 then
                            plantas[i].porcentajeCrecimiento = 100
                        else
                            if not (plantas[i].porcentajeAgua <= 0.1) then
                                plantas[i].porcentajeCrecimiento = plantas[i].porcentajeCrecimiento + (Config
                                    .velocidadCrecimiento * Config.boostCrecimiento)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

local function esmafia(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    for idmafia, identifiersplayers in pairs(Integrantes) do
        for i = 1, #identifiersplayers, 1 do
            if identifiersplayers[i] == identifier then
                return idmafia
            end
        end
    end
    return 0
end

RegisterNetEvent('wincox_plantacion:regar')
AddEventHandler('wincox_plantacion:regar', function(source, planta)
    local idmafia = esmafia(source)
    if idmafia ~= 0 then
        for idmafias, plantas in pairs(Plantaciones) do
            if idmafias == idmafia then
                for key, value in pairs(plantas) do -- cada una de las plantas de esta mafia
                    if value.idplanta == planta.idplanta then
                        if Plantaciones[idmafia][key].porcentajeAgua + 20 > 100 then
                            Plantaciones[idmafia][key].porcentajeAgua = 100
                        else
                            Plantaciones[idmafia][key].porcentajeAgua = Plantaciones[idmafia][key].porcentajeAgua + 20
                        end
                    end
                end
            end
        end
    else
        print("NO ES MAFIA")
    end
end)

ESX.RegisterServerCallback('wincox_plantacion:obtenerPlantas', function(source, cb)
    while #Plantaciones == 0 do
        Citizen.Wait(10)
    end
    local idmafia = esmafia(source)
    --print("idmafia: " .. idmafia)
    if idmafia ~= 0 then
        --print(Plantaciones[idmafia][1].idplanta)
        cb(Plantaciones[idmafia])
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('wincox_plantacion:obtenerMejoras', function(source, cb)
    while #Mejoras == 0 do
        Citizen.Wait(10)
    end
    local idmafia = esmafia(source)
    --print("idmafia: " .. idmafia)
    if idmafia ~= 0 then
        cb(Mejoras[idmafia])
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('wincox_plantacion:obtenerIdMafia', function(source, cb)
    while #Integrantes == 0 do
        Citizen.Wait(10)
    end
    local idmafia = esmafia(source)
    if idmafia ~= 0 then
        cb(idmafia)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('wincox_plantacion:ComprarPlanta', function(source, cb, cantidadPlantas)
    print("cantidadPlantas: " .. cantidadPlantas)
    local xPlayer = ESX.GetPlayerFromId(source)
    local idmafia = esmafia(source)
    if idmafia ~= 0 then
        if #Plantaciones[idmafia] < 9 then
            if xPlayer.getMoney() >= Config.preciosplanta[cantidadPlantas + 1] then
                xPlayer.removeMoney(Config.preciosplanta[cantidadPlantas + 1])
                table.insert(Plantaciones[idmafia],
                    {
                        idplanta = cantidadPlantas + 1,
                        porcentajeAgua = 20,
                        porcentajeCrecimiento = 0
                    }
                )
                xPlayer.removeMoney(precio)
            else
                cb(false)
                return
            end

            cb(Plantaciones[idmafia])
            return
        else
            cb(false)
            return
        end
    else
        cb(false)
        return
    end
end)

RegisterCommand('simulacionCompra', function()
    table.insert(Plantaciones[1],
        {
            idplanta = 3,
            ultimavisita = GetGameTimer(),
            porcentajeAgua = 80,
            porcentajeCrecimiento = 33
        })
end, false)
