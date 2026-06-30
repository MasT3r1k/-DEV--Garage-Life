local Data = {
	playerData = {},
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local carStore = DataStoreService:GetDataStore("TuningData")
local Configurations = ReplicatedStorage.Garage.Configurations

local playerData = Data.playerData

function Data.CarTuneGetData(player)
	local success, data = pcall(function()
		return carStore:GetAsync(player.UserId)
	end)

	if success and data then
		playerData[player.UserId] = data
	else
		playerData[player.UserId] = {}
	end

	local dataChanged = false

	for _, configModule in pairs(Configurations:GetChildren()) do
		local configName = configModule.Name
		if not playerData[player.UserId][configName] then
			local configData = require(configModule)
			playerData[player.UserId][configName] = configData.defaultCarData 
			dataChanged = true
		end
	end

	if dataChanged then
		Data.CarTuneSetData(player)
	
		local success, updatedData = pcall(function()
			return carStore:GetAsync(player.UserId)
		end)
		if success and updatedData then
			playerData[player.UserId] = updatedData
		end
	end
end

function Data.CarTuneSetData(player)
	local success, errorMessage = pcall(function()
		carStore:SetAsync(player.UserId, playerData[player.UserId])
	end)

	if success then
		print("Data successfully saved for player:", player.UserId)
	else
		warn("Failed to save data for player:", player.UserId, errorMessage)
	end
end

return Data
