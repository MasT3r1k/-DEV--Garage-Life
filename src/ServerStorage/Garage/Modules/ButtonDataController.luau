--this module checks which part of the car you want to modify based on the data of the textbutton

local ButtonDataConverter = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Configuration = ReplicatedStorage.Garage.Configurations
local CarOwners = ServerStorage.Garage["Car Owners"]
local ColorModule = require(ServerStorage.Garage.Modules.Color)
local CarTuneModule = require(ServerStorage.Garage.Modules.CarTune)
local GarageSetup = require(ServerStorage.Garage.Modules.GarageSetup)
local Bodykit = require(ServerStorage.Garage.Modules.Bodykit)
local GarageCar = workspace.Garage.System.GarageCar



local cooldowns = {}


local function getCar(CarName)
	return GarageCar:FindFirstChild(CarName)
end


function ButtonDataConverter.Data(player, Type, PartName, Category)
	local CarName = GarageSetup.CarData
	local Car = getCar(CarName)
	local currentTime = tick()
	if cooldowns[player.UserId] and currentTime - cooldowns[player.UserId] < 1 then
		return 
	end
	cooldowns[player.UserId] = currentTime

	local CarConf = require(Configuration:FindFirstChild(Car.Name))

	if Type == "Paint" then
		local hexCode = CarConf.Tune[Type][PartName].HexCode
		local CarBody = Car.Body.Model
		local paintType = Category
		ColorModule.Paint(CarBody, paintType, hexCode)--recolors the entire car based on the hexCode
		CarTuneModule.Color(player, Car, paintType, hexCode)--rewrites the hex code into the data table (this data will be saved when the player exits)
	elseif Type == "PerformanceTuning" then
		local PerformanceValues = CarConf.Tune[Type][Category][PartName].Values
		local PerformanceType = Category
		CarTuneModule.Performance(player, Car, PerformanceType, PerformanceValues) --rewrites the value of the car's engine or turbo in the data table(this data will be saved when the player exits)
	elseif Type == "Body" then
		local BodyType = Category
		local BodyName = PartName
		CarTuneModule.Body(player, Car, BodyType, BodyName)--places the car element on the car
		Bodykit.Body(player, Car, BodyType, BodyName)--rewrites the name of the car element in the Data table(this data will be saved when the player exits)

	end
end

return ButtonDataConverter
