local Players = game:GetService("Players")
local MaxFuel = 100
local car = script.Parent.Parent

local findfuel = car.DriveSeat.FuelAmount

script.Parent.OnServerEvent:Connect(function(player, fueltaken)
	if fueltaken then
		findfuel.Value = findfuel.Value - fueltaken
	else
		script.Parent:FireClient(player, findfuel.Value)
	end
end)

findfuel.Changed:Connect(function()
	if car.DriveSeat.Occupant then
		script.Parent:FireClient(Players:GetPlayerFromCharacter(car.DriveSeat.Occupant.Parent), findfuel.Value)
	end
end)
