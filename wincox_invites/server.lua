ESX = nil
ESX = exports['es_extended']:getSharedObject()
if ESX == nil then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local discordToken =
"MTE1MzE2OTY4MzA1MTE5NjQ2Nw.GG1_7v.jm_c82u0NJLHu6LL4GZJsy2brGbz0Q4t5Z2ILI" -- Reemplaza con tu token de Discord

local headers = {
    ["Authorization"] = "Bot " .. discordToken
}

local channelId = 1153134250086891674

function encontrarUltimoMensajePorMentionID(mensajes, mention_id)
    local ultimoMensaje = nil
    for _, mensaje in ipairs(mensajes) do
        -- Verifica si el mensaje contiene la mención del ID
        if string.find(mensaje.content, "<@" .. mention_id .. ">") then
            -- Compara las cadenas de fecha para encontrar la más reciente
            if not ultimoMensaje or mensaje.timestamp > ultimoMensaje.timestamp then
                ultimoMensaje = mensaje
            end
        end
    end
    return ultimoMensaje
end

Citizen.CreateThread(function()
    while true do
        local url = 'https://discord.com/api/v10/channels/' .. channelId .. '/messages'
        PerformHttpRequest(url, function(statusCode, responseBody, responseHeaders)
            if statusCode == 200 then
                --print(responseBody)
                local response = json.decode(responseBody)
                for key, value in pairs(response) do
                    if #value.mentions > 0 then
                        MySQL.Async.execute('INSERT IGNORE INTO wincox_invites (discordid) VALUES (@identifier)', {
                            ['@identifier'] = value.mentions[1].id,
                        }) -- cargar todas las personas que realizaron invitaciones
                    end
                end
                local result = MySQL.Sync.fetchAll('SELECT * FROM wincox_invites', {})
                for i = 1, #result, 1 do
                    local ultimoMensajeEncontrado = encontrarUltimoMensajePorMentionID(response, result[i].discordid)
                    --local userId = mensaje:match("<@(%d+)>")
                    if ultimoMensajeEncontrado then
                        local invitaciones = tonumber(ultimoMensajeEncontrado.content:match("(%d+) invitaciones"))
                        --print("fecha ultimo mensaje: " .. ultimoMensajeEncontrado.timestamp)
                        --print("Invitaciones del usuario " .. result[i].discordid .. ": " .. invitaciones)
                        MySQL.Async.execute(
                            'UPDATE wincox_invites SET invitacionesTot = @invitacionesTot WHERE discordid = @discordid',
                            {
                                ['@invitacionesTot'] = invitaciones,
                                ['@discordid'] = result[i].discordid,
                            })
                    end
                end
            else
                print('wincox_invites: Error en la solicitud: ' .. tostring(statusCode))
            end
        end, 'GET', "", headers)
        Citizen.Wait(120000)
    end
end)

RegisterServerEvent('wincox_invites:spawnplayer')
AddEventHandler('wincox_invites:spawnplayer', function(source)
    local sourcePlayer = tonumber(source)
    if sourcePlayer > 0 then
        local discord = ''
        for k, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("discord:")) == "discord:" then
                discord = v
            end
        end
        local discordID = string.sub(discord, 9, -1)
        --print(discordID)

        local result = MySQL.Sync.fetchAll('SELECT * FROM wincox_invites WHERE discordid = @discordid', {
            ['@discordid'] = discordID,
        })
        local xPlayer = ESX.GetPlayerFromId(source)
        if result then
            if result[1].invitacionesTot > result[1].invitacionesUs then -- hay que agregarle dinero
                xPlayer.addAccountMoney('bank', (result[1].invitacionesTot - result[1].invitacionesUs) * 10000)
                MySQL.Async.execute(
                    'UPDATE wincox_invites SET invitacionesUs = @invitacionesUs WHERE discordid = @discordid', {
                        ['@invitacionesUs'] = result[1].invitacionesTot,
                        ['@discordid'] = discordID,
                    })
                TriggerClientEvent('chat:addMessage', source,
                    {
                        args = { '^1INVITACIONES',
                            "Se te acredito " .. ((result[1].invitacionesTot - result[1].invitacionesUs) * 10000) ..
                            " en el banco por las invitaciones del discord. Muchas gracias por tu apoyo!" }
                    })
            else
                TriggerClientEvent('chat:addMessage', source,
                    {
                        args = { '^1INVITACIONES',
                            "No hay nuevas invitaciones de discord. Recuerda que obtienes dinero al invitar miembros al discord. ($10.000 por user) " }
                    })
            end
        end

        local url = "https://discord.com/api/v9/users/" .. discordID
        PerformHttpRequest(url, function(statusCode, data, headers)
            if statusCode == 200 then
                local userData = json.decode(data)
                local username = userData.username
                MySQL.Async.execute(
                    'UPDATE wincox_invites SET discordname = @discordname WHERE discordid = @discordid', {
                        ['@discordname'] = username,
                        ['@discordid'] = discordID,
                    })
                --print("Nombre de Discord del usuario:", username)
            else
                print("Error al obtener información del usuario. Código de estado:", statusCode)
            end
        end, "GET", "", headers)
    end
end)


RegisterCommand("invites", function(source, args, rawCommand)
    local sourcePlayer = tonumber(source)
    if sourcePlayer > 0 then
        local discord = false
        for k, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("discord:")) == "discord:" then
                discord = v
            end
        end
        local discordID = string.sub(discord, 9, -1)
        --print(discordID)
        local result = MySQL.Sync.fetchAll('SELECT * FROM wincox_invites WHERE discordid = @discordid', {
            ['@discordid'] = discordID,
        })
        TriggerClientEvent('chat:addMessage', source,
            {
                args = { '^1INVITACIONES',
                    "Has obtenido: " ..
                    (result[1].invitacionesUs * 10000) ..
                    " por invitar a " .. result[1].invitacionesUs .. " personas. Gracias por tu apoyo!!" }
            })
    end
end, false)
