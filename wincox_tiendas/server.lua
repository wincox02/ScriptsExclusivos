ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    local asd = {
        bread = { cantidad = 50, precio = 150 }
    }
    MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
        ['@items'] = json.encode(asd),
        ['@id'] = 1,
    })
end)

ESX.RegisterServerCallback("obtenershops", function(source, cb)
    local shops = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops')
    cb(shops)
end)

ESX.RegisterServerCallback("obteneridentificador", function(source, cb, serverid)
    local xPlayer = ESX.GetPlayerFromServerId(serverid)
    while xPlayer == nil do
        Citizen.Wait(400)
        xPlayer = ESX.GetPlayerFromServerId(serverid)
    end
    cb(xPlayer.identifier)
end)

ESX.RegisterServerCallback("shop:obteneritems", function(source, cb, tiendaid)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE id = @id', {
        ['@id'] = tiendaid
    })
    local cosa = json.decode(shop[1].items)
    cb(cosa)
end)

ESX.RegisterServerCallback("shop:obtenertodoslositems", function(source, cb)
    local items = MySQL.Sync.fetchAll('SELECT * FROM items')
    cb(items)
end)

--TriggerServerEvent('shops:agregaritem', identificador, data.current.value, tonumber(data2.value))
RegisterServerEvent('shops:agregaritem')
AddEventHandler('shops:agregaritem', function(identificador, item, cantidad)
    local source = source
    local xPlayer = ESX.GetPlayerFromServerId(source)
    local itemcount = xPlayer.getInventoryItem(item).count
    if cantidad > itemcount then
        TriggerClientEvent('chat:addMessage', source, { args = { 'Tienda: ', "No tenes tanto" } })
    else
        xPlayer.removeInventoryItem(item, cantidad)
        local shops = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops')
        local id = 0
        for i = 1, #shops, 1 do
            if shops[i].duenoid == identificador then
                id = i
                break
            end
        end
        local items = json.decode(shops[id].items)
        if items[item] then
            items[item].cantidad = items[item].cantidad + cantidad
            MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                ['@items'] = json.encode(items),
                ['@id'] = id,
            })
        else
            local cosa = { cantidad = cantidad, precio = 100 }
            items[item] = cosa
            MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                ['@items'] = json.encode(items),
                ['@id'] = id,
            })
        end
    end
end)

--TriggerServerEvent('shops:compraritem', GetPlayerServerId(PlayerId()), idtienda, data.current.value, quantity)
RegisterServerEvent('shops:compraritem')
AddEventHandler('shops:compraritem', function(source, idtienda, item, cantidad)
    local xPlayer = ESX.GetPlayerFromServerId(source)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE id = @id', {
        ['@id'] = idtienda
    })
    local items = json.decode(shop[1].items)
    local precio = items[item].precio * cantidad
    if cantidad <= items[item].cantidad then
        if precio < xPlayer.getMoney() then
            xPlayer.removeMoney(precio)
            local monedas = shop[1].money + precio
            MySQL.Async.execute('UPDATE wincox_shops SET `money` = @money WHERE id = @id',
                {
                    --actualizo dinero "sociedad"
                    ['@money'] = monedas,
                    ['@id'] = idtienda,
                })

            items[item].cantidad = items[item].cantidad - tonumber(cantidad)

            MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                --cantidad de items
                ['@items'] = json.encode(items),
                ['@id'] = idtienda,
            })

            xPlayer.addInventoryItem(item, cantidad)
        else
            TriggerClientEvent('chat:addMessage', source, { args = { 'Tienda: ', "No tiene suficiente dinero" } })
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { 'Tienda: ', "No hay tantos items" } })
    end
end)

RegisterServerEvent('shop:retirardinero')
AddEventHandler('shop:retirardinero', function(playerid, identificador)
    local xPlayer = ESX.GetPlayerFromServerId(playerid)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE duenoid = @duenoid', {
        ['@duenoid'] = identificador
    })
    local plata = shop[1].money
    if plata > 0 then
        xPlayer.addMoney(plata)
        MySQL.Async.execute('UPDATE wincox_shops SET `money` = @money WHERE duenoid = @duenoid', {
            ['@money'] = 0,
            ['@duenoid'] = identificador,
        })
    else
        TriggerClientEvent('chat:addMessage', playerid,
            { args = { 'Tienda: ', "No tienes dinero (no te compro nadie)" } })
    end
end)

ESX.RegisterServerCallback("shop:obtenerjefeitems", function(source, cb, identificador)
    --print(identificador)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE duenoid = @duenoid', {
        ['@duenoid'] = identificador
    })
    local cosa = json.decode(shop[1].items)
    cb(cosa)
end)

ESX.RegisterServerCallback("obtenernombretienda", function(source, cb, idtienda)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE id = @id', {
        ['@id'] = idtienda
    })
    cb(shop[1].nombre)
end)

--TriggerServerEvent('shops:cambiarprecio', identificador, data.current.value, nuevoprecio)
RegisterServerEvent('shops:cambiarprecio')
AddEventHandler('shops:cambiarprecio', function(playerid, identificador, item, nuevoprecio)
    local shop = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops WHERE duenoid = @duenoid', {
        ['@duenoid'] = identificador
    })
    local items = json.decode(shop[1].items)
    TriggerClientEvent('chat:addMessage', playerid,
        { args = { 'Tienda: ', "Precio cambiado con exito: " .. items[item].precio .. " --> " .. nuevoprecio } })
    items[item].precio = nuevoprecio
    MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE duenoid = @duenoid', {
        --cantidad de items
        ['@items'] = json.encode(items),
        ['@duenoid'] = identificador,
    })
end)

--TriggerServerEvent('shops:cambiarnombre', GetPlayerServerId(PlayerId()), identificador, data2.current.value, nuevonombre)
RegisterServerEvent('shops:cambiarnombre')
AddEventHandler('shops:cambiarnombre', function(playerid, identificador, nuevonombre)
    MySQL.Async.execute('UPDATE wincox_shops SET `nombre` = @nombre WHERE duenoid = @duenoid', {
        --cantidad de items
        ['@nombre'] = nuevonombre,
        ['@duenoid'] = identificador,
    })
end)

RegisterServerEvent('shops:blips')
AddEventHandler('shops:blips', function()
    TriggerClientEvent('shops:recrearblips', -1)
end)

--AddEventHandler('shops:agregaritem', function(identificador, item, cantidad)
-- comprarStoreitem, ID, numerotienda, item a comprar, cantidad a comprar
RegisterServerEvent('shops:comprarStoreitem')
AddEventHandler('shops:comprarStoreitem', function(playerId, numerotienda, item, cantidad)
    local xPlayer = ESX.GetPlayerFromServerId(playerId)
    local shops = MySQL.Sync.fetchAll('SELECT * FROM wincox_shops')
    if item == "bread" then
        if 20 * cantidad < xPlayer.getMoney() then
            xPlayer.removeMoney(20 * cantidad)
            local items = json.decode(shops[numerotienda].items)
            if items[item] then
                items[item].cantidad = items[item].cantidad + cantidad
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            else
                local cosa = { cantidad = cantidad, precio = 100 }
                items[item] = cosa
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            end
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "Se agrego " .. cantidad .. " de Pan a tu tienda: " } })
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "No tienes suficiente dinero" }})
        end
    elseif item == "water" then
        if 20 * cantidad < xPlayer.getMoney() then
            xPlayer.removeMoney(20 * cantidad)
            local items = json.decode(shops[numerotienda].items)
            if items[item] then
                items[item].cantidad = items[item].cantidad + cantidad
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            else
                local cosa = { cantidad = cantidad, precio = 100 }
                items[item] = cosa
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            end
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "Se agrego " .. cantidad .. " de Agua a tu tienda: " } })
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "No tienes suficiente dinero" }})
        end
    elseif item == "phone" then
        if 50 * cantidad < xPlayer.getMoney() then
            xPlayer.removeMoney(50 * cantidad)
            local items = json.decode(shops[numerotienda].items)
            if items[item] then
                items[item].cantidad = items[item].cantidad + cantidad
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            else
                local cosa = { cantidad = cantidad, precio = 100 }
                items[item] = cosa
                MySQL.Async.execute('UPDATE wincox_shops SET `items` = @items WHERE id = @id', {
                    ['@items'] = json.encode(items),
                    ['@id'] = numerotienda,
                })
            end
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "Se agrego " .. cantidad .. " de Telefonos a tu tienda: " } })
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { 'Tienda: ', "No tienes suficiente dinero" }})
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'tiendasblips', 'admin', function(source, args, raw)
	TriggerEvent('shops:blips')
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, {help = "Actualizar los blips de las tiendas"})