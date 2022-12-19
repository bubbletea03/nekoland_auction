
---------------------------------------------------------
--[[
세팅 해야할 부분이며, 안쓰는 번호로 등록바람
스트링변수와 변수는 별개이므로, 숫자가 중복되어도 상관없다.

한번에 많은 사람이 동시다발적으로 한 물건을 누르게 됬을때, 동시처리가 안되서 문제가 발생할 수 있다고 들은 적이 있습니다. (직접 보진 못했습니다. 혹, 발견하시면 제보해주세요)
이 점 유의하시고, 여러 테스트 이후 사용하여 주시길 바랍니다. 문제 발생 시 책임은 사용자에게 있습니다.
그 밖에 다른 문제 발생 시 제보 부탁드립니다.


Made By - HanRyang 한량
]]--
rubyitem_dataID = 438			--수정요망

varStringList_ruby = {106,107,108,109,110}
-- 아이템정보 저장 스트링변수번호

varString_Title_ruby = 100
-- 장터 간판 이름 저장 스트링변수번호

var_Open_ruby = 103
-- 장터오픈 유무 변수번호

var_item_ruby = 121
-- 아이템 선택 변수번호

var_safe_ruby = 102
-- 안전장치1 변수번호

global_Event_ruby = 502
-- 데이터베이스 - 공용이벤트 - '장터 아이템등록'이 있는 이벤트의 번호를 넣어주면 됩니다.

SuperGM_ruby = {"GM봉팔"}
-- 운영자 이름으로 넣어주시길 바랍니다. 대상 아이템을 강제로 회수시킬 수 있는 권한이 생깁니다.
-- {"한량","껄껄"} 이런식으로 두명 이상 지정 가능.

---------------------------------------------------------


s_market_ruby = {}


function s_market_ruby:GM(target_playerID,target_playerName)
	if not unit or not target_playerID then
		return
	end
	
	local ck = 0
	for i, v in ipairs(SuperGM_ruby) do
		if v or v ~= "" then
			if v == unit.player.name then
				ck = ck+1
				break
			end
		end
	end
	if ck <= 0 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 강제회수는 운영자 권한입니다.")
		s_market_ruby:target(target_playerID, target_playerName)
		return
	end
	
	for i, v in ipairs(Server.players) do
		if v.id == target_playerID then
			local count = 0
			for j, y in ipairs(varStringList_ruby) do
				if v.unit.GetStringVar(y) and v.unit.GetStringVar(y) ~= "" then
					count = count + 1
				end
			end
			if count <= 0 then
				unit.SendCenterLabel("<Color=Red>[System]</color> 등록된 아이템이 없습니다.")
				return
			end
			break
		end
	end
	
	for i, v in ipairs(Server.players) do
		if v.id == target_playerID then
			v.unit.SetVar(var_Open_ruby, 0)
			for j, y in ipairs(varStringList_ruby) do
				if v.unit.GetStringVar(y) and v.unit.GetStringVar(y) ~= "" then
					local list = Utility.JSONParse(v.unit.GetStringVar(y))
					v.unit.SetStringVar(y, "")
					v.unit.AddItem(list[1], list[2])
					local a = v.unit.player.GetItems()
					for k, z in ipairs(a) do
						if z.dataID == list[1] and #z.options == 0 and z.level == 0 then
							z.level = list[3]
							for m=5, #list, 3 do
								Utility.AddItemOption(z,list[m],list[m+1],list[m+2])
							end
							v.unit.player.SendItemUpdated(z)
						break
						end
					end
				end
			end
			s_market_ruby:target(v.id, v.name)
			unit.SendCenterLabel("<Color=Red>[System]</color> 성공적으로 모든 아이템을 강제회수 시켰습니다.")
			v.unit.SendCenterLabel("<Color=Red>[System]</color> 운영자가 장터에 등록된 아이템을 강제회수 시켰습니다.")
			break
		end
	end
end
Server.GetTopic("s_market_ruby:GM").Add(function(a,b) s_market_ruby:GM(a,b) end)


function s_market_ruby:text(a)
	if not unit then
		return
	end
	
	if a == 1 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 마지막 페이지 입니다.")
	elseif a == 2 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 첫 페이지 입니다.")
	elseif a == 3 then
		if unit.GetVar(var_Open_ruby) ~= 1 then
			unit.SendCenterLabel("<Color=Red>[System]</color> 장터를 열었습니다.")
			unit.SetVar(var_Open_ruby,1)
		else
			unit.SendCenterLabel("<Color=Red>[System]</color> 이미 열려있습니다.")
		end
	elseif a == 4 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 먼저 상품을 등록해주세요.")
	elseif a == 5 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 목록을 갱신합니다.")
	elseif a == 6 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 본인의 물건은 살 수 없습니다.")
	end
end
Server.GetTopic("s_market_ruby:text").Add(function(a) s_market_ruby:text(a) end)


function s_market_ruby:players()
	if not unit then
		return
	end
	
	local list = {[1]={},[2]={},[3]={}}
	
	for i, v in ipairs(Server.players) do
		if v.unit.GetVar(var_Open_ruby) == 1 then
			table.insert(list[1], v.id)
			if string.find(v.name,"/") ~= nil then
				local name = v.name
				name = name:gsub("/","")
				table.insert(list[2], name)
			else
				table.insert(list[2], v.name)
			end
			table.insert(list[3], v.unit.GetStringVar(varString_Title_ruby))
		end
	end
	
	if #list[1] <= 0 then
		unit.SendCenterLabel("<Color=Red>[System]</color> 장터에 올라간 물건이 없습니다.")
		return
	end

	list[1] = Utility.JSONSerialize(list[1])
	list[2] = Utility.JSONSerialize(list[2])
	list[3] = Utility.JSONSerialize(list[3])

	unit.FireEvent("c_market_ruby:players", list[1], list[2], list[3], unit.player.id)
end
Server.GetTopic("s_market_ruby:players").Add(function() s_market_ruby:players() end)


function s_market_ruby:target(target_id,target_name)
	if not unit or not target_id then
		return
	end
	
	local list = {}
	for i, v in ipairs(Server.players) do
		if v.id == target_id then
			for j, y in ipairs(varStringList_ruby) do
				if v.unit.GetStringVar(y) and v.unit.GetStringVar(y) ~= "" then
					table.insert(list, v.unit.GetStringVar(y))
				else
					table.insert(list, 0)
				end
			end
			unit.FireEvent("c_market_ruby:target_table", list[1], list[2], list[3], list[4], list[5], target_id, target_name)
			return
		end
	end
	unit.SendCenterLabel("<Color=Red>[System]</color>해당 유저는 서버에 없습니다(종료).")
	unit.FireEvent("c_market_ruby:players")
end
Server.GetTopic("s_market_ruby:target").Add(function(a,b) s_market_ruby:target(a,b) end)


function s_market_ruby:sellItemList()
	if not unit then
		return
	end
	
	local list = {}
	for i, v in ipairs(varStringList_ruby) do
		if unit.GetStringVar(v) and unit.GetStringVar(v) ~= "" then
			table.insert(list, unit.GetStringVar(v))
		else
			table.insert(list, 0)
		end
	end
	
	if not unit.GetStringVar(varString_Title_ruby) then
		unit.SetStringVar(varString_Title_ruby, "아이템 팝니다.")
	end
	
	unit.FireEvent("c_market_ruby:management", unit.GetStringVar(varString_Title_ruby), list[1], list[2], list[3], list[4], list[5])
end
Server.GetTopic("s_market_ruby:sellItemList").Add(function() s_market_ruby:sellItemList() end)


function s_market_ruby:reTitle(reTitle)
	if not unit or not reTitle then
		return
	end
	
	unit.SetStringVar(varString_Title_ruby, reTitle)
	s_market_ruby:sellItemList()
end
Server.GetTopic("s_market_ruby:reTitle").Add(function(a) s_market_ruby:reTitle(a) end)


function s_market_ruby:registerItem()
	if not unit then
		return
	end
	
	unit.StartGlobalEvent(global_Event_ruby)
end
Server.GetTopic("s_market_ruby:registerItem").Add(function() s_market_ruby:registerItem() end)


function s_market_ruby:registerItem2(item_price, num, item_count)
	if not unit or not item_price or not num or not item_count then
		return
	end
	
	local item = unit.player.GetItem(unit.GetVar(var_item_ruby))
	
	if item.count < item_count then -- 보안 검사
		unit.SendCenterLabel("<Color=Red>[System]</color> 아이템 수량이 이상합니다.")
		return
	end

	local list = {item.dataID,item_count,item.level,item_price}
	for i, v in ipairs(item.options) do
		table.insert(list, item.options[i].type)
		table.insert(list, item.options[i].statID)
		table.insert(list, item.options[i].value)
	end
	unit.RemoveItemByID(unit.GetVar(var_item_ruby),item_count)
	unit.SetStringVar(varStringList_ruby[num], Utility.JSONSerialize(list))
	s_market_ruby:sellItemList()
end
Server.GetTopic("s_market_ruby:registerItem2").Add(function(a,b,c) s_market_ruby:registerItem2(a,b,c) end)


function s_market_ruby:collectItem(num, check)
	if not unit or not num or not check then
		return
	end
	
	if not unit.GetStringVar(varStringList_ruby[num]) or  unit.GetStringVar(varStringList_ruby[num]) == "" or unit.GetStringVar(varStringList_ruby[num]) ~= check  then -- 1차 보안
		unit.SendCenterLabel("<Color=Red>[System]</color> 아이템이 이미 팔렸거나 회수되었습니다.")
		return
	end

	local item = Utility.JSONParse(unit.GetStringVar(varStringList_ruby[num]))
	--item[1] = dataID / [2] = count / [3] = level / [4] = price / ... options
	unit.SetStringVar(varStringList_ruby[num], nil)
	
	if unit.GetStringVar(varStringList_ruby[num]) and unit.GetStringVar(varStringList_ruby[num]) ~= "" then -- 2차 보안
		return
	end
	
	unit.AddItem(item[1], item[2])
	local a = unit.player.GetItems()
	for i, v in ipairs(a) do
		if v.dataID == item[1] and #v.options == 0 and v.level == 0 then
			v.level = item[3]
			for j=5, #item, 3 do
				Utility.AddItemOption(v,item[j],item[j+1],item[j+2])
			end
			unit.player.SendItemUpdated(v)
		break
		end
	end
	s_market_ruby:sellItemList()
	for i, v in ipairs(varStringList_ruby) do
		if unit.GetStringVar(varStringList_ruby[i]) and unit.GetStringVar(varStringList_ruby[i]) ~= "" then
			return
		end
	end
	unit.SetVar(var_Open_ruby, 0)
end
Server.GetTopic("s_market_ruby:collectItem").Add(function(a,b) s_market_ruby:collectItem(a,b) end)


function s_market_ruby:delay(u)
Server.RunLater(function()
	if not u then
		return
	end
	
	u.SetVar(var_safe_ruby, 0)
end,2)
end


function s_market_ruby:delay_reset()
if not unit then
	return
end
	
unit.SetVar(var_safe_ruby, 0)
end
Server.GetTopic("s_market_ruby:delay_reset").Add(function() s_market_ruby:delay_reset() end)


function s_market_ruby:buyItem(num,target_playerID,check)
	if not unit or not num or not target_playerID or not check then
		return
	end
	
	for i, v in ipairs(Server.players) do
		if v.id == target_playerID then
			if v.unit.GetVar(var_Open_ruby) == 0 then
				unit.SendCenterLabel("<Color=Red>[System]</color> 대상이 장터를 닫았습니다.")
				s_market_ruby:target(v.id, v.name)
				return
			end
		
			if v.unit.GetVar(var_safe_ruby) == 1 then
				unit.SendCenterLabel("<Color=Red>[System]</color> 대상이 거래중이오니 잠시후 다시 시도하세요.")
				s_market_ruby:target(v.id, v.name)
				return
			else
				v.unit.SetVar(var_safe_ruby, 1)
				s_market_ruby:delay(v.unit)
			end
			
			if not v.unit.GetStringVar(varStringList_ruby[num]) or v.unit.GetStringVar(varStringList_ruby[num]) == "" or v.unit.GetStringVar(varStringList_ruby[num]) ~= check then -- 1차 보안
				unit.SendCenterLabel("<Color=Red>[System]</color> 아이템이 이미 팔렸거나 회수됬습니다.")
				s_market_ruby:target(v.id, v.name)
				return
			end
			
			local item = Utility.JSONParse(v.unit.GetStringVar(varStringList_ruby[num]))
			
			if unit.CountItem(rubyitem_dataID) < item[4] then
				unit.SendCenterLabel("<Color=Red>[System]</color> 루비가 <Color=Yellow>" .. item[4]-unit.CountItem(rubyitem_dataID) .. "개</color> 만큼 모자랍니다.")
				s_market_ruby:target(v.id, v.name)
				return
			end
			
			v.unit.SetStringVar(varStringList_ruby[num], "")
	
			if v.unit.GetStringVar(varStringList_ruby[num]) and v.unit.GetStringVar(varStringList_ruby[num]) ~= "" then -- 2차 보안
				return
			end
			
			unit.AddItem(item[1], item[2])
			local a = unit.player.GetItems()
			for j, y in ipairs(a) do
				if y.dataID == item[1] and #y.options == 0 and y.level == 0 then
					y.level = item[3]
					for k=5, #item, 3 do
						Utility.AddItemOption(y,item[k],item[k+1],item[k+2])
					end
					unit.player.SendItemUpdated(y)
					unit.SendCenterLabel("<Color=Red>[System]</color> 정상적으로 구매되었습니다.")
					unit.RemoveItem(rubyitem_dataID,item[4])
					v.unit.AddItem(rubyitem_dataID,item[4])
					v.unit.SendCenterLabel("<Color=Red>[System] </color>장터에 등록한 <Color=Yellow>" .. Server.GetItem(item[1]).name .. "</color> 이(가) 팔렸습니다.")
					s_market_ruby:target(v.id, v.name)
				break
				end
			end
			
			for j, y in ipairs(varStringList_ruby) do
				if v.unit.GetStringVar(varStringList_ruby[j]) and v.unit.GetStringVar(varStringList_ruby[j]) ~= "" then
					return
				end
			end
			v.unit.SendCenterLabel("<Color=Red>[System] </color>모든 아이템이 팔렸습니다. 장터를 닫습니다.")
			v.unit.SetVar(var_Open_ruby, 0)
			break
		end
	end
end
Server.GetTopic("s_market_ruby:buyItem").Add(function(a,b,c) s_market_ruby:buyItem(a,b,c) end)

