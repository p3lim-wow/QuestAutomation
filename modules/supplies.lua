local _, addon = ...
local L = addon.L

local QUESTS = {
	[356465] = { -- spellID trigger for 'The Weight of Stone' in Korthia
		distance = 12,
		mapID = 1961, -- Korthia
		locations = {
			{x=0.512295, y=0.659946, action=2},
			{x=0.495522, y=0.702267, action=1},
			{x=0.436255, y=0.774560, action=1},
			{x=0.457401, y=0.651537, action=2},
			{x=0.571717, y=0.738390, action=1},
			{x=0.483011, y=0.703747, action=2},
			{x=0.540073, y=0.696586, action=1},
			{x=0.438710, y=0.691987, action=1},
			{x=0.547435, y=0.680365, action=1},
			{x=0.456530, y=0.756301, action=2},
			{x=0.449992, y=0.781604, action=2},
			{x=0.553119, y=0.704497, action=2},
			{x=0.561304, y=0.736615, action=1},
			{x=0.457527, y=0.718790, action=2},
			{x=0.493594, y=0.653566, action=1},
			{x=0.556713, y=0.688418, action=1},
			{x=0.533274, y=0.686950, action=2},
			{x=0.472837, y=0.653830, action=1},
			{x=0.519417, y=0.696308, action=2},
			{x=0.509723, y=0.704670, action=1},
			{x=0.522772, y=0.665827, action=1},
			{x=0.555976, y=0.720724, action=1},
			{x=0.571639, y=0.709176, action=1},
			{x=0.437535, y=0.653663, action=2},
			{x=0.503524, y=0.656182, action=2},
			{x=0.447420, y=0.735700, action=2},
		},
	},
	-- TODO: there is one in Revendreth as well
}

local activeTicker
local activeQuestData
local function onVehicleExit(self, unit)
	if unit ~= 'player' then
		return
	end

	-- ensure no deadlocks
	self:Unbind()

	-- reset
	activeTicker:Cancel()
	return true
end

local function pollPlayerPosition()
	local x, y = addon:GetPlayerPosition(activeQuestData.mapID)

	local actionIndex
	for _, location in next, activeQuestData.locations do
		-- use utilities by Blizzard (MathUtil)
		local distance = CalculateDistance(location.x * 100, location.y * 100, x * 100, y * 100)
		if distance <= (activeQuestData.distance / 100) then
			actionIndex = location.action
			break
		end
	end

	if actionIndex then
		addon:BindAction(actionIndex)
		addon:SendNotice(L['Spam %s to complete']) -- just as a reminder
	else
		addon:Unbind()
	end
end

function addon:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if unit ~= 'player' then
		return
	end

	local questData = QUESTS[spellID]
	if questData then
		self:SendNotice(L['Spam %s to complete'])

		activeQuestData = questData

		-- this quest is location dependant, so we'll have to poll
		activeTicker = C_Timer.NewTicker(0.05, pollPlayerPosition)
		self:RegisterEvent('UNIT_EXITED_VEHICLE', onVehicleExit)
	end
end
