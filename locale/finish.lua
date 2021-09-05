local _, addon = ...
local L = addon.L

local KEY_SPACE = KEY_SPACE:upper() -- GlobalStrings

-- do some finishing touches to the locales
L['Click %s first'] = L['Click %s first']:format(L['Squeezums'])
L['Spam %s to complete'] = L['Spam %s to complete']:format(KEY_SPACE)
L['Stand in circle and spam %s to complete'] = L['Stand in circle and spam %s to complete']:format(KEY_SPACE)
