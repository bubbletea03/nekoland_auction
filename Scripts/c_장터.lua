-----------------------------------------------------------------------------------
--[[
statName 만 수정하면 됩니다. 본인 게임에서 쓰는 스탯이름으로 바꿔주세요.
커스텀스텟은 알아서 이름이 새겨지니 건들지 마세요.

상품 이미지 클릭시 정보창이 뜹니다.
수량은 가방에서 나눠서 등록하시고, 한묶음으로 구매가 됩니다.

추후, 수량이나 갯수별 구매는 시간이 널널하고 생각나면 업데이트하겠습니다.

한번에 많은 사람이 동시다발적으로 한 물건을 누르게 됬을때, 동시처리가 안되서 문제가 발생할 수 있다고 들은 적이 있습니다. (직접 보진 못했습니다. 혹, 발견하시면 제보해주세요)
이 점 유의하시고, 여러 테스트 이후 사용하여 주시길 바랍니다. 문제 발생 시 책임은 사용자에게 있습니다.
그 밖에 다른 문제 발생 시 제보 부탁드립니다.


Made By - HanRyang 한량
]]--

ttype = {"", "직업", "직업", "아이템", "아이템"}
statName = {"공격력","방어력","마법공격력","마법방어력","민첩","행운","체력","마력"}
statName2 = {Client.GetStrings().custom1,Client.GetStrings().custom2,Client.GetStrings().custom3,Client.GetStrings().custom4,Client.GetStrings().custom5,Client.GetStrings().custom6,Client.GetStrings().custom7,Client.GetStrings().custom8,Client.GetStrings().custom9,Client.GetStrings().custom10,Client.GetStrings().custom11,Client.GetStrings().custom12,Client.GetStrings().custom13,Client.GetStrings().custom14,Client.GetStrings().custom15,Client.GetStrings().custom16,Client.GetStrings().custom17,Client.GetStrings().custom18,Client.GetStrings().custom19,Client.GetStrings().custom20,Client.GetStrings().custom21,Client.GetStrings().custom22,Client.GetStrings().custom23,Client.GetStrings().custom24,Client.GetStrings().custom25,Client.GetStrings().custom26,Client.GetStrings().custom27,Client.GetStrings().custom28,Client.GetStrings().custom29,Client.GetStrings().custom30,Client.GetStrings().custom31,Client.GetStrings().custom32}

price_max = 999999999999999
-- 15자리수를 넘어가게되면 표기형식이 1E+16 같이 바뀜
------------------------------------------------------------------------------------



c_market = {}
c_market.ids = {}
c_market.names = {}
c_market.title = {}
c_market.me = 0
c_market.page = 1
c_market.choose = 0

function c_market:players(ids,names,title,me)
	if ids then
		c_market.ids = Utility.JSONParse(ids)
		c_market.names = Utility.JSONParse(names)
		c_market.title = Utility.JSONParse(title)
		c_market.me = me
	end
	
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(50)
	mask.color = Color(0,0,0)
	
	local p00 = Panel(Rect(0,0,400,300))
	p00.SetOpacity(255)
	p00.color = Color(80,80,80)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)
	
	local sp00 = ScrollPanel(Rect(5,-5,350,250))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(255)
	c00.color = Color(150,150,150)
	sp00.content = c00
	
	local t00 = Text("Players", Rect(5,5,390,30))
	t00.textAlign = 4
	p00.AddChild(t00)
	
	local b00 = Button("취소", Rect(-5,-5,35,35))
	b00.SetOpacity(255)
	b00.color = Color(150,150,150)
	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		mask.Destroy()
		c_market:list()
	end)
	p00.AddChild(b00)
	
	local b01 = Button("▶", Rect(-5,-45,35,35))
	b01.SetOpacity(255)
	b01.color = Color(150,150,150)
	b01.anchor = 8
	b01.pivotX = 1
	b01.pivotY = 1
	b01.onClick.Add(function()
		if self.page >= math.ceil(#self.ids/5) then
			Client.FireEvent("s_market:text", 1)
			return
		end
		mask.Destroy()
		self.page = self.page + 1
		c_market:players()
	end)
	p00.AddChild(b01)
	
	local b02 = Button("◀", Rect(-5,-85,35,35))
	b02.SetOpacity(255)
	b02.color = Color(150,150,150)
	b02.anchor = 8
	b02.pivotX = 1
	b02.pivotY = 1
	b02.onClick.Add(function()
		if self.page <= 1 then
			Client.FireEvent("s_market:text", 2)
			return
		end
		mask.Destroy()
		self.page = self.page - 1
		c_market:players()
	end)
	p00.AddChild(b02)
	
	local b03 = Button("갱신", Rect(-5,-125,35,35))
	b03.SetOpacity(255)
	b03.color = Color(150,150,150)
	b03.anchor = 8
	b03.pivotX = 1
	b03.pivotY = 1
	b03.onClick.Add(function()
		Client.FireEvent("s_market:text", 5)
		mask.Destroy()
		self.page = 1
		Client.FireEvent("s_market:players")
	end)
	p00.AddChild(b03)

	local list = {panel={}, txt={}, button={}}
	for i=1+(self.page-1)*5, self.page*5 do
		if not self.ids[i] then
			break
		end
		
		list.panel[i-(self.page-1)*5] = Panel(Rect(0,c00.height/5*(i-(self.page-1)*5-1),c00.width,c00.height/5))
		if i/2 == math.floor(i/2) then
			list.panel[i-(self.page-1)*5].color = Color(120,120,120)
		else
			list.panel[i-(self.page-1)*5].color = Color(150,150,150)
		end
		c00.AddChild(list.panel[i-(self.page-1)*5])
		
		list.txt[i] = Text(self.names[i] .. '\n' .. self.title[i], Rect(10,5,330,list.panel[i-(self.page-1)*5].height-10))
		list.txt[i].textAlign = 3
		list.panel[i-(self.page-1)*5].AddChild(list.txt[i])
		
		list.button[i] = Button("",Rect(0,0,list.panel[i-(self.page-1)*5].width,list.panel[i-(self.page-1)*5].height))
		list.button[i].SetOpacity(80)
		list.button[i].onClick.Add(function()
			if self.ids[i] == self.me then
				Client.FireEvent("s_market:text", 6)
				return
			end
			mask.Destroy()
			Client.FireEvent("s_market:target", self.ids[i], self.names[i])
		end)
		list.panel[i-(self.page-1)*5].AddChild(list.button[i])
	end
end
Client.GetTopic("c_market:players").Add(function(a,b,c,d) c_market:players(a,b,c,d) end)


function c_market:target_table(a,b,c,d,e,player_id,player_name)
	if not a or not b or not c or not d or not e or not player_id or not player_name then
		return
	end
	
	local item = {}
	local aa = {a,b,c,d,e}
	for i=1, 5 do
		if aa[i] ~= 0 then
			item[i] = Utility.JSONParse(aa[i])
		else
			item[i] = 0
		end
	end
	
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(50)
	mask.color = Color(0,0,0)
	
	local p00 = Panel(Rect(0,0,400,300))
	p00.SetOpacity(255)
	p00.color = Color(80,80,80)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)
	
	local sp00 = ScrollPanel(Rect(5,-5,350,250))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(255)
	c00.color = Color(150,150,150)
	sp00.content = c00
	
	local t00 = Text("<Color=Yellow>" .. player_name .. "</color>'s", Rect(5,5,390,30))
	t00.textAlign = 4
	p00.AddChild(t00)
	
	local b00 = Button("취소", Rect(-5,-5,35,35))
	b00.SetOpacity(255)
	b00.color = Color(150,150,150)
	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		mask.Destroy()
		c_market:players()
	end)
	p00.AddChild(b00)
	
	local b01 = Button("강제회수", Rect(-5,-45,35,35))
	b01.SetOpacity(255)
	b01.color = Color(150,150,150)
	b01.anchor = 8
	b01.pivotX = 1
	b01.pivotY = 1
	b01.onClick.Add(function()
		mask.Destroy()
		Client.FireEvent("s_market:GM", player_id, player_name)
	end)
	p00.AddChild(b01)

	local list = {panel={}, image={}, button={}, button2={}, txt={}}
	for i, v in ipairs(item) do
		list.panel[i] = Panel(Rect(0,50*(i-1),c00.width,c00.height/5))
		if i/2 == math.floor(i/2) then
			list.panel[i].color = Color(150,150,150)
		end
		c00.AddChild(list.panel[i])
		
		if v ~= 0 then
			list.image[i] = Image("", Rect(5,5,40,40))
			list.image[i].SetImageID(Client.GetItem(item[i][1]).imageID)
			list.txt[i] = Text("",Rect(60,5,list.panel[i].width-65,40))
			list.txt[i].textAlign = 3
			list.txt[i].text = Client.GetItem(item[i][1]).name .. ' ' .. item[i][2] .. '개' .. '\n<Color=Yellow>' .. comma(item[i][4]) .. ' Gold</color>'
			list.button2[i] = Button('<Color=#ADFF2F>+' .. item[i][3] .. '</color>', Rect(0,0,40,40))
			list.button2[i].textAlign = 2
			list.button2[i].SetOpacity(0)
			list.button2[i].onClick.Add(function()
				local mask2 = Panel(Rect(0,0,Client.width,Client.height))
				mask2.showOnTop = true
				mask2.SetOpacity(0)
				local ttp = Panel(Rect(50,0,200,400))
				ttp.anchor = 3
				ttp.pivotY = 0.5
				ttp.SetOpacity(200)
				local ttt = Text(Client.GetItem(item[i][1]).name .. ' +' .. item[i][3] .. '\n' .. Client.GetItem(item[i][1]).desc,Rect(10,10,ttp.width-10,ttp.height-10))
				ttt.textAlign = 0
				
				if #item[i] > 4 then
					ttt.text = ttt.text .. '\n\n' .. '<color=#FF00FF>옵션</color>'
					for j=5, #item[i], 3 do
						local tttp = ""
						if item[i][j] == 2 or item[i][j] == 4 then
							tttp = "%"
						end
						if item[i][j+1] < 100 then 
							ttt.text = ttt.text .. '\n<color=#00FFFF>' .. ttype[item[i][j]+1] .. statName[item[i][j+1]+1] .. ' + ' .. item[i][j+2] .. tttp .. '</color>'
						else
							ttt.text = ttt.text .. '\n<color=#00FFFF>' .. ttype[item[i][j]+1] .. statName2[item[i][j+1]-100] .. ' + ' .. item[i][j+2] .. tttp .. '</color>'
						end
					end
				end
				
				local tte = Button("",Rect(0,0,mask.width,mask.height))
				tte.SetOpacity(0)
				tte.onClick.Add(function()
					mask2.Destroy()
				end)
				mask2.AddChild(ttp)
				ttp.AddChild(ttt)
				mask2.AddChild(tte)
			end)
			list.button[i] = Button("구매", Rect(-5,5,40,40))
			list.button[i].anchor = 2
			list.button[i].pivotX = 1
			list.button[i].onClick.Add(function()
				Client.ShowYesNoAlert("정말 구매하시겠습니까?\n\n" .. Client.GetItem(item[i][1]).name .. " +" .. item[i][3] .. "\n" .. item[i][2] .. "개\n" .. item[i][4] .. "Gold", function(a)
					if a == 1 then
						Client.FireEvent("s_market:buyItem", i, player_id, Utility.JSONSerialize(item[i]))
						mask.Destroy()
					end
				end)
			end)
			list.panel[i].AddChild(list.image[i])
			list.panel[i].AddChild(list.txt[i])
			list.panel[i].AddChild(list.button[i])
			list.panel[i].AddChild(list.button2[i])
		end
	end
end
Client.GetTopic("c_market:target_table").Add(function(a,b,c,d,e,f,g) c_market:target_table(a,b,c,d,e,f,g) end)


function c_market:list()
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(50)
	mask.color = Color(0,0,0)
	
	local p00 = Panel(Rect(0,0,200,100))
	p00.SetOpacity(255)
	p00.color = Color(80,80,80)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)
	
	local button = {}
	button[1] = Button("장터",Rect(5,5,90,40))
	button[1].SetOpacity(255)
	button[1].color = Color(150,150,150)
	button[1].anchor = 0
	button[1].onClick.Add(function()
		Client.FireEvent("s_market:players")
		mask.Destroy()
	end)
	
	button[2] = Button("관리",Rect(5,5,90,40))
	button[2].SetOpacity(255)
	button[2].color = Color(150,150,150)
	button[2].anchor = 1
	button[2].onClick.Add(function()
		Client.FireEvent("s_market:sellItemList")
		mask.Destroy()
	end)
	
	button[3] = Button("취소",Rect(0,-5,90,40))
	button[3].SetOpacity(255)
	button[3].color = Color(150,150,150)
	button[3].anchor = 7
	button[3].pivotX = 0.5
	button[3].pivotY = 1
	button[3].onClick.Add(function()
		mask.Destroy()
	end)
	
	p00.AddChild(button[1])
	p00.AddChild(button[2])
	p00.AddChild(button[3])
end


function c_market:management(market_title,a,b,c,d,e)
	if not market_title or not a or not b or not c or not d or not e then
		return
	end
	
	local item = {}
	local aa = {a,b,c,d,e}

	for i=1, 5 do
		if aa[i] ~= 0 then
			item[i] = Utility.JSONParse(aa[i])
		else
			item[i] = 0
		end
	end

	
	if not self.mask1 then
		self.mask1 = Panel(Rect(0,0,Client.width,Client.height))
	end
	self.mask1.showOnTop = true
	self.mask1.SetOpacity(50)
	self.mask1.color = Color(0,0,0)
	
	local p00 = Panel(Rect(0,0,400,300))
	p00.SetOpacity(255)
	p00.color = Color(80,80,80)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	self.mask1.AddChild(p00)
	
	local sp00 = ScrollPanel(Rect(5,-5,350,250))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(255)
	c00.color = Color(150,150,150)
	sp00.content = c00
	
	local t00 = Text("Title : " .. market_title, Rect(5,5,390,30))
	t00.textAlign = 3
	p00.AddChild(t00)
	
	local b00 = Button("취소", Rect(-5,-5,35,35))
	b00.SetOpacity(255)
	b00.color = Color(150,150,150)
	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		self.mask1.Destroy()
		self.mask1 = nil
		c_market:list()
	end)
	p00.AddChild(b00)
	
	local b01 = Button("간판", Rect(-5,-45,35,35))
	b01.SetOpacity(255)
	b01.color = Color(150,150,150)
	b01.anchor = 8
	b01.pivotX = 1
	b01.pivotY = 1
	b01.onClick.Add(function()
		c_market:reTitle()
	end)
	p00.AddChild(b01)
	
	local b02 = Button("오픈", Rect(-5,-85,35,35))
	b02.SetOpacity(255)
	b02.color = Color(150,150,150)
	b02.anchor = 8
	b02.pivotX = 1
	b02.pivotY = 1
	b02.onClick.Add(function()
		for i, v in ipairs(item) do
			if item[i] ~= 0 then
				Client.FireEvent("s_market:text", 3)
				return
			end
		end
		Client.FireEvent("s_market:text", 4)
	end)
	p00.AddChild(b02)
	
	local b03 = Button("갱신", Rect(-5,-125,35,35))
	b03.SetOpacity(255)
	b03.color = Color(150,150,150)
	b03.anchor = 8
	b03.pivotX = 1
	b03.pivotY = 1
	b03.onClick.Add(function()
		Client.FireEvent("s_market:sellItemList")
	end)
	p00.AddChild(b03)
	
	local list = {panel={}, image={}, button={}, button2={}, txt={}}
	
	for i, v in ipairs(item) do
		list.panel[i] = Panel(Rect(0,50*(i-1),c00.width,c00.height/5))
		if i/2 == math.floor(i/2) then
			list.panel[i].color = Color(150,150,150)
		end
		c00.AddChild(list.panel[i])
		
		if v ~= 0 then
			list.image[i] = Image("", Rect(5,5,40,40))
			list.image[i].SetImageID(Client.GetItem(item[i][1]).imageID)
			list.txt[i] = Text("",Rect(60,5,list.panel[i].width-65,40))
			list.txt[i].textAlign = 3
			list.txt[i].text = Client.GetItem(item[i][1]).name .. ' ' .. item[i][2] .. '개' .. '\n<Color=Yellow>' .. comma(item[i][4]) .. ' Gold</color>'
			list.button2[i] = Button('<Color=#ADFF2F>+' .. item[i][3] .. '</color>', Rect(0,0,40,40))
			list.button2[i].textAlign = 2
			list.button2[i].SetOpacity(0)
			list.button2[i].onClick.Add(function()
				local mask = Panel(Rect(0,0,Client.width,Client.height))
				mask.showOnTop = true
				mask.SetOpacity(0)
				local ttp = Panel(Rect(50,0,200,400))
				ttp.anchor = 3
				ttp.pivotY = 0.5
				ttp.SetOpacity(200)
				local ttt = Text(Client.GetItem(item[i][1]).name .. ' +' .. item[i][3] .. '\n' .. Client.GetItem(item[i][1]).desc,Rect(10,10,ttp.width-10,ttp.height-10))
				ttt.textAlign = 0
				
				if #item[i] > 4 then
					ttt.text = ttt.text .. '\n\n' .. '<color=#FF00FF>옵션</color>'
					for j=5, #item[i], 3 do
						local tttp = ""
						if item[i][j] == 2 or item[i][j] == 4 then
							tttp = "%"
						end
						if item[i][j+1] < 100 then 
							ttt.text = ttt.text .. '\n<color=#00FFFF>' .. ttype[item[i][j]+1] .. statName[item[i][j+1]+1] .. ' + ' .. item[i][j+2] .. tttp .. '</color>'
						else
							ttt.text = ttt.text .. '\n<color=#00FFFF>' .. ttype[item[i][j]+1] .. statName2[item[i][j+1]-100] .. ' + ' .. item[i][j+2] .. tttp .. '</color>'
						end
					end
				end
				
				local tte = Button("",Rect(0,0,mask.width,mask.height))
				tte.SetOpacity(0)
				tte.onClick.Add(function()
					mask.Destroy()
				end)
				mask.AddChild(ttp)
				ttp.AddChild(ttt)
				mask.AddChild(tte)
			end)
			list.button[i] = Button("회수", Rect(-5,5,40,40))
			list.button[i].anchor = 2
			list.button[i].pivotX = 1
			list.button[i].onClick.Add(function()
				Client.FireEvent("s_market:collectItem", i, Utility.JSONSerialize(item[i]))
			end)
			list.panel[i].AddChild(list.image[i])
			list.panel[i].AddChild(list.txt[i])
			list.image[i].AddChild(list.button2[i])
		else
			list.button[i] = Button("등록", Rect(-5,5,40,40))
			list.button[i].anchor = 2
			list.button[i].pivotX = 1
			list.button[i].onClick.Add(function()
				self.choose = i
				Client.FireEvent("s_market:registerItem")
			end)
		end
		list.panel[i].AddChild(list.button[i])
		
	end
end
Client.GetTopic("c_market:management").Add(function(a,b,c,d,e,f) c_market:management(a,b,c,d,e,f) end)


function c_market:reTitle()
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(0)
	mask.color = Color(100,100,100)
	
	local i00 = InputField(Rect(0,0,300,30))
	i00.color = Color(255,255,255)
	i00.anchor = 4
	i00.pivotX = 0.5
	i00.pivotY = 0.5
	i00.textAlign = 3
	i00.placeholder = "15자(공백포함) 이하로 작성해주세요."
	mask.AddChild(i00)
	
	local b00 = Button("설정", Rect(5,0,50,50))
	b00.SetOpacity(255)
	b00.anchor = 5
	b00.color = Color(80,80,80)
	b00.pivotY = 0.5
	b00.onClick.Add(function()
		i00.text = tostring(i00.text)
		
		if not i00.text or i00.text == "" then
			i00.text = ""
			i00.placeholder = "공백은 안됩니다."
			return
		end
		
		if string.match(i00.text, "/") then
			i00.text = ""
			i00.placeholder = "'/' 는 쓸 수 없습니다."
			return
		end
		
		if string.len(i00.text) >= 15 then
			i00.text = ""
			i00.placeholder = "15자(공백포함)를 초과했습니다."
			return
		end
		
		mask.Destroy()
		self.mask1.Destroy()
		self.mask1 = nil
		Client.FireEvent("s_market:reTitle", i00.text)
	end)
	i00.AddChild(b00)
	
	local b01 = Button("취소", Rect(60,0,50,50))
	b01.SetOpacity(255)
	b01.anchor = 5
	b01.color = Color(80,80,80)
	b01.pivotY = 0.5
	b01.onClick.Add(function()
		mask.Destroy()
	end)
	i00.AddChild(b01)
end


function c_market:setPrice(Titem_count)
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(0)
	mask.color = Color(100,100,100)
	
	local i00 = InputField(Rect(0,0,300,30))
	i00.color = Color(255,255,255)
	i00.anchor = 4
	i00.pivotX = 0.5
	i00.pivotY = 0.5
	i00.textAlign = 3
	i00.placeholder = "가격은?(낱개판매X)"
	mask.AddChild(i00)
	
	local i01 = InputField(Rect(0,-40,300,30))
	i01.color = Color(255,255,255)
	i01.anchor = 4
	i01.pivotX = 0.5
	i01.pivotY = 0.5
	i01.textAlign = 3
	i01.placeholder = "수량은? " .. "보유수량(" .. Titem_count .. "개)"
	mask.AddChild(i01)
	
	local b00 = Button("설정", Rect(5,0,50,50))
	b00.SetOpacity(255)
	b00.anchor = 5
	b00.color = Color(80,80,80)
	b00.pivotY = 1
	b00.onClick.Add(function()
		i00.text = i00.text
		
		if not tonumber(i00.text) or i00.text == "" then
			i00.text = ""
			i00.placeholder = "공백이나 문자는 안됩니다."
			return
		end
		
		if tonumber(i00.text) < 0 then
			i00.text = ""
			i00.placeholder = "0 미만의 수는 적을 수 없습니다."
			return
		end
		
		if tonumber(i00.text) > price_max then
			i00.text = ""
			i00.placeholder = comma(price_max) .. "까지 허용."
			return
		end
		
		if not tonumber(i01.text) or i01.text == "" then
			i01.text = ""
			i01.placeholder = "공백이나 문자는 안됩니다."
			return
		end
		
		if tonumber(i01.text) <= 0 or tonumber(i01.text) > Titem_count then
			i01.text = ""
			i01.placeholder = "보유수량(" .. Titem_count .. "개)"
			return
		end
		
		mask.Destroy()
		self.mask1.Destroy()
		self.mask1 = nil
		Client.FireEvent("s_market:registerItem2", math.floor(tonumber(i00.text)), self.choose, math.floor(tonumber(i01.text)))
	end)
	i00.AddChild(b00)
	
	local b01 = Button("취소", Rect(60,0,50,50))
	b01.SetOpacity(255)
	b01.anchor = 5
	b01.color = Color(80,80,80)
	b01.pivotY = 1
	b01.onClick.Add(function()
		mask.Destroy()
	end)
	i00.AddChild(b01)
end
Client.GetTopic("c_market:setPrice").Add(function(a) c_market:setPrice(a) end)



function comma(str)
if not str then
	return
end

local str = tonumber(str)
local str2 = ""
local leng = string.len(str)

if leng < 4 or leng > 15 then
	return str
end

local num = 0

for i=1,math.ceil(leng/3) do
	if num ~= leng-1 then
		str2 = str2 .. string.reverse(string.sub(str, leng-(num+2), leng-num)) .. ","
		num = num + 3
	else
		str2 = str2 .. string.sub(str, 1, 1)
	end
end
str2 = string.reverse(str2)
if string.sub(str2, 1, 1) == "," then
	str2 = string.gsub(str2,",","",1)
end 
return str2
end