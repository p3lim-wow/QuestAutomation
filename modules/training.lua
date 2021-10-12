local _, addon = ...
local L = addon.L

local QUESTS = {
	-- questID = {trainer = 'npcName', spells = {...}}
	[59585] = { -- We'll Make an Aspirant Out of You, Bastion
		trainer = L['Trainer Ikaros'],
		spells = {
			-- buffID = {actionSpellID = actionIndex}
			[321842] = {
				[321843] = 1, -- Strike
				[321844] = 2, -- Sweep
				[321847] = 3, -- Parry
			},
			[341925] = {
				[341931] = 1, -- Slash
				[341928] = 2, -- Bash
				[341929] = 3, -- Block
			},
			[341985] = {
				[342000] = 1, -- Jab
				[342001] = 2, -- Kick
				[342002] = 3, -- Dodge
			},
		}
	},
	[64271] = { -- A More Civilized Way, Korthia
		trainer = L['Nadjia the Mistblade'],
		spells = {
			-- buffID = {actionSpellID = actionIndex}
			[355677] = {
				[355834] = 1, -- Lunge
				[355835] = 2, -- Parry
				[355836] = 3, -- Riposte
			},
		}
	},
}

local activeQuestData
local actionMessages = {}
local actionResetSpells = {}

local function onActionCast(self, unit, _, spellID)
	if unit ~= 'player' then
		return
	end

	-- check if the player cast the action
	if actionResetSpells[spellID] then
		-- bind to something useless to avoid spamming jump, the 4th action button isn't used
		self:BindAction(4)
	end
end

local function onTrainerSay(self, message, sender)
	if sender == activeQuestData.trainer then
		-- figure out which action the trainer wants the player to cast
		local actionID
		for actionName, actionIndex in next, actionMessages do
			if (message:gsub('%.', '')):match(actionName) then
				actionID = actionIndex
			end
		end

		if actionID then
			-- wait a split second before we bind the action to get a "perfect" reward
			C_Timer.After(0.5, function()
				self:BindAction(actionID)
			end)
		end
	end
end

local function onUnitAura(self, unit)
	if unit ~= 'player' then
		return
	end

	-- check if the player has the buff that starts the "training session", of which there
	-- can be multiple versions of, depending on the quest
	for buff, actionSpells in next, activeQuestData.spells do
		if AuraUtil.FindAura(addon.AuraFilterID, 'player', 'HELPFUL', buff) then
			-- store all possible messages the "trainer" will yell out for the player to do
			table.wipe(actionMessages)
			table.wipe(actionResetSpells)
			for spellID, actionIndex in next, actionSpells do
				actionMessages[(GetSpellInfo(spellID))] = actionIndex
				actionResetSpells[spellID] = true
			end

			-- bind to something useless to avoid spamming jump, the 4th action button isn't used
			self:BindAction(4)

			-- watch for the next action the trainer asks the player to perform
			self:SendNotice(L['Spam %s to complete'])
			self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', onActionCast)
			self:RegisterEvent('CHAT_MSG_MONSTER_SAY', onTrainerSay)

			break
		elseif self:IsBound() then
			-- no buff found, give control back to the player
			if InCombatLockdown() then
				self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
					self:Unbind()
					return true
				end)
			else
				self:Unbind()
			end

			-- and reset
			self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', onActionCast)
			self:UnregisterEvent('CHAT_MSG_MONSTER_SAY', onTrainerSay)
		end
	end
end

local function onQuestRemoved(self, questID)
	if QUESTS[questID] or not questID then
		if addon:IsEventRegistered('UNIT_AURA', onUnitAura) then
			self:UnregisterEvent('UNIT_AURA', onUnitAura)
		end

		activeQuestData = nil
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	-- if logging in with the quest already accepted
	for questID, questData in next, QUESTS do
		if C_QuestLog.IsOnQuest(questID) then
			if not addon:IsEventRegistered('UNIT_AURA', onUnitAura) then
				addon:RegisterEvent('UNIT_AURA', onUnitAura)
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
