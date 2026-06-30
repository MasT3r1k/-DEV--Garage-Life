--this module makes the player and the car exit the garage
--similar to the spawn module but different

local Exit = {}
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SetupFolder = ServerStorage.Garage.CarSetup
local BodyFolder = ReplicatedStorage.Garage.Body
local CarOwners = ServerStorage.Garage["Car Owners"]
local DataModule = require(game.ServerStorage.Garage.Modules.Data)
local ColorModule = require(ServerStorage.Garage.Modules.Color)
local GarageSetup = require(ServerStorage.Garage.Modules.GarageSetup)
local GarageCar = workspace.Garage.System.GarageCar
local CarsFolder = ServerStorage.Garage.Cars
local CarValue = workspace.Garage.System.Car

local playerData = DataModule.playerData
local cooldowns = {}

local function setPerformanceData(sourceData, targetFolder)
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

function Exit.Spawn(player, SpawnPos)
	local CarName = GarageSetup.CarData
	local CarDelete = getCar(CarName)
	local Car = CarsFolder:FindFirstChild(CarName)
	CarDelete:Destroy()

	local existingOwner = CarOwners:FindFirstChild(player.Name)
	if existingOwner then
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
	wait(4.7)
	local DriveSeat = finalCar.DriveSeat
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	DriveSeat:Sit(humanoid)
	CarValue.Value = false
	
end




function Exit.DeleteUI(player)
	local tuningFrame = player.PlayerGui.Garage.Main.Tuning["Tuning Frame2"]["Tuning Frame"]
	local framesToClear = {"Body", "Paint", "Performance"}

	for _, frameName in ipairs(framesToClear) do
		local frame = tuningFrame:FindFirstChild(frameName)
		if frame then
			for _, child in pairs(frame:GetDescendants()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
		end
	end
end

return Exit

