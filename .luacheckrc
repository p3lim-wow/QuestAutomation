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
	'RaidWarningFrame',
	'UIParent',

	-- FrameXML functions
	'RaidNotice_AddMessage',
	'CalculateDistance',
	'Mixin',

	-- FrameXML constants
	'ChatTypeInfo',

	-- GlobalStrings
	'KEY_SPACE',

	-- namespaces
	'C_GossipInfo',
	'C_Item',
	'C_QuestLog',
	'C_Spell',
	'C_Timer',

	-- API
	'ClearOverrideBindings',
	'CreateFrame',
	'GetActionInfo',
	'GetLocale',
	'GetRaidTargetIndex',
	'HasExtraActionBar',
	'InCombatLockdown',
	'IsShiftKeyDown',
	'SetOverrideBinding',
	'SetOverrideBindingClick',
	'SetRaidTarget',

	-- exposed from other addons
	'LibStub',
}
