-- this script controls all things on the server (for example: car spawning, saving data)

-- Get Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Module Imports
local Zone = require(ReplicatedStorage.Garage.Modules.Zone)
local GarageSetup = require(ServerStorage.Garage.Modules.GarageSetup)
local TemplateUIcreater = require(ServerStorage.Garage.Modules.TemplateUIcreater)
local Configurations = ReplicatedStorage.Garage.Configurations
local UiEvent = ReplicatedStorage.Garage.Events.UI
local UISetupEvent = ReplicatedStorage.Garage.Events.UISetup
local ExitEvent = ReplicatedStorage.Garage.Events.Exit
local ExitModule = require(ServerStorage.Garage.Modules.Exit)
local CarSpawn = require(ServerStorage.Garage.Modules.CarSpawn)
local ButtonDataController = require(ServerStorage.Garage.Modules.ButtonDataController)
local DataModule = require(ServerStorage.Garage.Modules.Data)

-- Event References
local event = ReplicatedStorage.Garage.Events.Spawn
local TweenEvent = ReplicatedStorage.Garage.Events:WaitForChild("TweenEvent")
local ButtonDataEvent = ReplicatedStorage.Garage.Events.ButtonData

-- Workspace References
local playerPart = Workspace.Garage.System.PositionParts.PlayerPart
local SpawnPos = Workspace.Garage.System.PositionParts.GaragePart
local SpawnPos2 = Workspace.Garage.System.PositionParts.ExitSpawn
local CarFolder = ServerStorage.Garage.Cars
local CarValue = Workspace.Garage.System.Car
local GarageCar = Workspace.Garage.System.GarageCar

-- folders
local CarOwners = ServerStorage.Garage["Car Owners"]

-- Zone Setup
local GarageDoorZone = Workspace.Garage.System.Zones["Garage Door"]
local GarageZone = Workspace.Garage.System.Zones.Garage
local doorZone = Zone.new(GarageDoorZone)
local garageZone = Zone.new(GarageZone)

-- Helper Functions
local function handleGarageError(player, message) --it receives the error messages and forwards them to the uicontroller
	UiEvent:FireClient(player, "GarageError", message)
end

doorZone.playerEntered:Connect(function(player) --activated when the player entered this zone
	local character = player.Character
	if character then
		local Humanoid = character:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.SeatPart then
			local Car = Humanoid.SeatPart.Parent
			local carConfigExists = Configurations:FindFirstChild(Car.Name)
			local isCarValueTrue = CarValue.Value

			if carConfigExists and not isCarValueTrue then --checks whether there is a car in the garage or whether the car has a Configuration
				TweenEvent:FireClient(player, true)
			elseif isCarValueTrue then
				handleGarageError(player, "The garage is currently occupied")
			else
				handleGarageError(player, "This car cannot be modified")
			end
		end
	end
end)

doorZone.playerExited:Connect(function(player) --activated when the player leaves the zone
	local character = player.Character
	if character then
		local Humanoid = character:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.SeatPart then
			local Car = Humanoid.SeatPart.Parent
			local carConfigExists = Configurations:FindFirstChild(Car.Name)
			local isCarValueTrue = CarValue.Value

			if carConfigExists and not isCarValueTrue then
				if not garageZone:findPlayer(player) then
					TweenEvent:FireClient(player, false)
				end
			elseif isCarValueTrue then
				handleGarageError(player, "The garage is currently occupied")
			else
				handleGarageError(player, "This car cannot be modified")
			end
		else
			TweenEvent:FireClient(player, false)
		end
	end
end)

-- Player Entered Garage Zone
garageZone.playerEntered:Connect(function(player) --activated when the player entered this zone
	local character = player.Character
	if character then
		local Humanoid = character:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.SeatPart then
			local CarDelete = Humanoid.SeatPart.Parent
			local CarName = CarDelete.Name
			local Car = CarFolder:FindFirstChild(CarName) --searches for the car in the carfolder

			UISetupEvent:FireClient(player, CarName)
			TemplateUIcreater.CreateUIBody(player, CarName) --creating template textbuttons to modify the car (Exterior Modification)
			TemplateUIcreater.CreateUIPerformance(player, CarName) --creating template textbuttons to modify the car (Performance tuning)
			TemplateUIcreater.CreateUIPaint(player, CarName) --creating template textbuttons to modify the car (Paint)
			CarValue.Value = true

			Humanoid.SeatPart:Sit(nil)
			task.wait(0.1)
			GarageSetup.Spawn(player, Car, SpawnPos) --spawn the car in the garage
			CarDelete:Destroy()
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			humanoidRootPart.CFrame = playerPart.CFrame
		end
	end
end)

-- Button Data Event
ButtonDataEvent.OnServerEvent:Connect(function(player, Type, PartName, Category)
	ButtonDataController.Data(player, Type, PartName, Category) --sends the button data to the ButtonDataController module
end)

-- Exit Event
ExitEvent.OnServerEvent:Connect(function(player)
	ExitModule.DeleteUI(player) --deletes the created template textbuttons
	ExitModule.Spawn(player, SpawnPos2) --the Exit module spawns the car
end)

-- Spawn Event
event.OnServerEvent:Connect(function(player, CarValue, pawnPos)
	CarSpawn.Spawn(player, CarValue, pawnPos) --the Spawn module spawns the car
end)

game.Players.PlayerAdded:Connect(function(player)
	DataModule.CarTuneGetData(player)
end)

local function getCar(CarName) --function checks that the car is in the GarageCar folder
	return GarageCar:FindFirstChild(CarName)
end

game.Players.PlayerRemoving:Connect(
	function(player) --if the player exits, it saves the data and checks whether the car is in the garage, if it is in the garage, it deletes the car
		DataModule.CarTuneSetData(player) --saves the data in the Datamodule

		local existingOwner = CarOwners:FindFirstChild(player.Name)
		if existingOwner then --checks if the car has been left in the garage
			local CarName = GarageSetup.CarData --car name written in a module, to make it easier to find
			local Car = getCar(CarName)
			if Car then
				CarValue.Value = false
			end
			existingOwner.Value:Destroy() --destroys the car
			existingOwner:Destroy() -- deletes the object value
		end
	end
)
