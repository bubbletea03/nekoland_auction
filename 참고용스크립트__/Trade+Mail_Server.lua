--[[
	제작 : 사랑요(수니몬)
	거래소 베타버전 2
	
	컴퓨터환경으로 테스트 했을 때는 확인된 문제가 없었으나
	모바일환경에서는 어떤 문제가 있을지 몰라요.
	버그 발생 시 책임지지 않습니다.
	
	※ 월드변수랑 월드스트링변수는 다른거에요!
	※ 마찬가지로 변수랑 개인스트링변수랑 달라요.
	※ 클라이언트 스크립트 파일은 2개고 파일이름을 바꾸시지 않는걸 추천해요.
		왜냐하면 글자순으로 읽어올 때 Mail이 먼저 실행되어야해요.
	
	✐ onJoinPlayer 사용중
	✐ 아이템 검색 미구현
	✐ 랜덤정렬 지원 (가격순 정렬은 테이블 구조 때문에 포기했듬..)
	
	☑ 사용법
	거래소[서버] : unit.FireEvent('거래소_open')
	거래소[클라] : Client.FireEvent('거래소_open')
	
	소포함[서버] : mail_main()
	소포함[클라] : Client.FireEvent('소포함_open')
	
	
]]


local tradeVar = {
	[0] = 1, -- 모자
	[1] = 2, -- 갑옷
	[2] = 3, -- 무기
	[3] = 4, -- 방패
	[4] = 5, -- 신발
	[5] = 6, -- 반지
	[6] = 7, -- 악세
	[7] = 8, -- 날개
	[8] = 9, -- 포션
	[9] = 10, -- 재료
	[10] = 11 -- 소모품
}
local nameType = {[0]='모자', '갑옷', '무기', '방패', '신발', '반지', '악세서리', '날개', '포션', '재료', '소모품'}
local mailVar = 12 -- 소포함 대기
local avgVar = 13 -- 최근 거래가(3000개 정도 입력가능)
local sellVar = 14 -- 판매완료 거래로그
-- 월드스트링 변수

local NtradeVar = 0 -- 거래소 안전변수
local packageVar = 1 -- 소포함 안전변수
local feeVar = 2 -- 거래 수수료가 쌓이는 변수
-- 월드변수
-- 여기까지는 전부 월드변수 혹은 월드스트링 변수 입력
--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
※ 연산겹침 메세지가 계~~속 뜨면 운영자 아이디로 들어가서 다음과 같이 채팅창에 쳐주세요.

	[거래소]
	/script Server.SetWorldStringVar(거래소 안전변수 번호, 0) 
	거래소 안전변수 번호 << 여기에는 위에 48번째 줄에 작성한 그 번호가 들어가야겠죠?
	
	[소포함]
	/script Server.SetWorldStringVar(소포함 안전변수 번호, 0) 
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]]

local pnalVar = 14
-- 개인스트링변수

local global_Event = 60
-- 아이템 선택 공용이벤트

Global_ItemVar = 142
-- 아이템 선택 변수번호

local upcount = 4
-- 개인이 카테고리당 등록할 수 있는 아이템 건수
-- 서버스트링은 한정적이기 때문에 upcount는 10 이 넘지않는 것이 좋습니다.

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local TemDataID = 77
--[[	거래소 재화 - 골드:-1 / 아이템:dataID
		즉, -1 넣으면 골드가 거래소 거래재화가 되고,
		아이템 번호를 넣으면 그 아이템이 재화가 돼요. OK?
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]]

local fee = 5 
-- 거래 수수료 5%

local days = 3 -- 미구현
-- 거래소에 올라간 아이템이 3일간 안팔릴 경우 자동으로 소포함 반송

--[[
	[거래소 로직]
	
	아이템 올리기 -> 서버스트링 저장 -> 클라이언트 UI 표시
	
	거래소 물건이 판매됨 -> 서버스트링 저장 -> 유저가 소포함을 열면 개인스트링으로 옮겨짐
	
	os.time()+32400 이 중복으로 더해지는 점 본섭적용 확인
	
	서버스트링 0~1022 값 까지 들어갈 수 있음.
]]


local SetSvar, GetSvar = Server.SetWorldStringVar, Server.GetWorldStringVar
local SetNvar, GetNvar = Server.SetWorldVar, Server.GetWorldVar
local GetTem = Server.GetItem
local goldName = Server.GetStrings().gameMoney == '' and '골드' or string.gsub(Server.GetStrings().gameMoney, "{0} ", "")


local function table_check()
	local bool = nil
	local dumy_table = {}
	local k = 1
	for i=0, 10 do dumy_table[k]=tradeVar[i] k=k+1 end
	for i, v in ipairs(dumy_table) do 
		for j, b in ipairs(dumy_table) do 
			if i~=j and v==b then
				bool = 'key 중복 오류'
				return bool
			end
		end
		if v==nil or not tonumber(v) then
			bool = 'key 값이 없거나 number가 아님'
			return bool
		end
		
		if GetSvar(v)==nil or GetSvar(v)=='' then
			-- SetSvar(v, '{"0":0}')
			SetSvar(v, '[]')
		end
	end
	
	if GetSvar(mailVar)==nil or GetSvar(mailVar)=='' then
		SetSvar(mailVar, '[]')
	end
	
	if GetSvar(avgVar)==nil or GetSvar(avgVar)=='' then
		SetSvar(avgVar, '[]')
	end
	
	if GetSvar(sellVar)==nil or GetSvar(sellVar)=='' then
		SetSvar(sellVar, '[]')
	end
	
	return bool
end

local check = table_check()
if check then
	Server.RunLater(function()
		Server.SendSay('<color=#F78181>[#] 거래소 스크립트 테이블이 잘못되었습니다.</color><color=#FFBF00>\n사유 : '..check..'</color>')
	end, 1)
end
check = nil

local function Perfect_Remove(txt, key)
	local f, b = {',"', '"', '"'}, {'":{}', '":{},', '":{}'}
	local x, y = nil, nil
	for i=1, 3 do
		x, y = string.find(txt, f[i]..tostring(key)..b[i])
		if x then
			break
		end
	end
	if x and y then
		local Sb = string.sub
		local txt1 = Sb(txt, 1, x-1)
		local txt2 = Sb(txt, y+1, #txt)
		txt = txt1..txt2
	end
	return txt
end




local function goods(num, value)
	if num==1 then -- 소지(개수확인)
		if TemDataID == -1 then
			return unit.gameMoney
		else
			return unit.CountItem(TemDataID)
		end
	elseif num==2 then -- Use(소비)
		if value then
			if TemDataID == -1 then
				if unit.gameMoney >= value then
					unit.UseGameMoney(value)
					return true
				else
					unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> "..goldName.." 부족합니다.</size>")
					return false
				end
			else
				if unit.CountItem(TemDataID) >= value then
					unit.RemoveItem(TemDataID, value)
					return true
				else
					unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> "..Server.GetItem(TemDataID).name.."이(가) 부족합니다.</size>")
					return false
				end
			end
		end
	elseif num==3 then -- Add(획득)
		if value then
			if TemDataID == -1 then
				unit.AddGameMoney(value)
				return true
			else
				unit.AddItem(TemDataID, value)
				return true
			end
		end
	end
end





local trade = {}
function trade.registerItem()
	if not unit then
		return
	end
	
	unit.StartGlobalEvent(global_Event)
end
Server.GetTopic("trade.registerItem").Add(trade.registerItem)


function trade.set_selectItem(itemId, cnt, lv) -- 아이템 선택 후
	if not unit then
		return
	end
	
	local t = Server.GetItem(itemId).type
	if #GetSvar(tradeVar[t]) > 50000 then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> "..nameType[t].." 카테고리가 꽉찼습니다.</size>")
		return 
	end
	local serverT = Utility.JSONParse(GetSvar(tradeVar[t]))
	local d = serverT[tostring(unit.player.id)]
	if d and #d >= upcount then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 카테고리당 "..upcount.."건까지 아이템 등록이 가능합니다.</size>")
		return 
	end
	
	unit.FireEvent("trade.setPrice", itemId, cnt, lv)
end
Server.GetTopic("trade.set_selectItem").Add(trade.set_selectItem)

function trade.registerItem2(item_price, item_count) -- 등록/판매 입력
	if not unit or not item_price or not item_count then
		return
	end
	
	local item = unit.player.GetItem(unit.GetVar(Global_ItemVar))
	
	if item.count < item_count then -- 개수 검사
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 아이템 수량이 맞지 않습니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	local item_type = GetTem(item.dataID).type
	local keyValue = tradeVar[item_type]
	
	if GetNvar(NtradeVar) == 1 then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 연산겹침. 잠시 후 다시 시도해주세요.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	SetNvar(NtradeVar, 1)
	local list_table = Utility.JSONParse(GetSvar(keyValue))
	--[[
		서버스트링 용량을 최소로 하기위해 변수 이름도 최대한 짧게 설정
		[테이블 구성]
		key값 = 스트링 + unit.player.id
		I = dataID
		t = 시간
		lv = 레벨
		op = {t=type, i=statID, v=value}
		s = 개당판매금액
		c = 판매개수
	]]
	local data = list_table[tostring(unit.player.id)]
	
	if not data then
		data = {}
	end
	
	local Len = #data+1
	data[Len] = {
		I=item.dataID, 
		t=math.floor(os.time()+32400),
		lv=item.level,
		op = {t={}, i={}, v={}},
		s = item_price,
		c = item_count
	}
	
	for i, v in ipairs(item.options) do
		data[Len].op.t[i] = v.type
		data[Len].op.i[i] = v.statID
		data[Len].op.v[i] = v.value
	end
	
	
	
	list_table[tostring(unit.player.id)] = data
	SetSvar(keyValue, Utility.JSONSerialize(list_table))
	SetNvar(NtradeVar, 0)
	unit.RemoveItemByID(item.id, item_count)
	
	unit.FireEvent("trade_management", item_type+1, GetSvar(keyValue), GetSvar(avgVar))
end
Server.GetTopic("trade.registerItem2").Add(trade.registerItem2)

function trade.registerItem3(num)
	if not unit or not num then
		return
	end
	
	local keyValue = tradeVar[num-1]
	
	unit.FireEvent("trade_management", num, GetSvar(keyValue), GetSvar(avgVar))
end
Server.GetTopic("trade.registerItem3").Add(trade.registerItem3)

function trade.registerItem4(txt, num, count) -- 등록/구매 입력
	if not unit or not txt or not num then
		return
	end
	
	local keyValue = tradeVar[num-1]
	local itemT = Utility.JSONParse(txt)
	
	if itemT.c < count then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 아이템 수량이 맞지 않습니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	if itemT.s*count > goods(1) then
		local str = TemDataID==-1 and goldName or Server.GetItem(TemDataID).name
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> "..str.."가(이) 부족합니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	local playerID = tostring(itemT.playerID)
	
	if unit.player.id == tonumber(itemT.playerID) then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 나의 아이템은 구매할 수 없습니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	local serverT = Utility.JSONParse(GetSvar(keyValue))
	if not serverT[playerID] or not serverT[playerID][itemT.key] then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 거래가 종료된 아이템입니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	local list = serverT[playerID][itemT.key]
	
	if list.t~=itemT.t or list.I~=itemT.I or list.s~=itemT.s then
		-- 해당 아이템이 맞는지 확인
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 거래가 종료된 아이템입니다.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	if count / list.c <= 0.099 then
--		[주의사항]
--		불편하지만 최소개수를 10%로 설정해놓은 이유는
--		1개씩 계속 사들이면 서버스트링변수에 데이터가 계속 쌓이기 때문에
--		서버부하에 안좋고 소포함 오작동이 발생할 가능성이 있습니다.
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 구매개수가 적습니다.\n최소 개수 10% 이상 구매해 주세요.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	if GetNvar(NtradeVar) == 1 then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 연산겹침. 잠시 후 다시 시도해주세요.</size>")
		unit.FireEvent('거래소_로딩패널삭제')
		return
	end
	
	SetNvar(NtradeVar, 1)
	
	local item = Server.CreateItem(list.I, count)
	for i, v in ipairs(list.op.t) do
		Utility.AddItemOption(item, v, list.op.i[i], list.op.v[i])
	end
	item.level = list.lv
	-- unit.UseGameMoney(itemT.s*count)
	goods(2, itemT.s*count)
	unit.AddItemByTItem(item, true)
	--========소포함 시작==============================================================================================
	local list_table = nil
	if GetSvar(mailVar)==nil or GetSvar(mailVar)=='' then
		list_table = {}
	else
		list_table = Utility.JSONParse(GetSvar(mailVar))
	end
	--[[
		[테이블 구성]
		key값 = 스트링 + itemT.playerID
		count = 판매된 개수
		sellTime = 판매된 시각
		sellName = 구매자 닉네임
		goldType = 재화 타입
		RemoveType = 회수 타입('Gold', 'Item')
	]]
	local data = list_table[playerID]
	if not data then
		data = {}
	end
	
	local Len = #data+1
	data[Len] = list
	data[Len].count = count
	data[Len].sellTime = math.floor(os.time()+32400)
	data[Len].sellName = string.gsub(unit.player.name, '/', 'n_Q5s')
	data[Len].goldType = TemDataID
	data[Len].RemoveType = 'Gold'
	
	list_table[playerID] = data
	SetSvar(mailVar, Utility.JSONSerialize(list_table))
	local u = Unit_data[tonumber(itemT.playerID)]
	if u~=nil then
		local txt = '<color=#00FF00><color=#FFFF00>[거래소]</color> '..Server.GetItem(data[Len].I).name..' 판매되었습니다.\n소포함을 확인해주세요.</color>'
		u.SendSay(txt)
	end
	--======================================================================================================
	local avgTbl = Utility.JSONParse(GetSvar(avgVar))
	avgTbl[tostring(list.I)] = list.s
	SetSvar(avgVar, Utility.JSONSerialize(avgTbl))
	--======================================================================================================
	
	list.c = list.c - count
	if list.c < 1 then
		table.remove(serverT[playerID], itemT.key)
	else
		serverT[playerID][itemT.key].c = list.c
	end
	
	local txt0 = Utility.JSONSerialize(serverT)
	if serverT[playerID] and #serverT[playerID] == 0 then
		txt0 = Perfect_Remove(txt0, playerID)
	end
	SetSvar(keyValue, txt0)
	SetNvar(NtradeVar, 0)
	unit.FireEvent("trade_management", num, GetSvar(keyValue), GetSvar(avgVar))
end
Server.GetTopic("trade.registerItem4").Add(trade.registerItem4)

Server.GetTopic("거래소_아이템회수").Add(function(txt, num)
	if not unit or not txt or not num then
		return
	end
	
	
	local itemT = Utility.JSONParse(txt)
	
	if unit.player.id ~= tonumber(itemT.playerID) then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 나의 아이템만 회수 가능합니다.</size>")
		return
	end
	local keyValue = tradeVar[num-1]
	local playerID = tostring(itemT.playerID)
	local serverT = Utility.JSONParse(GetSvar(keyValue))
	if not serverT[playerID] or not serverT[playerID][itemT.key] then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 거래가 종료된 아이템입니다.</size>")
		return
	end
	
	local list = serverT[playerID][itemT.key]
	if list.t~=itemT.t or list.I~=itemT.I or list.s~=itemT.s then
		-- 해당 아이템이 맞는지 확인
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 거래가 종료된 아이템입니다.</size>")
		return
	end
	
	if GetNvar(NtradeVar) == 1 then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[거래소]</color> 연산겹침. 잠시 후 다시 시도해주세요.</size>")
		return
	end
	
	SetNvar(NtradeVar, 1)
	
	local list_table = nil
	if GetSvar(mailVar)==nil or GetSvar(mailVar)=='' then
		list_table = {}
	else
		list_table = Utility.JSONParse(GetSvar(mailVar))
	end
	
	local data = list_table[playerID]
	if not data then
		data = {}
	end
	
	local Len = #data+1
	data[Len] = list
	data[Len].count = list.c
	data[Len].sellTime = math.floor(os.time()+32400)
	data[Len].sellName = string.gsub(unit.player.name, '/', 'n~Q5 ')
	data[Len].goldType = TemDataID
	data[Len].RemoveType = 'Item'
	
	list_table[playerID] = data
	local txt = '<color=#00FF00><color=#FFFF00>[거래소]</color> 회수 완료. 우편함을 확인하세요.</color>'
	unit.SendSay(txt)
	unit.SendCenterLabel('<size=15>'..txt..'</size>')
	SetSvar(mailVar, Utility.JSONSerialize(list_table))
	
	table.remove(serverT[playerID], itemT.key)
	
	local txt0 = Utility.JSONSerialize(serverT)
	if serverT[playerID] and #serverT[playerID] == 0 then
		txt0 = Perfect_Remove(txt0, playerID)
	end
	SetSvar(keyValue, txt0)
	SetNvar(NtradeVar, 0)
	unit.FireEvent("trade_management", num, GetSvar(keyValue), GetSvar(avgVar))
end)


local dumy_table = {}
local itemData = Server.GetItem
local Max = 0
for i=3, 0, -1 do
	local a = 10^i
	for j=10^(i+1)-a,a,-a do
		if itemData(Max + j) then
			Max = Max + j
			break
		end
	end
end
local j = 1
local Type = 0 -- 0은 모자
for i=0, Max do
	if itemData(i).name ~= '' and itemData(i).canTrade and itemData(i).maxCount==1 and itemData(i).type==Type then
		dumy_table[j] = i
		j = j+1
	end
end

local function dataAdd() -- 테스트를 위한 거래소 아이템 랜덤 생성(모자부분)
--[테스트환경에서만 사용하시고 본섭에서는 사용하지 마세요.]
	local start = '{'
	local End = '}'
	local txt = ''
	local u, r = 1, 500
	for i=u, r do
		local mid = '"'..i..'":[{"I":'..dumy_table[rand(1, #dumy_table+1)]..',"t":'
		..math.floor(os.time()-rand(100, 1000))..',"lv":'..rand(1, 99)..',"op":{"t":['..rand(0, 5)..'],"i":['..rand(0, 8)..'],"v":['..rand(100000,999999)
		..']},"s":'..rand(1,999999)..',"c":1}]'
		if i==r then
			txt = start..txt..mid..End
		else
			txt = txt..mid..','
		end
	end
	
	SetSvar(tradeVar[Type], txt)
end
-- dataAdd()
local function dataRemove(num) -- 거래소 아이템 모두삭제 
--[테스트환경에서만 사용하시고 본섭에서는 사용하지 마세요.]
	SetSvar(num, '{}')
end

function mail_main()
	if GetNvar(packageVar) == 1 then
		unit.FireEvent('프레시_알림창', "<size=15><Color=Red>[소포함]</color> 연산겹침. 잠시 후 다시 시도해주세요.</size>")
		unit.FireEvent('소포함_로딩패널삭제')
		return
	end
	
	local list_table = nil 
	if GetSvar(mailVar)==nil or GetSvar(mailVar)=='' then
		list_table = {}
	else
		list_table = Utility.JSONParse(GetSvar(mailVar))
	end
	
	local data = list_table[tostring(unit.player.id)]
	if not data then
		unit.FireEvent('소포함_open', unit.GetStringVar(pnalVar))
		return
	end
	SetNvar(packageVar, 1)
	
	local panlText = unit.GetStringVar(pnalVar)
	if panlText==nil or panlText=='' then
		panlText = '[]'
	end
	
	local pnal_table = Utility.JSONParse(panlText)
	for _, v in ipairs(data) do
		table.insert(pnal_table, v)
	end
	
	unit.SetStringVar(pnalVar, Utility.JSONSerialize(pnal_table))
	unit.FireEvent('소포함_open', unit.GetStringVar(pnalVar))
	
	for i=1, #data do
		table.remove(data, 1)
	end
	
	local txt0 = Utility.JSONSerialize(data)
	if #data == 0 then
		txt0 = Perfect_Remove(txt0, unit.player.id)
		SetSvar(mailVar, txt0)
	end
	SetNvar(packageVar, 0)
end

Server.GetTopic('mail_main').Add(mail_main)


local function commaValue(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
Server.GetTopic('소포함_받기').Add(function(txt, idx)
	local tbl = Utility.JSONParse(txt)
	local data = tbl[idx]
	
	if data.RemoveType == 'Item' then
		local item = Server.CreateItem(data.I, data.count)
		for i, v in ipairs(data.op.t) do
			Utility.AddItemOption(item, v, data.op.i[i], data.op.v[i])
		end
		item.level = data.lv
		unit.AddItemByTItem(item, true)
	elseif data.RemoveType == 'Gold' then
		if data.goldType == -1 then
			local gold = data.s*data.count*(100-fee)*0.01
			goods(3, gold)
			unit.SendCenterLabel('수수료 '..fee..'%를 납입하고\n<color=#D7DF01>'..commaValue(math.floor(gold))..' '..goldName..'</color> 획득하셨습니다.')
			SetNvar(feeVar, GetNvar(feeVar)+data.s*data.count*0.01*fee)
		else
			local gold = data.s*data.count*(100-fee)*0.01
			unit.SendCenterLabel('수수료 '..fee..'%를 납입하고\n'..commaValue(math.floor(gold))..' '..Server.GetItem(TemDataID).name..' 획득하셨습니다.')
			SetNvar(feeVar, GetNvar(feeVar)+data.s*data.count*0.01*fee)
			unit.AddItem(data.goldType, gold, false)
		end
	end
	
	local pnal_table = Utility.JSONParse(unit.GetStringVar(pnalVar))
	table.remove(pnal_table, idx)
	unit.SetStringVar(pnalVar, Utility.JSONSerialize(pnal_table))
	unit.FireEvent('소포함_open', unit.GetStringVar(pnalVar))
end)

Server.GetTopic('TemDataID').Add(function() 
	local t = {}
	for i=0, #nameType do
		t[i+1] = nameType[i]
	end
	unit.FireEvent('TemDataID', TemDataID, Utility.JSONSerialize(t)) 
end)

Server.GetTopic('거래소_open').Add(function() 
	unit.FireEvent('거래소_open') 
end)

Server.GetTopic('소포함_open').Add(mail_main)
--[[
local function three_days()
	if GetNvar(NtradeVar) ~= 1 then
		SetNvar(NtradeVar, 1)
		for i=0, 10 do
			local tbl = Utility.JSONParse(GetSvar(tradeVar[i]))
			for j, v in pairs(tbl) do
				for k, b in ipairs(v) do
					if os.time()-b.t > days*24*3600 then
						table.remove(v, k)
						
						break
					end
				end
			end
		end
		SetNvar(NtradeVar, 0)
	end
	Server.RunLater(three_days, 2) -- 300초 마다 실행
end
-- Server.RunLater(three_days, 2)]]


Unit_data, Nickname_data = {}, {}
local function onJoinPlayer(player)
	Unit_data[player.id] = player.unit
	Nickname_data[player.name] = player.unit
	
	local list_table = nil 
	if GetSvar(mailVar)==nil or GetSvar(mailVar)=='' then
		list_table = {}
	else
		list_table = Utility.JSONParse(GetSvar(mailVar))
	end
	
	local data = list_table[tostring(player.id)]
	if data then
		local txt = '<color=#00FF00>[#] 소포함에 상품이 도착했습니다.</color>'
		player.unit.SendCenterLabel(txt)
		player.unit.SendSay(txt)
	end
end
Server.onJoinPlayer.Add(onJoinPlayer)



--[[ 오리지날 테이블
{
"163578":[
	{"I":0,"t":1667316347,"lv":75,"op":{"t":[0,2,4],"i":[0,4,2],"v":[18925,33368,10502]},"s":555,"c":1},
	{"I":0,"t":1667316400,"lv":33,"op":{"t":[2,0,2,4,4,0],"i":[1,1,3,3,3,3],"v":[26482,48070,30338,62529,69612,67438]},"s":6655,"c":1}
	],
"221567":[
	{"I":0,"t":1667316565,"lv":53,"op":{"t":[3,0,2,4,0,2],"i":[4,1,5,5,1,1],"v":[27504,70393,86370,95774,22103,71421]},"s":5580,"c":1}
	],
"356311":[
	{"I":0,"t":1667316576,"lv":39,"op":{"t":[0,2,1,0,4,1],"i":[3,7,0,3,7,2],"v":[3949,61279,11575,68265,81065,26878]},"s":777,"c":1},
	{"I":0,"t":1667316582,"lv":99,"op":{"t":[2,1,0,1],"i":[2,1,6,1],"v":[34522,6740,54132,32012]},"s":77777,"c":1}
	],
"4593":[
	{"I":0,"t":1667316723,"lv":72,"op":{"t":[0,3,4],"i":[0,7,1],"v":[99014,90119,20101]},"s":447,"c":1},
	{"I":0,"t":1667316729,"lv":64,"op":{"t":[0,3,1],"i":[6,0,7],"v":[13747,29029,54326]},"s":778,"c":1},
	{"I":0,"t":1667316735,"lv":46,"op":{"t":[0,2,1],"i":[4,0,6],"v":[7025,33520,87628]},"s":415,"c":1},
	{"I":0,"t":1667316750,"lv":48,"op":{"t":[0,0,3,1,1,1,2],"i":[5,6,2,6,3,2,1],"v":[91076,40639,10323,80334,87298,83809,25545]},"s":8000000,"c":1}
	]
}
]]

--[[ 정수키 테이블
[
	{"163578":[
		{"I":0,"t":1667650696,"lv":27,"op":{"t":[2,1,3,4,0,4,4],"i":[4,2,0,7,0,7,2],"v":[27480,31493,28236,71541,96306,8714,83252]},"s":null,"c":null},
		{"I":0,"t":1667650698,"lv":81,"op":{"t":[2,2,4,2,1,2,1],"i":[5,1,5,6,6,3,1],"v":[60908,47146,87403,84860,76953,98763,20159]},"s":null,"c":null}
		]
	},
	{"2":[
		{"I":0,"t":1667650711,"lv":77,"op":{"t":[0,4,0],"i":[7,5,3],"v":[26138,52182,62191]},"s":null,"c":null}
		]
	}
]
]]