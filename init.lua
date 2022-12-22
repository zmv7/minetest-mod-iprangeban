local stor = core.get_mod_storage()

core.register_on_prejoinplayer(function(name,ip)
	local stor_table = stor:to_table()
	local list = stor_table and stor_table.fields
	if not (name and ip and list) then return end
	for pat,_ in pairs(list) do
		if ip:match(pat) then
			return "Your IP ("..ip..") included in banned IP range: "..pat
		end
	end
end)

core.register_chatcommand("ipban",{
  description = "IP range banner",
  privs = {server=true},
  params = "<add|rm> <IP part> | <ls>",
  func = function(name,param)
	local action, ip = param:match("^(%S+) (.+)$")
	if not (action and ip) then
		action = param
		if action == "ls" then
			local stor_table = stor:to_table()
			local list = stor_table and stor_table.fields
			if not list then return end
			local out = {}
			for pat,_ in pairs(list) do
				table.insert(out, pat)
			end
			table.sort(out)
			return true, "List of patterns: "..table.concat(out,", ")
		end
		return false, "Invalid params"
	end
	local segs = ip:split(".")
	local pattern = {"%d+","%d+","%d+","%d+"}
	for i,seg in ipairs(segs) do
		if seg:match("%D+") then
			seg = "%d+"
		end
		pattern[i] = seg
	end
	local patstring = table.concat(pattern,".")
	if action == "add" then
		stor:set_string(patstring,"true")
		return true, "Added pattern: "..patstring
	end
	if action == "rm" then
		stor:set_string(patstring,"")
		return true, "Removed pattern: "..patstring
	end
end})
