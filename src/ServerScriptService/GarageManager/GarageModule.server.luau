local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ProfileManager = require(ServerScriptService.DataManager.ProfileManager)
local GarageModule = require(ReplicatedStorage.Services.GarageService)

local DataTemplate = require(ServerScriptService.DataManager.DataTemplate)
local Types = require(ServerScriptService.DataManager.Types)
local Data = require(ServerStorage.Garage.Modules.Data)

local GaragesFolder = workspace:WaitForChild("Garages")

local TELEPORT_COOLDOWN_TIME = 2.5
local teleportingPlayers = {}

-- Změněno na lokální funkci, která se spustí po načtení profilu
local function onPlayerInit(player: Player, profile)
	local data = profile.Data

	local car: Types.Vehicle = {
		vehicle_name = "Nissan Silvia S13",
		body = {
			front_bumper = "Bumper1",
			front_fender = "Fender1",
			headlight = {
				type = "Headlight2",
				color = "#FFFFFF",
			},
			hood = "Hood1",
			rear_bumper = "Bumper1",
			rear_fender = "Fender1",
			skirt = "Skirt1",
			exhaust = "Exhaust1",
			spoiler = "Spoiler2",
			window_tint = 0,
		},
		body_colors = {
			["Primary Paint"] = "#FFFFFF",
			["Secondary Paint"] = "#FFFFFF",
		},
		body_dirty = 0,
		fuel = 100,
		odometer = 0,
		license_plate = "GARAGE",
		engine = {
			engine_type = "",
			transmission = {
				transmission_type = "",
				condition = 100,
				gear_ratios = {},
			},
			oil_quality = 100,
			engine_tolerance = 1,
			installed_parts = {},
			custom_tune = {
				power_limit = 0,
				boost = 0,
				ignition = 0,
				fuel_mix = 0,
				valve_timing = 0,
			},
		},
		active_fault_codes = {},
		ride_height = 0,
		wheels = {},
	}

	GarageModule.spawnGarageModel(player, data.garage)
	GarageModule.addPlayerCar(player, car)
end

Players.PlayerAdded:Connect(function(player: Player)
	task.spawn(function()
		local profile = nil
		while not profile and player.Parent == Players do
			profile = ProfileManager:GetProfile(player)
			if not profile then
				task.wait(0.5)
			end
		end

		if profile then
			ProfileManager:CreateReplica(player, profile)
			onPlayerInit(player, profile)
		end
	end)

	player.CharacterAdded:Connect(function()
		local playerGarage = GarageModule:WaitForGarageLoad(player, 15)
		if playerGarage then
			GarageModule.TeleportPlayerToGarage(player, playerGarage)
		end
	end)
end)

local function setupGarageTeleport(garage)
	if not garage:IsA("Model") then
		return
	end

	local nameValue = garage:WaitForChild("Name")
	local walls = garage:WaitForChild("Walls")
	local garageDoor = walls:WaitForChild("GarageDoor")
	local teleportPart = garageDoor:WaitForChild("Teleport")

	teleportPart.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end

		if teleportingPlayers[player.UserId] then
			return
		end

		local profile = ProfileManager:GetProfile(player)
		if not profile then
			return
		end

		local currentGarage = profile.Data.garage

		if nameValue.Value ~= currentGarage then
			return
		end

		teleportingPlayers[player.UserId] = true

		local playerGarage = GarageModule:WaitForGarageLoad(player, 15)
		if playerGarage then
			GarageModule.TeleportPlayerToGarage(player, playerGarage)
		end

		task.wait(TELEPORT_COOLDOWN_TIME)
		teleportingPlayers[player.UserId] = nil
	end)
end

for _, garage in GaragesFolder:GetChildren() do
	setupGarageTeleport(garage)
end

GaragesFolder.ChildAdded:Connect(setupGarageTeleport)
