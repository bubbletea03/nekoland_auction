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
	local panel_bg = Image("Pictures/레이아웃판넬.png",Rect(0,0,400,300))
	local btn_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,400,300))
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
	mask.SetOpacity(0)
	
	local p00 = Panel(Rect(0,0,555,318))
	local p00_bg = Image("Pictures/레이아웃판넬.png", Rect(0,0,p00.width,p00.height))
	p00.AddChild(p00_bg)
	p00.SetOpacity(0)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)

	local sp00 = ScrollPanel(Rect(10,-10,452,258))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(0)
	sp00.content = c00
	
	local t00 = Text("유저 골드장터목록", Rect(0,5,p00.width,30))
	local t001 = Text("유저 골드장터목록", Rect(0,4,p00.width,30))
	local t002 = Text("유저 골드장터목록", Rect(-1,5,p00.width,30))
	local t003 = Text("유저 골드장터목록", Rect(0,6,p00.width,30))
	local t004 = Text("유저 골드장터목록", Rect(1,5,p00.width,30))

	t00.color = Color(255,255,0)
	t001.color = Color(0,0,0)
	t002.color = Color(0,0,0)
	t003.color = Color(0,0,0)
	t004.color = Color(0,0,0)

	t00.textAlign = 4
	t001.textAlign = 4
	t002.textAlign = 4
	t003.textAlign = 4
	t004.textAlign = 4

	t00.textSize = 18
	t001.textSize = 18
	t002.textSize = 18
	t003.textSize = 18
	t004.textSize = 18

	p00.AddChild(t004)
	p00.AddChild(t001)
	p00.AddChild(t002)
	p00.AddChild(t003)
	p00.AddChild(t00)

	local b00 = Button("", Rect(-10,-10,70,35))
	local b00_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local b00_txt = Text("취소", Rect(0,0,70,35))
	b00_txt.textAlign = 4
	b00_txt.textSize = 11

	b00.AddChild(b00_bg)
	b00.AddChild(b00_txt)
	b00.SetOpacity(0)

	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		mask.Destroy()
		c_market:list()
	end)
	p00.AddChild(b00)
	
	local b01 = Button("", Rect(-10,-50,70,35))
	local b01_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local b01_txt = Text("▶", Rect(0,0,70,35))
	b01_txt.textAlign = 4
	b01_txt.textSize = 11

	b01.AddChild(b01_bg)
	b01.AddChild(b01_txt)

	b01.SetOpacity(0)
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
	
	local b02 = Button("", Rect(-10,-90,70,35))
	local b02_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local b02_txt = Text("◀", Rect(0,0,70,35))
	b02_txt.textAlign = 4
	b02_txt.textSize = 11

	b02.AddChild(b02_bg)
	b02.AddChild(b02_txt)
	b02.SetOpacity(0)
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
	
	local b03 = Button("", Rect(-10,-130,70,35))
	local b03_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local b03_txt = Text("갱신", Rect(0,0,70,35))
	b03_txt.textAlign = 4
	b03_txt.textSize = 11

	b03.AddChild(b03_bg)
	b03.AddChild(b03_txt)
	
	b03.SetOpacity(0)
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

	local b04 = Text("", Rect(-10,-170,70,35))
	b04.textAlign = 4
	b04.textSize = 13
	b04.anchor = 8
	b04.pivotX = 1
	b04.pivotY = 1

	b04.text = "<color=#FFFF00>Page</color>\n"..self.page.." / "..math.ceil(#self.ids/10)

	p00.AddChild(b04)

	local list = {panel={}, txt={}, button={}}
	for i=1+(self.page-1)*10, self.page*10 do
		if not self.ids[i] then
			break
		end
		
		list.panel[i-(self.page-1)*10] = Panel(Rect(227*((i-(self.page-1)*10-1)%2),52*math.floor((i-(self.page-1)*10-1)/2),225,50))
		list.panel[i-(self.page-1)*10].SetOpacity(70)

		c00.AddChild(list.panel[i-(self.page-1)*10])
		
		list.txt[i] = Text("<color=#FFFF00>["..i.."]</color>".." "..self.names[i] .. '\n' .. self.title[i], Rect(10,5,330,list.panel[i-(self.page-1)*10].height-10))
		list.txt[i].textAlign = 3
		list.panel[i-(self.page-1)*10].AddChild(list.txt[i])
		
		list.button[i] = Button("",Rect(0,0,list.panel[i-(self.page-1)*10].width,list.panel[i-(self.page-1)*10].height))
		list.button[i].SetOpacity(10)
		list.button[i].onClick.Add(function()
			if self.ids[i] == self.me then
				Client.FireEvent("s_market:text", 6)
				return
			end
			mask.Destroy()
			Client.FireEvent("s_market:target", self.ids[i], self.names[i])
		end)
		list.panel[i-(self.page-1)*10].AddChild(list.button[i])
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
	mask.SetOpacity(0)
	
	local p00 = Panel(Rect(0,0,450,318))
	p00.SetOpacity(0)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)

	local panel_bg = Image("Pictures/레이아웃판넬.png",Rect(0,0,450,318))
	p00.AddChild(panel_bg)

	local sp00 = ScrollPanel(Rect(10,-10,350,258))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(0)
	sp00.content = c00

	local t00 = Text("<Color=Yellow>" .. player_name .. "</color> 님의 골드장터", Rect(5,5,450,30))
	t00.textAlign = 4
	t00.textSize = 15
	p00.AddChild(t00)
	
	local b00 = Button("", Rect(-10,-10,70,35))
	b00.SetOpacity(0)
	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		mask.Destroy()
		c_market:players()
	end)

	local btn_bg1 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text1 = Text("취소", Rect(0,0,70,35))
	btn_text1.textSize = 11
	btn_text1.textAlign = 4

	b00.AddChild(btn_bg1)
	b00.AddChild(btn_text1)

	p00.AddChild(b00)
	
	local b01 = Button("", Rect(-10,-55,70,35))
	b01.SetOpacity(0)
	b01.anchor = 8
	b01.pivotX = 1
	b01.pivotY = 1
	b01.onClick.Add(function()
		mask.Destroy()
		Client.FireEvent("s_market:GM", player_id, player_name)
	end)

	local btn_bg2 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text2 = Text("강제회수", Rect(0,0,70,35))
	btn_text2.textSize = 11
	btn_text2.textAlign = 4

	b01.AddChild(btn_bg2)
	b01.AddChild(btn_text2)

	p00.AddChild(b01)

	local list = {panel={}, image={}, button={}, button2={}, txt={},buttonimg ={}, buttontext ={}}
	for i, v in ipairs(item) do
		list.panel[i] = Panel(Rect(0,52*(i-1),c00.width,50))
		list.panel[i].SetOpacity(70)
		c00.AddChild(list.panel[i])
		
		if v ~= 0 then
			list.image[i] = Image("", Rect(5,7.5,35,35))
			list.image[i].SetImageID(Client.GetItem(item[i][1]).imageID)
			list.txt[i] = Text("",Rect(60,5,list.panel[i].width-65,40))
			list.txt[i].textAlign = 3
			list.txt[i].text = Client.GetItem(item[i][1]).name .. ' ' .. item[i][2] .. '개' .. '\n<Color=Yellow>' .. comma(item[i][4]) .. ' Gold</color>'
			list.button2[i] = Button('<Color=#ADFF2F>+' .. item[i][3] .. '</color>', Rect(5,7.5,35,35))
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
			list.button[i] = Button("", Rect(-5,10,50,30))
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

			list.buttonimg[i] = Image("Pictures/카테고리버튼.png", Rect(0,0,50,30))
			list.buttontext[i] = Text("구매", Rect(0,0,50,30))
			list.buttontext[i].textAlign = 4
			list.buttontext[i].textSize = 10

			list.button[i].AddChild(list.buttonimg[i])
			list.button[i].AddChild(list.buttontext[i])

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
	mask.SetOpacity(1)
	
	local p00 = Panel(Rect(0,0,200,130))
	p00.SetOpacity(0)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	mask.AddChild(p00)
	local panel_bg = Image("Pictures/레이아웃판넬.png",Rect(0,0,200,130))
	p00.AddChild(panel_bg)
	
	local button = {}
	local button_text ={}
	button[1] = Button("",Rect(15,10,170,30))
	button[1].SetOpacity(0)
	button[1].onClick.Add(function()
		Client.FireEvent("s_market:players")
		mask.Destroy()
	end)
	
	button_text[1] = Text("골드장터", Rect(0,0,170,30))
	button_text[1].textAlign = 4
	button_text[1].textSize = 11
	button_text[1].color = Color(255,255,255)
	
	button[2] = Button("",Rect(15,50,170,30))
	button[2].SetOpacity(0)
	button[2].onClick.Add(function()
		Client.FireEvent("s_market:sellItemList")
		mask.Destroy()
	end)

	button_text[2] = Text("골드장터 관리", Rect(0,0,170,30))
	button_text[2].textAlign = 4
	button_text[2].textSize = 11
	button_text[2].color = Color(255,255,255)
	
	button[3] = Button("",Rect(15,90,170,30))
	button[3].SetOpacity(0)
	button[3].onClick.Add(function()
		mask.Destroy()
	end)

	button_text[3] = Text("취소", Rect(0,0,170,30))
	button_text[3].textAlign = 4
	button_text[3].textSize = 11
	button_text[3].color = Color(255,255,255)
	
	local btn_bg1 = Image("Pictures/카테고리버튼.png",Rect(0,0,170,30))
	local btn_bg2 = Image("Pictures/카테고리버튼.png",Rect(0,0,170,30))
	local btn_bg3 = Image("Pictures/카테고리버튼.png",Rect(0,0,170,30))

	button[1].AddChild(btn_bg1)
	button[2].AddChild(btn_bg2)
	button[3].AddChild(btn_bg3)

	button[1].AddChild(button_text[1])
	button[2].AddChild(button_text[2])
	button[3].AddChild(button_text[3])

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
	self.mask1.SetOpacity(0)
	
	local p00 = Panel(Rect(0,0,450,318))
	p00.SetOpacity(0)
	p00.anchor = 4
	p00.pivotX = 0.5
	p00.pivotY = 0.5
	self.mask1.AddChild(p00)

	local panel_bg = Image("Pictures/레이아웃판넬.png",Rect(0,0,450,318))
	p00.AddChild(panel_bg)
	
	local sp00 = ScrollPanel(Rect(10,-10,350,258))
	sp00.horizontal = false
	sp00.SetOpacity(0)
	sp00.anchor = 6
	sp00.pivotY = 1
	p00.AddChild(sp00)
	
	local c00 = Panel(Rect(0,0,sp00.width,sp00.height))
	c00.SetOpacity(0)
	sp00.content = c00
	
	local t00 = Text("  Title : " .. market_title, Rect(10,10,390,30))
	t00.textAlign = 3
	p00.AddChild(t00)
	
	local b00 = Button("", Rect(-10,-10,70,35))
	b00.SetOpacity(0)
	b00.anchor = 8
	b00.pivotX = 1
	b00.pivotY = 1
	b00.onClick.Add(function()
		self.mask1.Destroy()
		self.mask1 = nil
		c_market:list()
	end)

	local btn_bg1 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text1 = Text("취소", Rect(0,0,70,35))
	btn_text1.textSize = 11
	btn_text1.textAlign = 4

	b00.AddChild(btn_bg1)
	b00.AddChild(btn_text1)

	p00.AddChild(b00)
	
	local b01 = Button("", Rect(-10,-55,70,35))
	b01.SetOpacity(0)
	b01.anchor = 8
	b01.pivotX = 1
	b01.pivotY = 1
	b01.onClick.Add(function()
		c_market:reTitle()
	end)
	local btn_bg2 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text2 = Text("간판", Rect(0,0,70,35))
	btn_text2.textSize = 11
	btn_text2.textAlign = 4
	
	b01.AddChild(btn_bg2)
	b01.AddChild(btn_text2)

	p00.AddChild(b01)
	
	local b02 = Button("", Rect(-10,-100,70,35))
	b02.SetOpacity(0)
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

	local btn_bg3 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text3 = Text("오픈", Rect(0,0,70,35))
	btn_text3.textAlign = 4
	btn_text3.textSize = 11
	b02.AddChild(btn_bg3)
	b02.AddChild(btn_text3)

	p00.AddChild(b02)
	
	local b03 = Button("", Rect(-10,-145,70,35))
	b03.SetOpacity(0)
	b03.anchor = 8
	b03.pivotX = 1
	b03.pivotY = 1
	b03.onClick.Add(function()
		Client.FireEvent("s_market:sellItemList")
	end)
	local btn_bg4 = Image("Pictures/카테고리버튼.png",Rect(0,0,70,35))
	local btn_text4 = Text("갱신", Rect(0,0,70,35))
	btn_text4.textAlign = 4
	btn_text4.textSize = 11
	b03.AddChild(btn_bg4)
	b03.AddChild(btn_text4)

	p00.AddChild(b03)
	
	local list = {panel={}, image={}, button={}, button2={}, txt={}, buttonimg ={},buttontext ={}}
	
	for i, v in ipairs(item) do
		list.panel[i] = Panel(Rect(0,52*(i-1),c00.width,50))
		list.panel[i].SetOpacity(70)
		
		c00.AddChild(list.panel[i])
		
		if v ~= 0 then
			list.image[i] = Image("", Rect(5,7.5,35,35))
			list.image[i].SetImageID(Client.GetItem(item[i][1]).imageID)
			list.txt[i] = Text("",Rect(60,5,list.panel[i].width-65,40))
			list.txt[i].textAlign = 3
			list.txt[i].text = Client.GetItem(item[i][1]).name .. ' ' .. item[i][2] .. '개' .. '\n<Color=Yellow>' .. comma(item[i][4]) .. ' Gold</color>'
			list.button2[i] = Button('<Color=#ADFF2F>+' .. item[i][3] .. '</color>', Rect(0,0,35,35))
			list.button2[i].textAlign = 2
			list.button2[i].SetOpacity(0)
			list.button2[i].onClick.Add(function()
				local mask = Panel(Rect(0,0,Client.width,Client.height))
				mask.showOnTop = true
				mask.SetOpacity(0)
				local ttp = Panel(Rect(50,0,200,400))
				local ttp_bg = Image("Pictures/WindowSkin(Red).png",Rect(0,0,200,400))
				ttp_bg.imageType = 1
				ttp.anchor = 3
				ttp.pivotY = 0.5
				ttp.SetOpacity(0)
				ttp.AddChild(ttp_bg)
				local ttt = Text(Client.GetItem(item[i][1]).name .. ' <color=#00FF22>+' .. item[i][3] .. '</color>\n' .. Client.GetItem(item[i][1]).desc,Rect(10,10,ttp.width-10,ttp.height-10))
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
			list.button[i] = Button("", Rect(-5,10,50,30))
			list.button[i].SetOpacity(0)
			list.button[i].anchor = 2
			list.button[i].pivotX = 1
			list.button[i].onClick.Add(function()
				Client.FireEvent("s_market:collectItem", i, Utility.JSONSerialize(item[i]))
			end)
			list.buttonimg[i] = Image("Pictures/카테고리버튼.png", Rect(0,0,50,30))
			list.buttontext[i] = Text("<color=#FFFF00>회수</color>", Rect(0,0,50,30))
			list.buttontext[i].textAlign = 4
			list.buttontext[i].textSize = 10

			list.button[i].AddChild(list.buttonimg[i])
			list.button[i].AddChild(list.buttontext[i])

			list.panel[i].AddChild(list.image[i])
			list.panel[i].AddChild(list.txt[i])
			list.image[i].AddChild(list.button2[i])
		else
			list.button[i] = Button("", Rect(-5,10,50,30))
			list.button[i].SetOpacity(0)
			list.button[i].anchor = 2
			list.button[i].pivotX = 1
			list.button[i].onClick.Add(function()
				self.choose = i
				Client.FireEvent("s_market:registerItem")
			end)
			list.buttonimg[i] = Image("Pictures/카테고리버튼.png", Rect(0,0,50,30))
			list.buttontext[i] = Text("등록", Rect(0,0,50,30))
			list.buttontext[i].textAlign = 4
			list.buttontext[i].textSize = 10

			
			list.button[i].AddChild(list.buttonimg[i])
			list.button[i].AddChild(list.buttontext[i])
		end
		list.panel[i].AddChild(list.button[i])
		
	end
end
Client.GetTopic("c_market:management").Add(function(a,b,c,d,e,f) c_market:management(a,b,c,d,e,f) end)


function c_market:reTitle()
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(0)

	local i00panel = Panel(Rect(0,0,320,90))
	i00panel.anchor = 4
	i00panel.pivotX = 0.5
	i00panel.pivotY = 0.5
	local i00panel_bg = Image("Pictures/레이아웃판넬.png", Rect(0,0,320,90))
	i00panel.AddChild(i00panel_bg)
	mask.AddChild(i00panel)
	
	local i00 = InputField(Rect(10,10,300,30))
	i00.color = Color(255,255,255)
	i00.textAlign = 3
	i00.placeholder = "15자(공백포함) 이하로 작성해주세요."
	i00panel.AddChild(i00)
	
	local b00 = Button("", Rect(95,50,60,30))
	local b00_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,60,30))
	local b00_text = Text("설정", Rect(0,0,60,30))
	b00_text.textAlign = 4
	b00_text.textSize = 10
	b00.SetOpacity(0)
	b00.AddChild(b00_bg)
	b00.AddChild(b00_text)

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
	i00panel.AddChild(b00)
	
	local b01 = Button("", Rect(165,50,60,30))
	local b01_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,60,30))
	local b01_text = Text("취소", Rect(0,0,60,30))
	b01_text.textAlign = 4
	b01_text.textSize = 10
	b01.SetOpacity(0)
	b01.AddChild(b01_bg)
	b01.AddChild(b01_text)
	
	b01.onClick.Add(function()
		mask.Destroy()
	end)
	i00panel.AddChild(b01)
end


function c_market:setPrice(Titem_count)
	local mask = Panel(Rect(0,0,Client.width,Client.height))
	mask.showOnTop = true
	mask.SetOpacity(0)

	local i00panel = Panel(Rect(0,0,320,130))
	i00panel.anchor = 4
	i00panel.pivotX = 0.5
	i00panel.pivotY = 0.5
	local i00panel_bg = Image("Pictures/레이아웃판넬.png", Rect(0,0,320,130))
	i00panel.AddChild(i00panel_bg)
	mask.AddChild(i00panel)
	
	local i00 = InputField(Rect(10,10,300,30))
	i00.color = Color(255,255,255)
	i00.textAlign = 3
	i00.placeholder = "가격은?(낱개판매X)"
	i00panel.AddChild(i00)
	
	local i01 = InputField(Rect(10,50,300,30))
	i01.color = Color(255,255,255)
	i01.textAlign = 3
	i01.placeholder = "수량은? " .. "보유수량(" .. Titem_count .. "개)"
	i00panel.AddChild(i01)
	
	local b00 = Button("", Rect(95,90,60,30))
	local b00_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,60,30))
	local b00_text = Text("설정", Rect(0,0,60,30))
	b00_text.textAlign = 4
	b00_text.textSize = 10
	b00.SetOpacity(0)
	b00.AddChild(b00_bg)
	b00.AddChild(b00_text)

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
	i00panel.AddChild(b00)
	
	local b01 = Button("취소", Rect(165,90,60,30))
	local b01_bg = Image("Pictures/카테고리버튼.png",Rect(0,0,60,30))
	local b01_text = Text("취소", Rect(0,0,60,30))
	b01_text.textAlign = 4
	b01_text.textSize = 10
	b01.SetOpacity(0)
	b01.AddChild(b01_bg)
	b01.AddChild(b01_text)
	b01.onClick.Add(function()
		mask.Destroy()
	end)
	i00panel.AddChild(b01)
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