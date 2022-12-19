function onSay(unit, text)
	if(string.match(text, "/강제회수 ")) and (unit.player.name == "운영자이름으로해주세요") then
		text = text:gsub("/강제회수 ", "")
		text = split(text, " ")
		for i, v in ipairs(Server.players) do
		end
	end
end
Server.onSay.Add(onSay)