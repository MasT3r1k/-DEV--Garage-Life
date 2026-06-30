local Bodykit = {}

--puts the car element on the car based on the data

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BodyFolder = ReplicatedStorage.Garage.Body
local ColorModule = require(game.ServerStorage.Garage.Modules.Color)
local DataModule = require(game.ServerStorage.Garage.Modules.Data)
local playerData = DataModule.playerData
local paintTypes = {"Primary Paint", "Secondary Paint"}


function Bodykit.Body(player, Car, BodyType, BodyName)
	local CarBody = Car.Body.Model
	local carName = Car.Name
	local bodyPart = BodyFolder[carName][BodyType][BodyName]:Clone()
	local targetPart = CarBody[BodyType]:FindFirstChild("CFrame")
	local playerCarData = playerData[player.UserId][Car.Name]
	for _, paintType in ipairs(paintTypes) do
		local hexCode = playerCarData.Paint[paintType]
		
		ColorModule.Paint(bodyPart, paintType, hexCode) --repaints the element with the Color module
	end

	for _, child in pairs(CarBody[BodyType]:GetChildren()) do
		if child:IsA("Model") and child ~= targetPart then
			child:Destroy()
		end
	end

	bodyPart.Parent = CarBody[BodyType]
	bodyPart:SetPrimaryPartCFrame(targetPart.CFrame)
end

return Bodykit
