import'Turbine'

import'Turbine.UI'
import'Turbine.UI.Lotro'
pcall(import, 'Turbine.Utils')
if not _G.class then
	import'Shady.Manager.Class'
else
	pcall(import, 'Turbine.Debug')--hmm can still print errors, if they are in Turbine.Debug
									--Turbine.Debug still requires Turbine.Uitils
end

--debug alias
dump = function(...)
	if Turbine.Debug then
		Turbine.Debug.Table.Dump(...)
	end
end
write = Turbine.Shell.WriteLine

DB = Turbine.PluginData.Load(Turbine.DataScope.Character, 'ShadyManagerDB') or {
	plugins = {},
}
--Turbine.PluginData.Save(Turbine.DataScope.Character, 'ShadyManagerDB', DB)

import'Shady.Manager.locale'
import'Shady.Manager.window'

local sortA = {}
local sortB = {}
sortAcsend = true
sortBy = {1, 2, 3}
local function sortDispList(a, b)
	--i need to get a .Enabled
	--local enabledA = findLoadedPlugin(a.Name)
	--local enabledB = findLoadedPlugin(b.Name)
	local enabledA = DB.plugins[a.Name]
	local enabledB = DB.plugins[b.Name]
	enabledA = enabledA and 1 or 0
	enabledB = enabledB and 1 or 0
	sortA[1], sortA[2], sortA[3] = a.Name, enabledA, a.Author
	sortB[1], sortB[2], sortB[3] = b.Name, enabledB, b.Author

	if sortA[sortBy[1]] ~= sortB[sortBy[1]] then
		if sortAcsend then
			return sortA[sortBy[1]] < sortB[sortBy[1]]
		else
			return sortA[sortBy[1]] > sortB[sortBy[1]]
		end
	elseif sortA[sortBy[2]] ~= sortB[sortBy[2]] then
		return sortA[sortBy[2]] < sortB[sortBy[2]]
	else
		return sortA[sortBy[3]] < sortB[sortBy[3]]
	end
end

function sortPlugins()
	if sortBy[1] == 1 then
		table.sort(_plugins, function(a, b)
			if sortAcsend then
				return a.Name < b.Name
			else
				return a.Name > b.Name
			end
		end)
	else
		table.sort(_plugins, sortDispList)
	end
end

function getPlugins()
	_plugins = Turbine.PluginManager.GetAvailablePlugins()
	_loaded_plugins = Turbine.PluginManager.GetLoadedPlugins()

	table.sort(_plugins, function(a,b)
		return tostring(a.Name) < tostring(b.Name)
	end)
end

local updatewindow = Turbine.UI.Control()
function updatewindow:Update(args)
	local gameTime = Turbine.Engine.GetGameTime()
	if gameTime >= self.time then
		self:SetWantsUpdates(false)
		self.time = nil

		_loaded_plugins = Turbine.PluginManager.GetLoadedPlugins()
		window:PluginLoaded()

		sortPlugins()
	end
end

--.. ugh this only fires for this plugin because of the apartment
--tp = Turbine.Plugin()--this doesn't get Load event
--tp.Load = function()
--	write('plugin has Loaded()')
--end
Turbine.Plugin.Load = function(sender, args)--args is empty table
	--write('A plugin has Loaded()')

	--getPlugins()
	_loaded_plugins = Turbine.PluginManager.GetLoadedPlugins()

--	if not updatewindow.time then
--		updatewindow.time = Turbine.Engine.GetGameTime() + 3
--		updatewindow:SetWantsUpdates(true)
--	end

	--window:PluginLoaded()
end

function findLoadedPlugin(name)
	_loaded_plugins = Turbine.PluginManager.GetLoadedPlugins()
	for k,v in pairs(_loaded_plugins) do
		if v.Name == name then
			return 1
		end
	end
	return 0
end

function LoadAllPlugins()
	for k,v in pairs(_plugins) do
		Turbine.PluginManager.LoadPlugin(v.Name)
	end
end

function PluginLoaded()
	if not updatewindow.time then
		updatewindow.time = Turbine.Engine.GetGameTime() + 1
		updatewindow:SetWantsUpdates(true)
	end
end

function LoadAllEnabledPlugins()
	local foundplugins = {}
	for k,v in pairs(_plugins) do
		foundplugins[v.Name] = true
	end
	for k in pairs(DB.plugins) do
		if foundplugins[k] then
			Turbine.PluginManager.LoadPlugin(k)
		end
	end
	foundplugins = nil
	PluginLoaded()
end

function UnloadAllPlugins()
	local apartments = {}
	for k,v in pairs(_plugins) do
		if v.ScriptState ~= 'ShadyManager' then
			apartments[v.ScriptState] = true
		end
	end

	for k in pairs(apartments) do
		Turbine.PluginManager.UnloadScriptState(k)
	end
end

shellCommand = Turbine.ShellCommand()
function shellCommand:Execute(command, arguments)
	window:Show()
end
function shellCommand:GetHelp()
	return L'shorthelp'
end
function shellCommand:GetShortHelp()
	return L'shorthelp'
end
Turbine.Shell.AddCommand('man;manager', shellCommand)

getPlugins()

LoadAllEnabledPlugins()
