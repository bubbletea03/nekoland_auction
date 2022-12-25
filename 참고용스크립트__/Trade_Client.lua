 

local trade = {}
trade.Garo = 750
trade.Sero = 400
trade.page = 6
trade.trading = 0


local showPage = -1
local Loading_panel = nil
local strings = Client.GetStrings()
local statT = {}
statT[0] = strings.attack == '' and '공격력' or strings.attack
statT[1] = strings.defense == '' and '방어력' or strings.defense
statT[2] = strings.magic_attack == '' and '마법 공격력' or strings.magic_attack
statT[3] = strings.magic_defense == '' and '마법 방어력' or strings.magic_defense
statT[4] = strings.agility == '' and '민첩' or strings.agility
statT[5] = strings.lucky == '' and '운' or strings.lucky
statT[6] = strings.hp == '' and '체력' or strings.hp
statT[7] = strings.mp == '' and '마나' or strings.mp
statT[101] = strings.custom1	statT[102] = strings.custom2	statT[103] = strings.custom3
statT[104] = strings.custom4 	statT[105] = strings.custom5 	statT[106] = strings.custom6
statT[107] = strings.custom7 	statT[108] = strings.custom8 	statT[109] = strings.custom9
statT[110] = strings.custom10 	statT[111] = strings.custom11 	statT[112] = strings.custom12
statT[113] = strings.custom13 	statT[114] = strings.custom14 	statT[115] = strings.custom15
statT[116] = strings.custom16 	statT[117] = strings.custom17 	statT[118] = strings.custom18
statT[119] = strings.custom19 	statT[120] = strings.custom20 	statT[121] = strings.custom21
statT[122] = strings.custom22 	statT[123] = strings.custom23 	statT[124] = strings.custom24
statT[125] = strings.custom25 	statT[126] = strings.custom26 	statT[127] = strings.custom27
statT[128] = strings.custom28 	statT[129] = strings.custom29 	statT[130] = strings.custom30
statT[131] = strings.custom31 	statT[132] = strings.custom32
statT.type = {
	[0] = '',		[5] = '',
	[1] = '직업 ',	[6] = '',
	[2] = '직업 ',	[7] = '%',
	[3] = '아이템 ',	[8] = '',
	[4] = '아이템 ',	[9] = '%'
}

local function filter(Type, statID, value)
	local txt = ''
	
	if statT[statID] then
		txt = statT[statID]
	else
		txt = '<color=#FF0000>statID error</color>'
	end
	
	txt = txt..' +'..value
	
	if statT.type[Type] and statT.type[Type+5] then
		txt = statT.type[Type]..txt..statT.type[Type+5]
	else
		txt = '<color=#FF0000>type error</color>'
	end
	
	txt = '<color=#00FFFF>'..txt..'</color>'
	
	return txt
end

local path = 'Pictures/거래소/'

local function comma(str)
	if not str then
		return 
	end
	
	if string.len(str) < 3 then
		return str
	end
	local subFlag = false
	local strFind = "%."
	local strSub = ''
	if string.find(str, strFind) ~= nil then  -- 문자열내에 검색 문자가 있다면
		 local strFindStart, strFindEnd = string.find(str, strFind)
	
		strSub = string.sub(str, strFindStart, string.len(str)) 
		str = string.sub(str, 1, strFindStart-1) 
		subFlag = true
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
	if subFlag then
		str2 = str2 .. strSub
	end
	return str2
end

local goods = nil
local gbn, max, _text = '', 0, ''

local inputBG, innerImg, title_text, inputPanel = nil, nil, nil, nil
local boardlist = {1,2,3,'+10',4,5,6,'+50',7,8,9,'+100','MAX',0,'←','Clear'}
local inputBtn = {}
local iFlag, px = 0, 40
local function Func_()
	inputBG = Panel(Rect(250+25, 50, 200, 200))
	inputBG.color = Color(0,0,0,50)
	inputBG.showOnTop = true
	inputBG.visible = false
	
	innerImg = Image(path..'innerBG.png', Rect(0, 0, inputBG.width, 224))
	title_text = Text(_text, Rect(0, 10,  inputBG.width, 22))
	title_text.textSize = 11
	title_text.textAlign = 1
	
	inputPanel = Panel(Rect(5, 30,  inputBG.width-10, 190))
	inputPanel.color = Color(130,130,130,50)
	inputBG.AddChild(innerImg)
	inputBG.AddChild(title_text)
	inputBG.AddChild(inputPanel)
	trade.bg.AddChild(inputBG)
	
	
	for i,v in pairs(boardlist) do
		iFlag = iFlag +1
		local x = (iFlag-1)*(px+5)-( math.ceil(iFlag/4-1) * (px+5) * 4 )+5
		inputBtn[iFlag] = Button(v, Rect(x, math.floor((iFlag-1)/4)*(px+5)+5, px, px))
		inputBtn[iFlag].color = Color(30,30,30,150)
		if tonumber(v) then
			inputBtn[iFlag].color = Color(114,142,219,150)
		end
		inputBtn[iFlag].onClick.Add(function()
				if trade.trading==1 and gbn == 'price' then
					-- Client.ShowAlert('구매 가격을 바꿀 수 없습니다.')
					return
				end
				
				local target = nil
				if gbn == 'cnt' then
					target = trade.cntBtn 
					
				elseif gbn == 'price' then
					target = trade.priceBtn
				end
				
				
				target.text = string.gsub(target.text,",","",1)
				local len = string.len(target.text)

				if v =='+10' then
					target.text = comma(tonumber(target.text)+10)
				elseif v =='+50' then
					target.text = comma(tonumber(target.text)+50)
				elseif v =='+100' then
					target.text = comma(tonumber(target.text)+100)
				elseif v =='MAX' then
					target.text = comma(max)
				elseif v =='Clear' then
					target.text = 0
				elseif v == '←' then
					if len == 1 then 
						target.text = 0
					else
						target.text = comma(string.sub(target.text,1, string.len(target.text)-1))
					end
				else
					target.text = comma(target.text .. v)
				end

				if len == 0 then 
					target.text = 0
				elseif len > 14 then 
					showAlert_panel('최대 14자리까지 입력이 가능합니다.')
					target.text = comma(tonumber(target.text))
					return 
				end
				
				-- 최대갯수 설정
				-- print(max, trade.cnt)
				max = max and tonumber(max) or trade.cnt
				if trade.cntBtn.text=='' then
					trade.cntBtn.text = comma(max)
					return
				end
				if gbn == 'cnt' and max < tonumber(trade.cntBtn.text) then
					trade.cntBtn.text = comma(max)
					showAlert_panel('최대개수를 초과하여 입력할 수 없습니다.\n보유개수 : '..max .. '개')
				end

				if string.len(trade.cntBtn.text) > 0 and string.len(trade.priceBtn.text) > 0 then 
						trade.totalPrice.text = comma(tonumber(trade.cntBtn.text) * tonumber(trade.priceBtn.text) )
				else
						trade.totalPrice.text = 0
				end
		end)
		inputPanel.AddChild(inputBtn[iFlag])
	end
end


function trade:init()
	self.blick = Panel(Rect(0, 0, Client.width, Client.height))
	self.blick.visible = false
	self.blick.showOnTop = true

	self.Make_Panel = Panel(Rect(0, 0, self.Garo, self.Sero))
	self.Make_Panel.anchor = 4
	self.Make_Panel.pivotX = 0.5
	self.Make_Panel.pivotY = 0.5
	self.Make_Panel.color = Color(0, 0, 0, 255)
	self.blick.AddChild(self.Make_Panel)

	self.Make_Panel2 = Panel(Rect(1, 1, self.Make_Panel.width-2, self.Make_Panel.height-2))
	self.Make_Panel2.AddChild(Image(path..'큐브상점 이미지.png', Rect(0, 0, self.Garo, self.Sero)))
	self.Make_Panel2.color = Color(66, 66, 66, 255)
	self.Make_Panel.AddChild(self.Make_Panel2)
	
	

	local maketext = Text('거 래 소', Rect(0, 10, 120, 60))
	maketext.textAlign = 1
	maketext.anchor = 1
	maketext.pivotX = 0.5
	maketext.textSize = 22
	maketext.borderEnabled = true
	maketext.borderDistance = Point(1, 1)
	self.Make_Panel2.AddChild(maketext)

	local CloseButtonImg =  Image(path..'취소.png', Rect(self.Garo-80, 5, 75, 30))
	CloseButtonImg.AddChild(text_border(CloseButtonImg, '닫기'))
	self.Make_Panel2.AddChild(CloseButtonImg)
	
	local CloseButton = Button('', Rect(0, 0, CloseButtonImg.width, CloseButtonImg.height))
	CloseButton.textAlign = 4
	CloseButton.SetOpacity(0)
	CloseButtonImg.AddChild(CloseButton)
	
	CloseButton.onClick.Add(function()
		self.blick.visible = false
	end)
	
	self.main_panel = Panel(Rect(10, 85, 720, 270))
	self.main_panel.color = Color(77, 77, 77, 100)
	self.Make_Panel2.AddChild(self.main_panel)
	
	
	
	local MakerImg = Image(path..'취소.png', Rect(10, 363.5, 110, 30))
	self.Make_Panel.AddChild(MakerImg)
	local MakerButton = Button('', Rect(0, 0, MakerImg.width, MakerImg.height))
	MakerButton.AddChild(text_border(MakerButton, '아이템 검색'))
	MakerButton.setOpacity(0)
	MakerImg.AddChild(MakerButton)
	
	local MakerImg2 = Image(path..'취소.png', Rect(MakerImg.width+15, MakerImg.y, MakerImg.width, MakerImg.height))
	self.Make_Panel.AddChild(MakerImg2)
	local MakerButton2 = Button('', Rect(0, 0, MakerImg2.width, MakerImg2.height))
	MakerButton2.AddChild(text_border(MakerButton2, '아이템 올리기'))
	MakerButton2.setOpacity(0)
	MakerImg2.AddChild(MakerButton2)
	MakerButton2.onClick.Add(function()
		self.trading = 0
		Client.FireEvent("trade.registerItem")
		self:sellInput('cnt', '', '판매수량 입력')
		self.priceImg.SetOpacity(0)
		self.priceBtn.SetOpacity(255)
	end)

	local LeftImg = Image(path..'ButL.png', Rect(MakerImg2.x+MakerImg2.width+22, MakerImg2.y-2, 36, 36))
	self.Make_Panel.AddChild(LeftImg)
	local LeftBut = Button('', Rect(0, 0, LeftImg.width, LeftImg.height))
	LeftBut.SetOpacity(0)
	LeftImg.AddChild(LeftBut)
	
	local pagePal = Panel(Rect(LeftImg.x+LeftImg.width+2, LeftImg.y+5, 50, 26))
	self.Make_Panel.AddChild(pagePal)
	self.pageText = Text('1/0', Rect(0, 0, pagePal.width, pagePal.height))
	self.pageText.textAlign = 4
	self.pageText.textSize = 12
	pagePal.AddChild(self.pageText)
	self.Make_Panel.AddChild(pagePal)
	
	local RightImg = Image(path..'ButR.png', Rect(pagePal.x+pagePal.width+2, LeftImg.y, 36, 36))
	self.Make_Panel.AddChild(RightImg)
	local RightBut = Button('', Rect(0, 0, RightImg.width, RightImg.height))
	RightBut.SetOpacity(0)
	RightImg.AddChild(RightBut)
	
	LeftBut.onClick.Add(function()
		if showPage ~= -1 then
			if showPage > 1 then
				showPage = showPage-1
				self.pageText.text = showPage..'/'..self.maxPage
				trade:pageFunc()
			end
		end
	end)
	RightBut.onClick.Add(function()
		if showPage ~= -1 then
			if showPage < self.maxPage then
				showPage = showPage+1
				self.pageText.text = showPage..'/'..self.maxPage
				trade:pageFunc()
			end
		end
	end)
	
	self.mainMenuScrollPanel = ScrollPanel(Rect(5, 50, 740, 32))
	local a = Image(path..'740300.png', Rect(5, 50, 740, 32))


	self.mainMenuScrollPanel.setOpacity(0)
	self.mainMenuScrollPanel.vertical = false
	self.mainMenuSon = Panel(Rect(0, 0, 105*(#self.MenuName), 32))
	self.mainMenuSon.setOpacity(0)

	self.mainMenuScrollPanel.AddChild(self.mainMenuSon)

	self.mainMenuScrollPanel.content = self.mainMenuSon
	self.Make_Panel.AddChild(a) 
	self.Make_Panel.AddChild(self.mainMenuScrollPanel)

	self.inP = Panel(Rect(self.main_panel.width-263, 5, 260, 265))
	self.inP.AddChild(Image(path..'내부1.png', Rect(0, 0, self.inP.width, self.inP.height)))
	self.inP.SetOpacity(0)

	self.main_panel.AddChild(self.inP)
	self.inL = Panel(Rect(0, 0, self.main_panel.width-self.inP.width-10, 45*self.page+5))
	
	local itempaneling = Image(path..'내부1.png', Rect(5, 5, self.inL.width, self.main_panel.height -5))
	self.main_panel.AddChild(itempaneling)
	
	

	self.scroll_panel = ScrollPanel(Rect(5, 5, self.main_panel.width - self.inP.width - 10 , self.main_panel.height -5))
	self.scroll_panel.SetOpacity(0)
	self.scroll_panel.horizontal = false
	self.scroll_panel.content = self.inL
	self.main_panel.AddChild(self.scroll_panel)
	
	self.inPtext = text_border(self.inP, '')
	self.inPtext.rect = Rect(5, 5, self.inP.width-10, self.inP.height-10)
	self.inPtext.textAlign = 0
	self.inP.AddChild(self.inPtext)
	
	self.buyImg = Image(path..'취소.png', Rect(0, self.inP.height-40, 75, 30))
	self.buyImg.visible = false
	self.buyImg.AddChild(text_border(self.buyImg, '구매'))
	self.buyImg.anchor = 1
	self.buyImg.pivotX = -0.3
	self.inP.AddChild(self.buyImg)
	
	self.collectImg = Image(path..'취소.png', Rect(0, self.inP.height-40, 75, 30))
	self.collectImg.visible = false
	self.collectImg.AddChild(text_border(self.collectImg, '회수'))
	self.collectImg.anchor = 1
	self.collectImg.pivotX = 1.3
	self.inP.AddChild(self.collectImg)
	
	local buyBut = Button('', Rect(0, 0, self.buyImg.width, self.buyImg.height))
	buyBut.SetOpacity(0)
	self.buyImg.AddChild(buyBut)
	buyBut.onClick.Add(function()
		self.trading = 1
		self:sellInput('cnt', '', '구매수량 입력')
		self:setPrice(self.nowID, self.nowCnt, self.nowLv)
		self.priceBtn.text = commaValue(self.purItem)
		self.priceImg.SetOpacity(255)
		self.priceBtn.SetOpacity(0)
	end)
	
	local collectBut = Button('', Rect(0, 0, self.collectImg.width, self.collectImg.height))
	collectBut.SetOpacity(0)
	self.collectImg.AddChild(collectBut)
	collectBut.onClick.Add(function()
		Client.FireEvent('거래소_아이템회수', Utility.JSONSerialize(self.ItemTableData[self.choose]), self.idx)
	end)



	-- 거래소 아이템 타입 구분 버튼 (상단)
	self.MainMenuButton = {}
	self.MenuButtonText = {}
 
	for i = 1, #self.MenuName do
		local img =  Image(path..'취소.png', Rect(5+100*(i-1), 0, 90, 32))
		self.MainMenuButton[i] = Button('', Rect(5+100*(i-1), 0, 90, 32))
		self.MainMenuButton[i].setOpacity(0)
		self.MainMenuButton[i].onClick.Add(function()
			Loading_panel.visible = true
			Client.FireEvent('trade.registerItem3', i)
			self.black_pal.visible = true
			Client.RunLater(function()
				self.black_pal.visible = false
			end, 0.65)
		end)
		
		self.MenuButtonText[i] = text_border(self.MainMenuButton[i], self.MenuName[i])
		self.MainMenuButton[i].AddChild(self.MenuButtonText[i])

		self.mainMenuSon.AddChild(img)
		self.mainMenuSon.AddChild(self.MainMenuButton[i])
	end
	
	self.tItem = {
		img = {},
		Gtext = {},
		but = {},
		iconImg = {},
		count = {},
		data = {},
		lvText = {}
	}
	
	local t = self.tItem
	for i=1, self.page do
		t.img[i] = Image(path..'상점2.png', Rect(5, 5+45*(i-1), self.inL.width-10, 40))
		self.inL.AddChild(t.img[i])
		t.img[i].visible = false
		
		t.Gtext[i] = text_border(t.img[i], '')
		t.Gtext[i].width = t.Gtext[i].width-5
		t.Gtext[i].textAlign = 5
		t.img[i].AddChild(t.Gtext[i])
		
		t.but[i] = Button('', Rect(0, 0, t.img[i].width, t.img[i].height))
		t.but[i].color = Color(0, 0, 0, 0)
		t.img[i].AddChild(t.but[i])

		local icon_panel = Panel(Rect(1, 1, t.but[i].height-2, t.but[i].height-2))
		icon_panel.setOpacity(100)
		t.but[i].AddChild(icon_panel)

		t.iconImg[i] = Image('', Rect(0, 0, icon_panel.width, icon_panel.height))
		icon_panel.AddChild(t.iconImg[i])
		
		t.count[i] = text_border(t.but[i], '')
		t.count[i].rect = Rect(icon_panel.width+7, 0, t.but[i].width-icon_panel.width-10, t.but[i].height)
		t.count[i].textAlign = 3
		t.but[i].AddChild(t.count[i])
		
		t.lvText[i] = Text('',Rect(0, 0, icon_panel.width, icon_panel.height))
		t.lvText[i].textSize = 11
		t.lvText[i].borderEnabled = true
		t.lvText[i].textAlign = 0
		t.iconImg[i].AddChild(t.lvText[i])

		t.but[i].onClick.Add(function()
			self.buyImg.visible = true
			self.collectImg.visible = true
			local I = i+(showPage-1)*self.page
			local tt = self.showKey[I]
			self.purItem = commaValue(t.data[I].s)
			local lvT = "<Color=#ADFF2F>+"..t.data[I].lv.." </Color>"
			if t.data[I].lv == 0 then lvT = '' end
			local ttt = '\n<color=#D8D8D8>판매 가격 : <color=#D7DF01>'..self.purItem..' Gold</color>\n수량 : '
			if goods > -1 then
				ttt = '\n<color=#D8D8D8>판매 가격 : <color=#F7D358>'..self.purItem..' '..Client.GetItem(goods).name..'</color>\n수량 : '
			end
			self.inPtext.text = lvT..Client.GetItem(t.data[I].id).name..ttt..
				commaValue(t.data[I].cnt)..'개\n\n</color><size=12>'..tt.txt..'</size>'
			self.nowID = t.data[I].id
			self.nowCnt = t.data[I].cnt
			self.nowLv = t.data[I].lv
			self.choose = I
		end)
	end
	
	--[[ 판매정보 MASK]]
	self.dataMask = Panel(Rect(0,0,Client.width,Client.height))
	self.dataMask.visible = false
	self.dataMask.showOnTop = true
	self.dataMask.SetOpacity(0)
	self.dataMask.color = Color(0,0,0,200)
	
	self.bg = Panel(Rect(Client.width/2-250, Client.height/2-150, 500, 300))
	local bgImg = Image(path..'makeBGpanel.png', Rect(0, 0, 500, self.bg.height))
	
    self.title_text = Text('───┼   판매정보 입력   ┼───', Rect(0, 10, 500, 50))
    self.title_text.textSize = 18
    self.title_text.textAlign = 1

	self.bg.AddChild(bgImg)
	self.bg.AddChild(self.title_text)
	-- self.bg.AddChild(inputBG)
	self.dataMask.AddChild(self.bg)

--[[ 판매정보 배경 및 패널 ]]
	local itemInfoBG = Panel(Rect(20, 50, 250, 200))
	itemInfoBG.color = Color(0,0,0,50)
	itemInfoBG.showOnTop = true
	
	local item_img = Image(path..'innerBG.png', Rect(0, 0, 250, 50))
	local itemData_img = Image(path..'itemBg.png', Rect(5,5,40,40))
	
	self.itemData = Image("", Rect(4, 4, 32, 32))

	self.itemData_Lvtext = Text('',Rect(0, 0, self.itemData.width, self.itemData.height))
	self.itemData_Lvtext.textSize = 11
	self.itemData_Lvtext.textAlign = 0
	
	self.itemData.AddChild(self.itemData_Lvtext)
	itemData_img.AddChild(self.itemData)
	self.itemData_text = Text("",Rect(50, 0, 155, 45))
	self.itemData_text.textAlign = 3
		
	item_img.AddChild(self.itemData_text)
	item_img.AddChild(itemData_img)
	itemInfoBG.AddChild(item_img)
	
	self.inputPanel = Panel(Rect(0, 51, 250, 100))
	local inputBGimg =  Image(path..'innerBG.png', Rect(0, 0, 250, 100))
	self.inputPanel.AddChild(inputBGimg)	
	self.inputPanel.SetParent(itemInfoBG)
	self.cntText =  Text("판매수량",Rect(10, 5, 100, 20))
	self.cntText.textSize = 12
	
	self.cntBtn = Button('1',Rect(self.cntText.width+10,5, 120, 20))
	self.cntBtn.color = Color(30,30,30)
	
	self.cntBtn.onClick.Add(function()
		if self.trading == 0 then
			self:sellInput('cnt', self.cnt, '판매수량 입력')
		else
			self:sellInput('cnt', self.cnt, '구매수량 입력')
		end
	end)
	
	self.priceText =  Text("개당 판매금액",Rect(10, self.cntText.height+15, 100, 20))
	self.priceText.textSize = 12
	
	self.priceImg = Image(path..'button1.png',Rect(self.priceText.width+10,self.cntText.height+15, 120, 20))
	self.priceImg.SetOpacity(0)
	
	self.priceBtn = Button('0',Rect(0, 0, 120, 20))
	self.priceBtn.color = Color(30,30,30)
	self.priceImg.AddChild(self.priceBtn)
	self.priceBtn.onClick.Add(function()
		if self.trading == 0 then
			self:sellInput('price','','개당 판매금액 입력')
		else
			self:sellInput('price','','개당 구매금액 입력')
		end
	end)
	
	local avgPriceText =  Text("최근 거래가",Rect(10, self.cntText.height+self.priceText.height+25, 100, 20))
	avgPriceText.textSize = 12
	
	local avgPriceImg =  Image(path..'button1.png',Rect(avgPriceText.width+10, self.cntText.height+self.priceText.height+25, 120, 20))
	self.avgPrice =  Text('' ,Rect(avgPriceText.width+10, self.cntText.height+self.priceText.height+25, 120, 20))
	self.avgPrice.textSize = 12
	self.avgPrice.textAlign =4
	
	self.inputPanel.AddChild(self.cntText)	
	self.inputPanel.AddChild(self.cntBtn)
	self.inputPanel.AddChild(self.priceText)
	self.inputPanel.AddChild(self.priceImg)
	self.inputPanel.AddChild(avgPriceText)
	self.inputPanel.AddChild(avgPriceImg)
	self.inputPanel.AddChild(self.avgPrice)
		
	local buyPanel = Panel(Rect(0, self.inputPanel.height+item_img.height+3, 250, 70))
	local buyBGimg =  Image(path..'innerBG.png', Rect(0, 0, 250, 70))
	buyPanel.AddChild(buyBGimg)

	self.totalPriceText =  Text("총 판매금액",Rect(10, 10, 100, 20))
	self.totalPriceText.textSize = 12
	local totalPriceImg =  Image(path..'button1.png',Rect(self.totalPriceText.width+10, 10, 120, 21))

	self.totalPrice =  Text("0",Rect(self.totalPriceText.width+10,10, 120, 20))
	self.totalPrice.textSize = 12
	self.totalPrice.textAlign =4

	buyPanel.AddChild(self.totalPriceText)
	buyPanel.AddChild(totalPriceImg)
	buyPanel.AddChild(self.totalPrice)

	local cancelBtn = Button('취소',Rect(35,self.cntText.height+self.totalPriceText.height, 90, 25))
	cancelBtn.color = Color(30,30,30,150)
	cancelBtn.borderEnabled = true
	cancelBtn.borderColor = Color(0,0,0)
	cancelBtn.onClick.Add(function()
		self.dataMask.visible = false
		self.cntBtn.text = '1'
		self.priceBtn.text = '0'
		self.totalPrice.text = '0'
		max = nil
	end)

	buyPanel.AddChild(cancelBtn)

	self.addBtn = Button('등록',Rect(140,self.cntText.height+self.totalPriceText.height, 90, 25))
	self.addBtn.color = Color(30,30,30,150)
	self.addBtn.borderEnabled = true
	self.addBtn.borderColor = Color(0,0,0)
	self.addBtn.onClick.Add(function()
		Loading_panel.visible = true
		local txt = self.trading==0 and '판매' or '구매'
		if self.cntBtn.text == '' or self.cntBtn.text == '0' then
			showAlert_panel(txt..'수량을 입력해주세요.')
			Loading_panel.visible = false
			return
		end

		if self.priceBtn.text == '' or self.priceBtn.text == '0' then
			showAlert_panel('개당 '..txt..'금액을 입력해주세요.')
			Loading_panel.visible = false
			return
		end
		
		if self.trading==0 then
			self:sellInput('cnt', self.cnt, '판매수량 입력')
			Client.FireEvent("trade.registerItem2", math.floor(tonumber(self.priceBtn.text)), math.floor(tonumber(self.cntBtn.text)))
		else
			self:sellInput('cnt', self.cnt, '구매수량 입력')
			Client.FireEvent("trade.registerItem4", Utility.JSONSerialize(self.ItemTableData[self.choose]), self.idx,
				tonumber(self.cntBtn.text))
		end
		self.dataMask.visible = false
		self.cntBtn.text = '1'
		self.priceBtn.text = '0'
		self.totalPrice.text = '0'
		max = nil
	end)

	buyPanel.AddChild(self.addBtn)
	itemInfoBG.AddChild(buyPanel)
	self.bg.AddChild(itemInfoBG)
	
	Func_()
	Func_ = nil
	
	self:sellInput('cnt', self.cnt, '판매수량 입력')
	
	self.black_pal = Panel(Rect(5, 50, 740, 32)){
		opacity = 0,
		visible = false,
		parent = self.Make_Panel
	}
	
	Loading_panel = Panel(Rect(-25, -25, Client.width+25, Client.height+25)){
		color = Color.black,
		showOnTop = true,
		visible = false,
		opacity = 150
	}
	local Loading_txt = text_border(Loading_panel, 'Loading...')
	Loading_txt.textSize = 56
	Loading_panel.AddChild(Loading_txt)
end 

 



function trade:sellInput(a, b, c)
	gbn, max, _text = a, b, c
	if gbn == nil then
		gbn = 'cnt'
		_text = '판매수량 입력'
	end
	
	title_text.text = _text
	inputBG.visible = true
end


function trade:setPrice(id, cnt, lv)
	self.cnt = cnt
	self.dataMask.visible = true
	
	self.itemData.SetImageID(Client.GetItem(id).imageID)
	
	if self.trading==1 then
		self.title_text.text = '───┼   구매정보 입력   ┼───'
		self.cntText.text = '구매수량' -- <size=9>\n('..b..'개)</size>
		self.priceText.text = '개당 구매금액'
		self.totalPriceText.text = '총 구매금액'
		self.addBtn.text = '구매'
	else
		self.title_text.text = '───┼   판매정보 입력   ┼───'
		self.cntText.text = '판매수량'
		self.priceText.text = '개당 판매금액'
		self.totalPriceText.text = '총 판매금액'
		self.addBtn.text = '등록'
	end

	local lvT = "<Color=#ADFF2F>+"..lv.."</Color>"
	if lv == 0 then lvT = '' end
	self.itemData_Lvtext.text = lvT
	self.itemData_text.text = --[[lvT..' '..]]Client.GetItem(id).name
	if self.avg and self.avg[tostring(id)] then
		self.avgPrice.text =  commaValue(math.ceil(self.avg[tostring(id)] * 10^1 - 0.5 ) / 10^1)
	else
		self.avgPrice.text = '거래내역 없음'
	end
end
Client.GetTopic("trade.setPrice").Add(function(a,b,c) trade:setPrice(a,b,c) end)




function trade:showList(idx, items)
	for i, v in pairs(self.MenuButtonText)  do
		v.text = '<color=#FFFFFF>'..self.MenuName[i]..'</color>'
	end
	self.idx = idx
	self.MenuButtonText[idx].text = '<color=#01A9DB>'..self.MenuName[idx]..'</color>'
	self.buyImg.visible = false
	self.collectImg.visible = false
	self.inPtext.text = ''
	showPage = 1
	
	local t = self.tItem
	local k = 0
	self.sumPage = 0
	self.showKey = {}
	self.ItemTableData = {}
	for i, v in pairs(items) do
		self.sumPage = self.sumPage + #v
		for j, b in ipairs(v) do
			k = k+1
			self.ItemTableData[k] = b
			self.ItemTableData[k].playerID = i
			self.ItemTableData[k].key = j
			
			self.showKey[k] = {}
			local tt = self.showKey[k]
			local ttt = '<size=12><color=#BDBDBD>개당 </color></size><color=#D7DF01>'..commaValue(b.s)..' Gold</color>'
			if goods > -1 then
				ttt = '<size=12><color=#BDBDBD>개당 </color></size><color=#F7D358>'..commaValue(b.s)..' '..Client.GetItem(goods).name..'</color>'
			end
			tt.priceText = ttt
			tt.imageID = Client.GetItem(b.I).imageID
			tt.countText = Client.GetItem(b.I).name..'\n<size=12><color=#BDBDBD>(수량 : '..commaValue(b.c)..'개)</color></size>'
			if b.op.t[1] then
				tt.txt = '<color=#FF00FF>옵션\n</color>'
			else
				tt.txt = '<color=#BDBDBD>옵션 없음</color>'
			end
			for m, _ in ipairs(b.op.t) do
				tt.txt = tt.txt..filter(b.op.t[m], b.op.i[m], b.op.v[m])..'\n'
			end
			if k <= self.page then
				local lvT = "<Color=#ADFF2F>+"..b.lv.."</Color>"
				if b.lv == 0 then lvT = '' end
				t.lvText[k].text = lvT
				t.img[k].visible = true
				t.Gtext[k].text = tt.priceText
				t.iconImg[k].SetImageID(tt.imageID)
				t.count[k].text = tt.countText
			end
			t.data[k] = {id=b.I, cnt=b.c, lv=b.lv, s=b.s}
		end
	end
	
	if self.sumPage < self.page then
		for i=self.page, self.sumPage+1, -1 do
			t.img[i].visible = false
		end
	end
	
	self.maxPage = math.ceil(self.sumPage/self.page)
	self.pageText.text = showPage..'/'..self.maxPage
end

function trade:pageFunc()
	local t = self.tItem
	local num = (self.sumPage+self.page)-showPage*self.page
	local maxIndex = num > self.page and self.page or num
	for i=1, maxIndex do
		local I = i+(showPage-1)*self.page
		local tt = self.showKey[I]
		t.img[i].visible = true
		t.Gtext[i].text = tt.priceText
		t.iconImg[i].SetImageID(tt.imageID)
		t.count[i].text = tt.countText
		local lvT = "<Color=#ADFF2F>+"..t.data[I].lv.."</Color>"
		if t.data[I].lv == 0 then lvT = '' end
		t.lvText[i].text = lvT
	end
	
	for i=self.page, maxIndex+1, -1 do
		t.img[i].visible = false
	end
end

local function shuffle(tbl) -- suffles numeric indices
    local len = #tbl
    for i = len, 2, -1 do
        local j = rand( 1, i+1 )
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

Client.GetTopic("trade_management").Add(function(idx, txt, txt2)
	-- 랜덤정렬 지원
	local tbl = Utility.JSONParse(txt)
	trade.avg = Utility.JSONParse(txt2)
	
	local numTbl = {}
	local i = 1
	for key, v in pairs(tbl) do
		numTbl[i] = {[key]=v}
		i = i+1
	end
	
	shuffle(numTbl)
	
	local textTbl = {}
	for _, v in ipairs(numTbl) do
		for j, b in pairs(v) do
			textTbl[j] = b
		end
	end
	
	trade:showList(idx, textTbl)
	Loading_panel.visible = false
end)

Client.FireEvent('TemDataID')
Client.GetTopic("TemDataID").Add(function(TemDataID, t)
	goods = TemDataID
	trade.MenuName = Utility.JSONParse(t)
	trade:init()
end)

Client.GetTopic("거래소_open").Add(function()
	trade.blick.visible = true
end)

Client.GetTopic("거래소_아이템선택").Add(function(a, b, c)
	Client.FireEvent('trade.set_selectItem', a, b, c)
end)

Client.GetTopic("거래소_로딩패널삭제").Add(function()
	Loading_panel.visible = false
end)

