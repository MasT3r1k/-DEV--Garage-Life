local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local StartTemp = 25.0       -- Výchozí teplota studeného motoru (°C)
local TargetTemp = 90.0      -- Provozní teplota, na které se motor ustálí (°C)
local IdleRPM = 1000          -- Otáčky na volnoběh pro výpočet rychlosti ohřevu

local HeatingSpeed = 0.15     -- Základní rychlost ohřevu za sekundu při volnoběhu
local CoolingSpeed = 0.08     -- Rychlost chladnutí za sekundu, když je motor vypnutý

local AC6UI = script.Parent
local center = AC6UI:WaitForChild("Gauges"):WaitForChild("Center")
local bar = center.Temp.Bar;
local IsOn = script.Parent:WaitForChild("IsOn")
local TweenSer = game:GetService("TweenService")


local Car = script.Parent.Car.Value
local RPM = script.Parent.Values.RPM

local CoolantTemp = script.Parent.Values:FindFirstChild("CoolantTemp")
if not CoolantTemp then
	CoolantTemp = Instance.new("NumberValue")
	CoolantTemp.Name = "CoolantTemp"
	CoolantTemp.Value = StartTemp
	CoolantTemp.Parent = script.Parent.Values
end

CoolantTemp.Changed:Connect(function(newTemp)
	local TempText = center.Temp:FindFirstChild("Current")
	if TempText then
		TempText.Text = string.format("%.0f°C", newTemp)
	end
	bar.Size = UDim2.new(.5, 0, math.clamp((newTemp - 50) / (130 - 50), 0, 1) * .94, 0)
	
	if newTemp > 110 then
		TweenSer:Create(bar, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(189, 42, 42)}):Play()
	end

end)

while task.wait(0.5) do
	local currentTemp = CoolantTemp.Value

	if IsOn.Value == true then
		if currentTemp < TargetTemp then
			local rpmFactor = math.max(1, RPM.Value / IdleRPM)
			local tempGain = (HeatingSpeed * rpmFactor) * 0.5 -- 0.5 protože smyčka běží každých 0.5s

			currentTemp = math.min(TargetTemp, currentTemp + tempGain)
		elseif currentTemp > TargetTemp then
			currentTemp = math.max(TargetTemp, currentTemp - (CoolingSpeed * 0.5))
		end
	else
		if currentTemp > StartTemp then
			local tempLoss = CoolingSpeed * 0.5
			currentTemp = math.max(StartTemp, currentTemp - tempLoss)
		end
	end

	CoolantTemp.Value = currentTemp
end