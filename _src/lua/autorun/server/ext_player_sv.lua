local meta = FindMetaTable 'Player'

local function unpackValue(tbl)
	if not istable(tbl) then return end
	return tbl[1]
end
function meta:GetQuestProperty(val)
	local cfg = QuestConfig
	if not istable(cfg) then return end
	if not istable(cfg[self]) then
		return unpackValue(cfg[val])
	end
	local current, everyone = cfg[self][val], cfg[val]
	if not istable(current) then
		return unpackValue(everyone)
	elseif not istable(everyone) then
		return unpackValue(current)
	end
	return current[2] > everyone[2] and current[1] or everyone[1]
end

function meta:UpdateQuestSpeed()
	local val = self:GetQuestProperty('walkspeed')
	if val then self:SetWalkSpeed(val) end
	val = self:GetQuestProperty('slowwalkspeed')
	if val then self:SetSlowWalkSpeed(val) end
	val = self:GetQuestProperty('runspeed')
	if val then self:SetRunSpeed(val) end
	val = self:GetQuestProperty('climbspeed')
	if val then self:SetLadderClimbSpeed(val) end
	val = self:GetQuestProperty('crouchspeed')
	if val then self:SetCrouchedWalkSpeed(val) end
	val = self:GetQuestProperty('jumppower')
	if val then self:SetJumpPower(val) end
end

function meta:UpdateQuestNetwork()
	net.Start('quest.updateClientside')
		net.WriteBool(self:GetQuestProperty('showhealth'))
	net.Send(self)
end