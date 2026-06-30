--this module spawns the car

local CarSpawn = {}
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SetupFolder = ServerStorage.Garage.CarSetup
local BodyFolder = ReplicatedStorage.Garage.Body
local CarOwners = ServerStorage.Garage["Car Owners"]
local DataModule = require(game.ServerStorage.Garage.Modules.Data)
local GarageSetup = require(ServerStorage.Garage.Modules.GarageSetup)
local ColorModule = require(ServerStorage.Garage.Modules.Color)
local GarageCar = workspace.Garage.System.GarageCar
local CarValue2 = workspace.Garage.System.Car

local playerData = DataModule.playerData
local cooldowns = {}

local function setPerformanceData(sourceData, targetFolder)--sets the engine / turbo data for the car
	for key, value in pairs(sourceData) do
		if targetFolder:FindFirstChild(key) and targetFolder[key]:IsA("NumberValue") then
			targetFolder[key].Value = tonumber(value)
		elseif targetFolder:FindFirstChild(key) then
			targetFolder[key].Value = value
		end
	end
end

local function getCar(CarName)
	return GarageCar:FindFirstChild(CarName)
end

function CarSpawn.Spawn(player, CarValue, SpawnPos)--adjusts the car's elements based on the player data and clones the car to the right place
	if cooldowns[player.UserId] and tick() - cooldowns[player.UserId] < 10 then
		return
	end

	cooldowns[player.UserId] = tick()
	
	local Car = ServerStorage.Garage.Cars:FindFirstChild(CarValue)

	local existingOwner = CarOwners:FindFirstChild(player.Name)
	if existingOwner then
		local CarName = GarageSetup.CarData
		local Car2 = getCar(CarName)
		if Car2 then
			CarValue2.Value = false 
		end
		existingOwner.Value:Destroy()
		existingOwner:Destroy()
	end

	local clonedCar = Car:Clone()
	clonedCar.Parent = SetupFolder
	local CarBody = clonedCar.Body.Model
	local carName = clonedCar.Name
	local playerCarData = playerData[player.UserId][carName]

	if playerCarData then
		for partType, partName in pairs(playerCarData.Body) do
			if partName ~= "" then
				local bodyPart = BodyFolder[carName][partType][partName]:Clone()
				local targetPart = CarBody[partType]:FindFirstChild("CFrame")
				bodyPart.Parent = CarBody[partType]
				bodyPart:SetPrimaryPartCFrame(targetPart.CFrame)
			end
		end

		for paintType, hexCode in pairs(playerCarData.Paint) do
			ColorModule.Paint(CarBody, paintType, hexCode)
		end

		
		local CarTuneFolder = clonedCar.Tune.Performance
		setPerformanceData(playerCarData.Performance.Engine, CarTuneFolder.Engine)
		setPerformanceData(playerCarData.Performance.Turbo, CarTuneFolder.Turbo)

	end

	local finalCar = clonedCar:Clone()
	finalCar.Parent = game.Workspace
	clonedCar:Destroy()
	finalCar:SetPrimaryPartCFrame(SpawnPos.CFrame)
	local Owner = Instance.new("ObjectValue", CarOwners)
	Owner.Name = player.Name
	Owner.Value = finalCar
end

return CarSpawn

