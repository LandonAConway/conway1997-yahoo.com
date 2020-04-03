o_s_methods = {}

function o_s_methods.separate_string(inputstr, sep)
	if sep == nil then
		sep = ", "
	end
	
	local t = {}
	if string.find(inputstr, sep) then
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
		end
	else
		table.insert(t, inputstr)
	end
	
	return t
end

function o_s_methods.join_string(list, sep)
	if sep == nil then
		sep = ", "
	end
	
	return table.concat(list, sep)
end