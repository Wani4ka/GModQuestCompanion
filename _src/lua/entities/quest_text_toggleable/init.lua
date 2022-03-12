ENT.Type	= 'point'
ENT.Base	= 'quest_text_timed'


function ENT:SetupDataTables()
	self.Defaults.length = -1
	self.Defaults.showinlogs = false
	self.Parsers.length = function() return -1 end
	self.Parsers.showinlogs = function() return false end
	self.Validators.length = nil
end

function ENT:DoHide(ply)

	local kvs = self.kvs
	if not self:Validate(kvs) then return end

	net.Start('quest.hide')
		net.WriteUInt(self.uid, 31)
		net.WriteFloat(kvs.fadeout)
		net.WriteString(kvs.fadeoutstyle)
		net.WriteFloat(kvs.fadeoutdelay)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	name = name:lower()
	if name:sub(1, 2) == 'on' then
		self:FireOutput(name, activator, caller, args)
		return true
	elseif name == 'showtoactivator' then
		self:ValidateAndSend(activator)
	elseif name == 'showtoeveryone' then
		self:ValidateAndSend()
	elseif name == 'hidefromactivator' then
		self:DoHide(activator)
	elseif name == 'hidefromeveryone' then
		self:DoHide()
	end
end

function ENT:KeyValue(key, value)
	self.kvs = self.kvs or {}
	key = key:lower()
	if self.Parsers[key] then value = self.Parsers[key](value) end
	self.kvs[key] = value
end