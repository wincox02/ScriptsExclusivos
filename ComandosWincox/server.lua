--wincox#2959

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addGroupCommand', 'darauto', 'adminplus', function(source, args, raw)
        TriggerClientEvent('comandogivecar', source, args)
    end, function(source, args, user)
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
    end,
    {
        help = "Asignar grupo",
        params = { { name = "id", help = 'Id del player' }, { name = "Modelo", help = "Modelo del auto" } }
    })



TriggerEvent('es:addGroupCommand', 'debug', 'superadmin', function(source, args, raw)
    TriggerClientEvent('comandodebug', source, args)
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, { help = "Desbuguearte" })


TriggerEvent('es:addGroupCommand', 'dm', 'admin', function(source, args, raw)
        local emisor = GetPlayerName(source)
        local mensaje = ""
        for i = 2, #args, 1 do
            mensaje = mensaje .. " " .. args[i]
        end
        TriggerClientEvent('enviardm', tonumber(args[1]), emisor, mensaje)

        TriggerClientEvent('chat:addMessage', source, { args = { 'DM', "^2MENSAJE ENVIADO" } })
    end, function(source, args, user)
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
    end,
    {
        help = "Enviar mensaje privado",
        params = { { name = "ID", help = "ID del destinantario" }, { name = "MENSAJE", help = "Mensaje a enviar" } }
    })

TriggerEvent('es:addGroupCommand', 'load', 'superadmin', function(source, args, raw)
    local id = tonumber(args[1])
    TriggerEvent('esx:playerLoaded', id)
    local xPlayer = ESX.GetPlayerFromServerId(id)
    TriggerClientEvent('esx:playerLoaded', id, xPlayer)
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, { help = "Asignar grupo", params = { { name = "id", help = 'Id del player' } } })


TriggerEvent('es:addGroupCommand', 'aviso', 'moderador', function(source, args, raw)
        --TriggerClientEvent('winaviso',source, args)
        local id = tonumber(args[1])
        local mensaje = ""
        for i = 2, #args, 1 do
            mensaje = mensaje .. " " .. args[i]
        end
        TriggerClientEvent('exp:Notificate', id, mensaje)
    end, function(source, args, user)
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
    end,
    {
        help = "Aviso a usuario",
        params = { { name = "id", help = 'Id del player' }, { name = "MENSAJE", help = "Mensaje que le llega al user" } }
    })

TriggerEvent('es:addGroupCommand', 'repararauto', 'admin', function(source, args, raw)
    TriggerClientEvent('comandorepairauto', source, args)
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, { help = "Reparar auto" })
