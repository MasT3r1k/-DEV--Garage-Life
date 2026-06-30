return function(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			obj:Destroy()
		end
	end
end
