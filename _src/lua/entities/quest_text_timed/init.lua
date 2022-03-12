ENT.Type	= 'point'

local tonumber, writeTable, writeFloat, writeString, writeBool, writeUInt, writeColor = tonumber, net.WriteTable, net.WriteFloat, net.WriteString, net.WriteBool, net.WriteUInt, net.WriteColor

include 'qt_validate.lua'

ENT.Defaults = {
	localizationkeys = {},
	length = 10,
	fadein = 0.25,
	fadeinstyle = 'together',
	fadeindelay = 0,
	fadeout = 0.25,
	fadeoutstyle = 'together',
	fadeoutdelay = 0,
	showinlogs = true,
	type = '',
	fontweight = 500,
	alignment = TEXT_ALIGN_CENTER,
	textcolor = color_white,
	spawnflags = 0,
}
ENT.Parsers = {
	localizationkeys = function(val) return val:Split(',') end,
	length = tonumber,
	fadein = tonumber,
	fadeindelay = tonumber,
	fadeout = tonumber,
	fadeoutdelay = tonumber,
	showinlogs = tobool,
	marginleft = tonumber,
	margintop = tonumber,
	marginright = tonumber,
	marginbottom = tonumber,
	fontsize = tonumber,
	fontweight = function(val) return math.floor(val) or -1 end,
	alignment = function(val) return _G['TEXT_ALIGN_' .. val:upper()] end,
	textcolor = function(val) return string.ToColor(val .. ' 255') end,
}

function ENT:Initialize()
	self.uid = math.random(2147483647)
	self.kvs = self.kvs or {}
	for k, v in pairs(self.Defaults) do
		if self.kvs[k] == nil then
			self.kvs[k] = v
		end
	end
end


function ENT:ValidateAndSend(target)

	local kvs = self.kvs
	if not self:Validate(kvs) then
		return
	end

	net.Start(kvs.type ~= '' and 'quest.sendTyped' or 'quest.sendCustom')

		writeUInt(self.uid, 31)
		writeTable(kvs.localizationkeys)
		writeFloat(kvs.length)
		writeFloat(kvs.fadein)
		writeString(kvs.fadeinstyle)
		writeFloat(kvs.fadeindelay)
		writeFloat(kvs.fadeout)
		writeString(kvs.fadeoutstyle)
		writeFloat(kvs.fadeoutdelay)
		writeBool(kvs.showinlogs)
	
		if kvs.type == '' then
			writeTable({
				top = kvs.margintop,
				left = kvs.marginleft,
				right = kvs.marginright,
				bottom = kvs.marginbottom,
			})
			writeString(kvs.fontname)
			writeFloat(kvs.fontsize)
			writeUInt(kvs.fontweight, 11)
			writeUInt(kvs.spawnflags, 3)
			writeColor(kvs.textcolor)
			writeUInt(kvs.alignment, 2)
		else
			writeString(kvs.type)
		end

	if not target then
		net.Broadcast()
	else
		net.Send(target)
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
	end
end

function ENT:KeyValue(key, value)
	self.kvs = self.kvs or {}
	key = key:lower()
	if self.Parsers[key] then value = self.Parsers[key](value) end
	self.kvs[key] = value
end