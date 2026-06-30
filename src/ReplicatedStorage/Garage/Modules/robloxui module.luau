--deactivate the basic roblox ui (for example: Leaderboard, backpack, chat)

local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local UIController = {}
UIController.Enabled = true

function UIController:SetUIEnabled(enabled)
	self.Enabled = enabled
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, enabled)
end


return UIController
