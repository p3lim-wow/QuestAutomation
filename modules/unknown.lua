local _, addon = ...
local L = addon.L

local VERSE_NPC = 174365
local JUICE_NPC = 174371
local JUICE_ITEM = 183961
local GUESS_NPCS = {
	-- it seems all the NPCs are correct, but I could be wrong
	[174770] = true,
	[174498] = true,
	[174771] = true,
	[174499] = true,
}

-- local gormJuiceStage
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
		-- create "Gorm Juice" by talking to the NPC in the correct sequence
		if GetItemCount(JUICE_ITEM) == 0 then
			self:SendNotice(L['Click Squeezums first'])
		else
			-- TODO: this one needs some work
			-- https://www.wowhead.com/quest=62453/into-the-unknown#comments:id=3281316

			-- if not gormJuiceStage then
			-- 	C_GossipInfo.SelectOption(2)
			-- elseif gormJuiceStage == 1 then
			-- 	C_GossipInfo.SelectOption(C_GossipInfo.GetNumOptions())
			-- end

			-- gormJuiceStage = (gormJuiceStage or 0) + 1
		end
	elseif GUESS_NPCS[npcID] then
		C_GossipInfo.SelectOption(3)
	end
end
