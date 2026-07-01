local car = script.Parent.Parent -- Skript je teď přímo v autě, takže Parent je samotné auto
local driveSeat = car:WaitForChild("DriveSeat") :: VehicleSeat

-- Počkáme chvíli, než se auto usadí na mapě
task.wait(0.3)

-- Najdeme hodnotu Owner, kterou tam vkládá tvůj spawn systém
local ownerValue = car:FindFirstChild("Owner")

if ownerValue then
	-- Pokud se stane, že se hodnota ještě nestihla zapsat, chvíli počkáme
	if not ownerValue.Value then
		ownerValue:GetPropertyChangedSignal("Value"):Wait()
	end

	local player = ownerValue.Value
	if player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 and not driveSeat.Occupant then
			-- Posadíme hráče
			driveSeat:Sit(humanoid)
		end
	end
else
	warn("AutoSit Error: V kořenu auta nebyl nalezen objekt 'Owner'!")
end
