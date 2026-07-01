local BaseConsumption = 150 -- 8.0 (l/100 km)
local EngineMultiplier = 1
local IdleRPM = 1000
local MaxFuel = 10

local AC6UI = script.Parent
local center = AC6UI:WaitForChild("Gauges"):WaitForChild("Center")
local IsOn = script.Parent:WaitForChild("IsOn")

local Car = script.Parent.Car.Value
local RPM = script.Parent.Values.RPM

local FuelAmount = Car:WaitForChild("CarFuel") 
local GasEvent = Car:WaitForChild("GasEvent")

local totalFuelConsumed = 0
local totalDistanceKM = 0

local function UpdateFuelGUI()
	local fuelPercent = FuelAmount.Value / MaxFuel

	local fuelColor = Color3.fromRGB(254, 254, 254)
	if fuelPercent <= 0.1499 and fuelPercent >= 0.05 then
		fuelColor = Color3.fromRGB(243, 239, 21)
	elseif fuelPercent < 0.05 then
		fuelColor = Color3.fromRGB(189, 42, 42)
	end

	center.Fuel.Needle.N1.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, fuelColor),
		ColorSequenceKeypoint.new(math.min(fuelPercent - 0.001, 1), fuelColor),
		ColorSequenceKeypoint.new(math.min(fuelPercent + 0.001, 1), Color3.fromRGB(1, 37, 58)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 37, 58)),
	})
end

FuelAmount.Changed:Connect(UpdateFuelGUI)
UpdateFuelGUI() -- Prvotní načtení GUI

while task.wait(0.4) do
	if FuelAmount.Value <= 0.5 then
		IsOn.Value = false
		script.Parent.Values.Throttle.Value = 0
	elseif FuelAmount.Value > 0.5 then
		IsOn.Value = true
		
		local speedKMH = Car.DriveSeat.Velocity.Magnitude / 1.799
		if speedKMH < 1 then speedKMH = 0 end

		local stepDistanceKM = (speedKMH / 3600) * 0.4
		totalDistanceKM = totalDistanceKM + stepDistanceKM

		local rpmFactor = (RPM.Value / IdleRPM)
		local currentL100KM = BaseConsumption * rpmFactor * EngineMultiplier

		if speedKMH < 5 then
			currentL100KM = BaseConsumption * 0.5
		end

		local fueltaken = (currentL100KM / 100) * stepDistanceKM

		if speedKMH == 0 and IsOn.Value == true and script.Parent.Values.Throttle.Value > 0 then
			fueltaken = (BaseConsumption * EngineMultiplier * 0.001) * 0.4
		end

		if fueltaken > 0 then
			totalFuelConsumed = totalFuelConsumed + fueltaken
			GasEvent:FireServer(fueltaken)
		end
	end
end
