local _, addon = ...
local L = addon.L

-- not really a quest, but easily automated and in a heavy quest area, so why not

local TAMING_SPELL = 356137 -- cast when the player starts "taming" the wilderling
local ACTION_SPELL = 356148 -- the spell the wilderling casts that the player needs to counter
local REACTION_SPELL = 356151 -- this is the spell the player casts to counter the wilderling "action"

local isTaming = false
local function onVehicleExit(self, unit)
	if unit ~= 'player' then
		return
	end

	-- ensure no deadlocks
	addon:Unbind()

	-- reset
	isTaming = false
	return true
end

function addon:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if unit ~= 'player' then
		return
	end

	if spellID == TAMING_SPELL then
		-- player initiated the wilderling
		self:SendNotice(L['Spam SPACEBAR to complete'])
		self:RegisterEvent('UNIT_EXITED_VEHICLE', onVehicleExit)

		isTaming = true
	elseif isTaming and spellID == ACTION_SPELL then
		-- the wilderling sped up, bind the reactionary spell
		self:BindAction(1)
	elseif isTaming and spellID == REACTION_SPELL then
		-- the player cast the reactionary spell, reset the bindings
		self:Unbind()
	end
end
