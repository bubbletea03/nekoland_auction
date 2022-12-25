-- Starting
function Open_Auction()
    Auction:Init()
end


-- Auction UI
Auction = { page = 1 }
    function Auction:Init()

        local screen = Panel(Rect(0,0,Client.width,Client.height)) -- 최상위 UI 요소입니다.
        screen.showOnTop = true
        screen.color = Colors.BLACK
        screen.SetOpacity(100)

        self.panel = SetupComponent(screen, Panel(Rect(0, 0, 640, 360)), Colors.GRAY, Aligns.MIDDLE_CENTER, 0.5, 0.5)

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
            screen.Destroy()
        end)
    end

    function Auction:Goto_BuyTab()
        Auction:ClearTabPanel()
        self.buyTab_panel = SetupComponent(self.panel, Panel(Rect(10, 50, 620, 300)), Colors.NONE, Aligns.TOP_LEFT)

        local itemlist_panel = SetupComponent(self.buyTab_panel, Panel(Rect(0, 20, 620, 240)), Colors.NONE, Aligns.TOP_CENTER, 0.5, 0)
        local itemPanels = SetupSeparatingPanels(itemlist_panel, 5); -- '아이템 목록 패널' 안에 5개의 '아이템 패널'을 만든다.

        local arrowLeft_btn = SetupComponent(self.buyTab_panel, Button("<", Rect(-25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)
        local arrowRight_btn = SetupComponent(self.buyTab_panel, Button(">", Rect(25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)

        local pageText = SetupComponent(self.buyTab_panel, Text(self.page .. "/" .. "2", Rect(80, -15, 40, 40)), nil, Aligns.BOTTOM_CENTER, 0.5, 0.5)

    end

    function Auction:Goto_SellTab()
        Auction:ClearTabPanel()
        self.sellTab_panel = SetupComponent(self.panel, Panel(Rect(10, 50, 620, 300)), Colors.NONE, Aligns.TOP_LEFT)

        local registered_itemlist_panel = SetupComponent(self.sellTab_panel, Panel(Rect(0, 20, 400, 240)), Colors.NONE, Aligns.TOP_LEFT)
        local itemPanels = SetupSeparatingPanels(registered_itemlist_panel, 5);

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
    end

    function Auction:ClearTabPanel()
        if self.buyTab_panel ~= nil then
            self.buyTab_panel.Destroy() end
        if self.sellTab_panel ~= nil then
            self.sellTab_panel.Destroy() end
        self.selected_itemID = nil
    end

    function Auction:SelectItem(serialized_itemDB)
        local itemDB = Utility.JSONParse(serialized_itemDB)
        self.selected_itemDB = itemDB
        local id = itemDB[1]
        self.item_img.SetImageID(Client.GetItem(id).imageID)
    end
    Client.GetTopic("Auction:SelectItem").Add(function(param) Auction:SelectItem(param) end)

















----------- Utilities -------------

-- 한 패널 안에 count개의 새로운 패널들을 생성한다. [새로운 패널들을 테이블로 반환]
-- 아이템 목록을 표시할 때 사용한다.
function SetupSeparatingPanels(rootPanel, count)
    
    local panels_table = {}
    for i = 1, count do
        local w, h = rootPanel.width, rootPanel.height/count
        local c = (i % 2 == 0) and Colors.LIGHT_GRAY or Colors.DARK_GRAY
        local panel = SetupComponent(rootPanel, Panel(Rect(0, h * (i-1), w, h)), c, Aligns.TOP_LEFT)
        table.insert(panels_table, panel)
    end

    return panels_table
end

function SetupComponent(root, compObj, color, anchor, pivotX, pivotY)
    if color ~= nil then
        compObj.color = color
    end
    compObj.anchor = anchor
    compObj.pivotX = pivotX or 0
    compObj.pivotY = pivotY or 0

    root.AddChild(compObj)

    return compObj
end







----------- Consts -------------

Colors = {
    NONE = Color(0, 0, 0, 0),
    BLACK = Color(0, 0, 0, 255),
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