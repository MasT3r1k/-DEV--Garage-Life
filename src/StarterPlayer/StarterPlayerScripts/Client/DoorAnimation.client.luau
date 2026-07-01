local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replica = require(ReplicatedStorage.ReplicaClient)
local ZonePlus = require(ReplicatedStorage.Packages.ZonePlus)

local currentGarage = nil

Replica.OnNew("PlayerProfile", function(replica)
	currentGarage = replica.Data.garage

	replica:OnSet({ "garage" }, function(new_garage, old_garage)
		currentGarage = new_garage
	end)
end)

-- Door options
local slideDistance = 5.5
local rotationAngle = 80
local speed = 1.5

local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenTrack = nil

function setupGarageDoor(door)
	local model = door.Parent
	local sensor = model:WaitForChild("Sensor")
	local garage_name = model.Parent.Parent:FindFirstChild("Name").Value
	local DoorZone = ZonePlus.new(sensor)

	local closedCFrame = door.CFrame
	local openCFrame = closedCFrame * CFrame.new(0, slideDistance, 0) * CFrame.Angles(math.rad(rotationAngle), 0, 0)

	if currentGarage == garage_name then
		door.CanCollide = true
	end

	DoorZone.localPlayerEntered:Connect(function()
		if currentGarage ~= garage_name then
			return
		end

		if tweenTrack then
			tweenTrack:Cancel()
		end

		tweenTrack = TweenService:Create(door, tweenInfo, { CFrame = openCFrame })
		tweenTrack:Play()
	end)

	DoorZone.localPlayerExited:Connect(function()
		if currentGarage ~= garage_name then
			return
		end

		if tweenTrack then
			tweenTrack:Cancel()
		end

		tweenTrack = TweenService:Create(door, tweenInfo, { CFrame = closedCFrame })
		tweenTrack:Play()
	end)
end

local garage_doors = CollectionService:GetTagged("GarageDoor")
for _, door in garage_doors do
	setupGarageDoor(door)
end

CollectionService:GetInstanceAddedSignal("GarageDoor"):Connect(function(door)
	setupGarageDoor(door)
end)
