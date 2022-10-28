std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'614', -- trailing whitespace in a comment
	'631', -- line is too long
}

exclude_files = {}

globals = {}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'RaidWarningFrame', -- FrameXML/RaidWarning.xml

	-- FrameXML functions
	'RaidNotice_AddMessage', -- FrameXML/RaidWarning.lua

	-- FrameXML constants
	'ChatTypeInfo', -- FrameXML/ChatFrame.lua

	-- SharedXML functions
	'Mixin', -- SharedXML/Mixin.lua
	'CalculateDistance', -- 'SharedXML/MathUtil.lua'

	-- GlobalStrings
	'KEY_SPACE',

	-- namespaces
	'C_GossipInfo',
	'C_Map',
	'C_Timer',
	'C_QuestLog',

	-- API
	'ClearOverrideBindings',
	'CreateFrame',
	'GetActionInfo',
	'GetItemCount',
	'GetLocale',
	'GetRaidTargetIndex',
	'GetSpellInfo',
	'HasExtraActionBar',
	'InCombatLockdown',
	'IsShiftKeyDown',
	'SetOverrideBinding',
	'SetRaidTarget',
	'UnitExists',
	'UnitGUID',
	'UnitAuraBySlot',
	'UnitAuraSlots',
	'UnitAuraBySlot',
	'GetPlayerAuraBySpellID',

	-- exposed from other addons
	'LibStub',
}
