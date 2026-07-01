local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ProfileManager = require(ServerScriptService.DataManager.ProfileManager)

local gasEvent = script.Parent
local myCar = gasEvent.Parent

gasEvent.OnServerEvent:Connect(function(player, fueltaken)
	if type(fueltaken) ~= "number" or fueltaken <= 0 then return end
	
	local driveSeat = myCar:FindFirstChild("DriveSeat")
	if not driveSeat or driveSeat.Occupant == nil then return end
	if driveSeat.Occupant.Parent ~= player.Character then return end
	
	local carFuel = myCar:FindFirstChild("CarFuel")
	local carIdValue = myCar:FindFirstChild("CarId")
	local carOwnerId = myCar:FindFirstChild("CarOwner")

	if not carFuel or not carIdValue or not carOwnerId then return end

	-- Snížíme hodnotu na autě (změna se okamžitě replikuje všem klientům okolo)
	carFuel.Value = math.max(0, carFuel.Value - fueltaken)

	-- Uložení do databáze majitele na pozadí
	local ownerPlayer = Players:GetPlayerByUserId(tonumber(carOwnerId.Value))
	if ownerPlayer then
		local replica = ProfileManager:GetReplica(ownerPlayer)
		if replica then
			-- ProfileManager a Replica v autě bezpečně updatují skutečná data
			replica:Set({"cars", carIdValue.Value, "fuel"}, carFuel.Value)
		end
	end
end)
