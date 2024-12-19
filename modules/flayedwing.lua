local _, addon = ...
local L = addon.L

local FLAYEDWING_NPC_ID = 172876
local actions = {
	-- flayedwingSpellID = {buttonIndex, vehicleSpellID}
	[337827] = {1, 337835},
	[337832] = {2, 337837},
	[337833] = {3, 337842},
}

local reactButtonIndex
local function onLeaveCombat()
	addon:BindAction(reactButtonIndex)
	reactButtonIndex = nil
	return true
end

local reactSpellID
local function onSpellCast(self, unit, _, spellID)
	if unit ~= 'vehicle' then
		return
	end

	if spellID == reactSpellID then
		addon:Unbind()
		reactSpellID = nil
	else
		local info = actions[spellID]
		if info then
			if InCombatLockdown() then
				-- there are mobs flying around in the area the Flayedwing paths through, and they
				-- can put the player in combat, so we'll have to account for that
				addon:RegisterEvent('PLAYER_REGEN_ENABLED', onLeaveCombat)
				reactButtonIndex = info[1]
			else
				addon:BindAction(info[1])
			end

			reactSpellID = info[2]
		end
	end
end

local function onVehicleExit(self, unit)
	if unit ~= 'player' then
		return
	end

	-- ensure no deadlocks
	addon:Unbind()

	-- reset
	reactSpellID = nil
	reactButtonIndex = nil

	addon:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', onSpellCast)
	return true
end

function addon:UNIT_ENTERED_VEHICLE(unit, _, _, _, vehicleGUID)
	if addon:GetUnitID(vehicleGUID) == FLAYEDWING_NPC_ID then
		self:SendNotice(L['Spam SPACEBAR to complete'])

		addon:RegisterEvent('UNIT_EXITING_VEHICLE', onVehicleExit)
		addon:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', onSpellCast)
	end
end
