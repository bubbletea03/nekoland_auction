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

        self.panel = Panel(Rect(0, 0, 640, 360))
        self.panel.color = Colors.GRAY
        self.panel.anchor = Aligns.MIDDLE_CENTER
        self.panel.pivotX = 0.5
        self.panel.pivotY = 0.5
        screen.AddChild(self.panel)

        local btn_buyTab = Button("구매", Rect(5, 5, 90, 40));
        btn_buyTab.color = Colors.LIGHT_GRAY
        btn_buyTab.anchor = Aligns.TOP_LEFT
        btn_buyTab.onClick.Add(function()
            Auction:Goto_BuyTab()
        end)

        local btn_sellTab = Button("판매", Rect(100, 5, 90, 40))
        btn_sellTab.color = Colors.LIGHT_GRAY
        btn_sellTab.anchor = Aligns.TOP_LEFT
        btn_sellTab.onClick.Add(function()
            Auction:Goto_SellTab()
        end)

        self.panel.AddChild(btn_buyTab)
        self.panel.AddChild(btn_sellTab)
    end

    function Auction:Goto_BuyTab()
        Auction:Clear_TabPanel()
        self.buyTab_panel = Panel(Rect(10, 50, 620, 300)) -- 구매 탭의 최상위 패널
        self.buyTab_panel.color = Colors.GREEN
        self.buyTab_panel.anchor = Aligns.TOP_LEFT
        self.buyTab_panel.SetOpacity(0)

        self.panel.AddChild(self.buyTab_panel)

        local itemlist_panel = Panel(Rect(0, 20, 620, 240))
        itemlist_panel.color = Colors.LIGHT_GRAY
        itemlist_panel.anchor = Aligns.TOP_CENTER
        itemlist_panel.pivotX = 0.5

        local arrowLeft_btn = Button("<", Rect(-25, -15, 40, 40))
        arrowLeft_btn.color = Colors.LIGHT_GRAY
        arrowLeft_btn.anchor = Aligns.BOTTOM_CENTER
        arrowLeft_btn.pivotX = 0.5
        arrowLeft_btn.pivotY = 0.5

        local arrowRight_btn = Button(">", Rect(25, -15, 40, 40))
        arrowRight_btn.color = Colors.LIGHT_GRAY
        arrowRight_btn.anchor = Aligns.BOTTOM_CENTER
        arrowRight_btn.pivotX = 0.5
        arrowRight_btn.pivotY = 0.5

        local pageText = Text(self.page .. "/" .. "2", Rect(80, -15, 40, 40))
        pageText.anchor = Aligns.BOTTOM_CENTER
        pageText.pivotX = 0.5
        pageText.pivotY = 0.5

        self.buyTab_panel.AddChild(itemlist_panel)
        self.buyTab_panel.AddChild(arrowLeft_btn)
        self.buyTab_panel.AddChild(arrowRight_btn)
        self.buyTab_panel.AddChild(pageText)
    end

    function Auction:Goto_SellTab()
        Auction:Clear_TabPanel()
        self.sellTab_panel = Panel(Rect(10, 70, 620, 280))
        self.sellTab_panel.color = Colors.BLACK
        self.sellTab_panel.anchor = Aligns.TOP_LEFT

        self.panel.AddChild(self.sellTab_panel)
    end

    function Auction:Clear_TabPanel()
        if self.buyTab_panel ~= nil then
            self.buyTab_panel.Destroy() end
        if self.sellTab_panel ~= nil then
            self.sellTab_panel.Destroy() end
    end











-- Consts
Colors = {
    BLACK = Color(0, 0, 0),
    GRAY = Color(60, 60, 60),
    LIGHT_GRAY = Color(120, 120, 120),
    GREEN = Color(0, 255, 0),
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