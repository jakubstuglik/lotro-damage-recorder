import'Shady.Manager.item'

local screenWidth, screenHeight = Turbine.UI.Display.GetSize()
local left, top = screenWidth / 2, screenHeight / 2

local currentState = {}
local refreshing = false

do
	if Turbine.UI.ListBox.ClearItems then
		--error('Turbine added ListBox:ClearItems()  I don\'t need to fake it anymore!')
	else
		--i should probably recycle items
		Turbine.UI.ListBox.ClearItems = function(self)
			local count = self:GetItemCount()
			for i = count, 1, -1 do
				self:RemoveItemAt(i)
			end
		end
	end
end

local function saveDB(s, a)
	for k in pairs(currentState) do
		currentState[k] = nil
	end
	for k in pairs(DB.plugins) do
		currentState[k] = true
		if a then
			Turbine.PluginManager.LoadPlugin(k)
		end
	end
	s.apply:SetEnabled(false)

	Turbine.PluginData.Save(Turbine.DataScope.Character, 'ShadyManagerDB', DB)

	if a then
		PluginLoaded()
	end
end

local function sorterMouseEnter(self, args)
	if sortBy[1] ~= self._id then
		--self:SetOpacity(0.5)
		--self:SetVisible(true)
		self:SetBackground('Shady/Manager/Resources/sortbarxh1.jpg')
	end
end
local function sorterMouseLeave(self, args)
	if sortBy[1] ~= self._id then
		--self:SetOpacity(0.0)
		--self:SetVisible(false)
		self:SetBackground('Shady/Manager/Resources/sortbar1.jpg')
	end
end
local function sorterMouseClick(self, args)
	if sortBy[1] ~= self._id then
		local old = self:GetParent().hovers[sortBy[1]]
		old:SetBackground('Shady/Manager/Resources/sortbar1.jpg')
		self:SetBackground('Shady/Manager/Resources/sortbarh1.jpg')

		old.sorted:SetVisible(false)
		self.sorted:SetVisible(true)

		sortAcsend = true
		if self._id == 1 then
			sortBy[1], sortBy[2], sortBy[3] = 1, 2, 3
		elseif self._id == 2 then
			sortBy[1], sortBy[2], sortBy[3] = 2, 1, 3
			sortAcsend = false
		elseif self._id == 3 then
			sortBy[1], sortBy[2], sortBy[3] = 3, 1, 2
		end
		sortPlugins()

		if sortAcsend then
			self.sorted:SetBackground('Shady/Manager/Resources/sortup.jpg')
		else
			self.sorted:SetBackground('Shady/Manager/Resources/sortdown.jpg')
		end

		self:GetParent():GetParent():Sorted()
	else
		sortAcsend =  not sortAcsend
		sortPlugins()

		if sortAcsend then
			self.sorted:SetBackground('Shady/Manager/Resources/sortup.jpg')
		else
			self.sorted:SetBackground('Shady/Manager/Resources/sortdown.jpg')
		end

		self:GetParent():GetParent():Sorted()
	end
end

local control = class(Turbine.UI.Lotro.Window)
function control:Constructor()
	self.base.Constructor(self)

	self:SetSize(300, 400)--300, 354
	self:SetPosition(left - (self:GetWidth() / 2), top - (self:GetHeight() / 2))
	self:SetZOrder(5)

	self:SetText(L'windowname')

	self:SetWantsKeyEvents(true)
	self.KeyDown = function(sender, args)
		if args.Action == Turbine.UI.Lotro.Action.Escape then
			sender:SetVisible(false)
		end
	end

	self.listboxScrollbar = Turbine.UI.Lotro.ScrollBar()
	self.listboxScrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
	self.listboxScrollbar:SetParent(self)

	self.listbox = Turbine.UI.ListBox()
	self.listbox:SetParent(self)
	self.listbox:SetOrientation(Turbine.UI.Orientation.Vertical)
	self.listbox:SetVerticalScrollBar(self.listboxScrollbar)
	self.listbox:SetBackColorBlendMode(Turbine.UI.BlendMode.None)
	--self.listbox:SetBackColor(Turbine.UI.Color(0.5, 0, 1, 0))--lol oops

	self.apply = Turbine.UI.Lotro.Button()
	self.apply:SetParent(self)
	self.apply:SetEnabled(false)--only need to apply if something has changed
	--self.apply:SetPosition(15, 35)
	--self.apply:SetSize(listWidth, listHeight)
	self.apply:SetText(L'apply')
	self.apply:SetWidth(70)--default is 50
	self.apply.Click = function(sender, args)
		--save and load selected plugins
		saveDB(self, true)

		sortPlugins()
		self:Sorted()
	end

	--write(self.apply:GetWidth())

	self.reload = Turbine.UI.Lotro.Button()
	self.reload:SetParent(self)
	self.reload:SetEnabled(true)
	--self.reload:SetPosition(15, 35)
	--self.reload:SetSize(listWidth, listHeight)
	self.reload:SetText(L'reload')
	self.reload:SetWidth(70)--default is 50
	self.reload.Click = function(sender, args)
		--i should probably treat reload like Apply but also reloads plugins
		saveDB(self)

		--reload selected plugins
		UnloadAllPlugins()

		Turbine.UI.Lotro.LotroUI.Reset()

		LoadAllEnabledPlugins()

		sortPlugins()
		self:Sorted()
	end

	--[[
	self.refresh.Click = function(sender,args)
		refreshing = true
		Turbine.PluginManager.RefreshAvailablePlugins()
		PluginLoaded()
	end
	]]

	self.sortbg = Turbine.UI.Control()
	self.sortbg:SetParent(self)
	--self.sortbg:SetSize(itemSize, 18)
	self.sortbg:SetBackground('Shady/Manager/Resources/sortbar1.jpg')
	self.sortbg.hovers = {}

	--Enabled
	self.sortbg.hovers[2] = Turbine.UI.Control()
	self.sortbg.hovers[2]._id = 2
	self.sortbg.hovers[2]:SetParent(self.sortbg)
	self.sortbg.hovers[2]:SetPosition(0, 0)
	self.sortbg.hovers[2]:SetSize(17, 18)
	--self.sortbg.hovers[2]:SetBackground('Shady/Manager/Resources/sortbarh1.jpg')
	self.sortbg.hovers[2]:SetBackColorBlendMode(Turbine.UI.BlendMode.Screen)
	--self.sortbg.hovers[2]:SetVisible(false)
	--self.sortbg.hovers[2]:SetOpacity(0.0)
	self.sortbg.hovers[2].MouseEnter = sorterMouseEnter
	self.sortbg.hovers[2].MouseLeave = sorterMouseLeave
	self.sortbg.hovers[2].MouseClick = sorterMouseClick

	--name label
	self.sortbg.hovers[1] = Turbine.UI.Control()
	self.sortbg.hovers[1]._id = 1
	self.sortbg.hovers[1]:SetParent(self.sortbg)
	self.sortbg.hovers[1]:SetPosition(16 + 4, 0)
	self.sortbg.hovers[1]:SetSize((260 * 0.6) - (16 + 3), 18)--260 * 0.53
	self.sortbg.hovers[1]:SetBackground('Shady/Manager/Resources/sortbarh1.jpg')
	self.sortbg.hovers[1]:SetBackColorBlendMode(Turbine.UI.BlendMode.Screen)
	--self.sortbg.hovers[1]:SetVisible(false)
	--self.sortbg.hovers[1]:SetOpacity(0.0)
	self.sortbg.hovers[1].MouseEnter = sorterMouseEnter
	self.sortbg.hovers[1].MouseLeave = sorterMouseLeave
	self.sortbg.hovers[1].MouseClick = sorterMouseClick

	--author label
	self.sortbg.hovers[3] = Turbine.UI.Control()
	self.sortbg.hovers[3]._id = 3
	self.sortbg.hovers[3]:SetParent(self.sortbg)
	self.sortbg.hovers[3]:SetPosition((260 * 0.6) + 4, 0)
	self.sortbg.hovers[3]:SetSize((260 * 0.45) - (16 + 1), 18)
	--self.sortbg.hovers[3]:SetBackground('Shady/Manager/Resources/sortbarh1.jpg')
	self.sortbg.hovers[3]:SetBackColorBlendMode(Turbine.UI.BlendMode.Screen)
	--self.sortbg.hovers[3]:SetVisible(false)
	--self.sortbg.hovers[3]:SetOpacity(0.0)
	self.sortbg.hovers[3].MouseEnter = sorterMouseEnter
	self.sortbg.hovers[3].MouseLeave = sorterMouseLeave
	self.sortbg.hovers[3].MouseClick = sorterMouseClick

	self.label = Turbine.UI.Label()
	self.label:SetParent(self.sortbg)
	self.label:SetPosition(16 + 8, 2)--was + 5 instead of 8
	self.label:SetSize((260 * 0.6) - (16 + 5), 16)
	self.label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	self.label:SetFontStyle(Turbine.UI.FontStyle.Outline)
	self.label:SetOutlineColor(Turbine.UI.Color(0, 0, 0))
	self.label:SetMouseVisible(false)
	self.label:SetText('Name')

	self.author = Turbine.UI.Label()
	self.author:SetParent(self.sortbg)
	self.author:SetPosition((260 * 0.6) + 8, 2)--was + 5 instead of 8
	self.author:SetSize((260 * 0.45) - (16 + 5), 16)
	self.author:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	self.author:SetFontStyle(Turbine.UI.FontStyle.Outline)
	self.author:SetOutlineColor(Turbine.UI.Color(0, 0, 0))
	self.author:SetMouseVisible(false)
	self.author:SetText('Author')

	self.labeltab = Turbine.UI.Control()
	self.labeltab:SetParent(self.sortbg)
	self.labeltab:SetPosition(16 + 2, -1)
	self.labeltab:SetSize(2, 18)
	self.labeltab:SetBackground('Shady/Manager/Resources/sortbartab1.jpg')

	self.authortab = Turbine.UI.Control()
	self.authortab:SetParent(self.sortbg)
	self.authortab:SetPosition((260 * 0.6) + 2, -1)
	self.authortab:SetSize(2, 18)
	self.authortab:SetBackground('Shady/Manager/Resources/sortbartab1.jpg')

	self.sortbg.hovers[2].sorted = Turbine.UI.Control()
	self.sortbg.hovers[2].sorted:SetParent(self.sortbg)
	self.sortbg.hovers[2].sorted:SetPosition(7, 8)
	self.sortbg.hovers[2].sorted:SetSize(5, 3)
	self.sortbg.hovers[2].sorted:SetBackground('Shady/Manager/Resources/sortup.jpg')
	self.sortbg.hovers[2].sorted:SetMouseVisible(false)
	self.sortbg.hovers[2].sorted:SetVisible(false)

	local len = self.label:GetText():len()
	self.sortbg.hovers[1].sorted = Turbine.UI.Control()
	self.sortbg.hovers[1].sorted:SetParent(self.sortbg)
	self.sortbg.hovers[1].sorted:SetPosition(len * 14, 8)
	self.sortbg.hovers[1].sorted:SetSize(5, 3)
	self.sortbg.hovers[1].sorted:SetBackground('Shady/Manager/Resources/sortup.jpg')
	self.sortbg.hovers[1].sorted:SetMouseVisible(false)
	--self.sortbg.hovers[1].sorted:SetVisible(false)

	len = self.author:GetText():len()
	self.sortbg.hovers[3].sorted = Turbine.UI.Control()
	self.sortbg.hovers[3].sorted:SetParent(self.sortbg)
	self.sortbg.hovers[3].sorted:SetPosition((260 * 0.6) + (len * 9), 8)
	self.sortbg.hovers[3].sorted:SetSize(5, 3)
	self.sortbg.hovers[3].sorted:SetBackground('Shady/Manager/Resources/sortup.jpg')
	self.sortbg.hovers[3].sorted:SetMouseVisible(false)
	self.sortbg.hovers[3].sorted:SetVisible(false)

	self:UpdateRect()
end

function control:Show()
	self:SetVisible(true)

	for k in pairs(currentState) do
		currentState[k] = nil
	end
	for k in pairs(DB.plugins) do
		currentState[k] = true
	end

	self:Sorted()
end

function control:Sorted()
--[[
	self.listbox:ClearItems()
	for k,v in pairs(_plugins) do
		if v.Name ~= 'manager' then
			local s = item(v)
			if DB.plugins[v.Name] then
				s:SetChecked(true)
			end

			self.listbox:AddItem(s)
		end
	end
]]

	local pc = #_plugins - 1
	local lc = self.listbox:GetItemCount()

	--getting ready for refreshing plugins
	--if pc > lc remove extra items

	local i = 1
	for k,v in pairs(_plugins) do
		if v.Name ~= 'manager' then
			local r, s = pcall(self.listbox.GetItem, self.listbox, i)
			i = i + 1
			if not r or not s then
				s = item(v)
				self.listbox:AddItem(s)
			else
				s:SetPlugin(v)
			end

			s.label:SetText(v.Name)
			s.author:SetText(v.Author)

			s:SetChecked(DB.plugins[v.Name])
		end
	end

	self:ShowLoaded()
end

function control:UpdateRect()
	local width, height = self:GetSize()

	--sortbar will be 18 height

	local listWidth = width - 40
	local listHeight = height - 94

	self.listbox:SetPosition(15, 53)
	self.listbox:SetSize(listWidth, listHeight)
	--self.listbox:SetMaxItemsPerLine(1)

	self.listboxScrollbar:SetPosition(width - 25, 53)
	self.listboxScrollbar:SetSize(10, listHeight)

	local applyWidth = self.apply:GetWidth()
	local applyLeft = width - (applyWidth + 30)
	self.apply:SetPosition(applyLeft, height - 33)

	local reloadWidth = self.reload:GetWidth()
	self.reload:SetPosition(applyLeft - applyWidth, height - 33)

	self.sortbg:SetPosition(15, 33)--y was 35
	self.sortbg:SetSize(listWidth, 18)
end

--function control:UpdateContent()
--end

--function control:VisibleChanged(args)
--	if self:IsVisible() then
--		self:UpdateContent()
--	end
--end

function control:Closing(args)
	--closing the window will act as a cancel and reset DB to what it was when the window opened
	if self.apply:IsEnabled() then
		for k in pairs(DB.plugins) do
			DB.plugins[k] = nil
		end
		for k in pairs(currentState) do
			DB.plugins[k] = true
		end
		Turbine.PluginData.Save(Turbine.DataScope.Character, 'ShadyManagerDB', DB)
		self.apply:SetEnabled(false)
	end
end

function control:Compare()
	local changed = false
	for k in pairs(DB.plugins) do
		if not currentState[k] then
			--plugin was disabled but now is enabled
			changed = true
			break
		end
	end
	if not changed then
		for k in pairs(currentState) do
			if not DB.plugins[k] then
				--plugin was enabled and now is disabled
				changed = true
				break
			end
		end
	end

	if changed then
		self.apply:SetEnabled(true)
	else
		self.apply:SetEnabled(false)
	end
end

function control:ShowLoaded()
	_loaded_plugins = Turbine.PluginManager.GetLoadedPlugins()

	local count = self.listbox:GetItemCount()
	for i = 1, count do
		local item = self.listbox:GetItem(i)
		local name = item:GetPlugin().Name
		local loaded = false
		for k,v in pairs(_loaded_plugins) do
			if name == v.Name then
				loaded = true
				break
			end
		end
		if loaded then
			item.label:SetForeColor(Turbine.UI.Color(0, 0.77, 0))
		else
			item.label:SetForeColor(Turbine.UI.Color(1, 1, 1))
		end
	end
end

Shady.Manager.window = control()
Shady.Manager.window:SetVisible(false)

function control:PluginLoaded()
	if not refreshing then
		--self:UpdateContent()
		self:ShowLoaded()
	else
		refreshing = false
		_plugins = Turbine.PluginManager.GetAvailablePlugins()--hmm
		self:Closing()
		self:Sorted()
	end
end

shellCommandReloadUI = Turbine.ShellCommand()
function shellCommandReloadUI:Execute(command, arguments)
	Shady.Manager.window.reload.Click()
end
function shellCommandReloadUI:GetHelp()
	return L'rlhelp'
end
function shellCommandReloadUI:GetShortHelp()
	return L'rlhelp'
end
Turbine.Shell.AddCommand('reloadui;rl', shellCommandReloadUI)
