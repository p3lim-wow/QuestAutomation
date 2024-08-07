local _, addon = ...

local FRUIT_QUEST = 70549 -- Low Hanging Fruit
local MACRO = ([[
/target %s
/click ExtraActionButton1
]]):format('Honey Plum', C_Spell.GetSpellName(388556)) -- TODO: localize

local function onQuestRemoved(self, questID)
	if questID == FRUIT_QUEST then
		-- reset
		addon:Unbind()
		return true
	end
end

function addon:QUEST_LOG_UPDATE()
	if C_QuestLog.IsOnQuest(FRUIT_QUEST) then
		self:BindMacro(MACRO)

		if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
			addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
		end
	end
end
