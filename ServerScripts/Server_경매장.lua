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

    local itemDB = ConvertItemToItemDB(item)

    if Server.GetItem(item.dataID).canTrade then
        unit.FireEvent("Auction:SelectItem", SerializeItemDB(itemDB))
    else
        unit.SendCenterLabel("<Color=Red>거래 불가 아이템입니다.</color>")
    end
end













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

-- JSON 형태의 itemDB를 받아 dict 형식의 정돈된 테이블로 반환합니다.
function ParseSerializedItemDB(serializedItemDB)
    local parsedItemDB = Utility.JSONParse(serializedItemDB)
    local itemDB = {
        id = parsedItemDB[1],
        level = parsedItemDB[2],
        count = parsedItemDB[3],
        price = parsedItemDB[4],
        options = {}
    }

    for i = 5, #parsedItemDB, 3 do -- 인덱스 [5] 부턴 option들 나란히 있음. 3개씩 뭉쳐서 삽입하기
        local option = {
            type = parsedItemDB[i],
            statID = parsedItemDB[i+1],
            value = parsedItemDB[i+2]
        }
        table.insert(itemDB.options, option)
    end

    return itemDB
end