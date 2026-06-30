local CarTune = {}
local DataModule = require(game.ServerStorage.Garage.Modules.Data)

function CarTune.Body(player, Car, BodyType, BodyName)
	local playerData = DataModule.playerData[player.UserId]
	if playerData and playerData[Car.Name] then
		playerData[Car.Name].Body[BodyType] = BodyName
	end
end

function CarTune.Performance(player, Car, PerformanceType, PerformanceValues)
	
	local playerData = DataModule.playerData[player.UserId]
	if playerData and playerData[Car.Name] and playerData[Car.Name].Performance[PerformanceType] then
		for key, value in pairs(PerformanceValues) do
			playerData[Car.Name].Performance[PerformanceType][key] = value
		end
	else
		warn("Invalid PerformanceType: " .. tostring(PerformanceType))
	end
end

function CarTune.Color(player, Car, paintType, hexCode)
	local playerData = DataModule.playerData[player.UserId]
	if playerData and playerData[Car.Name] then
		playerData[Car.Name].Paint[paintType] = hexCode
	end
end

return CarTune
