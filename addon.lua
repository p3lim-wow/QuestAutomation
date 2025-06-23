local addonName, addon = ...

local isBound
local bindParent = CreateFrame('Frame')
function addon:Unbind()
	self:Defer('ClearOverrideBindings', bindParent)
	isBound = true
end

function addon:IsBound()
	return not not isBound
end

local ACTION_NAME = 'ACTIONBUTTON%d'
function addon:BindAction(actionIndex, key)
	self:Unbind()
	self:Defer('SetOverrideBinding', bindParent, true, key or 'SPACE', ACTION_NAME:format(actionIndex))
	isBound = true
end

do
	local macroButton = addon:CreateButton('Button', addonName .. 'MacroButton', UIParent, 'SecureActionButtonTemplate')
	macroButton:SetAttribute('type', 'macro')

	function addon:BindMacro(macro, key)
		self:Unbind()
		self:DeferMethod(macroButton, 'SetAttribute', 'macrotext', macro)
		self:Defer('SetOverrideBindingClick', bindParent, true, key or 'SPACE', macroButton:GetName(), 'LeftButton')
		isBound = true
	end
end

function addon:SendNotice(message)
	for _ = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo.RAID_WARNING)
	end
end
