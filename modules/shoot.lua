local _, addon = ...
local L = addon.L

local QUESTS_MOBS = { -- questID = npcID
	[70549] = 195601, -- "Low Hanging Fruit"
	[85399] = 233643, -- "Caddyshock"
	[85473] = 233280, -- "Extra! Extra!"
	[84929] = 231016, -- "Lifeguard On Duty"
}

local MACRO = [[
/cleartarget
/target %s
/click ExtraActionButton1
]]

local function onQuestRemoved(_, questID)
	if questID and QUESTS_MOBS[questID] then
		-- reset
		addon:Unbind()
		return true
	end
end

local function updateQuestLog()
	local name
	for questID, mobName in next, QUESTS_MOBS do
		if C_QuestLog.IsOnQuest(questID) then
			name = mobName
			break
		end
	end

	if name then
		local key = GetBindingKey('EXTRAACTIONBUTTON1')
		addon:BindMacro(MACRO:format(name), key)
		addon:SendNotice(string.format(L['Spam %s to complete'], key or 'SPACEBAR'))

		if not addon:IsEventRegistered('QUEST_REMOVED', onQuestRemoved) then
			addon:RegisterEvent('QUEST_REMOVED', onQuestRemoved)
		end
	end
end

local ticker
local function getCreatureNames()
	local missing = 0
	for questID, npcID in next, QUESTS_MOBS do
		if type(npcID) == 'number' then
			local name = addon:GetNPCName(npcID)
			if not name then
				missing = missing + 1
			else
				QUESTS_MOBS[questID] = name
			end
		end
	end

	if missing == 0 then
		updateQuestLog() -- force check in case cache had to build

		if ticker then
			ticker:Cancel()
			ticker = nil
		end
	end
end

function addon:OnLogin()
	getCreatureNames()
	ticker = C_Timer.NewTicker(2, getCreatureNames, 20)
	addon:RegisterEvent('QUEST_LOG_UPDATE', updateQuestLog)
end
