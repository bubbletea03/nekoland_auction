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
    end

    function Auction:Goto_BuyTab()
        Auction:ClearTabPanel()
        self.buyTab_panel = SetupComponent(self.panel, Panel(Rect(10, 50, 620, 300)), Colors.GREEN, Aligns.TOP_LEFT)
        self.buyTab_panel.SetOpacity(0)

        local itemlist_panel = SetupComponent(self.buyTab_panel, Panel(Rect(0, 20, 620, 240)), Colors.LIGHT_GRAY, Aligns.TOP_CENTER, 0.5, 0)

        local arrowLeft_btn = SetupComponent(self.buyTab_panel, Button("<", Rect(-25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)
        local arrowRight_btn = SetupComponent(self.buyTab_panel, Button(">", Rect(25, -15, 40, 40)), Colors.LIGHT_GRAY, Aligns.BOTTOM_CENTER, 0.5, 0.5)

        local pageText = SetupComponent(self.buyTab_panel, Text(self.page .. "/" .. "2", Rect(80, -15, 40, 40)), Colors.NONE, Aligns.BOTTOM_CENTER, 0.5, 0.5)
    end

    function Auction:Goto_SellTab()
        Auction:ClearTabPanel()
        self.sellTab_panel = SetupComponent(self.panel, Panel(Rect(10, 70, 620, 280)), Colors.BLACK, Aligns.TOP_LEFT)


    end

    function Auction:ClearTabPanel()
        if self.buyTab_panel ~= nil then
            self.buyTab_panel.Destroy() end
        if self.sellTab_panel ~= nil then
            self.sellTab_panel.Destroy() end
    end

    function Auction:Get_ItemData() -- 경매장에 존재하는 아이템들 테이블로 반환

    end


-- Utilities
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





-- Consts
Colors = {
    NONE = nil,
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