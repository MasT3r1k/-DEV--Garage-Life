--creates the ui based on the car configuration

local TemplateUIcreater = {}

local TemplateFrame = game.ReplicatedStorage.Garage.TemplateFrame

local function padNumber(number)
	return string.format("%02d", number)
end

local function addStringValues(button, category, partName, Type)
	local categoryValue = Instance.new("StringValue")
	categoryValue.Name = "Category"
	categoryValue.Value = category
	categoryValue.Parent = button

	local nameValue = Instance.new("StringValue")
	nameValue.Name = "PartName"
	nameValue.Value = partName
	nameValue.Parent = button
	local TypeValue = Instance.new("StringValue")
	TypeValue.Name = "Type"
	TypeValue.Value = Type
	TypeValue.Parent = button
end

function TemplateUIcreater.CreateUIBody(player, Car)
	local Configuration = require(game.ReplicatedStorage.Garage.Configurations:FindFirstChild(Car))
	local scrollingframesframe = player.PlayerGui.Garage.Main.Tuning["Tuning Frame2"]["Tuning Frame"].Body 

	for category, parts in pairs(Configuration.Tune.BodyKit) do

		local categoryFrame = scrollingframesframe:FindFirstChild(category)
		if categoryFrame then
			local scrollingFrame = categoryFrame
			if scrollingFrame then

				local uiListLayout = Instance.new("UIListLayout")
				uiListLayout.SortOrder = Enum.SortOrder.Name
				uiListLayout.Parent = scrollingFrame

				for partName, partInfo in pairs(parts) do
					local newItem = TemplateFrame:Clone()
					newItem.Name = partName
					newItem.Text = partName
					newItem.Parent = scrollingFrame
					local Type = "Body"

					addStringValues(newItem, category, partName, Type)
				end
			end
		end
	end
end


function TemplateUIcreater.CreateUIPerformance(player, Car)
	local Configuration = require(game.ReplicatedStorage.Garage.Configurations:FindFirstChild(Car))
	local scrollingframesframe = player.PlayerGui.Garage.Main.Tuning["Tuning Frame2"]["Tuning Frame"].Performance 

	for category, parts in pairs(Configuration.Tune.PerformanceTuning) do

		local categoryFrame = scrollingframesframe:FindFirstChild(category)
		if categoryFrame then
			local scrollingFrame = categoryFrame
			if scrollingFrame then

				local uiListLayout = Instance.new("UIListLayout")
				uiListLayout.SortOrder = Enum.SortOrder.Name
				uiListLayout.Parent = scrollingFrame

				for partName, partInfo in pairs(parts) do
					local newItem = TemplateFrame:Clone()
					newItem.Name = padNumber(tonumber(partName:match("%d+"))) .. partName:match("%D+")
					newItem.Text = partName
					newItem.Parent = scrollingFrame
					local Type = "PerformanceTuning"
					addStringValues(newItem, category, partName, Type)
				end
			end
		end
	end
end



function TemplateUIcreater.CreateUIPaint(player, Car)
	local Configuration = require(game.ReplicatedStorage.Garage.Configurations:FindFirstChild(Car))
	local scrollingframesframe = player.PlayerGui.Garage.Main.Tuning["Tuning Frame2"]["Tuning Frame"].Paint

	
	local primaryPaintFrame = scrollingframesframe:FindFirstChild("Primary Paint")
	if primaryPaintFrame then
		local primaryScrollingFrame = primaryPaintFrame
		if primaryScrollingFrame then
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.SortOrder = Enum.SortOrder.Name
			uiListLayout.Parent = primaryScrollingFrame

			for paintName, paintInfo in pairs(Configuration.Tune.Paint) do
				local newItem = TemplateFrame:Clone()
				newItem.Name = paintName
				newItem.Text = paintName
				newItem.Parent = primaryScrollingFrame

				local category = "Primary Paint"
				local Type = "Paint"
				addStringValues(newItem, category, paintName, Type)
			end
		end
	end

	
	local secondaryPaintFrame = scrollingframesframe:FindFirstChild("Secondary Paint")
	if secondaryPaintFrame then
		local secondaryScrollingFrame = secondaryPaintFrame
		if secondaryScrollingFrame then
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.SortOrder = Enum.SortOrder.Name
			uiListLayout.Parent = secondaryScrollingFrame

			for paintName, paintInfo in pairs(Configuration.Tune.Paint) do
				local newItem = TemplateFrame:Clone()
				newItem.Name = paintName
				newItem.Text = paintName
				newItem.Parent = secondaryScrollingFrame
				local category = "Secondary Paint"
				local Type = "Paint"
				addStringValues(newItem, category, paintName, Type)
			end
		end
	end
end

return TemplateUIcreater
