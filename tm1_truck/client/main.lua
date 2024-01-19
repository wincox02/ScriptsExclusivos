---------------------------
--------VARIABLES----------
---------------------------
ESX                = nil

local points       = {
	{
		name = "truckChecker",
		message = "~w~Deja aquí el camión para pedir un trabajo",
		x = -141.96,
		y = 6203.28,
		z = 31.24,
		distance = 4.0
	},
	{
		name = "getJob",
		message = "~r~Pulsa E para buscar un trabajo",
		x = -136.96,
		y = 6199.0,
		z = 32.4,
		distance = 2.0
	},
	{
		name = "cloackRoom",
		message = "~w~Pulsa E para cambiarte de ropa",
		x = -121.8,
		y = 6204.96,
		z = 32.4,
		distance = 4.0
	},
}

local truckChecker = {
	x = -141.96,
	y = 6203.28,
	z = 31.24
}

local blips        = {
	{
		x = -136.96,
		y = 6199.0,
		z = 32.4,
		name = "Contratacion de camioneros",
		id = 477,
		color = 1
	}
}

local truckAllowed = {
	"hauler",
	"packer",
	"phantom"
}

--------------------------
-----------HILOS----------
--------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		-- TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		ESX = exports['es_extended']:getSharedObject()
		Citizen.Wait(0)
	end
end)

local entrabajo = false
local siguientepaso = false
local patente = ""

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for i, v in pairs(points) do
			if GetDistanceBetweenCoords(v.x, v.y, v.z, GetEntityCoords(GetPlayerPed(-1), true)) <= v.distance then
				DrawText3D(v.x, v.y, v.z, v.message, 0, 0, 0)
				if IsControlJustPressed(1, 38) then
					if v.name == "getJob" then
						ESX.TriggerServerCallback('tm1_truck:obtenertrabajo', function(job)
							if job == "trucker" then
								if isInAnAllowedVehicle(truckChecker.x, truckChecker.y, truckChecker.z) and not entrabajo then
									successmsg("Ve a buscar la carga al lugar indicado en el GPS del Camion")
									iniciartrabajo()
								else
									local cadena = ""
									for key, value in pairs(truckAllowed) do
										if key == #truckAllowed then
											cadena = cadena .. value
										else
											cadena = cadena .. value .. ", "
										end
									end
									errormsg("Lo siento pero no tienes ningún camion permitido en la zona: " .. cadena)
								end
							else
								errormsg("No eres Camionero")
							end
						end)
					end
					if v.name == "cloackRoom" then
						MenuCloakRoom()
					end
				end
			end
		end
	end
end)

function iniciartrabajo()
	local spawnCharge = { x = -2530.1838, y = 2341.3818, z = 33.0599, h = 211.5916 }
	local destino = vector3(-2532.0405, 2324.6692, 33.0599)
	local destino2 = vector3(-126.4287, 6215.2837, 31.2024)
	--local spawn = vector4(-2530.1838, 2341.3818, 33.0599, 211.5916)
	Citizen.Wait(1)
	local blip = AddBlipForCoord(destino)
	SetBlipRoute(blip, true)
	entrabajo = true
	while entrabajo do
		Citizen.Wait(1000)
		local distance1 = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), destino, true)
		while distance1 < 20 and not siguientepaso and entrabajo do
			Citizen.Wait(1)
			distance1 = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), destino, true)
			DrawMarker(1, destino.x, destino.y, destino.z - 1, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001, 252, 255, 0,
				200, 0, 0, 0, 0)
			DrawText3D(destino.x, destino.y, destino.z + 2, "Pulsa E para obtener un trailer", 255, 255, 255)
			if IsControlJustPressed(1, 38) then
				RemoveBlip(blip)
				blip = AddBlipForCoord(destino2)
				SetBlipRoute(blip, true)
				ESX.Game.SpawnVehicle("docktrailer", spawnCharge, spawnCharge.h, function(vehicle)
					local plate = "CAM " .. math.random(100, 999)
					SetVehicleNumberPlateText(vehicle, plate)
					patente = plate
				end)
				successmsg("Carga el trailer y vuelve a la estacion de Camioneros")
				siguientepaso = true
				break
			end
		end
		local distance2 = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), destino2, true)
		while distance2 < 20 and siguientepaso and entrabajo do
			Citizen.Wait(1)
			distance2 = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), destino2, true)
			DrawMarker(1, destino2.x, destino2.y, destino2.z - 1, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001, 252, 255,
				0,
				200, 0, 0, 0, 0)
			DrawText3D(destino2.x, destino2.y, destino2.z + 2, "Pulsa E para finalizar el encargo", 255, 255, 255)
			if IsControlJustPressed(1, 38) then
				local vehicles = ESX.Game.GetVehicles()
				local result = false
				for i = 1, #vehicles, 1 do
					if string.sub(GetVehicleNumberPlateText(vehicles[i]), 1, 7) == patente then
						if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(vehicles[i]), true) < 15 then
							ESX.Game.DeleteVehicle(vehicles[i])
							result = true
							break
						else
							ESX.Game.DeleteVehicle(vehicles[i])
							break
						end
					end
				end
				if result then
					ESX.TriggerServerCallback('tm1_truck:pagar', function(cantidadcobrada)
						if cantidadcobrada > 0 then
							successmsg("Cobraste: " .. cantidadcobrada .. " por este encargo")
						else
							errormsg("No se pudo cobrar. Contacta a un administrador")
						end
					end)
				else
					errormsg("No es la carga que se acordo... Encargo cancelado")
				end
				RemoveBlip(blip)
				entrabajo = false
				patente = ""
				siguientepaso = false
			end
		end
	end
end

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	for _, info in pairs(blips) do
		info.blip = AddBlipForCoord(info.x, info.y, info.z)
		SetBlipSprite(info.blip, info.id)
		SetBlipDisplay(info.blip, 4)
		SetBlipScale(info.blip, 0.9)
		SetBlipColour(info.blip, info.color)
		SetBlipAsShortRange(info.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.name)
		EndTextCommandSetBlipName(info.blip)
	end
end)

---------------------------
--------FUNCIONES----------
---------------------------
function DrawText3D(x, y, z, text, r, g, b) -- some useful function, use it if you want!
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

	local scale = (1 / dist) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	if onScreen then
		SetTextScale(0.0 * scale, 0.8 * scale)
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

function successmsg(msg)
	TriggerEvent("pNotify:SetQueueMax", "center", 2)
	TriggerEvent("pNotify:SendNotification", {
		text = msg,
		type = "success",
		timeout = 8000,
		layout = "centerRight",
		queue = "center"
	})
end

function errormsg(msg)
	TriggerEvent("pNotify:SetQueueMax", "center", 2)
	TriggerEvent("pNotify:SendNotification", {
		text = msg,
		type = "error",
		timeout = 8000,
		layout = "centerRight",
		queue = "center"
	})
end

function isInAnAllowedVehicle(x1, y1, z1)
	local vehicle = GetClosestVehicle(x1, y1, z1, 8.0, 0, 70)
	local object = ESX.Game.GetClosestObject()
	Citizen.Trace(GetHashKey(object))
	for i, v in pairs(truckAllowed) do
		if IsVehicleModel(vehicle, GetHashKey(v)) or IsVehicleModel(object, GetHashKey(v)) then
			return true
		end
	end
	return false
end

function MenuCloakRoom()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = "Ropero",
			align    = 'bottom-right',
			elements = {
				{ label = "Ropa de trabajo", value = 'job_wear' },
				{ label = "Ropa de civil",   value = 'citizen_wear' }
			}
		},
		function(data, menu)
			if data.current.value == 'citizen_wear' then
				isInService = false
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end
			if data.current.value == 'job_wear' then
				isInService = true
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						local trabajo =
						'{"tshirt_1":59,"torso_1":89,"arms":31,"pants_1":36,"glasses_1":19,"decals_2":0,"hair_color_2":0,"helmet_2":0,"hair_color_1":0,"face":2,"glasses_2":0,"torso_2":1,"shoes":35,"hair_1":0,"skin":0,"sex":0,"glasses_1":19,"pants_2":0,"hair_2":0,"decals_1":0,"tshirt_2":0,"helmet_1":5}'
						local encode = json.decode(trabajo)
						TriggerEvent('skinchanger:loadClothes', skin, encode)
					else
						local trabajo =
						'{"tshirt_1":36,"torso_1":0,"arms":68,"pants_1":30,"glasses_1":15,"decals_2":0,"hair_color_2":0,"helmet_2":0,"hair_color_1":0,"face":27,"glasses_2":0,"torso_2":11,"shoes":26,"hair_1":5,"skin":0,"sex":1,"glasses_1":15,"pants_2":2,"hair_2":0,"decals_1":0,"tshirt_2":0,"helmet_1":19}'
						local encode = json.decode(trabajo)
						TriggerEvent('skinchanger:loadClothes', skin, encode)
					end
				end)
			end
			menu.close()
		end,
		function(data, menu)
			menu.close()
		end
	)
end

-- RegisterCommand('prueba', function()
-- 	local vehicles = ESX.Game.GetVehicles()
-- 	for key, value in pairs(vehicles) do
-- 		print("key")
-- 		print(key)
-- 		print("value")
-- 		print(value)
-- 		print("GetEntityCoords")
-- 		print(GetEntityCoords(value))
-- 	end
-- end, false)

-- RegisterCommand('dvall', function()
-- 	local vehicles = ESX.Game.GetVehicles()
-- 	for key, value in pairs(vehicles) do
-- 		ESX.Game.DeleteVehicle(value)
-- 	end
-- end, false)
