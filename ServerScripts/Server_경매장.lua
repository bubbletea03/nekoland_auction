-- 번호 입력 시 다른 스크립트와 겹치지 않도록 주의해 주세요.

ITEM_REGISTER_EVENT_VAR = 2 -- 경매장 아이템 등록하는 공용 이벤트의 번호를 입력해 주세요.

ITEM_STORAGE_STRING_VAR = {101,102,103,104,105} -- 아이템을 저장할 개인 스트링 변수의 번호를 입력해 주세요.

SELECTED_ITEM_VAR = 0 -- 공용 이벤트에서의 선택 아이템 변수의 번호를 입력해 주세요.



-------------------------------------------------------------------

-- Auction Server
S_Auction = {}

function S_Auction:Request_SelectItem()
    unit.StartGlobalEvent(ITEM_REGISTER_EVENT_VAR)
    -- 공용 이벤트 내용: S_Auction:Response_SelectItem()
end
Server.GetTopic("S_Auction:Request_SelectItem").Add(function() S_Auction:Request_SelectItem() end)

function S_Auction:Response_SelectItem()
    local item = unit.player.GetItem(unit.GetVar(SELECTED_ITEM_VAR))

    if Server.GetItem(item.dataID).canTrade then
        unit.FireEvent("Auction:SelectItem", item.dataID)
    else
        unit.FireEvent("Auction:UnselectItem")
        unit.SendCenterLabel("<Color=Red>거래 불가 아이템입니다.</color>")
    end
end

function S_Auction:CheckRegister(serialized_table) -- 가격, 개수 등을 체크하여 올바를 경우 아이템 등록으로 갑니다.

    local table = Utility.JSONParse(serialized_table)
    local isSelected = table.isSelected
    local price = table.price
    local amount = table.amount
    local moneyMode = table.moneyMode

    local item = unit.player.GetItem(unit.GetVar(SELECTED_ITEM_VAR))

    if not isSelected then
        unit.SendCenterLabel("아이템을 선택해 주세요.")
        return
    end

    if not price or not amount then
        unit.SendCenterLabel("가격과 개수를 입력해 주세요.")
    end

    if amount > item.count then
        unit.SendCenterLabel("개수를 잘못 입력하셨습니다.")
        return
    end

    MAX_PRICE = 200000000 -- 2억
    if not (price > 0) or price > MAX_PRICE then
        unit.SendCenterLabel("가격을 잘못 입력하셨습니다.")
        return
    end
end
Server.GetTopic("S_Auction:CheckRegister").Add(function(param) S_Auction:CheckRegister(param) end)

function S_Auction:SendCenterLabel(str)
    unit.SendCenterLabel(str)
end
Server.GetTopic("S_Auction:SendCenterLabel").Add(function(param) S_Auction(param) end)













---------- Utilities -------------

-- unit 기준으로 얻은 item을 parameter로 받아 dict 형식의 정돈된 테이블로 반환한다.
function ConvertItemToItemDB(item)
    local itemDB = {
        id = item.dataID,
        level = item.level,
        count = item.count,
        price = nil, -- price와 count는 아이템을 실제로 등록할 때 새로 초기화됩니다.
        options = {}
    }
    for i, option in ipairs(item.options) do
        table.insert(itemDB.options, option)
    end

    return itemDB
end

-- 변수에 저장하거나 넘기기 용이하도록 dict형식 테이블을 list형식으로 바꾼 후, JSON으로 반환합니다.
function SerializeItemDB(itemDB)
    local itemDB_listForm = {itemDB.id, itemDB.level, itemDB.count, itemDB.price}
    for i, option in ipairs(itemDB.options) do
        table.insert(itemDB_listForm, option.type)
        table.insert(itemDB_listForm, option.statID)
        table.insert(itemDB_listForm, option.value)
    end

    local serializedItemDB = Utility.JSONSerialize(itemDB_listForm)

    return serializedItemDB
end