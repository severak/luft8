----
-- LUFT-8 Lua UTF-8 From To conversion library
----
-- (c) Severák 2013
----

local _LUFT8 = {}

_LUFT8.from_table = {}
_LUFT8.to_table = {}

_LUFT8.replace_from_fallback = "?"

local LUFT8 = {}

local function mbyte_from(mbyte)
	if _LUFT8.from_table[mbyte] then
		return _LUFT8.from_table[mbyte]
	end
	return _LUFT8.replace_from_fallback
end

function LUFT8.from(text)
	local res_buff = {}
	local len = string.len(text)
	local mbyte_buff = {}
	local mbyte_len = 0
	for i=1, len do
		local nchar = string.byte(text, i, i)
		-- pokud je to vícebajt, zapiš kolikabajt to je
		if nchar > 193 and nchar < 208 then
			mbyte_len = 2
		elseif nchar > 207 and nchar < 224 then
			mbyte_len = 2
		elseif nchar > 223 and nchar < 240 then
			mbyte_len = 3
		elseif nchar > 239 and nchar < 245 then
			mbyte_len = 4
		end
		if mbyte_len == 0 then
			-- print('rbuff', nchar, mbyte_len) 
			-- pokud jsme v jednobajtu přidáme ho na výsledek
			res_buff[ #res_buff + 1 ] = string.char(nchar)
		else 
			-- jinak hážeme na mezivýsledek
			-- print('mbuff', nchar, mbyte_len)
			mbyte_buff[ #mbyte_buff + 1 ] = string.char(nchar)
			if mbyte_len == 1 then
				-- když už máme vícebajt shluknutý, převedeme
				res_buff[ #res_buff + 1 ] = mbyte_from(table.concat(mbyte_buff))
				mbyte_buff = {}
			end
			-- odečteme od zbývajících písmen
			mbyte_len = mbyte_len - 1
		end
	end
	return table.concat(res_buff)
end

function LUFT8.to(text)
	local res_buff = {}
	local len = string.len(text)
	for i=1, len do
		local char = string.sub( text, i, i )
		print(char)
		if _LUFT8.to_table[char] then
			char = _LUFT8.to_table[char]
		end
		res_buff[ #res_buff + 1 ] = char
	end
	return table.concat(res_buff)
end

function LUFT8.set_encoding(codename)
	local codebook = require("luft8." .. codename)
	for from, to in pairs(codebook) do
		if type(to)=="number" then
			to = string.char(to)
		end
		_LUFT8.from_table[from] = to
		_LUFT8.to_table[to] = from
	end
end

return LUFT8