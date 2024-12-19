local _, addon = ...
local L = addon.L

local QUESTS = {
	-- questID = {sequenceIndex = {sequenceStep1,...,sequenceStepN}}
	[51632] = { -- Make Loh Go (Tiragarde Sound)
		[0] = {3, 2},
		[1] = {1, 2, 3, 2, 2},
		[2] = {1, 2, 1, 2, 2},
		[3] = {1, 2, 3, 2},
		[4] = {3, 2, 2, 2},
		[5] = {3, 2, 2},
		[6] = {3, 2, 1, 2, 2, 1, 2, 3, 2, 2},
	},
	[51633] = { -- Make Loh Go (Stormsong Valley)
		[0] = {3, 2},
		[1] = {1, 2, 3, 2, 2},
		[2] = {2, 1, 2, 2},
		[3] = {2, 2, 1, 2},
		[4] = {3, 2},
		[5] = {3, 2, 3, 2, 1, 2},
		[6] = {1, 2, 3, 2, 2},
		[7] = {3, 2, 1, 2, 2},
	},
	[51635] = { -- Make Loh Go (Vol'dun)
		[0] = {2, 3, 2, 3, 2, 1, 2, 1, 2},
		[1] = {1, 2, 3, 2},
		[2] = {1, 2},
		[3] = {2, 1, 2, 1, 2, 3, 2},
		[4] = {3, 2, 3, 2, 2, 2},
		[5] = {2, 2, 2, 2},
	},
	[51636] = { -- Make Loh Go (Zuldazar)
		[0] = {2, 2},
		[1] = {1, 2, 2, 1, 2},
		[2] = {2, 2},
		[3] = {1, 2, 2},
		[4] = {1, 2, 2, 2, 2},
		[5] = {2, 3, 2, 1, 2},
		[6] = {3, 2, 2},
		[7] = {2},
	},
}

local TURTLE_CHECKPOINT = 276705
local TURTLE_SPELLS = {
	[271602] = true, -- 1: Turn Left
	[271600] = true, -- 2: Move Forward
	[271601] = true, -- 3: Turn Right
}

local activeQuestData
local activeCheckpoint
local nextActionIndex

local function updateSequenceAction()
	addon:BindAction(activeQuestData[activeCheckpoint][nextActionIndex])
end

local function onTurtleAction(self, unit, _, spellID)
	if unit ~= 'vehicle' then
		return
	end

	if TURTLE_SPELLS[spellID] then
		-- the "turtle" cast a spell, queue the next action in the sequence
		nextActionIndex = nextActionIndex + 1
		updateSequenceAction()
	end
end

local function getCheckpoint()
	local info = addon:GetUnitAura('vehicle', TURTLE_CHECKPOINT, 'HARMFUL')
	return info and info.points and info.points[1] or 0
end

local function onUnitAura(self, unit)
	if unit ~= 'vehicle' then
		return
	end

	local checkpoint = getCheckpoint()
	if checkpoint ~= activeCheckpoint then
		activeCheckpoint = checkpoint

		-- the "turtle" has reached a checkpoint, reset the sequence and queue the next action
		nextActionIndex = 1
		updateSequenceAction()
	end
end

local function onTurtleExited(self)
	-- reset
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
			self:Unbind()
			return true
		end)
	else
		self:Unbind()
	end

	self:UnregisterEvent('UNIT_AURA', onUnitAura)
	self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', onTurtleAction)
	return true
end

local function onTurtleEntered(self)
	-- the player has taken over a turtle, start counting checkpoints
	self:RegisterEvent('UNIT_AURA', onUnitAura)
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', onTurtleAction)
	self:RegisterEvent('UNIT_EXITED_VEHICLE', onTurtleExited)

	self:SendNotice(L['Spam SPACEBAR to complete'])
end

local function onQuestRemoved(self, questID)
	if QUESTS[questID] or not questID then
		if addon:IsEventRegistered('UNIT_ENTERED_VEHICLE', onTurtleEntered) then
			self:UnregisterEvent('UNIT_ENTERED_VEHICLE', onTurtleEntered)
		end

		activeQuestData = nil
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	-- if logging in with the quest already accepted
	for questID, questData in next, QUESTS do
		if C_QuestLog.IsOnQuest(questID) then
			if not addon:IsEventRegistered('UNIT_ENTERED_VEHICLE', onTurtleEntered) then
				addon:RegisterEvent('UNIT_ENTERED_VEHICLE', onTurtleEntered)
			end
			if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
				addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
			end

			activeQuestData = questData

			return
		end
	end

	-- reset if there are no matching quests
	onQuestRemoved(self)
end
