local diet = require 'diet'
local gmatch = string.gmatch

local arg = {...}  -- program arguments
if not arg[1] then print('pass the path to file with paths to files') return end

local fList = io.open(arg[1], 'r+')
local filesStr = fList:read('*a')
fList:close()
local files = {}
for f in gmatch(filesStr, '%S+') do
	files[#files + 1] = f
end

for _, f in ipairs(files) do
	print('compressing ' .. f)
	local fIn = io.open(f, 'r+')
	local content = fIn:read '*a'
	fIn:close()
	content = diet.optimize(content)
	local fOut = io.open(f, 'w')
	fOut:write(content)
	fOut:close()
end