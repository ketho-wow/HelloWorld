HelloWorld.defaults = {
	sessions = 0,
	hello = false,
	mushroom = false,
	jump = true,
	combat = true,
	--someNewOption = "banana",
}

local function CreateIcon(icon, width, height, parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(width, height)
	f.tex = f:CreateTexture()
	f.tex:SetAllPoints(f)
	f.tex:SetTexture(icon)
	return f
end

local function RegisterCanvas(frame)
	local cat = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name);
	cat.ID = frame.name
	Settings.RegisterAddOnCategory(cat)
end

function HelloWorld:CreateCheckbox(option, label, parent, updateFunc)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb.Text:SetText(label)
	local function UpdateOption(value)
		self.db[option] = value
		cb:SetChecked(value)
		if updateFunc then
			updateFunc(value)
		end
	end
	UpdateOption(self.db[option])
	-- there already is an existing OnClick script that plays a sound, hook it
	cb:HookScript("OnClick", function(_, btn, down)
		UpdateOption(cb:GetChecked())
	end)
	EventRegistry:RegisterCallback("HelloWorld.OnReset", function()
		UpdateOption(self.defaults[option])
	end, cb)
	return cb
end

function HelloWorld:InitializeOptions()
	-- main panel
	self.panel_main = CreateFrame("Frame")
	self.panel_main.name = "HelloWorld"

	local cb_hello = self:CreateCheckbox("hello", "Do the |cFFFFFF00/hello|r emote when you login", self.panel_main)
	cb_hello:SetPoint("TOPLEFT", 20, -20)

	local cb_mushroom = self:CreateCheckbox("mushroom", "Show a mushroom on your screen", self.panel_main, self.UpdateIcon)
	cb_mushroom:SetPoint("TOPLEFT", cb_hello, 0, -30)

	local cb_jump = self:CreateCheckbox("jump", "Print when you jump", self.panel_main)
	cb_jump:SetPoint("TOPLEFT", cb_mushroom, 0, -30)

	local cb_combat = self:CreateCheckbox("combat", "Print when you damage a unit", self.panel_main, function(value)
		self:UpdateEvent(value, "COMBAT_LOG_EVENT_UNFILTERED")
	end)
	cb_combat:SetPoint("TOPLEFT", cb_jump, 0, -30)

	local btn_reset = CreateFrame("Button", nil, self.panel_main, "UIPanelButtonTemplate")
	btn_reset:SetPoint("TOPLEFT", cb_combat, 0, -40)
	btn_reset:SetText(RESET)
	btn_reset:SetWidth(100)
	btn_reset:SetScript("OnClick", function()
		HelloWorldDB = CopyTable(HelloWorld.defaults)
		self.db = HelloWorldDB
		EventRegistry:TriggerEvent("HelloWorld.OnReset")
	end)

	RegisterCanvas(self.panel_main)

	-- sub panel
	local panel_shroom = CreateFrame("Frame")
	panel_shroom.name = "Shrooms"
	panel_shroom.parent = self.panel_main.name

	for i = 1, 10 do
		local icon = CreateIcon("interface/icons/inv_mushroom_11", 32, 32, panel_shroom)
		icon:SetPoint("TOPLEFT", 20, -32*i)
	end

	RegisterCanvas(panel_shroom)
end

function HelloWorld.UpdateIcon(value)
	if not HelloWorld.mushroom then
		HelloWorld.mushroom = CreateIcon("interface/icons/inv_mushroom_11", 64, 64, UIParent)
		HelloWorld.mushroom:SetPoint("CENTER")
	end
	HelloWorld.mushroom:SetShown(value)
end

-- a bit more efficient to register/unregister the event when it fires a lot
function HelloWorld:UpdateEvent(value, event)
	if value then
		self:RegisterEvent(event)
	else
		self:UnregisterEvent(event)
	end
end
