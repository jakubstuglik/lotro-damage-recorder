local control = class(Turbine.UI.Control)
itemIndex = 0
local itemSize = 260

function control:Constructor(args)
	self.base.Constructor(self)

	itemIndex = itemIndex + 1

	self:SetSize(itemSize, 18)

	--if itemIndex % 2 == 0 then
	--	self:SetBackColor(Turbine.UI.Color(0.5, 1, 0, 0))
	--else
	--	self:SetBackColor(Turbine.UI.Color(0.5, 0, 0, 1))
	--end

	--self:SetMouseVisible(true)

	local itemwidth = 16

	self.checkbox = Turbine.UI.CheckBox()--Turbine.UI.Lotro.CheckBox()
	self.checkbox:SetParent(self)
	self.checkbox:SetPosition(0, 0)
	self.checkbox:SetSize(16, 16)
--	self.checkbox:SetSize(itemSize, 16)
--	self.checkbox:SetText(args.Name)
	--self.checkbox:SetMouseVisible(false)--does nothing, like the goggles
	--self.checkbox:SetBackColor(Turbine.UI.Color(0.5, 0.3, 0.3, 0.3))
	self.checkbox:SetBackground('Shady/Manager/Resources/check-unchecked4.jpg')
	self.checkbox:SetBackColorBlendMode(Turbine.UI.BlendMode.None)

	--doesn't fire when clicking on the graphics for Turbine.UI.Lotro.CheckBox
	self.checkbox.CheckedChanged = function(sender, args)
		--write('CheckedChanged')
		if sender:IsChecked() then
			DB.plugins[sender:GetParent()._plugin.Name] = true
			--Turbine.PluginManager.LoadPlugin(sender:GetParent()._plugin.Name)
			--sender:SetBackColor(Turbine.UI.Color(0.5, 0, 1, 0))
			sender:SetBackground('Shady/Manager/Resources/check-checked4.jpg')
		else
			DB.plugins[sender:GetParent()._plugin.Name] = nil
			--sender:SetBackColor(Turbine.UI.Color(0.5, 0.3, 0.3, 0.3))
			sender:SetBackground('Shady/Manager/Resources/check-unchecked4.jpg')
		end
		window:Compare()
	end

	self.label = Turbine.UI.Label()
	self.label:SetParent(self)
	self.label:SetPosition(itemwidth + 5, 1)
	self.label:SetSize((itemSize * 0.6) - (itemwidth + 5), 16)
	self.label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	self.label:SetFontStyle(Turbine.UI.FontStyle.Outline)
	self.label:SetOutlineColor(Turbine.UI.Color(0, 0, 0))
	self.label:SetMouseVisible(false)
	self.label:SetText(args.Name)
	self.label:SetForeColor(Turbine.UI.Color(1, 1, 1))--0, 0.77, 0  for when plugin is enabled
	--self.label:SetBackColor(Turbine.UI.Color(0.5, 1, 1, 1))

	self.author = Turbine.UI.Label()
	self.author:SetParent(self)
	self.author:SetPosition((itemSize * 0.6) + 5, 1)
	self.author:SetSize((itemSize * 0.45) - (itemwidth + 5), 16)
	self.author:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	self.author:SetFontStyle(Turbine.UI.FontStyle.Outline)
	self.author:SetOutlineColor(Turbine.UI.Color(0, 0, 0))
	self.author:SetMouseVisible(false)
	self.author:SetText(args.Author)
	self.author:SetForeColor(Turbine.UI.Color(0.7, 0.7, 0.7))
	--self.author:SetBackColor(Turbine.UI.Color(0.5, 0, 0, 0))

	self:SetPlugin(args)
end

function control:SetChecked(val)
	self.checkbox:SetChecked(val)
end

function control:GetChecked()
	return self.checkbox:IsChecked()
end

function control:MouseClick(args)
	if self:GetChecked() then
		self:SetChecked(false)
	else
		self:SetChecked(true)
	end
end

function control:MouseEnter(args)
	self:SetBackColor(Turbine.UI.Color(0.5, 0.3, 0.3, 0.3))
	self:SetBackColorBlendMode(Turbine.UI.BlendMode.Overlay)--5
end

function control:MouseLeave(args)
	self:SetBackColor(Turbine.UI.Color(0.0, 0, 0, 0))
end

function control:SetPlugin(data)
	self._plugin = data
end

function control:GetPlugin()
	return self._plugin
end

Shady.Manager.item = control
