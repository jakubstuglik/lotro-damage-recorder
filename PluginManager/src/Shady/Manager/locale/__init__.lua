local _locale = Turbine.Engine.GetLocale()
local x = _.Name:sub(0, -8)
pcall(import, x..'.locale.en')
if _locale ~= 'en' then
	pcall(import, x..'.locale.'.._locale)
end
assert(loadstring(x..'.L = function(key) return l[key] or "<Localization Missing>" end'))()
