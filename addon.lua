local addonName, addon = ...
addon.mixins = {}

-- constants
addon.NAME = addonName

-- utils

function addon:Unbind()
	ClearOverrideBindings(self)
end

local BUTTON = 'ACTIONBUTTON%d'
function addon:BindAction(actionIndex)
	self:Unbind() -- for good measure
	SetOverrideBinding(self, true, 'SPACE', BUTTON:format(actionIndex))
end

local NPC_ID_PATTERN = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
function addon:GetNPCID(unit)
	if unit and UnitExists(unit) then
		local guid = UnitGUID(unit)
		if guid then
			return (tonumber(guid:match(NPC_ID_PATTERN))), guid
		end
	end
end

function addon:GetPlayerPosition(mapID)
	local playerPosition = C_Map.GetPlayerMapPosition(mapID, 'player')
	return playerPosition:GetXY()
end

function addon:SendNotice(message)
	for _ = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo.RAID_WARNING)
	end
end

function addon.AuraFilterID(a, _, _, _, _, _, _, _, _, _, _, _, b)
	return a == b
end

-- global utils
function table.size(tbl)
	-- would really like Lua 5.2 for this :/
	local size = 0
	for _ in next, tbl do
		size = size + 1
	end
	return size
end
