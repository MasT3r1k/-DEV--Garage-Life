-- === NASTAVENÍ SPOTŘEBY ===
local BaseConsumption = 150 --8.0   -- Základní spotřeba pro výpočet (l/100 km)
local EngineMultiplier = 1 -- Násobič motoru (1.0 = standard, 1.5 = silnější)
local IdleRPM = 1000 -- Otáčky na volnoběh
-- ==========================

local MaxFuel = 100
local AC6UI = script.Parent
local center = AC6UI:WaitForChild("Gauges"):WaitForChild("Center")
local IsOn = script.Parent:WaitForChild("IsOn")

local Car = script.Parent.Car.Value
local GasEvent = Car:WaitForChild("GasEvent")
local RPM = script.Parent.Values.RPM
local FuelAmount = Car:WaitForChild("DriveSeat"):WaitForChild("FuelAmount")

local totalFuelConsumed = 0
local totalDistanceKM = 0

GasEvent:FireServer()

GasEvent.OnClientEvent:Connect(function(fuel)
	if IsOn.Value == FuelAmount and fuel > 0 then
		IsOn.Value = true
	end
	FuelAmount.Value = fuel
end)

FuelAmount.Changed:Connect(function()
	local fuelPercent = FuelAmount.Value / MaxFuel

	local fuelColor = Color3.fromRGB(254, 254, 254)
	if fuelPercent <= 0.1499 and fuelPercent >= 0.05 then
		fuelColor = Color3.fromRGB(243, 239, 21)
	elseif fuelPercent < 0.05 then
		fuelColor = Color3.fromRGB(189, 42, 42)
	end

	print(fuelPercent)

	center.Fuel.Needle.N1.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, fuelColor),
		ColorSequenceKeypoint.new(math.min(fuelPercent - 0.001, 1), fuelColor),
		ColorSequenceKeypoint.new(math.min(fuelPercent + 0.001, 1), Color3.fromRGB(1, 37, 58)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 37, 58)),
	})
end)

while task.wait(0.4) do
	if FuelAmount.Value <= 1 then
		IsOn.Value = false
		script.Parent.Values.Throttle.Value = 0
	elseif FuelAmount.Value >= 1 then
		local speedKMH = Car.DriveSeat.Velocity.Magnitude / 1.799
		if speedKMH < 1 then
			speedKMH = 0
		end

		local stepDistanceKM = (speedKMH / 3600) * 0.4
		totalDistanceKM = totalDistanceKM + stepDistanceKM

		local rpmFactor = (RPM.Value / IdleRPM)
		local currentL100KM = BaseConsumption * rpmFactor * EngineMultiplier

		if speedKMH < 5 then
			currentL100KM = BaseConsumption * 0.5 -- Volnoběh
		end

		local fueltaken = (currentL100KM / 100) * stepDistanceKM

		if speedKMH == 0 and IsOn.Value == true and script.Parent.Values.Throttle.Value > 0 then
			fueltaken = (BaseConsumption * EngineMultiplier * 0.001) * 0.4
		end

		if fueltaken > 0 then
			totalFuelConsumed = totalFuelConsumed + fueltaken
			GasEvent:FireServer(fueltaken)
		end

		local averageL100KM = 0

		if totalDistanceKM > 0.001 then
			averageL100KM = (totalFuelConsumed / totalDistanceKM) * 100
		else
			averageL100KM = BaseConsumption * EngineMultiplier
		end

		-- center.Fuel.Average.Text = "∅ " .. string.format("%.1f", averageL100KM)
	end
end
