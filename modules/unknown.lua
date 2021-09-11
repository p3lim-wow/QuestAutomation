local _, addon = ...
local L = addon.L

local UNKNOWN_QUEST = 62453 -- Into the Unknown
local VERSE_NPC = 174365
local JUICE_NPC = 174371
local JUICE_ITEM = 183961
local GUESS_NPC = 174498 -- the correct version of Shimmersod

local gormJuiceStage = 0
function addon:GOSSIP_SHOW()
	if IsShiftKeyDown() then
		-- a way to hard-prevent the automation
		return
	end

	local npcID = self:GetNPCID('npc')
	if npcID == VERSE_NPC then
		-- the player needs to guess the correct word in a sentence, it's a fixed pattern,
		-- and it can be brute-forced by always selecting option 2
		if C_GossipInfo.GetNumOptions() == 1 then
			C_GossipInfo.SelectOption(1)
		else
			C_GossipInfo.SelectOption(2)
		end
	elseif npcID == JUICE_NPC then
		if GetItemCount(JUICE_ITEM) == 0 then
			if gormJuiceStage == 0 then -- no spammy
				self:SendNotice(L['Click Squeezums first'])
			end
		else
			gormJuiceStage = gormJuiceStage + 1
			if gormJuiceStage == 1 then
				C_GossipInfo.SelectOption(2)
			elseif gormJuiceStage == 2 then
				C_GossipInfo.SelectOption(5)
			end
		end
	elseif npcID == GUESS_NPC then
		C_GossipInfo.SelectOption(3)
	end
end

-- don't really need to mark the correct version, but it's handy
local function onMouseOver()
	local npcID = addon:GetNPCID('mouseover')
	if npcID == GUESS_NPC then
		if GetRaidTargetIndex('mouseover') ~= 8 then
			SetRaidTarget('mouseover', 8)
		end
	end
end

local function onQuestRemoved(self, questID)
	if questID == UNKNOWN_QUEST then
		-- reset
		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	if C_QuestLog.IsOnQuest(UNKNOWN_QUEST) then
		if not addon:IsEventRegistered('UPDATE_MOUSEOVER_UNIT', onMouseOver) then
			addon:RegisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		end
		if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
			addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
		end
	end
end
