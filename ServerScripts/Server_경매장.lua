-- 번호 입력 시 다른 스크립트와 겹치지 않도록 주의해 주세요.

ITEM_REGISTER_EVENT_VAR = 2 -- 경매장 아이템 등록하는 공용 이벤트의 번호를 입력해 주세요.
ASK_REGISTER_EVENT_VAR = 3 -- 등록 확인 공용 이벤트의 번호를 입력해 주세요.

TEMP_STRING_VAR = 100 -- 임시 저장용으로 쓰입니다. 개인 스트링 변수의 번호를 입력해주세요.
ITEM_STORAGE_STRING_VARS = {101,102,103,104,105} -- 아이템을 저장할 개인 스트링 변수의 번호를 입력해 주세요.

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

    if not GetEmptyRegisterSpaceVarNumber() then
        unit.SendCenterLabel("등록 칸이 가득 찼습니다.")
        return
    end

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

    local item_dict = ConvertItemToDict(item)
    item_dict.count = amount
    item_dict.price = price

    unit.SetStringVar(TEMP_STRING_VAR, Utility.JSONSerialize(item_dict)) -- 등록할 아이템을 임시 저장합니다.
    unit.StartGlobalEvent(ASK_REGISTER_EVENT_VAR) -- 정말 등록할 것인지 물어봅니다.
end
Server.GetTopic("S_Auction:CheckRegister").Add(function(param) S_Auction:CheckRegister(param) end)

function S_Auction:RegisterItem()
    local varNum = GetEmptyRegisterSpaceVarNumber()
    unit.SetStringVar(varNum, unit.GetStringVar(TEMP_STRING_VAR)) -- 임시 저장된 아이템을 리얼로 등록합니다.
end

-- 등록된 아이템들의 정보를 클라이언트로 보냅니다.
function S_Auction:SendRegisteredUserItems()
    
    local items = {}

    for i, var_number in ipairs(ITEM_STORAGE_STRING_VARS) do
        local var = unit.GetStringVar(var_number)

        if var and var ~= "" then
            local item = Utility.JSONParse(var)
            table.insert(items, item)
        end
    end

    unit.FireEvent("Auction:LoadRegisteredUserItems", Utility.JSONSerialize(items))
end
Server.GetTopic("S_Auction:SendRegisteredUserItems").Add(function(param) S_Auction:SendRegisteredUserItems(param) end)











---------- Utilities -------------

-- unit 기준으로 얻은 item을 parameter로 받아 dict 형식의 정돈된 테이블로 반환한다.
function ConvertItemToDict(item)
    local itemDB = {
        id = item.dataID,
        level = item.level,
        count = nil, -- price와 count는 아이템을 실제로 등록할 때 새로 초기화됩니다.
        price = nil,
        options = {}
    }
    for i, option in ipairs(item.options) do
        table.insert(itemDB.options, option)
    end

    return itemDB
end

function GetEmptyRegisterSpaceVarNumber() -- 등록할 공간이 있는지 확인하고 있다면 번호를 반환합니다.
    for i, var_number in ipairs(ITEM_STORAGE_STRING_VARS) do
        local var = unit.GetStringVar(var_number)
        if not var or var == "" then -- 빈 공간이 하나라도 있을 경우 번호 반환하고 종료
            return var_number
        end
    end

    return nil
end