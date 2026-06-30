--this module repaints the elements on the car based on the hex color code
local Color = {}

function Color.hexToColor3(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)))
end

function Color.applyPaintToParts(model, paintType, color)
	for _, part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") and part.Name == paintType then
			part.Color = color
		elseif part:IsA("Model") or part:IsA("Folder") then
			Color.applyPaintToParts(part, paintType, color)
		end
	end
end

function Color.Paint(CarBody, paintType, hexCode)
	local color = Color.hexToColor3(hexCode)
	Color.applyPaintToParts(CarBody, paintType, color)
end

return Color
