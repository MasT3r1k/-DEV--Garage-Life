local button = script.Parent
local event = game.ReplicatedStorage.Garage.Events.Spawn
local CarValue = script.Parent.Car.Value
local SpawnPos = workspace:WaitForChild("SpawnPos")

button.MouseButton1Click:Connect(function()
	event:FireServer(CarValue, SpawnPos)
end)
