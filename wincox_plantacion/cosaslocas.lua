----------------------CLIENTE-------------------------
local cosa = vector4(526.4042, 1902.56531, 37.2212341, -18.45)
ESX.Game.SpawnLocalObject('prop_fountain1', cosa, function(object)
    SetEntityCoordsNoOffset(object, cosa)
    SetEntityHeading(object, 111.6807)
    SetEntityRotation(object, 0.0, 180.0, 0.0)
    SetEntityAsMissionEntity(object, true, true)
    FreezeEntityPosition(object, true)
end)
local cosa2 = vector4(526.4042, 1902.56531, 34.2212341, -18.45)
ESX.Game.SpawnLocalObject('prop_sprink_golf_01', cosa2, function(object)
    SetEntityCoordsNoOffset(object, cosa2)
    SetEntityHeading(object, 111.6807)
    SetEntityAsMissionEntity(object, true, true)
    FreezeEntityPosition(object, true)
end)

----------------------SERVIDOR-----------------------------

-- local mafiasids = {
--     1
-- }
-- local Plantaciones = {
--     [1] = {
--         {
--             idplanta = 1,
--             porcentajeAgua = 80,
--             porcentajeCrecimiento = 20
--         },
--         {
--             idplanta = 2,
--             porcentajeAgua = 50,
--             porcentajeCrecimiento = 15
--         }
--     },
--     [2] = {
--         {
--             idplanta = 1,
--             porcentajeAgua = 10,
--             porcentajeCrecimiento = 10
--         },
--         {
--             idplanta = 2,
--             porcentajeAgua = 10,
--             porcentajeCrecimiento = 10
--         }
--     }
-- }
-- local Mejoras = {
--     [1] = {
--         tieneAgua = true,
--         tieneCrecimiento = true
--     },
--     [2] = {
--         tieneAgua = false,
--         tieneCrecimiento = false
--     }
-- }
-- local Integrantes = {
--     [1] = {
--         '1a8435356a766c25acd7181f330638eb2aabd2ed'
--     },
--     [2] = {
--         '1a8435356a766c25acd7181f330638eb2aabd2edd'
--     }
-- }