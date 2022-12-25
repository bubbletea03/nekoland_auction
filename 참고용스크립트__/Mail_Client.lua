local mail = {}
mail.page = 10


-- 전역 함수
function text_border(parents, text, size) 
	local obj = Text(text, Rect(0, 0, parents.width, parents.height))
	obj.textAlign = 4
	obj.textSize = size and size or 14
	obj.borderEnabled = true
	obj.borderDistance = Point(1, 1)
	return obj
end

-- 전역 함수
function commaValue(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- 전역 함수
local showPal, showText = nil, nil
function showAlert_panel(txt)
	if showPal==nil then
		showPal = Panel(Rect(-25, -25, Client.width+25, Client.height+25)){
		color = Color(128, 128, 128, 150),
		showOnTop = true,
		visible = false
		}
		
		local img = Image('Pictures/거래소/알림몸통.png', Rect(0, 0, 380, 248)){
			anchor = 4,
			pivot = Point(0.5, 0.5),
			parent = showPal
		}
		
		local text = Text('\n<size=28>알 림</size>'){
			rect = img.rect,
			textAlign = 1,
			color = Color(117, 152, 255),
			borderEnabled = true,
			parent = img
		}
		
		local img2 = Image('Pictures/거래소/알림속몸통.png', Rect(0, 60, 330, 140)){
			anchor = 1,
			pivotX = 0.5,
			parent = img
		}
		
		local img3 = Image('Pictures/거래소/알림버튼.png', Rect(0, 0, 91, 39)){
			anchor = 7,
			pivot = Point(0.5, 1.2),
			parent = img
		}
		
		local but = Button(){
			rect = img3.rect,
			opacity = 0,
			parent = img3
		}
		but.onClick.Add(function()
			showPal.visible = false
		end)
		
		local text2 = Text('<size=18><color=#F2F2F2>확 인</color></size>'){
			rect = img3.rect,
			textAlign = 4,
			borderEnabled = true,
			parent = but
		}
		
		showText = Text('안녕하세요. 불만있음 한판 뜨던가', Rect(5, 5, img2.width-10, img2.height-10)){
			color = Color(43, 43, 43),
			textSize = 15,
			-- borderEnabled = true,
			-- borderColor = Color.black,
			-- borderDistance = Point(1, 1),
			parent = img2
		}
	else
		if txt then
			showPal.visible = true
			showText.text = txt
		else
			showPal.visible = false
		end
	end
end
--[ UI우선순위 최상위로 올라오기 위해서 런레이터 ]
Client.RunLater(showAlert_panel, 2)

local Loading_panel = nil
local showPage = 1
local path = 'Pictures/거래소/'
function mail:init()
	self.mainPal = Image(path..'큐브상점 이미지.png', Rect(0, 0, 340, 420))
	self.mainPal.anchor = 4
	self.mainPal.pivotX = 0.5
	self.mainPal.pivotY = 0.5
	self.mainPal.showOnTop = true
	self.mainPal.visible = false
	
	local maketext = Text('소 포 함', Rect(0, 10, 120, 60))
	maketext.textAlign = 1
	maketext.anchor = 1
	maketext.pivotX = 0.5
	maketext.textSize = 22
	maketext.borderEnabled = true
	maketext.borderDistance = Point(1, 1)
	self.mainPal.AddChild(maketext)
	
	local CloseButtonImg =  Image(path..'취소2.png', Rect(-4, 4, 33, 33)){
		anchor = 2,
		pivotX = 1
	}
	self.mainPal.AddChild(CloseButtonImg)
	local dumyTxt = text_border(CloseButtonImg, '✖')
	dumyTxt.textSize = 21
	CloseButtonImg.AddChild(dumyTxt)
	
	
	local CloseButton = Button('', Rect(0, 0, CloseButtonImg.width, CloseButtonImg.height))
	CloseButton.textAlign = 4
	CloseButton.SetOpacity(0)
	CloseButtonImg.AddChild(CloseButton)
	
	CloseButton.onClick.Add(function()
		self.mainPal.visible = false
	end)
	
	local a = Image(path..'740300.png', Rect(0, 50, self.mainPal.width-20, 329)){
		anchor = 1,
		pivotX = 0.5
	}
	self.mainPal.AddChild(a)
	
	local scrollPal = ScrollPanel(){
		rect = Rect(0, 50, self.mainPal.width-20, 329), -- a.rect
		anchor = 1,
		pivotX = 0.5,
		vertical = true,
		horizontal = false
	}
	self.mainPal.AddChild(scrollPal)
	
	local mailImg = Image(path..'내부1.png', Rect(0, 0, scrollPal.width, 2+64*self.page))
	scrollPal.content = mailImg
	
	local pagePal = Panel(Rect(0, 0, 50, 36)){
		anchor = 7,
		pivot = Point(0.5, 1.1)
	}
	self.mainPal.AddChild(pagePal)
	self.pageText = text_border(pagePal, '1/1')
	pagePal.AddChild(self.pageText)
	self.mainPal.AddChild(pagePal)
	
	self.img, self.itemName, self.validity, self.iconImg = {}, {}, {}, {}
	for i=1, self.page do
		self.img[i] = Image(path..'상점2.png', Rect(4, 2+64*(i-1), scrollPal.width-8, 62))
		mailImg.AddChild(self.img[i])
		self.img[i].visible = false
		
		local itemIcon = Image(path..'itemBg.png', Rect(6, 6, 48, 48))
		self.img[i].AddChild(itemIcon)
		
		self.itemName[i] = Text('거래소\n\n4,444 Gold'){
			x = itemIcon.x+itemIcon.width+4,
			y = 6,
			width = self.img[i].width-(itemIcon.x+itemIcon.width)-10,
			height = self.img[i].height-12,
			textAlign = 3,
			borderEnabled = true
		}
		self.img[i].AddChild(self.itemName[i])
		
		self.validity[i] = Text('22/10/05 21:04 까지'){
			x = itemIcon.x+itemIcon.width+4,
			y = 6,
			width = self.img[i].width-(itemIcon.x+itemIcon.width)-10,
			height = self.img[i].height-12,
			textAlign = 5,
			borderEnabled = true
		}
		self.img[i].AddChild(self.validity[i])
		
		self.iconImg[i] = Image(path..'Gold.png', Rect(0, 0, itemIcon.width-8, itemIcon.height-8)){
			anchor = 4,
			pivot = Point(0.5, 0.5)
		}
		itemIcon.AddChild(self.iconImg[i])
		
		local but = Button('', Rect(0, 0, self.img[i].width, self.img[i].height))
		but.color = Color(0, 0, 0, 0)
		self.img[i].AddChild(but)

		but.onClick.Add(function()
			Loading_panel.visible = true
			Client.FireEvent('소포함_받기', Utility.JSONSerialize(self.package), i)
		end)
	end
	
	Loading_panel = Panel(Rect(-25, -25, Client.width+25, Client.height+25)){
		color = Color.black,
		showOnTop = true,
		visible = false,
		opacity = 150
	}
	Loading_panel.SetOpacity(150)
	local Loading_txt = text_border(Loading_panel, 'Loading...')
	Loading_txt.textSize = 56
	Loading_panel.AddChild(Loading_txt)
end

function mail:showItem(tbl)
	self.mainPal.visible = true
	self.package = tbl
	self.sumPage = #tbl
	local CI = Client.GetItem
	for i, v in ipairs(tbl) do
		if i > self.page then
			break
		end
		local UserName = string.gsub(v.sellName, 'n~Q5 ', '/')
		self.img[i].visible = true
		local goldText = ''
		local sellValue = commaValue(v.s*v.count)
		local word = ' 개 판매\n'
		if v.RemoveType == 'Gold' then
			if v.goldType == -1 then
				goldText = '<color=#D7DF01>'..sellValue..' 골드</color>'
				self.iconImg[i].image = path..'Gold.png'
			else
				goldText = CI(v.goldType).name..' '..sellValue..' 개'
				self.iconImg[i].SetImageID(Client.GetItem(v.goldType).imageID)
			end
		else
			self.iconImg[i].SetImageID(Client.GetItem(v.I).imageID)
			word = ' 개 회수\n'
		end
		self.itemName[i].text = CI(v.I).name..'\n'..commaValue(v.count)..word..goldText
		--os.date('\n%y/%m/%d %H:%M:%S\n', v.sellTime)
		local days = os.date('\n<color=#E6E6E6>%m/%d %H:%M:%S</color>\n', v.sellTime)
		self.validity[i].text = UserName..days
	end
	
	if self.sumPage < self.page then
		for i=self.page, self.sumPage+1, -1 do
			self.img[i].visible = false
		end
	end
	
	self.maxPage = math.ceil(self.sumPage/self.page)
	self.pageText.text = showPage..'/'..self.maxPage
	Loading_panel.visible = false
end

Client.GetTopic("소포함_open").Add(function(txt)
	if txt ~= nil then
		Loading_panel.visible = true
		mail:showItem(Utility.JSONParse(txt))
	else
		mail.mainPal.visible = true
		Loading_panel.visible = false
	end
end)

mail:init()

Client.GetTopic("소포함_로딩패널삭제").Add(function()
	Loading_panel.visible = false
end)

Client.GetTopic("프레시_알림창").Add(showAlert_panel)
