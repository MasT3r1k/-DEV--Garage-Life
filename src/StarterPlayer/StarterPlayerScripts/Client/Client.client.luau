local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replica = require(ReplicatedStorage.ReplicaClient)

Replica.OnNew("PlayerProfile", function(replica)
	replica:OnSet({ "garage" }, function(newGarageName, oldGarageName) end)

	replica:OnChange(function(changeType, path, value)
		-- path[1] je hlavní klíč (např. "garage_slots")
		if path[1] == "garage_slots" and changeType == "TableInsert" then
			print("Do inventáře bylo přidáno nové auto:", value)
		end
	end)
end)

Replica.RequestData()
