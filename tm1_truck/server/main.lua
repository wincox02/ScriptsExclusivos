ESX = nil
ESX = exports['es_extended']:getSharedObject()
if ESX == nil then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end


ESX.RegisterServerCallback('tm1_truck:pagar', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local paga = math.random(7000,9000)
    xPlayer.addMoney(paga)
    cb(paga)
end)

ESX.RegisterServerCallback('tm1_truck:obtenertrabajo', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		cb(xPlayer.job.name)
	end
end)
