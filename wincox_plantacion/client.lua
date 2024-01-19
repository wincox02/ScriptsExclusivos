local ESX = nil
ESX = exports['es_extended']:getSharedObject()
local esmafia = false     -- false por defecto
local estadentro = true   -- false por defecto
local estaenPC = false    -- false por defecto
local hudabierto = false  -- false por defecto
local cantidadPlantas = 0 -- 0 por defecto

Citizen.Wait(1500)

Ubicacion = Config.Ubicacion

local plantas = {}
local CosasSpawneadas = {}
local mejoras = {}

FreezeEntityPosition(PlayerPedId(), false)
DoScreenFadeIn(1)

----------------------------
---------FUNCIONES----------
----------------------------

local function apagarpantalla()
    Citizen.CreateThread(function()
        DoScreenFadeOut(1500)
        Citizen.Wait(1500)
        DoScreenFadeIn(1000)
    end)
end

-- local function SpawnearPlanta(tamano)
--     ESX.Game.SpawnLocalObject(Config.Plantas[tamano], Config.ubicaciones[i], function(object)
--         SetEntityCoordsNoOffset(object, Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z)
--         SetEntityHeading(object, 111.6807)
--         -- SetEntityRotation(object, 50.0, 50.0, 50.0)
--         SetEntityAsMissionEntity(object, true, true)
--         FreezeEntityPosition(object, true)
--         --CosasSpawneadas[i] = { obj = object, data = i, type = 'planta' }
--         table.insert(CosasSpawneadas, { obj = object, data = i, type = 'planta' })
--     end)
-- end

RegisterNetEvent('wincox_plantacion:regarPlanta')
AddEventHandler('wincox_plantacion:regarPlanta', function ()
    local plantamascercana = nil
    local distancia = 50
    for i=1, #plantas, 1 do
        local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.ubicaciones[i], true)
        if dist < distancia then
            plantamascercana = plantas[i]
            distancia = dist
        end
    end
    TriggerServerEvent('wincox_plantacion:regar', GetPlayerServerId(PlayerId()), plantamascercana)
    ESX.ShowNotification("Regaste la planta mas cercana")
end)

local function entrar(teleport)
    for k, v in pairs(CosasSpawneadas) do
        DeleteObject(v.obj)
    end
    SpawnedFurniture = {}
    DoScreenFadeOut(1500)
    Citizen.Wait(1500)
    estadentro = true
    ESX.TriggerServerCallback('wincox_plantacion:obtenerPlantas', function(plant)
        print("#plant: " .. #plant)
        plantas = plant
        --print("entrando...")
        if teleport then
            SetEntityCoords(PlayerPedId(), Ubicacion.positions.dentro, false, false, false, false)
        end
        print("#plantas: " .. #plantas)
        for i = 1, #plantas, 1 do
            print("plantando")
            if plantas[i].porcentajeCrecimiento < 25 then
                ESX.Game.SpawnLocalObject(Config.Plantas[1], Config.ubicaciones[i], function(object)
                    SetEntityCoordsNoOffset(object, Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z)
                    SetEntityHeading(object, 111.6807)
                    SetEntityAsMissionEntity(object, true, true)
                    FreezeEntityPosition(object, true)
                    CosasSpawneadas[i] = { obj = object, data = i, type = 'planta' }
                    table.insert(CosasSpawneadas, { obj = object, data = i, type = 'planta' })
                end)
            elseif plantas[i].porcentajeCrecimiento < 50 then
                ESX.Game.SpawnLocalObject(Config.Plantas[2], Config.ubicaciones[i], function(object)
                    SetEntityCoordsNoOffset(object, Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z)
                    SetEntityHeading(object, 111.6807)
                    SetEntityAsMissionEntity(object, true, true)
                    FreezeEntityPosition(object, true)
                    CosasSpawneadas[i] = { obj = object, data = i, type = 'planta' }
                    table.insert(CosasSpawneadas, { obj = object, data = i, type = 'planta' })
                end)
            elseif plantas[i].porcentajeCrecimiento < 75 then
                ESX.Game.SpawnLocalObject(Config.Plantas[3], Config.ubicaciones[i], function(object)
                    SetEntityCoordsNoOffset(object, Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z)
                    SetEntityHeading(object, 111.6807)
                    SetEntityAsMissionEntity(object, true, true)
                    FreezeEntityPosition(object, true)
                    CosasSpawneadas[i] = { obj = object, data = i, type = 'planta' }
                    table.insert(CosasSpawneadas, { obj = object, data = i, type = 'planta' })
                end)
            else
                ESX.Game.SpawnLocalObject(Config.Plantas[4], Config.ubicaciones[i], function(object)
                    SetEntityCoordsNoOffset(object, Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z)
                    SetEntityHeading(object, 111.6807)
                    SetEntityAsMissionEntity(object, true, true)
                    FreezeEntityPosition(object, true)
                    CosasSpawneadas[i] = { obj = object, data = i, type = 'planta' }
                    table.insert(CosasSpawneadas, { obj = object, data = i, type = 'planta' })
                end)
            end
        end
        if mejoras.tieneAgua then
            for key, coordenadas in pairs(Config.Mejoras) do
                if key == 'bidones' then
                    for key, coord in pairs(coordenadas) do
                        ESX.Game.SpawnLocalObject('prop_watercrate_01', coord, function(object)
                            SetEntityCoordsNoOffset(object, coord)
                            SetEntityHeading(object, coord.w)
                            -- SetEntityRotation(object, 50.0, 50.0, 50.0)
                            SetEntityAsMissionEntity(object, true, true)
                            FreezeEntityPosition(object, true)
                            --CosasSpawneadas[i] = { obj = object, data = i, type = 'bidones' }
                            table.insert(CosasSpawneadas, { obj = object, data = i, type = 'bidones' })
                        end)
                    end
                end
                if key == 'aspersores' then
                    for key, coord in pairs(coordenadas) do
                        ESX.Game.SpawnLocalObject('prop_sprink_golf_01', coord, function(object)
                            SetEntityCoordsNoOffset(object, coord)
                            SetEntityHeading(object, coord.w)
                            -- SetEntityRotation(object, 50.0, 50.0, 50.0)
                            SetEntityAsMissionEntity(object, true, true)
                            FreezeEntityPosition(object, true)
                            --CosasSpawneadas[i] = { obj = object, data = i, type = 'bidones' }
                            table.insert(CosasSpawneadas, { obj = object, data = i, type = 'bidones' })
                        end)
                    end
                end
            end
        end
        if mejoras.tieneCrecimiento then
            for key, coordenadas in pairs(Config.Mejoras) do
                if key == 'ventiladores' then
                    for key, coord in pairs(coordenadas) do
                        ESX.Game.SpawnLocalObject('xm_prop_tunnel_fan_02', coord, function(object)
                            SetEntityCoordsNoOffset(object, coord)
                            SetEntityHeading(object, coord.w)
                            -- SetEntityRotation(object, 50.0, 50.0, 50.0)
                            SetEntityAsMissionEntity(object, true, true)
                            FreezeEntityPosition(object, true)
                            --CosasSpawneadas[i] = { obj = object, data = i, type = 'bidones' }
                            table.insert(CosasSpawneadas, { obj = object, data = i, type = 'bidones' })
                        end)
                    end
                end
            end
        end
        --local cosa3 = vec3(531.1970, 1898.9537, 33.4895)
        --AddExplosion(cosa3, 13, 0.9, true, false, 0)
        --AddExplosion(cosa3, 13, 0.9, 1, 0, 1065353216, 0) -- traido de otro script
        Citizen.Wait(100)
        DoScreenFadeIn(1000)
    end)
end

local function salir()
    estadentro = false
    --print("Saliendo...")
    SetEntityCoords(PlayerPedId(), Ubicacion.positions.fuera, false, false, false, false)
end

local function entrarPC()
    estaenPC = true
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioAtPosition(PlayerPedId(), 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', Ubicacion.positions.pc, 0, true, true)
end

local function hudPC()
    hudabierto = true
    print("prendiendo hud...")
    if cantidadPlantas == 9 then
        SendNUIMessage({
            openMenu = true,
            precioSiguientePlanta = 'No Disponible',
            Plantas = plantas,
            Mejoras = mejoras,
            PreciosMejoras = Config.preciosMejoras
        })
    else
        SendNUIMessage({
            openMenu = true,
            precioSiguientePlanta = '$' .. Config.preciosplanta[cantidadPlantas + 1],
            Plantas = plantas,
            Mejoras = mejoras,
            PreciosMejoras = Config.preciosMejoras
        })
    end
    SetNuiFocus(true, true)
end

function DrawText3D(x, y, z, text, r, g, b) -- some useful function, use it if you want!
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- local function actualizarPlantas(cantidadAnterior, cantidadDespues)
--     if estadentro then
--         for i=1, (cantidadDespues-cantidadAnterior), 1 do

--         end
--     end
-- end

----------------------------
-----------HILOS------------
----------------------------
Citizen.CreateThread(function()
    while true do
        ESX.TriggerServerCallback('wincox_plantacion:obtenerIdMafia', function(idmafia)
            if idmafia then
                esmafia = true
            else
                esmafia = false
            end
        end)
        Citizen.Wait(8000)
    end
end)

--obtener plantas y mejoras del sv cada 10segs
Citizen.CreateThread(function()
    while true do
        if esmafia then
            ESX.TriggerServerCallback('wincox_plantacion:obtenerPlantas', function(plant)
                --print("#plant: " .. #plant)
                if plant then
                    if #plant == cantidadPlantas then
                        cantidadPlantas = #plant
                        plantas = plant
                    elseif cantidadPlantas ~= 0 then
                        --entrar(false)
                        plantas = plant
                        cantidadPlantas = #plant
                    else
                        plantas = plant
                        cantidadPlantas = #plant
                    end
                else
                    print("NO ERES MAFIA")
                end
            end)
            ESX.TriggerServerCallback('wincox_plantacion:obtenerMejoras', function(mej)
                --print("#plant: " .. #plant)
                if mej then
                    mejoras = mej
                else
                    print("NO ERES MAFIA")
                end
            end)
            -- Citizen.Wait(10000)
            Citizen.Wait(1000)
        end
        Citizen.Wait(100)
    end
end)

--para entrar a las plantaciones
Citizen.CreateThread(function()
    while true do
        if esmafia then
            while true do
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Ubicacion.positions.fuera, true) < 10 then
                    while true do
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Ubicacion.positions.fuera, true) < 2 then
                            while true do
                                ESX.TextUI('Pulsa E para entrar a las Plantaciones')
                                if IsControlPressed(0, 38) then
                                    entrar(true)
                                end
                                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Ubicacion.positions.fuera, true) > 2 then
                                    ESX.HideUI()
                                    break
                                end
                                Citizen.Wait(1)
                            end
                        end
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Ubicacion.positions.fuera, true) > 10 then
                            break
                        end
                        Citizen.Wait(100)
                    end
                end
                if not esmafia then
                    break
                end
                Citizen.Wait(1000)
            end
        end
        Citizen.Wait(5000)
    end
end)

--para todas las interacciones cuando el user esta dentro y para salir
Citizen.CreateThread(function()
    while true do
        if estadentro then
            while true do
                --PARA SALIR DEL LUGAR
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 530.4294, 1892.3807, 33.4318, false) < 1.5 then
                    while true do
                        ESX.TextUI('Pulsa E para salir de las Plantaciones')
                        if IsControlPressed(0, 38) then
                            salir()
                        end
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 530.4294, 1892.3807, 33.4318, false) > 2 then
                            ESX.HideUI()
                            break
                        end
                        Citizen.Wait(1)
                    end
                end
                --para entrar en el pc
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 538.6690, 1902.7531, 33.6237, true) < 1.5 and not estaenPC then
                    while true do
                        ESX.TextUI('Pulsa E para sentarse en la PC')
                        if IsControlPressed(0, 38) then
                            ESX.HideUI()
                            entrarPC()
                            break
                        end
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 538.6690, 1902.7531, 33.6237, false) > 1.5 then
                            ESX.HideUI()
                            break
                        end
                        Citizen.Wait(1)
                    end
                end
                --para abrir interfaz y levantarse
                if estaenPC then
                    Citizen.Wait(1000)
                    while true do
                        ESX.TextUI("[E]: Entrar en la PC.  [F]: Levantarse de la Silla")
                        if IsControlPressed(0, 38) and not hudabierto then
                            hudPC()
                            Citizen.Wait(300)
                        end
                        if IsControlPressed(0, 49) then
                            ClearPedTasks(PlayerPedId())
                            FreezeEntityPosition(PlayerPedId(), false)
                            ESX.HideUI()
                            estaenPC = false
                            break
                        end
                        Citizen.Wait(1)
                    end
                end



                if not estadentro then
                    break
                end









                Citizen.Wait(100)
            end
        end
        Citizen.Wait(1000)
    end
end)

--funcion para mostrar los porcentajes de cada plantas dentro
Citizen.CreateThread(function()
    while true do
        if estadentro then
            while true do
                for i = 1, cantidadPlantas, 1 do
                    --print("distancia: " .. GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.ubicaciones[i], true))
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.ubicaciones[i], true) < 3 then
                        DrawText3D(Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z + 1,
                            'Crecimiento: ' .. math.floor(plantas[i].porcentajeCrecimiento * 100) / 100 .. "%", 0, 255, 0)
                        DrawText3D(Config.ubicaciones[i].x, Config.ubicaciones[i].y, Config.ubicaciones[i].z + 1.25,
                            'Nivel de Agua: ' .. math.floor(plantas[i].porcentajeAgua * 100) / 100 .. "%", 120, 110, 255)
                    end
                end

                if not estadentro then
                    break
                end
                if GetDistanceBetweenCoords(Config.Ubicacion.positions.dentro, GetEntityCoords(PlayerPedId()), true) < 50 then
                    estadentro = false
                    break
                end
                Citizen.Wait(1)
            end
        end
        Citizen.Wait(2000)
    end
end)

----------------------------
------------HUI-------------
----------------------------

RegisterNUICallback('cerrar', function()
    SendNUIMessage({
        openMenu = false
    })
    hudabierto = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('comprarPlanta', function(data, cb)
    if cantidadPlantas == 9 then
        ESX.ShowNotification('No puedes comprar mas plantas')
    else
        SendNUIMessage({
            openMenu = false
        })
        hudabierto = false
        SetNuiFocus(false, false)
        apagarpantalla()
        ESX.TriggerServerCallback('wincox_plantacion:ComprarPlanta', function(result)
            if result then
                plantas = result
                entrar(false)
            else
                print("error")
            end
        end, cantidadPlantas)
    end
end)


RegisterNUICallback('refresh', function(data, cb)
    cb(plantas)
end)




















function AttemptHouseEntry(PropertyId)
    local Property = Properties[PropertyId]
    local Interior = GetInteriorValues(Property.Interior)
    if Interior.type == "shell" and not Config.Shells then
        ESX.ShowNotification(TranslateCap("shell_disabled"), "error")
        return
    end
    ESX.ShowNotification(TranslateCap("entering"), "success")
    CurrentId = PropertyId
    ESX.UI.Menu.CloseAll()
    local Property = Properties[CurrentId]
    FreezeEntityPosition(ESX.PlayerData.ped, true)
    DoScreenFadeOut(1500)
    Wait(1500)
    if Interior.type == "shell" then
        ESX.Streaming.RequestModel(joaat(Property.Interior), function()
            if Shell then
                DeleteObject(Shell)
                Shell = nil
            end
            local Pos = vector3(Property.Entrance.x, Property.Entrance.y, 2000)
            Shell = CreateObjectNoOffset(joaat(Property.Interior), Pos + Interior.pos, false, false, false)
            SetEntityHeading(Shell, 0.0)
            while not DoesEntityExist(Shell) do
                Wait(1)
            end
            FreezeEntityPosition(Shell, true)
        end)
    end
    if Properties[PropertyId].furniture then
        for k, v in pairs(Properties[PropertyId].furniture) do
            ESX.Game.SpawnLocalObject(v.Name, v.Pos, function(object)
                SetEntityCoordsNoOffset(object, v.Pos.x, v.Pos.y, v.Pos.z)
                SetEntityHeading(object, v.Heading)
                SetEntityAsMissionEntity(object, true, true)
                FreezeEntityPosition(object, true)
                SpawnedFurniture[k] = { obj = object, data = v }
            end)
        end
    end
    local ShowingTextUI2 = false
    FreezeEntityPosition(ESX.PlayerData.ped, false)
    TriggerServerEvent("esx_property:enter", PropertyId)
    Wait(1500)
    DoScreenFadeIn(1800)
    InProperty = true
    if not Config.OxInventory then
        Interior.positions.Storage = nil
        Properties[CurrentId].positions.Storage = nil
    end

    CreateThread(function()
        while InProperty do
            local Property = Properties[CurrentId]
            local Sleep = 1000
            local Near = false
            SetRainLevel(0.0)
            local PlayerPed = ESX.PlayerData.ped
            local PlayerCoords = GetEntityCoords(PlayerPed)
            if Interior.type == "shell" then
                if #(PlayerCoords - vector3(Property.Entrance.x, Property.Entrance.y, 1999)) < 5.0 then
                    Sleep = 0
                    DrawMarker(27, vector3(Property.Entrance.x, Property.Entrance.y, 2000.2), 0.0, 0.0, 0.0, 0.0, 0.0,
                        0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200,
                        false, false, 2, true, nil, nil, false)
                    if #(PlayerCoords.xy - vector2(Property.Entrance.x, Property.Entrance.y)) <= 2.5 then
                        Near = true
                        if not ShowingUIs.Exit then
                            local Pname = Properties[CurrentId].setName ~= "" and Properties[CurrentId].setName or
                                Properties[CurrentId].Name
                            ESX.TextUI(TranslateCap("access_textui", Pname))
                            ShowingUIs.Exit = true
                        end
                        if IsControlJustPressed(0, 38) then
                            OpenPropertyMenu(CurrentId)
                        end
                    else
                        if not Near and ShowingUIs.Exit and SettingValue == "" then
                            ShowingUIs.Exit = false
                            ESX.HideUI()
                            ESX.CloseContext()
                        end
                    end
                end

                if Property.Owned then
                    for k, v in pairs(Properties[CurrentId].positions) do
                        local v = vector3(v.x, v.y, v.z)
                        local CanDo = true
                        if CanDo then
                            local Poss = vector3(Property.Entrance.x, Property.Entrance.y, 1999) - v
                            if #(PlayerCoords - Poss) < 5.0 then
                                Sleep = 0
                                DrawMarker(27, Poss, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 200, 50, 50, 200, false,
                                    false, 2, true, nil, nil, false)
                                if #(PlayerCoords - Poss) < 2.0 and SettingValue == "" then
                                    Near = true
                                    if not ShowingUIs[k] then
                                        ShowingUIs[k] = true

                                        ESX.TextUI(TranslateCap("access_textui", k))
                                    end
                                    if IsControlJustPressed(0, 38) then
                                        OpenInteractionMenu(CurrentId, k)
                                    end
                                else
                                    if not Near and ShowingUIs[k] and SettingValue == "" then
                                        ShowingUIs[k] = false
                                        ESX.HideUI()
                                    end
                                end
                            end
                        end
                    end
                    if not Near and ShowingUIs and SettingValue == "" then
                        ShowingTextUI2 = false
                        ESX.HideUI()
                    end
                end
            else
                if #(PlayerCoords - Interior.pos) < 5.0 then
                    Sleep = 0
                    DrawMarker(27, vector3(Interior.pos.xy, Interior.pos.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
                        1.0, 1.0, 50, 50, 200, 200, false, false,
                        2, true, nil, nil, false)
                    if #(PlayerCoords - Interior.pos) < 2.0 then
                        if not ShowingUIs.Exit then
                            ShowingUIs.Exit = true
                            local Pname = Properties[CurrentId].setName ~= "" and Properties[CurrentId].setName or
                                Properties[CurrentId].Name
                            ESX.TextUI(TranslateCap("access_textui", Pname))
                        end
                        if IsControlJustPressed(0, 38) then
                            OpenPropertyMenu(CurrentId)
                        end
                    else
                        if ShowingUIs.Exit and SettingValue == "" then
                            ShowingUIs.Exit = false
                            ESX.HideUI()
                            ESX.CloseContext()
                        end
                    end
                end

                if Property.Owned then
                    for k, v in pairs(Properties[CurrentId].positions) do
                        v = vector3(v.x, v.y, v.z)
                        local CanDo = true

                        if CanDo then
                            if #(PlayerCoords - v) < 5.0 then
                                Sleep = 0
                                DrawMarker(27, vector3(v.xy, v.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                                    200, 50, 50, 200, false, false, 2, true, nil,
                                    nil, false)
                                if #(PlayerCoords - v) < 2.0 then
                                    if not ShowingUIs[k] then
                                        ShowingUIs[k] = true
                                        ESX.TextUI(TranslateCap("access_textui", k))
                                    end
                                    if IsControlJustPressed(0, 38) then
                                        OpenInteractionMenu(CurrentId, k)
                                    end
                                else
                                    if ShowingUIs[k] and SettingValue == "" then
                                        ShowingUIs[k] = false
                                        ESX.HideUI()
                                    end
                                end
                            end
                        end
                    end
                end
            end
            Wait(Sleep)
        end
    end)
end
