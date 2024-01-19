ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local shops = nil
local identificador = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)
    ESX.TriggerServerCallback('obtenershops', function(shopss)
        shops = shopss
    end)
    --Citizen.Wait(10000)--ACTIVAR DESPUES
    ESX.TriggerServerCallback('obteneridentificador', function(iden)
        identificador = iden
    end, GetPlayerServerId(PlayerId()))

    Citizen.Wait(5000)
    crearblips()
    while true do
        Citizen.Wait(10000)
        ESX.TriggerServerCallback('obtenershops', function(shopss)
            shops = shopss
        end)
    end
end)

local blips = {}

--CREO LOS BLIPS--
function crearblips()
    ESX.TriggerServerCallback('obtenershops', function(shops)
        for i = 1, #shops, 1 do
            local punto = json.decode(shops[i].puntocompra)
            blips[i] = AddBlipForCoord(punto.x, punto.y, punto.z - 1)
            SetBlipSprite(blips[i], 52)
            SetBlipDisplay(blips[i], 4)
            SetBlipScale(blips[i], 1.0)
            if shops[i].duenoid then
                SetBlipColour(blips[i], 2)
            else
                SetBlipColour(blips[i], 1)
            end
            SetBlipAsShortRange(blips[i], true)
            BeginTextCommandSetBlipName("STRING")
            if shops[i].nombre then
                AddTextComponentString(shops[i].nombre)
            else
                AddTextComponentString("Sin Dueño")
            end
            EndTextCommandSetBlipName(blips[i])
        end
    end)
end

RegisterNetEvent('shops:recrearblips')
AddEventHandler('shops:recrearblips', function()
    --print("buenas")
    for i = 1, #blips, 1 do
        RemoveBlip(blips[i])
    end
    --print("AA")
    crearblips()
end)

--CREO LOS PUNTOS EN EL PISO--
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        Citizen.Wait(1)
        for i = 1, #shops, 1 do
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local punto1 = json.decode(shops[i].puntocompra)
            local punto2 = json.decode(shops[i].puntojefe)
            if GetDistanceBetweenCoords(coords, punto1.x, punto1.y, punto1.z - 1, true) < 10 then --dibujar punto para compra
                DrawMarker(1, punto1.x, punto1.y, punto1.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 102, 102, 204,
                    100,
                    false, true, 2, false, false, false, false)
            end
            if GetDistanceBetweenCoords(coords, punto2.x, punto2.y, punto2.z - 1, true) < 10 then
                DrawMarker(1, punto2.x, punto2.y, punto2.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 102, 102, 204,
                    100,
                    false, true, 2, false, false, false, false)
            end
        end
    end
end)

local abriotienda = false
local abriojefe = false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        Citizen.Wait(1)
        if not abriojefe and not abriotienda then
            for i = 1, #shops, 1 do
                local coords = GetEntityCoords(GetPlayerPed(-1))
                local punto1 = json.decode(shops[i].puntocompra)
                local punto2 = json.decode(shops[i].puntojefe)
                if GetDistanceBetweenCoords(coords, punto1.x, punto1.y, punto1.z, true) < 1.2 then --entro en el punto de compra
                    SetTextComponentFormat('STRING')
                    AddTextComponentString("Pulsa E para abrir la tienda")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                    if IsControlJustPressed(0, 38) then --si aprieta la E se cambia abrio tienda
                        abrirtienda(i)
                        abriotienda = true
                        break
                    end
                end

                if GetDistanceBetweenCoords(coords, punto2.x, punto2.y, punto2.z, true) < 1.2 then --entro en el punto de jefe
                    SetTextComponentFormat('STRING')
                    AddTextComponentString("Pulsa E para abrir el menu de jefe")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustPressed(0, 38) then
                        if identificador == shops[i].duenoid then
                            abrirjefe()
                            abriojefe = true
                            break
                        else
                            TriggerEvent('chat:addMessage', { args = { '^1TIENDAS:', "No eres dueño de esta tienda" } })
                        end
                    end
                end
            end
        end
    end
end)

function abrirtienda(idtienda)
    ESX.TriggerServerCallback('shop:obteneritems', function(inventory)
        local elements = {}

        if inventory then
            ESX.TriggerServerCallback('shop:obtenertodoslositems', function(todositems)
                for i = 1, #todositems, 1 do
                    --print(todositems[i].name)
                    if inventory[todositems[i].name] then
                        local nombre = todositems[i].name
                        local cantidad = inventory[nombre].cantidad
                        local precio = inventory[nombre].precio
                        if cantidad > 0 then
                            table.insert(elements,
                                {
                                    label = todositems[i].label .. ' x' .. cantidad .. ' PRECIO: ' .. precio,
                                    value = nombre
                                })
                        end
                    end
                end

                ESX.UI.Menu.CloseAll()

                ESX.TriggerServerCallback('obtenernombretienda', function(nombre)
                    if not nombre then
                        nombre = "Sin Dueño"
                    end
                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'shop',
                        {
                            title    = "Tienda: " .. nombre,
                            align    = 'bottom-right',
                            elements = elements
                        },
                        function(data, menu)
                            ESX.UI.Menu.Open(
                                'dialog', GetCurrentResourceName(), 'get_item_count',
                                {
                                    title = "Cantidad: ",
                                },
                                function(data2, menu)
                                    local quantity = tonumber(data2.value)

                                    if quantity == nil then
                                        ESX.ShowNotification("Cantidad invalida")
                                    else
                                        abriotienda = false
                                        ESX.UI.Menu.CloseAll()
                                        menu.close()
                                        TriggerServerEvent('shops:compraritem', GetPlayerServerId(PlayerId()), idtienda,
                                            data.current.value, quantity)
                                    end
                                end,
                                function(data2, menu)
                                    menu.close()
                                end
                            )
                        end,
                        function(data, menu)
                            abriotienda = false
                            menu.close()
                        end
                    )
                end, idtienda)
            end)
        else
            abriotienda = false
            TriggerEvent('chat:addMessage', { args = { '^1TIENDAS:', "El dueño tiene la tienda vacia" } })
        end
    end, idtienda)
end

function abrirjefe()
    ESX.TriggerServerCallback('esx_property:getPlayerInventory', function(inventory)
        local inicio = {}

        table.insert(inicio, { label = "Depositar objetos", value = 'depositarobjeto' })
        --table.insert(inicio, { label = "Retirar objetos", value = 'retirarobjeto' })
        table.insert(inicio, { label = "Cambiar Precios", value = 'cambiarprecio' })
        table.insert(inicio, { label = "Retirar todo el dinero", value = 'retirardinero' })
        table.insert(inicio, { label = "Cambiar nombre sociedad", value = 'changename' })

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'inicio',
            {
                title    = "Menu jefe",
                align    = 'bottom-right',
                elements = inicio,
            },
            function(data, menuinicio)
                if data.current.value == 'depositarobjeto' then
                    local elements = {}
                    for i = 1, #inventory.items, 1 do
                        local item = inventory.items[i]
                        if item.count > 0 then
                            table.insert(elements,
                                { label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name })
                        end
                    end

                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'player_inventory',
                        {
                            title    = "Inventario Personal",
                            align    = 'bottom-right',
                            elements = elements,
                        },
                        function(data, menu1)
                            ESX.UI.Menu.Open(
                                'dialog', GetCurrentResourceName(), 'put_item_count',
                                {
                                    title = "Cantidad a depositar",
                                },
                                function(data2, menu)
                                    --abriojefe = false
                                    menu.close()
                                    menu1.close()
                                    TriggerServerEvent('shops:agregaritem', identificador, data.current.value,
                                        tonumber(data2.value))
                                end,
                                function(data2, menu)
                                    --abriojefe = false
                                    menu.close()
                                end)
                        end,
                        function(data, menu)
                            --abriojefe = false
                            menu.close()
                        end
                    )
                end

                if data.current.value == 'cambiarprecio' then
                    local elements = {}
                    ESX.TriggerServerCallback('shop:obtenerjefeitems', function(items)
                        ESX.TriggerServerCallback('shop:obtenertodoslositems', function(todositems)
                            for i = 1, #todositems, 1 do
                                if items[todositems[i].name] then
                                    local nombre = todositems[i].name
                                    local cantidad = items[nombre].cantidad
                                    local precio = items[nombre].precio
                                    if cantidad > 0 then
                                        table.insert(elements,
                                            {
                                                label = todositems[i].label .. ' x' .. cantidad .. ' PRECIO: ' .. precio,
                                                value = nombre
                                            })
                                    end
                                end
                            end
                            --print("holaaa")
                            ESX.UI.Menu.Open(
                                'default', GetCurrentResourceName(), 'price',
                                {
                                    title    = "Items dentro para cambiar precio",
                                    align    = 'bottom-right',
                                    elements = elements
                                },
                                function(data, menu1)
                                    ESX.UI.Menu.Open(
                                        'dialog', GetCurrentResourceName(), 'get_item_count',
                                        {
                                            title = "Precio nuevo: ",
                                        },
                                        function(data2, menu2)
                                            local nuevoprecio = tonumber(data2.value)
                                            --print("------------" .. nuevoprecio)

                                            if nuevoprecio < 1 then
                                                ESX.ShowNotification("Cantidad invalida")
                                            else
                                                --abriojefe = false
                                                TriggerServerEvent('shops:cambiarprecio', GetPlayerServerId(PlayerId()),
                                                    identificador,
                                                    data.current.value, nuevoprecio)
                                                menu1.close()
                                                menu2.close()
                                            end
                                        end,
                                        function(data2, menu)
                                            --abriojefe = false
                                            menu.close()
                                        end
                                    )
                                end,
                                function(data, menu)
                                    --abriojefe = false
                                    menu.close()
                                end
                            )
                        end)
                    end, identificador)
                end

                if data.current.value == 'retirardinero' then
                    TriggerServerEvent('shop:retirardinero', GetPlayerServerId(PlayerId()), identificador)
                end

                if data.current.value == 'changename' then
                    ESX.UI.Menu.Open(
                        'dialog', GetCurrentResourceName(), 'get_item_count',
                        {
                            title = "NOMBRE DE LA TIENDA: ",
                        },
                        function(data2, menu2)
                            local nuevonombre = data2.value

                            if string.len(nuevonombre) < 1 then
                                ESX.ShowNotification("No se puede dejar el nombre vacio")
                                menu2.close()
                            else
                                --abriojefe = false
                                TriggerServerEvent('shops:cambiarnombre', GetPlayerServerId(PlayerId()), identificador,
                                    nuevonombre)
                                menu2.close()
                                TriggerServerEvent('shops:blips')
                            end
                        end,
                        function(data2, menu)
                            --abriojefe = false
                            menu.close()
                        end
                    )
                end
            end,
            function(data, menu)
                abriojefe = false
                menu.close() --menu inicio
            end
        )
    end)
end

function createNPCA()
    created_ped = CreatePed(5, GetHashKey("G_M_Y_Lost_03"), 959.0409, 3619.9961, 32.6384 - 1, 10, false, true)
    FreezeEntityPosition(created_ped, true)
    SetEntityInvincible(created_ped, true)
    SetBlockingOfNonTemporaryEvents(created_ped, true)
    TaskStartScenarioInPlace(created_ped, "WORLD_HUMAN_DRINKING", 0, true)
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

Citizen.CreateThread(function()
    while not shops do
        Citizen.Wait(10)
    end
    local blip
    while true do
        local resultado = false
        for i = 1, #shops, 1 do
            if shops[i].duenoid == identificador then
                resultado = true
                break
            else
                resultado = false
            end
        end
        if resultado then
            if not blip then
                blip = AddBlipForCoord(959.0409, 3619.9961, 32.6384 - 1)
                SetBlipSprite(blip, 52)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, 27)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Comprar articulos para tu tienda")
                EndTextCommandSetBlipName(blip)
            end
        else
            RemoveBlip(blip)
            blip = nil
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    createNPCA()
    while true do
        Citizen.Wait(1000)
        if GetDistanceBetweenCoords(959.0409, 3619.9961, 31.6384, GetEntityCoords(GetPlayerPed(-1)), true) < 5 then
            while true do
                Citizen.Wait(1)
                DrawText3D(959.0409, 3619.9961, 32.6384 + 1, "Presiona E para comprar articulos para tu tienda", 0, 255,
                    0)
                if IsControlJustReleased(0, 38) then
                    OpenStore()
                end
                if GetDistanceBetweenCoords(959.0409, 3619.9961, 31.6384, GetEntityCoords(GetPlayerPed(-1)), true) > 5 then
                    break
                end
            end
        end
    end
end)

function OpenStore()
    local autorizado = false
    local numerotienda
    for i = 1, #shops, 1 do
        if identificador == shops[i].duenoid then
            autorizado = true
            numerotienda = i
            break
        end
    end
    if autorizado then
        local elements = {}
        table.insert(elements,
            {
                label = "Pan $20",
                value = "bread"
            })
        table.insert(elements,
            {
                label = "Agua $20",
                value = "water"
            })
        table.insert(elements,
            {
                label = "Telefono $50",
                value = "phone"
            })

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'StoreDueños',
            {
                title    = "Compra de articulos para tu tienda",
                align    = 'bottom-right',
                elements = elements
            },
            function(data, menu)
                ESX.UI.Menu.Open(
                    'dialog', GetCurrentResourceName(), 'get_item_count',
                    {
                        title = "Cantidad: ",
                    },
                    function(data2, menu)
                        local quantity = tonumber(data2.value)

                        if quantity == nil then
                            ESX.ShowNotification("Cantidad invalida")
                        else
                            ESX.UI.Menu.CloseAll()
                            menu.close()
                            -- comprarStoreitem, ID, numerotienda, item a comprar, cantidad a comprar
                            TriggerServerEvent('shops:comprarStoreitem', GetPlayerServerId(PlayerId()), numerotienda,
                                data.current.value, quantity)
                        end
                    end,
                    function(data2, menu)
                        menu.close()
                    end
                )
            end,
            function(data, menu)
                menu.close()
            end
        )
    else
        ESX.ShowNotification("No es dueño de ninguna tienda")
    end
end
