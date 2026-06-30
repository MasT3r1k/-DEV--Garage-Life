local prompt = script.Parent.ProximityPrompt
local Event = game.ReplicatedStorage.Garage.Events.UI

prompt.Triggered:Connect(function(player)
	local UI = "VehicleSpawner"
	Event:FireClient(player, UI)
end)
