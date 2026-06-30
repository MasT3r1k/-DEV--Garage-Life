local Main = script.Parent.Main
local Loading = script.Parent.Parent.Loading.Loading
local SelectFrame = Main.Tuning["Tuning Frame2"]["Tuning Frame"].Select
local ScrollingFrames = Main.Tuning["Tuning Frame2"]["Tuning Frame"].ScrollingFrames
local Bodyframe = Main.Tuning["Tuning Frame2"]["Tuning Frame"].Body
local Paintframe = Main.Tuning["Tuning Frame2"]["Tuning Frame"].Paint
local Performance = Main.Tuning["Tuning Frame2"]["Tuning Frame"].Performance
local TuningFrame = Main.Tuning["Tuning Frame2"]["Tuning Frame"]
local TuningFrame2 = Main.Tuning["Tuning Frame2"]
local Exitframe = Main.Tuning.Exitframe
local SelectTextlabel = Exitframe.TextLabel
local Exit = Exitframe.Exit
local UIEvent = game.ReplicatedStorage.Garage.Events.UI
local UISetupEvent = game.ReplicatedStorage.Garage.Events.UISetup
local ExitEvent = game.ReplicatedStorage.Garage.Events.Exit
local TweenService = game:GetService("TweenService")
local ButtonDataEvent = game.ReplicatedStorage.Garage.Events.ButtonData
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ExitButton = Main.CarSpawn.Frame.Exit
local robloxuimodule = require(game.ReplicatedStorage.Garage.Modules["robloxui module"])

local function resizeAndShowScrollingFrame(Goal, showFrames)
	local screenSize = workspace.CurrentCamera.ViewportSize
	local currentSize = TuningFrame2.Size
	local goalSize = UDim2.new(currentSize.X.Scale, currentSize.X.Offset, Goal.Y.Scale, Goal.Y.Offset * screenSize.Y / 1080)

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local goal = { Size = goalSize }
	local tween = TweenService:Create(TuningFrame2, tweenInfo, goal)
	tween:Play()
	tween.Completed:Connect(function()
		if showFrames then
			for _, frame in pairs(ScrollingFrames:GetChildren()) do
				if not frame:IsA("UIAspectRatioConstraint") then
					frame.Visible = frame.Name == SelectTextlabel.Text
				end
			end
		end
	end)
end


local function onButtonClick(button)
	SelectFrame.Visible = false
	for _, frame in pairs(ScrollingFrames:GetChildren()) do
		if not frame:IsA("UIAspectRatioConstraint") then
			frame.Visible = frame.Name == button.Name
		end
	end
	SelectTextlabel.Text = button.Name
	Exit.Text = SelectFrame.Visible and "⬅ Exit" or "⬅ Back"
end


for _, button in pairs(SelectFrame:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			onButtonClick(button)
			local Goal = UDim2.new(0, 337, 0, 443)
			resizeAndShowScrollingFrame(Goal, true)
		end)
	end
end

Exit.MouseButton1Click:Connect(function()
	if Exit.Text == "⬅ Exit" then
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		local Cam = workspace.CurrentCamera
		Loading.Visible = true
		Main.Tuning.Visible = false
		Cam.CameraSubject = humanoid
		ExitEvent:FireServer()
		wait(5)
		robloxuimodule:SetUIEnabled(true)
		Cam.CameraSubject = humanoid
		Loading.Visible = false
	
	else
		local bodyVisible, performanceVisible, PaintVisible = false, false, false

		for _, frame in pairs(Bodyframe:GetChildren()) do
			if frame:IsA("ScrollingFrame") and frame.Visible then
				frame.Visible = false
				bodyVisible = true
				ScrollingFrames["Exterior Modification"].Visible = true
			end
		end

		for _, frame in pairs(Performance:GetChildren()) do
			if frame:IsA("ScrollingFrame") and frame.Visible then
				frame.Visible = false
				performanceVisible = true
				ScrollingFrames["Performance Tuning"].Visible = true
			end
		end

		for _, frame in pairs(Paintframe:GetChildren()) do
			if frame:IsA("ScrollingFrame") and frame.Visible then
				frame.Visible = false
				PaintVisible = true
				ScrollingFrames["Paint"].Visible = true
			end
		end

		if not bodyVisible and not performanceVisible and not PaintVisible then
			for _, frame in pairs(ScrollingFrames:GetChildren()) do
				if frame:IsA("ScrollingFrame") then
					frame.Visible = false
					SelectFrame.Visible = true
					Exit.Text = "⬅ Exit"
					local Goal = UDim2.new(0, 337, 0, 201)
					resizeAndShowScrollingFrame(Goal, false)
				end
			end
		end
	end
end)

UIEvent.OnClientEvent:Connect(function(UI, message)
	if UI == "GarageError" then
		local GarageError = Main["Garage error"]
		local TextLabel = GarageError.Frame.TextLabel
		TextLabel.Text = message
		GarageError.Visible = not GarageError.Visible
	elseif UI == "VehicleSpawner" then
		local VehicleSpawner = Main.CarSpawn
		VehicleSpawner.Visible = true
	end
end)


UISetupEvent.OnClientEvent:Connect(function(CarName)
	Loading.Visible = true
	robloxuimodule:SetUIEnabled(false)
	wait(5)
	Loading.Visible = false
	Main.Tuning.Visible = true
	Main.Tuning.CarName.Text = CarName
end)

local function setupScrollFrame(scrollFrame, bodyFrame)
	for _, button in pairs(scrollFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Click:Connect(function()
				for _, frame in pairs(bodyFrame:GetChildren()) do
					if frame:IsA("ScrollingFrame") then
						scrollFrame.Visible = false
						frame.Visible = (frame.Name == button.Name)
					end
				end
			end)
		end
	end
end

setupScrollFrame(Main.Tuning["Tuning Frame2"]["Tuning Frame"].ScrollingFrames["Exterior Modification"], Main.Tuning["Tuning Frame2"]["Tuning Frame"].Body)
setupScrollFrame(Main.Tuning["Tuning Frame2"]["Tuning Frame"].ScrollingFrames["Performance Tuning"], Main.Tuning["Tuning Frame2"]["Tuning Frame"].Performance)
setupScrollFrame(Main.Tuning["Tuning Frame2"]["Tuning Frame"].ScrollingFrames["Paint"], Main.Tuning["Tuning Frame2"]["Tuning Frame"].Paint)


local function onButtonClicked(button)
	button.MouseButton1Click:Connect(function()
		local Type = button.Type.Value
		local PartName = button.PartName.Value
		local Category = button.Category.Value
		ButtonDataEvent:FireServer(Type, PartName, Category)
	end)
end

local function setupButtonsInScrollingFrame(scrollingFrame)
	for _, button in pairs(scrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			onButtonClicked(button)
		end
	end

	scrollingFrame.ChildAdded:Connect(function(child)
		if child:IsA("TextButton") then
			onButtonClicked(child)
		end
	end)
end

local function setupButtonsInFrame(frame)
	for _, scrollingFrame in pairs(frame:GetChildren()) do
		if scrollingFrame:IsA("ScrollingFrame") then
			setupButtonsInScrollingFrame(scrollingFrame)
		end
	end
end

setupButtonsInFrame(Bodyframe)
setupButtonsInFrame(Paintframe)
setupButtonsInFrame(Performance)


ExitButton.MouseButton1Click:Connect(function()
	Main.CarSpawn.Visible = false
end)

