local _, addon = ...

local BOGGARD_ID = 170080
local BOGGARD_QUEST = 60739

local function onMouseOver()
	local npcID = addon:GetNPCID('mouseover')
	if npcID == BOGGARD_ID then
		if GetRaidTargetIndex('mouseover') ~= 8 then
			-- the boggard is not already marked with a skull, mark it
			SetRaidTarget('mouseover', 8)
		end
	end
end

local function onQuestRemoved(self, questID)
	if questID == BOGGARD_QUEST then
		-- reset
		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	-- if logging in with the quest already accepted
	if C_QuestLog.IsOnQuest(BOGGARD_QUEST) then
		if not addon:IsEventRegistered('UPDATE_MOUSEOVER_UNIT', onMouseOver) then
			addon:RegisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		end
		if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
			addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
		end
	end
end
