local function checkNumber(a, min, max)
	return isnumber(a) and (not min or min <= a) and (not max or a <= max)
end
local youDidntDefine = 'You didn\'t define type, so you have to define '

ENT.Validators = {
	localizationkeys = function(val) return val[1], 'Why would you show an empty text? (no localizationkeys)' end,
	length = function(val) return checkNumber(val, 0), 'length should be positive' end,
	fadein = function(val) return checkNumber(val, 0), 'fadein should be positive' end,
	fadeinstyle = function(val) return val == 'together' or val == 'independently', 'fadeinstyle should be either "together" or "independently"' end,
	fadeindelay = function(val) return checkNumber(val, 0), 'fadeindelay should be positive' end,
	fadeout = function(val) return checkNumber(val, 0), 'fadeout should be positive' end,
	fadeoutstyle = function(val) return val == 'together' or val == 'independently', 'fadeoutstyle should be either "together" or "independently"' end,
	fadeoutdelay = function(val) return checkNumber(val, 0), 'fadeoutdelay should be positive' end,
	type = function(val) return val == '' or MapConfig.TypesData[val], val .. ' is not a registered type' end,
	fontname = function(val, kvs) return kvs.type ~= '' or (isstring(val) and val ~= ''), youDidntDefine .. 'font name' end,
	fontsize = function(val, kvs) return kvs.type ~= '' or checkNumber(val, 0), youDidntDefine .. 'font size' end,
	fontweight = function(val, kvs) return kvs.type ~= '' or checkNumber(val, 0), youDidntDefine .. 'font weight' end,
	alignment = function(val, kvs) return kvs.type ~= '' or (val == 0 or val == 1 or val == 2), youDidntDefine .. 'alignment' end,
	textcolor = function(val, kvs) return kvs.type ~= '' or IsColor(val), youDidntDefine .. 'text color' end,
	_custom = function(kvs)
		if kvs.type ~= '' then return true end
		local margin = {kvs.margintop, kvs.marginleft, kvs.marginright, kvs.marginbottom}
		local isOk = false
		for _, v in pairs(margin) do
			if isnumber(v) then
				isOk = true
				break
			end
		end
		return isOk, youDidntDefine .. 'any of margintop/marginleft/marginright/marginbottom'
	end,
}

function ENT:Nag(msg)
	if not MapConfig.ShutUp then
		ErrorNoHalt(('%s: %s'):format(self:GetName() or 'anonymous ' .. self.ClassName, msg))
	end
	return false
end

function ENT:Validate(kvs)
	if not istable(kvs) then return self:Nag('Why did you break the script?') end

	for key, validator in pairs(self.Validators) do
		if key == '_custom' then continue end
		local ok, msg = validator(kvs[key], kvs)
		if not ok then return self:Nag(msg) end
	end
	if self.Validators._custom then
		local ok, msg = self.Validators._custom(kvs)
		if not ok then return self:Nag(msg) end
	end

	return true

end