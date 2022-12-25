ITEM_REGISTER_EVENT_VAR = 2 -- 경매장 아이템 등록하는 공용 이벤트의 번호를 입력해 주세요.

ITEM_STORAGE_STRING_VAR = {101,102,103,104,105} -- 아이템을 저장할 개인 스트링 변수의 번호를 입력해 주세요.



-------------------------------------------------------------------

-- Auction Server
S_Auction = {}

function S_Auction:Request_SelectItem()
    unit.StartGlobalEvent(ITEM_REGISTER_EVENT_VAR)
    -- 공용 이벤트 내용
        -- local SELECTED_ITEM_VAR = 0
        -- local item = unit.player.GetItem(unit.GetVar(SELECTED_ITEM_VAR))
        -- S_Auction:Response_SelectItem(item)
end
Server.GetTopic("S_Auction:Request_SelectItem").Add(function() S_Auction:Request_SelectItem() end)

function S_Auction:Response_SelectItem(item)

    local itemDB = GetItemDB(item)

    if Server.GetItem(item.dataID).canTrade then
        unit.FireEvent("Auction:SelectItem", Utility.JSONSerialize(itemDB))
    else
        unit.SendCenterLabel("<Color=Red>거래 불가 아이템입니다.</color>")
    end
end













-- Utilities

function GetItemDB(item)
    -- unit 기준으로 얻은 item을 parameter로 받아 정돈된 테이블로 반환한다.
    local itemDB = {item.dataID, item.level}
    for i, option in ipairs(item.options) do
        table.insert(itemDB, option.type)
        table.insert(itemDB, option.statID)
        table.insert(itemDB, option.value)
    end

    return itemDB
end