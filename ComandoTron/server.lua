ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addGroupCommand', 'tron', 'soporte', function(source, args, raw)
    TriggerClientEvent('comandotron',source, args)

end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Permisos insuficientes.' } })
end, {help = "Activar/Desactivar TRON"})