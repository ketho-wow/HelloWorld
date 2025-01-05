HelloWorld = CreateFrame("Frame")

function HelloWorld:OnEvent(event, ...)
	self[event](self, event, ...)
end
HelloWorld:SetScript("OnEvent", HelloWorld.OnEvent)
HelloWorld:RegisterEvent("ADDON_LOADED")

function HelloWorld:ADDON_LOADED(event, addOnName)
	if addOnName == "HelloWorld" then
		HelloWorldDB = HelloWorldDB or {}
		self.db = HelloWorldDB
		for k, v in pairs(self.defaults) do
			if self.db[k] == nil then
				self.db[k] = v
			end
		end
		self.db.sessions = self.db.sessions + 1
		print("You loaded this addon "..self.db.sessions.." times")

		local version, build, _, tocversion = GetBuildInfo()
		print(format("The current WoW build is %s (%d) and TOC is %d", version, build, tocversion))

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		hooksecurefunc("JumpOrAscendStart", self.JumpOrAscendStart)

		self:InitializeOptions()
		self:UnregisterEvent(event)
	end
end

function HelloWorld:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	if isLogin and self.db.hello then
		DoEmote("HELLO")
	end
end

-- note we don't pass `self` here because of hooksecurefunc, hence the dot instead of colon
function HelloWorld.JumpOrAscendStart()
	if HelloWorld.db.jump then
		print("Your character jumped.")
	end
end

function HelloWorld:COMBAT_LOG_EVENT_UNFILTERED(event)
	-- it's more convenient to work with the CLEU params as a vararg
	self:CLEU(CombatLogGetCurrentEventInfo())
end

local playerGUID = UnitGUID("player")
local MSG_DAMAGE = "Your %s hit %s for %d damage."

function HelloWorld:CLEU(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
	local isDamageEvent

	if subevent == "SWING_DAMAGE" then
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
		isDamageEvent = true
	elseif subevent == "SPELL_DAMAGE" then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
		isDamageEvent = true
	end

	if isDamageEvent and sourceGUID == playerGUID then
		-- get the link of the spell or the MELEE globalstring
		local action = spellId and C_Spell.GetSpellLink(spellId) or MELEE
		print(MSG_DAMAGE:format(action, destName, amount))
	end
end

SLASH_HELLOW1 = "/hw"
SLASH_HELLOW2 = "/helloworld"

SlashCmdList.HELLOW = function(msg, editBox)
	Settings.OpenToCategory(HelloWorld.panel_main.name)
end
