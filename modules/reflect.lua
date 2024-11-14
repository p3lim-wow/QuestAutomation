local _, addon = ...

local ANSWERS = {
	[41523] = true,
	[41528] = true,
	[41532] = true,
	[41536] = true,
	[41539] = true,
	[41544] = true,
	[41546] = true,
	[41660] = true,
	[41674] = true,
	[41676] = true,
	[41683] = true,
	[41686] = true,
	[41706] = true,
	[41711] = true,
	[41716] = true,
	[42020] = true,
	[42025] = true,
	[42026] = true,
	[42032] = true,
	[42086] = true,
	[42088] = true,
	[42091] = true,
	[42098] = true,
	[42099] = true,
	[42156] = true,
	[42157] = true,
	[42162] = true,
	[42166] = true,
	[42169] = true,
	[42176] = true,
	[42179] = true,
	[42184] = true,
	[42185] = true,
	[42192] = true,
	[42210] = true,
	[42214] = true,
	[42220] = true,
	[45687] = true,
	[45695] = true,
	[45699] = true,
	[45705] = true,
	[46001] = true,
	[46004] = true,
	[46010] = true,
	[46017] = true,
	[46019] = true,
	[46026] = true,
	[46031] = true,
	[46036] = true,
	[46063] = true,
	[46069] = true,
	[46073] = true,
	[46080] = true,
	[46085] = true,
	[46088] = true,
	[46094] = true,
	[46101] = true,
	[46106] = true,
	[46108] = true,
	[46130] = true,
	[46134] = true,
	[46139] = true,
	[46146] = true,
	[46148] = true,
	[46155] = true,
	[46159] = true,
	[46166] = true,
	[46168] = true,
	[46175] = true,
	[46185] = true,
	[46192] = true,
	[46194] = true,
	[46202] = true,
	[46206] = true,
	[46212] = true,
	[46214] = true,
	[46219] = true,
	[46225] = true,
	[46229] = true,
	[46237] = true,
	[111278] = true,
	[111284] = true,
	[111287] = true,
	[111290] = true,
	[111295] = true,
	[111300] = true,
	[111302] = true,
	[111308] = true,
	[111311] = true,
	[111314] = true,
	[111320] = true,
	[111323] = true,
	[111327] = true,
	[111330] = true,
	[111336] = true,
	[111340] = true,
	[111342] = true,
	[111346] = true,
	[111351] = true,
	[111355] = true,
}

local QUESTS = {
	[43323] = true,
	[43461] = true,
}

local NPCS = {
	[110034] = true,
	[110035] = true,
}

local answered
function addon:GOSSIP_SHOW()
	if answered then
		answered = false
		C_GossipInfo.CloseGossip()
	else
		for _, info in next, C_GossipInfo.GetOptions() do
			if ANSWERS[info.gossipOptionID or 0] then
				answered = true
				C_GossipInfo.SelectOption(info.gossipOptionID)
				return
			end
		end

		local npcID = addon:GetUnitID('npc')
		if NPCS[npcID] then
			addon:Print('Unknown option')
			answered = false
			for _, info in next, C_GossipInfo.GetOptions() do
				addon:Print(info.gossipOptionID, info.name)
			end
		end
	end
end

function addon:QUEST_DETAIL()
	local questID = GetQuestID() or 0
	if QUESTS[questID] then
		AcceptQuest()
	end
end

function addon:QUEST_COMPLETE()
	local questID = GetQuestID() or 0
	if QUESTS[questID] then
		GetQuestReward(1)
	end
end
