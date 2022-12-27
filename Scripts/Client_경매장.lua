-------------------------------------------------
OPTION_TYPES = {"직업", "직업", "아이템", "아이템"}
STAT_NAMES = {"공격력", "방어력", "마법공격력", "마법방어력", "민첩", "행운", "체력", "마력"}
-------------------------------------------------






-- Starting
function Open_Auction()
    Auction:Init()
end


-- Auction UI
Auction = { page = 1 }
    function Auction:Init()

        self.screen = Panel(Rect(0,0,Client.width,Client.height)) -- 최상위 UI 요소입니다.
        self.screen.showOnTop = true
        self.screen.color = Colors.BLACK
        self.screen.SetOpacity(100)

        self.panel = SetupComponent(self.screen, Panel(Rect(0, 0, 640, 360)), Colors.GRAY, Aligns.MIDDLE_CENTER, 0.5, 0.5)

        local btn_buyTab = SetupComponent(self.panel, Button("구매", Rect(5, 5, 90, 40)), Colors.LIGHT_GRAY, Aligns.TOP_LEFT);
        btn_buyTab.onClick.Add(function()
            Auction:Goto_BuyTab()
        end)

        local btn_sellTab = SetupComponent(self.panel, Button("판매", Rect(100, 5, 90, 40)), Colors.LIGHT_GRAY, Aligns.TOP_LEFT)
        btn_sellTab.onClick.Add(function()
            Auction:Goto_SellTab()
        end)

        local btn_exit = SetupComponent(self.panel, Button("X", Rect(-5, 5, 40, 40)), Colors.LIGHT_GRAY, Aligns.TOP_RIGHT, 1.0, 0)
        btn_exit.onClick.Add(function()
            self.screen.Destroy()
        end)

        Client.FireEvent("S_Auction:SendAuctionItems")
    end

    function Auction:Goto_BuyTab()
        Auction:ClearTabPanel()
        self.buyTab_panel = SetupComponent(self.panel, Panel(Rect(10, 50, 620, 300)), Colors.NONE, Aligns.TOP_LEFT)

        local itemlist_panel = SetupComponent(self.buyTab_panel, Panel(Rect(0, 20, 400, 240)), Colors.NONE, Aligns.TOP_RIGHT, 1.0, 0)
        self.itemPanels = SetupSeparatingPanels(itemlist_panel, 5); -- '아이템 목록 패널' 안에 5개의 '아이템 패널'을 만든다.
        Auction:LoadBuyTabItems(1)

        local info_panel = SetupComponent(self.buyTab_panel, Panel(Rect(0, 20, 200, 240)), Colors.DARK_GRAY, Aligns.TOP_LEFT, 0, 0)
        self.info_txt = SetupComponent(info_panel, Text("", Rect(0, 0, info_panel.width, info_panel.height)), nil, Aligns.TOP_LEFT, 0, 0)
        self.info_txt.textAlign = Aligns.TOP_LEFT

        local arrowLeft_btn = SetupComponent(self.buyTab_panel, Button("<", Rect(-25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)
        local arrowRight_btn = SetupComponent(self.buyTab_panel, Button(">", Rect(25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)

        local pageText = SetupComponent(self.buyTab_panel, Text(self.page .. "/" .. "2", Rect(80, -15, 40, 40)), nil, Aligns.BOTTOM_CENTER, 0.5, 0.5)

    end

    function Auction:Goto_SellTab()
        Auction:ClearTabPanel()
        self.sellTab_panel = SetupComponent(self.panel, Panel(Rect(10, 50, 620, 300)), Colors.NONE, Aligns.TOP_LEFT)

        local registered_itemlist_panel = SetupComponent(self.sellTab_panel, Panel(Rect(0, 20, 400, 240)), Colors.NONE, Aligns.TOP_LEFT)
        self.itemPanels = SetupSeparatingPanels(registered_itemlist_panel, 5);
        Client.FireEvent("S_Auction:SendSellTabItems")

        self.isSelected = false -- 아이템이 선택되었는지

        local registering_panel = SetupComponent(self.sellTab_panel, Panel(Rect(400, 20, 220, 240)), Colors.NONE, Aligns.TOP_LEFT)
        self.item_img = SetupComponent(registering_panel, Image("", Rect(0 , 0, 60, 60)), nil, Aligns.TOP_CENTER, 0.5, 0)
        local item_selecting_btn = SetupComponent(registering_panel, Button("아이템 선택", Rect(0, 70, 100, 20)), Colors.LIGHT_GRAY, Aligns.TOP_CENTER, 0.5, 0)
        item_selecting_btn.onClick.Add(function()
            Client.FireEvent("S_Auction:Request_SelectItem")
        end)

        local price_txt = SetupComponent(registering_panel, Text("가격", Rect(-50, 100, 30, 30)), nil, Aligns.TOP_CENTER, 0.5, 0)
        local price_inputField = SetupComponent(registering_panel, InputField(Rect(20, 100, 100, 30)), nil, Aligns.TOP_CENTER, 0.5, 0)

        local amount_txt = SetupComponent(registering_panel, Text("개수", Rect(-50, 140, 30, 30)), nil, Aligns.TOP_CENTER, 0.5, 0)
        local amount_inputField = SetupComponent(registering_panel, InputField(Rect(20, 140, 100, 30)), nil, Aligns.TOP_CENTER, 0.5, 0)

        local moneyMode = "gold"
        local gold_radioBtn = SetupComponent(registering_panel, Button("골드", Rect(-20, 180, 50, 30)), Colors.DARK_GRAY, Aligns.TOP_CENTER, 0.5, 0)
        local ruby_radioBtn = SetupComponent(registering_panel, Button("루비", Rect(35, 180, 50, 30)), Colors.LIGHT_GRAY, Aligns.TOP_CENTER, 0.5, 0)

        gold_radioBtn.onClick.Add(function()
            moneyMode = "gold"
            gold_radioBtn.color = Colors.DARK_GRAY
            ruby_radioBtn.color = Colors.LIGHT_GRAY
        end)
        ruby_radioBtn.onClick.Add(function()
            moneyMode = "ruby"
            ruby_radioBtn.color = Colors.DARK_GRAY
            gold_radioBtn.color = Colors.LIGHT_GRAY
        end)

        local registering_btn = SetupComponent(registering_panel, Button("등록하기", Rect(0, 220, 80, 40)), Colors.LIGHT_GRAY, Aligns.TOP_CENTER, 0.5, 0)
        registering_btn.onClick.Add(function()
            local table = {
                isSelected = self.isSelected,
                price = tonumber(price_inputField.text),
                amount = tonumber(amount_inputField.text),
                moneyMode = moneyMode,
            }

            -- 올바른 등록인지 확인하러 서버 갔다오기.
            Client.FireEvent("S_Auction:CheckRegister", Utility.JSONSerialize(table))
        end)
    end

    function Auction:ClearTabPanel()
        if self.buyTab_panel ~= nil then
            self.buyTab_panel.Destroy() end
        if self.sellTab_panel ~= nil then
            self.sellTab_panel.Destroy() end
    end

    -- 아이템 선택 버튼을 누르면 서버를 거쳐 여기로 옵니다.
    function Auction:SelectItem(itemID)
        self.item_img.SetImageID(Client.GetItem(itemID).imageID)
        self.isSelected = true
    end
    Client.GetTopic("Auction:SelectItem").Add(function(param) Auction:SelectItem(param) end)

    function Auction:UnselectItem() -- 선택한 템에 문제가 있을 경우 아이템 선택을 해제시킵니다.
        self.item_img.SetImage(nil)
        self.isSelected = false
    end
    Client.GetTopic("Auction:UnselectItem").Add(function() Auction:UnselectItem() end)

    function Auction:RefreshSellTab() -- 아이템 등록 완료 후 판매탭 새로고침 시킵니다.
        Auction:Goto_SellTab()
    end
    Client.GetTopic("Auction:RefreshSellTab").Add(function() Auction:RefreshSellTab() end)

    -- 유저가 지금까지 등록한 아이템을 판매탭 패널에 띄워줍니다.
    function Auction:LoadSellTabItems(itemDB_list_serialized)

        local itemDB_list = Utility.JSONParse(itemDB_list_serialized)
        local currentPanelIndex = 1

        for _, itemDB in ipairs(itemDB_list) do
            local currentPanel = self.itemPanels[currentPanelIndex]

            FillItemPanel(currentPanel, itemDB)

            local btn = SetupComponent(currentPanel, Button("회수", Rect(-5, 0, 35, 35)), Colors.GRAY, Aligns.MIDDLE_RIGHT, 1.0, 0.5)
            btn.onClick.Add(function()
                Client.FireEvent("S_Auction:WithdrawItem", itemDB.varNum)
            end)

            currentPanelIndex = currentPanelIndex + 1
        end
    end
    Client.GetTopic("Auction:LoadSellTabItems").Add(function(param) Auction:LoadSellTabItems(param) end)

    function Auction:LoadAuctionItems(itemDB_list_serialized) -- 서버에서 경매장 템들을 불러옵니다.
        local itemDB_list = Utility.JSONParse(itemDB_list_serialized)
        self.itemDB_list = itemDB_list
    end
    Client.GetTopic("Auction:LoadAuctionItems").Add(function(param) Auction:LoadAuctionItems(param) end)

    -- 페이지 번호를 받아 구매탭에 템들을 띄웁니다.
    function Auction:LoadBuyTabItems(page)

        if not self.itemDB_list then
            return
        end

        local currentPanelIndex = 1

        local aPage_itemDB_list = Slice(self.itemDB_list, page*5-4, page*5)

        for _, itemDB in ipairs(aPage_itemDB_list) do
            local currentPanel = self.itemPanels[currentPanelIndex]

            FillItemPanel(currentPanel, itemDB)

            local info_btn = SetupComponent(currentPanel, Button("", Rect(0, 0, 300, 40)), Colors.NONE, Aligns.MIDDLE_LEFT, 0, 0.5)
            info_btn.onClick.Add(function()
                local client_item = Client.GetItem(itemDB.id)
                self.info_txt.text = " " .. client_item.name .. "<color=Green> (+" .. itemDB.level .. ")</color>\n" ..
                                    client_item.desc .. "\n\n" ..
                                    "<color=#FF00FF>옵션</color>" .. "\n" ..
                                    "<color=#00FFFF>"
                for _, option in ipairs(itemDB.options) do
                    if OPTION_TYPES[option.type] and STAT_NAMES[option.statID] then
                        self.info_txt.text = self.info_txt.text .. OPTION_TYPES[option.type] .. " " .. STAT_NAMES[option.statID] .. " +" .. option.value .. "\n"
                    else
                        self.info_txt.text = self.info_txt.text .. "option error" .. "\n"
                    end
                end
                self.info_txt.text = self.info_txt.text .. "</color>"
            end)

            local buy_btn = SetupComponent(currentPanel, Button("구매", Rect(-5, 0, 35, 35)), Colors.GRAY, Aligns.MIDDLE_RIGHT, 1.0, 0.5)
            buy_btn.onClick.Add(function()
                Client.FireEvent("S_Auction:CheckBuy", Utility.JSONSerialize(itemDB))
            end)

            currentPanelIndex = currentPanelIndex + 1
        end
    end

    function Auction:Close()
        self.screen.Destroy()
    end
    Client.GetTopic("Auction:Close").Add(function(param) Auction:Close(param) end)
















----------- Utilities -------------

-- 한 패널 안에 count개의 새로운 패널들을 생성하여 반환한다.
-- 아이템 목록을 표시할 때 사용한다.
function SetupSeparatingPanels(rootPanel, count)

    local panels = {}
    for i = 1, count do
        local w, h = rootPanel.width, rootPanel.height/count
        local c = (i % 2 == 0) and Colors.DARK_GRAY or Colors.DEEPDARK_GRAY
        local panel = SetupComponent(rootPanel, Panel(Rect(0, h * (i-1), w, h)), c, Aligns.TOP_LEFT)
        table.insert(panels, panel)
    end

    return panels
end

function SetupComponent(root, compObj, color, anchor, pivotX, pivotY)
    if color ~= nil then
        compObj.color = color
    end
    if anchor ~= nil then
        compObj.anchor = anchor
    end
    compObj.pivotX = pivotX or 0
    compObj.pivotY = pivotY or 0

    root.AddChild(compObj)

    return compObj
end

-- 아이템 패널에 아이템 정보가 나타나게 합니다.
function FillItemPanel(itemPanel, itemDB)
    local item_img = SetupComponent(itemPanel, Image("", Rect(0 , 0, 40, 40)), nil, Aligns.MIDDLE_LEFT, 0, 0.5)
    item_img.SetImageID(Client.GetItem(itemDB.id).imageID)

    if itemDB.level > 0 then
        local item_level_txt = SetupComponent(item_img, Text("<Color=#4FF53A>+" .. itemDB.level .. "</color>", Rect(0, 0, 20, 20)), nil, Aligns.TOP_LEFT, 0, 0)
        item_level_txt.borderEnabled = true
        item_level_txt.fontStyle = 1 -- Bold
    end

    local priceStr
    if itemDB.moneyMode == "gold" then
        priceStr = "<Color=Yellow>" .. itemDB.price .. " 골드" .. "</color>"
    else
        priceStr = "<Color=#e061f9>" .. itemDB.price .. " 루비" .. "</color>"
    end

    local txt = SetupComponent(itemPanel, Text("", Rect(0, 0, 200, 40)), nil, Aligns.MIDDLE_CENTER, 0.5, 0.5)
    txt.text = Client.GetItem(itemDB.id).name .. " " .. itemDB.count .. "개" .. "\n" .. priceStr
end

function Slice(targetTable, startIdx, endIdx) -- 리스트형 테이블을 받아 원하는 만큼 잘라서 반환합니다.
    local resultTable = {}
    for i = startIdx, endIdx do
        if targetTable[i] then
            table.insert(resultTable, targetTable[i])
        end
    end

    return resultTable
end







----------- Consts -------------

Colors = {
    NONE = Color(0, 0, 0, 0),
    BLACK = Color(0, 0, 0, 255),
    DEEPDARK_GRAY = Color(20, 20, 20, 255),
    DARK_GRAY = Color(40, 40, 40, 255),
    GRAY = Color(60, 60, 60, 255),
    LIGHT_GRAY = Color(120, 120, 120, 255),
    GREEN = Color(0, 255, 0, 255),
}

Aligns = {
    TOP_LEFT = 0,
    TOP_CENTER = 1,
    TOP_RIGHT = 2,
    MIDDLE_LEFT = 3,
    MIDDLE_CENTER = 4,
    MIDDLE_RIGHT = 5,
    BOTTOM_LEFT = 6,
    BOTTOM_CENTER = 7,
    BOTTOM_RIGHT = 8,
}