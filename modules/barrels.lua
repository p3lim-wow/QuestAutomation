local _, addon = ...

local BARREL_ID = 115947
local BARREL_ROUND_SPELL = 230884
local QUESTS = {
	[45068] = true,
	[45069] = true,
	[45070] = true,
	[45071] = true,
	[45072] = true,
}

local barrels = {}
local function onMouseOver(self)
	local npcID, guid = addon:GetUnitNPCID('mouseover')
	if npcID == BARREL_ID then
		-- only mark new barrels, keeping existing marks
		if not barrels[guid] then
			-- calculate next raid target icon and store it
			local index = (addon.tsize(barrels) % 8) + 1
			barrels[guid] = index

			-- if the barrel isn't already marked, mark it
			if GetRaidTargetIndex('mouseover') ~= index then
				SetRaidTarget('mouseover', index)
			end
		end
	end
end

local function onFinish(self, questID)
	if QUESTS[questID] then
		-- reset
		table.wipe(barrels)
		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		return true
	end
end

function addon:UPDATE_OVERRIDE_ACTIONBAR()
	-- when accepting the quest the player enters a vehicle, and this fires for every new round
	if HasExtraActionBar() then
		local _, spellID = GetActionInfo(_G.ExtraActionButton1.action)
		if spellID ==  BARREL_ROUND_SPELL then
			self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
			self:RegisterEvent('QUEST_REMOVED', onFinish)
		end
	end
end
