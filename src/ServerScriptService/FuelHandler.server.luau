local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Packet = require(ReplicatedStorage.Packages.Packet)
local ProfileManager = require(ServerScriptService.DataManager.ProfileManager)

local FuelPacket = Packet("UpdateFuel")
local myCar = script.Parent.Parent

FuelPacket.OnServerEvent:Connect(function(player, requestedCar, fueltaken)
	if requestedCar ~= myCar then
		return
	end
	if type(fueltaken) ~= "number" or fueltaken <= 0 then
		return
	end

	local driveSeat = myCar:FindFirstChild("DriveSeat")
	if not driveSeat or driveSeat.Occupant == nil then
		return
	end
	if driveSeat.Occupant.Parent ~= player.Character then
		return
	end

	local carFuel = myCar:FindFirstChild("CarFuel")
	local carIdValue = myCar:FindFirstChild("CarId")
	local carOwnerId = myCar:FindFirstChild("CarOwner")
	if not carFuel or not carIdValue or not carOwnerId then
		return
	end

	carFuel.Value = math.max(0, carFuel.Value - fueltaken)

	local ownerPlayer = Players:GetPlayerByUserId(tonumber(carOwnerId.Value))
	if ownerPlayer then
		local replica = ProfileManager:GetReplica(ownerPlayer)
		if replica then
			replica:Set({ "cars", carIdValue.Value, "fuel" }, carFuel.Value)
		end
	end
end)
