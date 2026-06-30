local ServerScriptService = game:GetService("ServerScriptService")

local Replica = require(ServerScriptService.ReplicaServer)

local ProfileManager = {}
ProfileManager.Profiles = {}
ProfileManager.Replicas = {}

local PlayerProfileToken = Replica.Token("PlayerProfile")

function ProfileManager:GetProfile(player)
	while not self.Profiles[player] and player.Parent do
		task.wait()
	end
	return self.Profiles[player]
end

function ProfileManager:GetReplica(player)
	while not self.Replicas[player] and player.Parent do
		task.wait()
	end
	return self.Replicas[player]
end

-- Tuto funkci zavoláš v hlavním skriptu po bezpečném načtení profilu
function ProfileManager:CreateReplica(player, profile)
	local replica = Replica.New({
		Token = PlayerProfileToken,
		Tags = { Player = player },
		Data = profile.Data,
	})

	-- Subscribe player to replica
	replica:Subscribe(player)

	self.Replicas[player] = replica

	replica:AddCleanupTask(function()
		self.Replicas[player] = nil
	end)

	return replica
end

return ProfileManager
