local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ProfileManager = require(ServerScriptService.DataManager.ProfileManager)
local Types = require(ServerScriptService.DataManager.Types)
local getTaggedPartFromModel = require(ReplicatedStorage.Utils.getTaggedPartFromModel)
local getTaggedPartsFromModel = require(ReplicatedStorage.Utils.getTaggedPartsFromModel)
local inTable = require(ReplicatedStorage.Utils.inTable)
local removeSeats = require(ReplicatedStorage.Utils.removeSeats)
local BodyFolder = ReplicatedStorage.Garage.Body

local MIN_DIST_BETWEEN_GARAGES = 300
local garageSpawnDebounce = {}

local GarageModule = {}

-- Find Folder
function GetFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

function GarageModule.GetDriveSystemFolder()
	return GetFolder(ServerStorage, "DriveSystem")
end

function GarageModule.GetGaragesFolder()
	return GetFolder(workspace, "Player_Garages")
end

function GarageModule.GetEntryGaragesFolder()
	return GetFolder(workspace, "Garages")
end

function GarageModule.GetCarsFolder()
	return GetFolder(workspace, "Cars")
end

function GarageModule.GetCarTemplatesFolder()
	local GarageFolder = GetFolder(ServerStorage, "Garage")
	return GetFolder(GarageFolder, "Cars")
end

function GarageModule.GetCarSetupFolder()
	local GarageFolder = GetFolder(ServerStorage, "Garage")
	return GetFolder(GarageFolder, "Car Setup")
end

function GarageModule.GetCarOwnersFolder()
	local GarageFolder = GetFolder(ServerStorage, "Garage")
	return GetFolder(GarageFolder, "Car Owners")
end

-- Garages
function GarageModule.GetPlayerGarageModel(player: Player)
	local garagesFolder = GarageModule.GetGaragesFolder()
	if not garagesFolder then
		return nil
	end
	local garage = garagesFolder:FindFirstChild(player.Name .. "_Garage")
	return garage
end

function GarageModule.GetPlayerCurrentGarageName(player: Player)
	if not player then
		return warn("Missing player argument")
	end
	local garage = GarageModule.GetPlayerGarageModel(player)
	if not garage then
		return nil
	end
	local name = garage:WaitForChild("GarageName")
	return name and name.Value or nil
end

function GarageModule.GetSafeGaragePosition()
	local maxAttempts = 50
	local mapSize = 10000
	for i = 1, maxAttempts do
		local potentialPos = Vector3.new(math.random(-mapSize, mapSize), 500, math.random(-mapSize, mapSize))
		local isSafe = true
		for _, obj in pairs(workspace.Player_Garages:GetChildren()) do
			if obj.PrimaryPart then
				if (obj.PrimaryPart.Position - potentialPos).Magnitude < MIN_DIST_BETWEEN_GARAGES then
					isSafe = false
					break
				end
			end
		end
		if isSafe then
			return CFrame.new(potentialPos)
		end
	end
	return CFrame.new(0, 500, 0)
end

function GarageModule.spawnGarageModel(player: Player, garageName: string)
	if not RunService:IsServer() then
		return
	end

	if garageSpawnDebounce[player.UserId] then
		return
	end
	garageSpawnDebounce[player.UserId] = true
	if GarageModule.GetPlayerCurrentGarageName(player) == garageName then
		return
	end

	local template = ServerStorage:FindFirstChild("Garages") and ServerStorage.Garages:FindFirstChild(garageName)
	if not template then
		warn("Garage " .. garageName .. " not found!")
		garageSpawnDebounce[player.UserId] = nil
		return
	end

	local old = GarageModule.GetPlayerGarageModel(player)
	if old then
		old:Destroy()
	end

	local GaragesFolder = GarageModule.GetGaragesFolder()

	local newGarage = template:Clone()
	newGarage.Name = player.Name .. "_Garage"
	newGarage:PivotTo(GarageModule.GetSafeGaragePosition())
	newGarage.Parent = GaragesFolder

	-- Owner of garage
	local ownerText = Instance.new("StringValue")
	ownerText.Name = "Owner"
	ownerText.Value = player.Name
	ownerText.Parent = newGarage

	local ownerIdText = Instance.new("StringValue")
	ownerIdText.Name = "OwnerId"
	ownerIdText.Value = player.UserId
	ownerIdText.Parent = newGarage

	-- Garage name
	local garageText = Instance.new("StringValue")
	garageText.Name = "GarageName"
	garageText.Value = garageName
	garageText.Parent = newGarage

	-- Leave Garage
	local getLeavePart = getTaggedPartFromModel(newGarage, "GarageLeave")
	if getLeavePart then
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ActionText = "Exit on foot"
		proximityPrompt.ClickablePrompt = true
		proximityPrompt.HoldDuration = 0.5
		proximityPrompt.ObjectText = "Garage"
		proximityPrompt.Parent = getLeavePart

		proximityPrompt.Triggered:Connect(function(p: Player)
			GarageModule.LeaveGarage(p, newGarage)
		end)
	else
		warn("GarageLeave part not found in " .. garageName .. " for " .. player.Name)
	end

	local spawnLocation = newGarage:FindFirstChild("InteriorSpawn")
	if not spawnLocation then
		spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "InteriorSpawn"
		spawnLocation.Size = Vector3.new(10, 0.1, 10)
		spawnLocation.AllowTeamChangeOnTouch = false
		spawnLocation.Transparency = 1
		spawnLocation.CanCollide = false
		spawnLocation.Anchored = true
		if newGarage.PrimaryPart then
			spawnLocation.CFrame = newGarage.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
		else
			spawnLocation.CFrame = CFrame.new(newGarage:GetPivot().Position) + Vector3.new(0, 5, 0)
		end
		spawnLocation.Parent = newGarage
	end

	spawnLocation.AllowTeamChangeOnTouch = false
	spawnLocation.Neutral = false
	player.RespawnLocation = spawnLocation

	GarageModule.spawnGarageCars(player)

	garageSpawnDebounce[player.UserId] = nil
end

function GarageModule:WaitForGarageLoad(player, timeout)
	local maxWaitTime = timeout or 10
	local GaragesFolder = GarageModule.GetGaragesFolder()
	local expectedGarageName = player.Name .. "_Garage"

	local loadedGarage = GaragesFolder:WaitForChild(expectedGarageName, maxWaitTime)

	if not loadedGarage then
		return nil
	end

	return loadedGarage
end

function GarageModule.TeleportPlayerToGarage(player: Player, garage)
	if not player or not player:IsA("Player") then
		return
	end

	if not garage or not garage:IsA("Model") then
		warn("Failed teleporting player " .. player.Name .. " to Garage.. you have to provide Garage Model")
		return
	end

	local loadingFrame = player:WaitForChild("PlayerGui"):WaitForChild("Loading"):WaitForChild("Loading")

	if loadingFrame then
		loadingFrame.Visible = true
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Sit then
		humanoid.Sit = false
	end

	local interiorSpawn = garage.InteriorSpawn
	if not interiorSpawn then
		return
	end

	local spawnPoint = interiorSpawn:Clone()

	if garage.OwnerId.Value == player.UserId then
		GarageModule.despawnCar(player)
	end

	if RunService:IsServer() then
		player:RequestStreamAroundAsync(spawnPoint.Position)
	end
	character:PivotTo(spawnPoint.CFrame + Vector3.new(0, 1, 0))

	if loadingFrame then
		loadingFrame.Visible = false
	end
end

function GarageModule.LeaveGarage(player: Player, garage: Model)
	if not player or not player:IsA("Player") then
		return
	end
	if not garage or not garage:IsA("Model") then
		warn("Failed teleporting player " .. player.Name .. " from Garage.. you have to provide a Garage Model")
		return
	end

	local garageNameValue = garage:FindFirstChild("GarageName")
	local garageName = garageNameValue and garageNameValue.Value
	if not garageName then
		return
	end

	local entryGaragesFolder = GarageModule.GetEntryGaragesFolder()
	if not entryGaragesFolder then
		return
	end

	local entryGarage = entryGaragesFolder:FindFirstChild(garageName .. "_Enter")
	if not entryGarage then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local spawnLocation = entryGarage:FindFirstChild("TargetPosition")
	if not spawnLocation then
		warn("SpawnLocation chybí v entryGarage: " .. garageName)
		return
	end

	if RunService:IsServer() then
		if entryGarage.PrimaryPart then
			player:RequestStreamAroundAsync(entryGarage.PrimaryPart.Position)
		end
	end

	character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 3, 0))
end

function GarageModule.getPlayerCars(player: Player)
	if not player then
		return
	end

	local profile = ProfileManager:GetProfile(player)
	return profile.Data.cars
end

function GarageModule.canAddPlayerCar(player)
	local emptySlots = GarageModule.EmptySpawnsInGarage(player)
	if #emptySlots == 0 then
		warn("No more space in Garage, buy bigger one")
		return
	end
	return true
end

function GarageModule.addPlayerCar(player: Player, car: Types.Vehicle)
	if not player then
		return
	end
	if not car then
		return
	end

	if not RunService:IsServer() then
		return
	end

	-- Verify if we have space in garage
	if not GarageModule.canAddPlayerCar(player) then
		return
	end

	-- Add Car to Garage
	local carId = HttpService:GenerateGUID(true)
	local profile = ProfileManager:GetProfile(player)
	local replica = ProfileManager:GetReplica(player)

	-- Update profile data
	if replica then
		car.car_id = carId
		replica:Set({ "cars", carId }, car)
		replica:TableInsert({ "garage_slots" }, carId)
		local codex = profile.Data.codex
		if not inTable(codex, car.vehicle_name) then
			replica:TableInsert({ "codex" }, car.vehicle_name)
		end
	end

	print(profile.Data.cars)

	GarageModule.spawnGarageCars(player) -- Update cars in garage
end

function GarageModule.getPlayerCarAtIndex(player: Player, index: number)
	if not player then
		return
	end
	if not index then
		return
	end

	if not RunService:IsServer() then
		return
	end

	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return
	end

	local car_id = profile.Data.garage_slots[index]
	local car = profile.Data.cars[car_id]

	return car
end

function GarageModule.GetGarageSlots(player)
	local garageModel = GarageModule.GetPlayerGarageModel(player)
	if not garageModel then
		return {}
	end

	local CarSpawns = getTaggedPartsFromModel(garageModel, "GarageCar")
	return CarSpawns
end

function GarageModule.EmptySpawnsInGarage(player)
	local spawns = {} :: { number }
	local garageSlots = GarageModule.GetGarageSlots(player)

	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return
	end

	local usedGarageSlots = profile.Data.garage_slots

	for index, slot in pairs(garageSlots) do
		if not slot then
			continue
		end
		if usedGarageSlots[index] then
			continue
		end
		table.insert(spawns, index)
	end
	return spawns
end

function GarageModule.spawnGarageCars(player: Player)
	local garageModel = GarageModule.GetPlayerGarageModel(player)
	if not garageModel then
		return
	end

	local CarSpawns = GarageModule.GetGarageSlots(player)
	for _, carSpawn in ipairs(CarSpawns) do
		local car = GarageModule.getPlayerCarAtIndex(player, _)

		if not car then
			continue
		end

		local previousCar = carSpawn:FindFirstChild("Car")
		if previousCar then
			previousCar:Destroy()
		end

		local setupCar = GarageModule.SetupCar(player, car)

		-- Unavailable car
		if not setupCar then
			warn("Failed to load car " .. car.vehicle_name)
			local carTemplatesFolder = GarageModule.GetCarTemplatesFolder()
			if not carTemplatesFolder then
				warn("Car Template Folder not found")
				return
			end
			local CarTemplate = carTemplatesFolder:WaitForChild("UnavailableCarTarp")
			if not CarTemplate then
				warn("Failed to unavailable car tarp")
				return
			end

			setupCar = CarTemplate:Clone()
			setupCar.Name = "UnavailableCar"
			continue
		else
			setupCar.Name = "Car"
			local UnavailableGui = Instance.new("BillboardGui")
			UnavailableGui.Name = "UnavailableGui"
			UnavailableGui.AlwaysOnTop = true
			UnavailableGui.Enabled = true
			UnavailableGui.MaxDistance = 50
			UnavailableGui.StudsOffset = Vector3.new(0, 5, 0)
			UnavailableGui.Size = UDim2.new(UDim.new(10, 0), UDim.new(2, 0))

			local TextLabel = Instance.new("TextLabel")
			TextLabel.Parent = UnavailableGui
			TextLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Text = car.vehicle_name or "Unknown"
			TextLabel.TextColor3 = Color3.new(1, 1, 1)
			TextLabel.TextScaled = true
			TextLabel.Size = UDim2.new(UDim.new(1, 0), UDim.new(1, 0))

			UnavailableGui.Parent = carSpawn

			removeSeats(setupCar)

			-- proximityprompt
			local carTakeout = carSpawn:FindFirstChild("CarTakeout")
			if carTakeout then
				local ProximityPrompt = Instance.new("ProximityPrompt")
				ProximityPrompt.ObjectText = "Garage"
				ProximityPrompt.ActionText = "Leave Garage With This Car"
				ProximityPrompt.Parent = carTakeout
				ProximityPrompt.HoldDuration = 0.5
				ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.F

				ProximityPrompt.Triggered:Connect(function()
					GarageModule.spawnCar(player, car)
				end)
			end
		end

		setupCar.Parent = carSpawn
		setupCar:SetPrimaryPartCFrame(carSpawn.CFrame * CFrame.new(0, 1, 0))

		-- Billboard gui
	end

	-- if garageCarSpawnCooldown[player.UserId] and tick() - garageCarSpawnCooldown[player.UserId] < 10 then
	-- 	return
	-- end

	-- garageCarSpawnCooldown[player.UserId] = tick()

	-- local Car = ServerStorage.Garage.Cars:FindFirstChild(car.vehicle_name)

	-- local CarOwners = GarageModule.GetCarOwnersFolder()

	-- GarageModule.despawnCar(player)

	-- local clonedCar = Car:Clone()
	-- clonedCar.Parent = GarageModule.GetCarSetupFolder()
	-- local CarBody = clonedCar.Body.Model
	-- local carName = clonedCar.Name
	-- local playerCarData = car

	-- -- if playerCarData then
	-- -- 	for partType, partName in pairs(playerCarData.Body) do
	-- -- 		if partName ~= "" then
	-- -- 			local bodyPart = BodyFolder[carName][partType][partName]:Clone()
	-- -- 			local targetPart = CarBody[partType]:FindFirstChild("CFrame")
	-- -- 			bodyPart.Parent = CarBody[partType]
	-- -- 			bodyPart:SetPrimaryPartCFrame(targetPart.CFrame)
	-- -- 		end
	-- -- 	end

	-- -- 	for paintType, hexCode in pairs(playerCarData.Paint) do
	-- -- 		ColorModule.Paint(CarBody, paintType, hexCode)
	-- -- 	end

	-- -- 	local CarTuneFolder = clonedCar.Tune.Performance
	-- -- 	setPerformanceData(playerCarData.Performance.Engine, CarTuneFolder.Engine)
	-- -- 	setPerformanceData(playerCarData.Performance.Turbo, CarTuneFolder.Turbo)
	-- -- end

	-- local finalCar = clonedCar:Clone()
	-- finalCar.Parent = GarageModule.GetCarsFolder()
	-- clonedCar:Destroy()
	-- finalCar:SetPrimaryPartCFrame(location)
	-- local Owner = Instance.new("ObjectValue", CarOwners)
	-- Owner.Name = player.Name
	-- Owner.Value = finalCar
end

function GarageModule.SetupCar(player: Player, car: Types.Vehicle)
	if not player then
		return
	end
	if not car then
		return
	end

	if not car.vehicle_name then
		warn("Vehicle name is not found")
		return
	end

	local carTemplatesFolder = GarageModule.GetCarTemplatesFolder()
	if not carTemplatesFolder then
		warn("Car Template Folder not found")
		return
	end
	local CarTemplate = carTemplatesFolder:WaitForChild(car.vehicle_name)
	if not CarTemplate then
		warn("Failed to load car " .. car.vehicle_name)
		return
	end

	local clonedCar = CarTemplate:Clone()
	clonedCar.Parent = GarageModule.GetCarSetupFolder()
	local CarBody = clonedCar.Body.Model
	local carName = clonedCar.Name

	if car then
		for partType, partName in pairs(car.body) do
			print(partType, partName)
			if partName ~= "" then
				local bodyFolderCar = BodyFolder:FindFirstChild(carName)
				if not bodyFolderCar then
					continue
				end
				local bodyFolderType = bodyFolderCar:FindFirstChild(partType)
				if not bodyFolderType then
					continue
				end
				local bodyFolderPart = bodyFolderType:FindFirstChild(partName)
				if not bodyFolderPart then
					continue
				end
				local bodyPart = bodyFolderPart:Clone()
				local targetPart = CarBody[partType]:FindFirstChild("CFrame")
				if not targetPart then
					continue
				end
				bodyPart.Parent = CarBody[partType]
				bodyPart:SetPrimaryPartCFrame(targetPart.CFrame)
			end
		end
	end
	-- for paintType, hexCode in pairs(playerCarData.Paint) do
	-- 	ColorModule.Paint(CarBody, paintType, hexCode)
	-- end

	-- 	local CarTuneFolder = clonedCar.Tune.Performance
	-- 	setPerformanceData(playerCarData.Performance.Engine, CarTuneFolder.Engine)
	-- 	setPerformanceData(playerCarData.Performance.Turbo, CarTuneFolder.Turbo)
	-- end
	return clonedCar
end

function GarageModule.ApplyApperanceOnTheCar(carModel)
	local owner = carModel:FindFirstChild("Owner")
	if not owner then
		return
	end
	local player = Players:FindFirstChild(owner.Value)
	if not player then
		return
	end
end

function GarageModule.spawnCar(player: Player, car: Types.Vehicle & { car_id: string })
	if not RunService:IsServer() then
		return
	end
	if not player then
		return
	end
	if not car then
		return
	end

	GarageModule.despawnCar(player) -- Despawn old car

	local garageName = GarageModule.GetPlayerCurrentGarageName(player)
	local garageModel = GarageModule.GetPlayerGarageModel(player)

	local GarageEntryFolder = GarageModule.GetEntryGaragesFolder()
	local entryGarage = GarageEntryFolder:WaitForChild(garageName .. "_Enter")
	local spawnPoint = entryGarage:WaitForChild("SpawnLocation")

	local setupCar = GarageModule.SetupCar(player, car)
	if not setupCar then
		return
	end

	setupCar.Name = player.Name .. "_Vehicle"
	setupCar.Parent = GarageModule.GetCarsFolder()
	setupCar:SetPrimaryPartCFrame(spawnPoint.CFrame * CFrame.new(0, 1, 0))

	-- Add Car Parameters
	local CarId = Instance.new("StringValue")
	CarId.Name = "CarId"
	CarId.Value = car.car_id
	CarId.Parent = setupCar

	local CarOwner = Instance.new("StringValue")
	CarOwner.Name = "CarOwner"
	CarOwner.Value = player.UserId
	CarOwner.Parent = setupCar

	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = player
	ownerValue.Parent = setupCar

	local CarFuel = Instance.new("IntValue")
	CarFuel.Name = "CarFuel"
	CarFuel.Value = car.fuel
	CarFuel.Parent = setupCar

	-- Add player to Car Owners
	local CarOwners = GarageModule.GetCarOwnersFolder()
	if CarOwners then
		local existingOwner = Instance.new("ObjectValue")
		existingOwner.Value = setupCar
		existingOwner.Name = player.Name
		existingOwner.Parent = CarOwners
	end

	-- Add A-Chassis
	local AChassis = GarageModule.GetDriveSystemFolder():WaitForChild("A-Chassis Tune"):Clone()
	AChassis.Parent = setupCar

	-- Make player leave garage
	GarageModule.LeaveGarage(player, garageModel)

	local targetPositionPart = entryGarage:FindFirstChild("TargetPosition")

	local Goal = targetPositionPart.CFrame * CFrame.new(0, 1, 0)
	local Info = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local CF_value = Instance.new("CFrameValue")
	CF_value.Changed:Connect(function(V)
		setupCar:PivotTo(V)
	end)
	CF_value.Value = setupCar:GetPivot()

	local Tween = TweenService:Create(CF_value, Info, { Value = Goal })
	Tween:Play()
end

function GarageModule.despawnCar(player: Player)
	if not RunService:IsServer() then
		return
	end

	local CarOwners = GarageModule.GetCarOwnersFolder()
	if not CarOwners then
		return
	end

	local existingOwner = CarOwners:FindFirstChild(player.Name)
	if existingOwner then
		existingOwner.Value:Destroy()
		existingOwner:Destroy()
	end

	-- Second try to destroy vehicle
	local carsFolder = GarageModule.GetCarsFolder()
	if carsFolder then
		local carModel = carsFolder:FindFirstChild(player.Name .. "_Vehicle")
		if carModel then
			carModel:Destroy()
		end
	end
end

return GarageModule
