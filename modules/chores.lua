local _, addon = ...

local BASTION_MAP_ID = 1533
local CHORES_QUEST = 60565
local STEWARD_LOCATIONS = {
	-- this is far from accurate or complete, but it works for the most part
	-- npcID = {{x, y}[, {x, y}[, ...]]}
	[169022] = {{0.5291, 0.4579}},
	[169023] = {{0.5306, 0.4750}},
	[169024] = {{0.5263, 0.4617}, {0.5258, 0.4660}},
	[169025] = {{0.5199, 0.4846}, {0.5265, 0.4744}},
	[169026] = {{0.5251, 0.4877}, {0.5182, 0.4540}},
	[169027] = {{0.5333, 0.4701}},
}

local HBD = LibStub('HereBeDragons-2.0')
local function getClosestSteward()
	local closestSteward
	local closestDistance = math.huge

	local x, y = addon:GetPlayerPosition(BASTION_MAP_ID)
	for npcID, data in next, STEWARD_LOCATIONS do
		for _, coords in next, data do
			local distance = HBD:GetZoneDistance(BASTION_MAP_ID, x, y, BASTION_MAP_ID, coords[1], coords[2])
			if distance < closestDistance then
				closestSteward = npcID
				closestDistance = distance
			end
		end
	end

	return closestSteward
end

local function onMouseOver()
	if addon:GetPlayerMapID() ~= BASTION_MAP_ID then
		return true
	end

	-- find the steward that has the correct "tool" for the closest "chore"
	local closestStewardID = getClosestSteward()
	if closestStewardID and closestStewardID == addon:GetNPCID('mouseover') then
		if GetRaidTargetIndex('mouseover') ~= 4 then
			-- the steward is not already marked with a star, mark it
			SetRaidTarget('mouseover', 4)
		end
	end
end

local function onQuestRemoved(self, questID)
	if questID == CHORES_QUEST then
		-- reset
		self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	-- if logging in with the quest already accepted
	if C_QuestLog.IsOnQuest(CHORES_QUEST) then
		if not addon:IsEventRegistered('UPDATE_MOUSEOVER_UNIT', onMouseOver) then
			addon:RegisterEvent('UPDATE_MOUSEOVER_UNIT', onMouseOver)
		end
		if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
			addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
		end
	end
end
