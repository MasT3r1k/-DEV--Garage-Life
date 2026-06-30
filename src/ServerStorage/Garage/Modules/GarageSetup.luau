--this is the garage setup module, it is also similar to the spawn module with some changes
local CarSpawn = {
	CarData = "",
}
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraEvent = ReplicatedStorage.Garage.Events.CameraEvent
local SetupFolder = ServerStorage.Garage.CarSetup
local BodyFolder = ReplicatedStorage.Garage.Body
local CarOwners = ServerStorage.Garage["Car Owners"]

local DataModule = require(game.ServerStorage.Garage.Modules.Data)
local ColorModule = require(ServerStorage.Garage.Modules.Color)

local playerData = DataModule.playerData

function CarSpawn.Spawn(player, Car, SpawnPos)
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
	end
	

	local finalCar = clonedCar:Clone()
	finalCar.Parent = game.Workspace.Garage.System.GarageCar
	clonedCar:Destroy()
	finalCar:SetPrimaryPartCFrame(SpawnPos.CFrame)
	local Subject = finalCar
	CarSpawn.CarData = carName
	CameraEvent:FireClient(player, Subject, "Subject")
	local existingOwner = CarOwners:FindFirstChild(player.Name)
	if existingOwner then
		existingOwner:Destroy()
	end
	local Owner = Instance.new("ObjectValue", CarOwners)
	Owner.Name = player.Name
	Owner.Value = finalCar
	task.wait(5)
	for _, part in pairs(finalCar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

end

return CarSpawn
