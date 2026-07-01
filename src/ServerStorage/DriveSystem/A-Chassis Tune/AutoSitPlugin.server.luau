local car = script.Parent.Parent
local driveSeat = car:WaitForChild("DriveSeat") :: VehicleSeat

task.wait(0.3)

local ownerValue = car:FindFirstChild("Owner")

if ownerValue then
	if not ownerValue.Value then
		ownerValue:GetPropertyChangedSignal("Value"):Wait()
	end

	local player = ownerValue.Value
	if player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 and not driveSeat.Occupant then
			driveSeat:Sit(humanoid)
			task.wait(2)
			driveSeat.Disabled = true
			task.wait()
			driveSeat.Disabled = false
			task.wait(2)
			driveSeat:Sit(humanoid)
		end
	end
else
	warn("AutoSit Error: V kořenu auta nebyl nalezen objekt 'Owner'!")
end
