local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuration
local FuelDepletionRate = 0.05 -- Palivo ztracené za sekundu při volnoběhu
local DrivingMultiplier = 3 -- Multiplikátor spotřeby, když auto jede (RPM > 1000)

-- Track vehicles
local activeCars = {}

local function setupCar(car)
	-- Bezpečné načtení A-Chassis Tune
	local tuneModule = car:WaitForChild("A-Chassis Tune", 5)
	if not tuneModule then
		return
	end

	local tune = require(tuneModule)
	local driveSeat = car:WaitForChild("DriveSeat", 5)
	local interface = tuneModule:WaitForChild("A-Chassis Interface", 5)

	if not driveSeat or not interface then
		return
	end

	local valuesFolder = interface:WaitForChild("Values", 5)
	if not valuesFolder then
		return
	end

	-- Inicializace hodnot paliva v autě
	local fuelVal = Instance.new("NumberValue")
	fuelVal.Name = "Fuel"
	fuelVal.Value = 100
	fuelVal.Parent = car

	local maxFuelVal = Instance.new("NumberValue")
	maxFuelVal.Name = "MaxFuel"
	maxFuelVal.Value = 100
	maxFuelVal.Parent = car

	-- Uložíme si odkazy, abychom je nemuseli v loopu stále hledat přes WaitForChild
	activeCars[car] = {
		DriveSeat = driveSeat,
		Values = valuesFolder,
		Fuel = fuelVal,
		MaxFuel = maxFuelVal,
	}
end

-- Detekce nově spawnutých A-Chassis aut
workspace.DescendantAdded:Connect(function(descendant)
	if
		descendant:IsA("Model")
		and descendant:FindFirstChild("A-Chassis Tune")
		and descendant:FindFirstChild("DriveSeat")
	then
		setupCar(descendant)
	end
end)

-- Kontrola již existujících aut při spuštění hry
for _, descendant in ipairs(workspace:GetDescendants()) do
	if
		descendant:IsA("Model")
		and descendant:FindFirstChild("A-Chassis Tune")
		and descendant:FindFirstChild("DriveSeat")
	then
		setupCar(descendant)
	end
end

-- Zpracování spotřeby paliva (Heartbeat/Stepped)
RunService.Heartbeat:Connect(function(deltaTime)
	for car, data in pairs(activeCars) do
		if not car or not car.Parent then
			activeCars[car] = nil
			continue
		end

		local driveSeat = data.DriveSeat
		local occupant = driveSeat.Occupant

		if not occupant or not occupant:IsA("Humanoid") then
			continue
		end

		local player = Players:GetPlayerFromCharacter(occupant.Parent)
		if not player then
			continue
		end

		local engineVal = data:FindFirstChild("IsOn")
		local rpmVal = data.Values:FindFirstChild("RPM")

		local isEngineOn = engineVal and engineVal.Value
		local rpm = rpmVal and rpmVal.Value or 0

		if isEngineOn and data.Fuel.Value > 0 then
			local speedMultiplier = (rpm > 1000) and DrivingMultiplier or 1

			local fuelToDrain = FuelDepletionRate * speedMultiplier * deltaTime
			data.Fuel.Value = math.max(0, data.Fuel.Value - fuelToDrain)
		elseif isEngineOn and data.Fuel.Value <= 0 then
			if engineVal then
				engineVal.Value = false
			end
		end
	end
end)
