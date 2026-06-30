local CollectionService = game:GetService("CollectionService")

return function(model: Model, tagName: string)
	local allTaggedParts = CollectionService:GetTagged(tagName)
	local targetParts = {}

	for _, taggedPart in ipairs(allTaggedParts) do
		if taggedPart:IsDescendantOf(model) and taggedPart:IsA("BasePart") then
			table.insert(targetParts, taggedPart)
		end
	end

	return targetParts
end
