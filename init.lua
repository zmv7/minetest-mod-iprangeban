local s = core.get_mod_storage()

local to_x = function(pat)
	return (pat and pat:gsub("%%d%+","X") or "error")
end

core.register_on_prejoinplayer(function(name,ip)
	local stor_table = s:to_table()
	local list = stor_table and stor_table.fields
	if not (name and ip and list) then return end
	for pat,descr in pairs(list) do
		if ip:match(pat) then
			return "Your IP ("..ip..") included in banned IP range: "..to_x(pat)..(descr and descr ~= "dummy" and " ("..descr..")" or "")
		end
	end
end)

core.register_chatcommand("ipban",{
  description = "IP range banner",
  privs = {server=true},
  params = "[<add> | <rm> <IP pattern> [description]] | <ls>",
  func = function(name,param)
	local action, ip_descr = param:match("^(%S+) (.+)$")
	if not (action and ip_descr) then
		action = param
		if action == "ls" then
			local stor_table = s:to_table()
			local list = stor_table and stor_table.fields
			if not list then return end
			local out = {}
			for pat,descr in pairs(list) do
				table.insert(out, to_x(pat)..(descr and descr ~= "dummy" and "("..descr..")" or ""))
			end
			table.sort(out)
			return true, "List of patterns: "..table.concat(out,", ")
		end
		return false, "Invalid params"
	end
	local ip, descr = ip_descr:match("^(%S+) (.+)$")
	if not (ip and descr) then
		ip = ip_descr
		descr = "dummy"
	end
	local segs = ip:split(".")
	local pattern = {"%d+","%d+","%d+","%d+"}
	for i,seg in ipairs(segs) do
		if seg:match("%D+") then
			seg = "%d+"
		end
		pattern[i] = seg
	end
	local pat = table.concat(pattern,".")
	if action == "add" then
		s:set_string(pat,descr)
		return true, "Added pattern: "..to_x(pat)
	end
	if action == "rm" then
		s:set_string(pat,"")
		return true, "Removed pattern: "..to_x(pat)
	end
end})
