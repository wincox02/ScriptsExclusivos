ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local patente = nil
local spawnedcar = nil

ESX.RegisterServerCallback('obtenercantidaddelavados', function(source, cb, PlayerId)
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local lavados = MySQL.Sync.fetchAll('SELECT * FROM wincox_lavar WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    cb(#lavados)
end)

ESX.RegisterServerCallback('cantidadpolisdispo', function(source, cb, PlayerId)
    local xPlayers = ESX.GetPlayers()
    local contador = 0
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromServerId(xPlayers[i])
        if xPlayer.job.name == 'police' and xPlayers[i] ~= PlayerId then
            contador = contador + 1
        end
    end
    cb(contador)
end)

local encargoenciudad = false

ESX.RegisterServerCallback('obtenerlavadosdia', function(source, cb, PlayerId)
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local lavadosdia = MySQL.Sync.fetchAll(
        'SELECT * FROM wincox_lavar WHERE identifier = @identifier AND fecha >= NOW() - INTERVAL 1 DAY', {
            ['@identifier'] = xPlayer.identifier
        })
    cb(#lavadosdia)
end)

--TriggerServerEvent('lavarguita', GetPlayerServerId(PlayerId()), tonumber(data2.value))
RegisterServerEvent('lavarguita')
AddEventHandler('lavarguita', function(PlayerId, cantidad)
    --print("PlayerId:  " .. PlayerId)
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local lavadosdia = MySQL.Sync.fetchAll(
        'SELECT * FROM wincox_lavar WHERE identifier = @identifier AND fecha >= NOW() - INTERVAL 1 DAY', {
            ['@identifier'] = xPlayer.identifier
        })
    if #lavadosdia == 0 then
        if xPlayer.getAccount('black_money').money >= cantidad then
            if cantidad <= Config.Maximo then
                --lavar instantaneo
                MySQL.Sync.execute(
                    'INSERT INTO wincox_lavar (identifier, nombrelavador, cantidad) VALUES (@identifier, @nombrelavador, @cantidad)',
                    {
                        ['@identifier'] = xPlayer.identifier,
                        ['@nombrelavador'] = GetPlayerName(PlayerId),
                        ['@cantidad'] = cantidad
                    })
                xPlayer.removeAccountMoney('black_money', cantidad)
                xPlayer.addMoney(cantidad * 0.7)
            else
                local lavados = MySQL.Sync.fetchAll('SELECT * FROM wincox_lavar WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier
                })
                if #lavados <= 3 then
                    TriggerClientEvent('chat:addMessage', PlayerId,
                        { args = { '^1LAVADORA', "No te conozco de nada. No te cambio tanta cantidad por ahora" } })
                end
            end
        else
            TriggerClientEvent('chat:addMessage', PlayerId,
                { args = { '^1LAVADORA', "No tienes tanta ropa para lavar" } })
        end
    else
        TriggerClientEvent('chat:addMessage', PlayerId,
            { args = { '^1LAVADORA', "Ya lavaste por hoy, relajate un poco" } })
    end
end)

--TriggerServerEvent('empiezatrabajocamion', GetPlayerServerId(PlayerId()), plate, spawned_car, cantidadcamion)
RegisterServerEvent('empiezatrabajocamion')
AddEventHandler('empiezatrabajocamion', function(PlayerId, plate, spawned_car, cantidadcamion)
    spawnedcar = spawned_car
    encargoenciudad = true
    patente = plate
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    xPlayer.removeAccountMoney('black_money', cantidadcamion)
    MySQL.Sync.execute(
        'INSERT INTO wincox_lavar (identifier, nombrelavador, autoid, cantidad) VALUES (@identifier, @nombrelavador, @autoid, @cantidad)',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@nombrelavador'] = GetPlayerName(PlayerId),
            ['@autoid'] = plate,
            ['@cantidad'] = cantidadcamion
        })
end)

ESX.RegisterServerCallback('hayencargosenciudad', function(source, cb)
    cb(encargoenciudad)
end)

ESX.RegisterServerCallback('obtenerplataennegro', function(source, cb, PlayerId)
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local plata = xPlayer.getAccount('black_money').money
    cb(plata)
end)

ESX.RegisterServerCallback('obtenerplayertrabajo', function(source, cb, PlayerId)
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local trabajo = xPlayer.job.name
    cb(trabajo)
end)

RegisterServerEvent('agarrarcoords')
AddEventHandler('agarrarcoords', function(coords)
    TriggerClientEvent("mostrarcoordenadas", -1, coords)
end)

RegisterServerEvent('terminotrabajomal')
AddEventHandler('terminotrabajomal', function()
    --encargoenciudad = false
    patente = nil
end)

--TriggerServerEvent('finalizarcamion', GetPlayerServerId(PlayerId()))
RegisterServerEvent('finalizarcamion')
AddEventHandler('finalizarcamion', function(PlayerId)
    encargoenciudad = false
    local xPlayer = ESX.GetPlayerFromServerId(PlayerId)
    local encargo = false
    if patente then
        encargo = MySQL.Sync.fetchAll(
            'SELECT * FROM wincox_lavar WHERE autoid = @autoid AND fecha >= NOW() - INTERVAL 15 MINUTE', {
                ['@autoid'] = patente
            })
        Citizen.Wait(500)
        if encargo[1] then
            if encargo[1].estado == 0 then
                TriggerClientEvent('chat:addMessage', PlayerId,
                    { args = { '^1LAVADORA', "Vehiclo entregado con exito" } })
                local plata = encargo[1].cantidad
                xPlayer.addMoney(plata)
                MySQL.Async.execute(
                    'UPDATE wincox_lavar SET `estado` = 1 WHERE autoid = @autoid AND fecha >= NOW() - INTERVAL 20 MINUTE',
                    {
                        ['@autoid'] = patente
                    })
            else
                TriggerClientEvent('chat:addMessage', PlayerId,
                    { args = { '^1LAVADORA', "Este vehiculo fue entregado/surgio un error" } })
            end
        else
            TriggerClientEvent('chat:addMessage', PlayerId,
                { args = { '^1LAVADORA', "Paso mucho tiempo del encargo ya vino la policia al local" } })
        end
    else
        TriggerClientEvent('chat:addMessage', PlayerId,
            { args = { '^1LAVADORA', "No hay encargos activos..." } })
    end
    patente = nil
    --if (encargo[1].estado == 1) then
    TriggerClientEvent('eliminarblip', -1)
end)

TriggerEvent('es:addGroupCommand', 'lavadogps', 'user', function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromServerId(source)
    local trabajo = xPlayer.job.name

    if trabajo == 'police' then
        TriggerClientEvent('alternargps', source)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1LAVADOR', "NO eres policia" } })
    end
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, { help = "Desactivar marcado automatico" })

--ESX.RegisterServerCallback('obteneridcamionactivo', function(source, cb)
--    if spawnedcar then
--        cb(spawnedcar)
--    else
--        cb(0)
--    end
--end)
