local ScreenGui = script.Parent.Parent.Garage

local function onHover(button)
	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(
			button,
			TweenInfo.new(0.5), 
			{BackgroundColor3 = Color3.new(1, 1, 1), TextColor3 = Color3.new(0.0509804, 0.0509804, 0.0509804)}
		):Play()
	end)
	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(
			button,
			TweenInfo.new(0.5), 
			{BackgroundColor3 = Color3.new(0.0509804, 0.0509804, 0.0509804), TextColor3 = Color3.new(1, 1, 1)}
		):Play()
	end)
end

-- Apply hover effect to existing buttons
for _, button in pairs(ScreenGui:GetDescendants()) do
	if button:IsA("TextButton") then
		onHover(button)
	end
end

-- Listen for new buttons being added
ScreenGui.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("TextButton") then
		onHover(descendant)
	end
end)
