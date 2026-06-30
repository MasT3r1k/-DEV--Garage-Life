local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local ProfileManager = require(ServerScriptService.DataManager.ProfileManager)
local template = require(ServerScriptService.DataManager.DataTemplate)

local PlayerStore = ProfileStore.New("PlayerStore", template)

local function PlayerAdded(player)
	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from Template

		profile.OnSessionEnd:Connect(function()
			ProfileManager.Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			ProfileManager.Profiles[player] = profile
		else
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

-- In case Players have joined the server earlier than this script ran:
for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = ProfileManager.Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end)
