local addonName, addon = ...
addon.mixins = {}

-- constants
addon.NAME = addonName

-- utils

local isBound
local bindParent = CreateFrame('Frame')
function addon:Unbind()
	ClearOverrideBindings(bindParent)
	isBound = false
end

local BUTTON = 'ACTIONBUTTON%d'
function addon:BindAction(actionIndex)
	self:Unbind() -- for good measure
	SetOverrideBinding(bindParent, true, 'SPACE', BUTTON:format(actionIndex))
	isBound = true
end

function addon:IsBound()
	return not not isBound
end

local NPC_ID_PATTERN = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
function addon:GetGUIDNPCID(guid)
	return (tonumber((guid or ''):match(NPC_ID_PATTERN)))
end

function addon:GetUnitNPCID(unit)
	if unit and UnitExists(unit) then
		local guid = UnitGUID(unit)
		if guid then
			return addon:GetGUIDNPCID(guid), guid
		end
	end
end

function addon:GetPlayerPosition(mapID)
	local playerPosition = C_Map.GetPlayerMapPosition(mapID, 'player')
	return playerPosition and playerPosition:GetXY()
end

function addon:SendNotice(message)
	for _ = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo.RAID_WARNING)
	end
end

do
	local function helper(unit, predicate, token, ...)
		local slot, _, spellID
		for index = 1, select('#', ...) do
			slot = select(index, ...)
			_, _, _, _, _, _, _, _, _, spellID = UnitAuraBySlot(unit, slot)
			if predicate == spellID then
				return nil, slot
			end
		end

		return token
	end

	function addon:GetAuraBySpellID(unit, spellID, filter)
		if unit == 'player' and not filter then
			return GetPlayerAuraBySpellID(spellID)
		end
		if not filter then
			error('GetAuraBySpellID requires a filter')
			return
		end

		local token, slot
		repeat
			token, slot = helper(unit, spellID, UnitAuraSlots(unit, filter, nil, token))
		until token == nil

		if slot then
			return UnitAuraBySlot(unit, slot)
		end
	end
end

-- global utils
function addon.tsize(tbl)
	-- would really like Lua 5.2 for this :/
	local size = 0
	for _ in next, tbl do
		size = size + 1
	end
	return size
end
