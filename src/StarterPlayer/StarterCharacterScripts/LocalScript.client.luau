-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Events
local CameraEvent = ReplicatedStorage.Garage.Events.CameraEvent
local TweenEvent = ReplicatedStorage.Garage.Events:WaitForChild("TweenEvent")
local UIetup = ReplicatedStorage.Garage.Events.UISetup

-- Modules
local CameraModule = require(ReplicatedStorage.Garage.Modules.Camera)

-- Tween Information
local tweenInfo = TweenInfo.new(
	7, 
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0, 
	false,
	0
)

-- Garage Door Setup
local GarageFolder = workspace.Garage.System:WaitForChild("GarageDoor")
local Opened = GarageFolder:WaitForChild("Opened") 
local Closed = GarageFolder:WaitForChild("Closed") 
local GarageDoor = GarageFolder:WaitForChild("GarageDoor")

-- Tweens
local openTween = TweenService:Create(GarageDoor, tweenInfo, {
	CFrame = Opened.CFrame,
})
local closeTween = TweenService:Create(GarageDoor, tweenInfo, {
	CFrame = Closed.CFrame,
})

-- Event Listeners
TweenEvent.OnClientEvent:Connect(function(value)
	
	if value == true then
		openTween:Play()
	elseif value == false then
		closeTween:Play()
	end
end)

CameraEvent.OnClientEvent:Connect(function(Subject, Mode)
	if Mode == "Subject" then
	CameraModule.CameraSubject(game.Players.LocalPlayer, Subject)
	elseif Mode == "CameraPos" then
		CameraModule.CaremraPos(game.Players.LocalPlayer, Subject)
	end
end)

