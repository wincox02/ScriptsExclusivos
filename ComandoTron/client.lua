ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local estado = false

SetEntityInvincible(GetPlayerPed(-1),false)

RegisterNetEvent('comandotron')
AddEventHandler('comandotron', function(args)
    if not estado then --ejecutar cambio de normal a tron
        estado = true
        TriggerEvent('chatMessage', 'Entraste a moderar')

        TriggerEvent('skinchanger:getSkin', function(skin)
            --local couleur = math.random(0, 9)
            local couleur = 2
            local model = GetEntityModel(GetPlayerPed( -1))
            armor = GetPedArmour(GetPlayerPed(-1))
            Citizen.CreateThread(function ()
                while true do 
                    Citizen.Wait(100)
                    SetEntityInvincible(GetPlayerPed(-1),true)
                end
            end)
            if model == GetHashKey("mp_m_freemode_01") then
                tron = true
                clothesSkin = {
                    ['bags_1'] = 0,
                    ['bags_2'] = 0,
                    ['tshirt_1'] = 15,
                    ['tshirt_2'] = 0,
                    ['torso_1'] = 178,
                    ['torso_2'] = couleur,
                    ['arms'] = 31,
                    ['pants_1'] = 77,
                    ['pants_2'] = couleur,
                    ['shoes_1'] = 55,
                    ['shoes_2'] = couleur,
                    ['mask_1'] = 0,
                    ['mask_2'] = 0,
                    ['bproof_1'] = 0,
                    ['chain_1'] = 0,
                    ['helmet_1'] = 91,
                    ['helmet_2'] = couleur,
                }
            else
                tron = true
                clothesSkin = {
                    ['bags_1'] = 0,
                    ['bags_2'] = 0,
                    ['tshirt_1'] = 14,
                    ['tshirt_2'] = 0,
                    ['torso_1'] = 180,
                    ['torso_2'] = couleur,
                    ['arms'] = 49,
                    ['arms_2'] = 0,
                    ['pants_1'] = 79,
                    ['pants_2'] = couleur,
                    ['shoes_1'] = 58,
                    ['shoes_2'] = couleur,
                    ['mask_1'] = 0,
                    ['mask_2'] = 0,
                    ['bproof_1'] = 0,
                    ['chain_1'] = 0,
                    ['helmet_1'] = 90,
                    ['helmet_2'] = couleur,
                }
            end
            TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
        end)
    else
        estado = false
        tron = false
        TriggerEvent('chatMessage', 'Saliste de moderar ')
        Citizen.CreateThread(function ()
            while true do 
                Citizen.Wait(100)
                SetEntityInvincible(GetPlayerPed(-1),false)
            end
        end)
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
            local isMale = skin.sex == 0
            TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                    TriggerEvent('esx:restoreLoadout')
                end)
            end)
        end)
        SetPedArmour(GetPlayerPed( -1), 0)

        FreezeEntityPosition(GetPlayerPed( -1), false)
        NoClip = false

        SetEntityVisible(GetPlayerPed( -1), 1, 0)
        NetworkSetEntityInvisibleToNetwork(GetPlayerPed( -1), 0)
    end
end)
