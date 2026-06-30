local CollectionService = game:GetService("CollectionService")

return function(model: Model, tagName: string)
	local allTaggedParts = CollectionService:GetTagged(tagName)

	for _, taggedPart in ipairs(allTaggedParts) do
		if taggedPart:IsDescendantOf(model) and taggedPart:IsA("BasePart") then
			return taggedPart
		end
	end

	return nil
end
