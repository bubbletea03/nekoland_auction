--------------------------------------------------------
-- Made by 기윤e

-- 깃허브 주소: https://github.com/bubbletea03

-- References 한량, 사랑요
-- 질문 받아주신 사랑요, B M, Windmill님 감사합니다.
--------------------------------------------------------



--------------------------------------------------------
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- [!] 테스트 버전입니다. 실제 게임에 사용하지 마시기 바랍니다.
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--------------------------------------------------------




------------------------------------------------------------------
-- 번호 입력 시 다른 스크립트와 겹치지 않도록 주의해 주세요.

ITEM_REGISTER_EVENT_VAR = 2 -- 경매장 아이템 등록하는 공용 이벤트의 번호를 입력해 주세요.
ASK_REGISTER_EVENT_VAR = 3 -- 판매 등록 확인을 물어보는 공용 이벤트의 번호를 입력해 주세요.
ASK_BUY_EVENT_VAR = 4 -- 구매 확인을 물어보는 공용 이벤트의 번호를 입력해 주세요.

TEMP_STRING_VAR = 100 -- 임시 저장용으로 쓰입니다. 개인 스트링 변수의 번호를 입력해주세요.
ITEM_STORAGE_STRING_VARS = {101,102,103,104,105} -- 아이템을 저장할 개인 스트링 변수의 번호를 입력해 주세요.

SELECTED_ITEM_VAR = 0 -- 공용 이벤트에서의 선택 아이템 변수의 번호를 입력해 주세요.

RUBY_ITEM_VAR = 90 -- 루비의 아이템 코드 번호를 입력해 주세요.
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

    local itemDB = ConvertItemToDict(item)
    itemDB.count = amount
    itemDB.price = price
    itemDB.moneyMode = moneyMode
    itemDB.playerName = unit.name

    unit.SetStringVar(TEMP_STRING_VAR, Utility.JSONSerialize(itemDB)) -- 등록할 아이템을 임시 저장합니다.
    unit.StartGlobalEvent(ASK_REGISTER_EVENT_VAR) -- 정말 등록할 것인지 물어봅니다.
end
Server.GetTopic("S_Auction:CheckRegister").Add(function(param) S_Auction:CheckRegister(param) end)

function S_Auction:RegisterItem()

    local varNum = GetEmptyRegisterSpaceVarNumber()
    local itemDB = Utility.JSONParse(unit.GetStringVar(TEMP_STRING_VAR))
    itemDB.varNum = varNum -- item의 DB에 변수 번호도 기록해둡니다.

    unit.RemoveItemByID(unit.GetVar(SELECTED_ITEM_VAR), itemDB.count) -- 아이템 뺏기 
    -- [?] ID기준으로 지우면, ID같은 것들은 어캐됨?
    -- A: 네코랜드 아이템에는 dataID와 고유ID가 있다. (선택 아이템 변수에는 고유ID가 들어간다.)

    unit.SetStringVar(varNum, Utility.JSONSerialize(itemDB)) -- 아이템 최종 등록
    unit.FireEvent("Auction:RefreshSellTab")
end

-- 등록된 아이템들의 정보를 클라이언트로 보냅니다.
function S_Auction:SendSellTabItems()

    local itemDB_list = GetItemDBListOfPlayer()

    unit.FireEvent("Auction:LoadSellTabItems", Utility.JSONSerialize(itemDB_list))
end
Server.GetTopic("S_Auction:SendSellTabItems").Add(function(param) S_Auction:SendSellTabItems(param) end)

-- 저장된 변수 번호를 받아 유저에게 회수 시켜줍니다.
function S_Auction:WithdrawItem(itemVarNum)
    local itemDB = Utility.JSONParse(unit.GetStringVar(itemVarNum))
    unit.SetStringVar(itemVarNum, nil)

    local item = GetItemByDB(itemDB)
    unit.AddItemByTItem(item, true)

    unit.FireEvent("Auction:RefreshSellTab")
end
Server.GetTopic("S_Auction:WithdrawItem").Add(function(param) S_Auction:WithdrawItem(param) end)

-- 경매장 내 등록된 모든 아이템을 탐색하여 클라이언트로 보냅니다.
function S_Auction:SendBuyTabItems()
    local itemDB_list = {}
    for _, player in ipairs(Server.players) do
        local aPlayer_itemDB_list = GetItemDBListOfPlayer(player)
        Concat(itemDB_list, aPlayer_itemDB_list)
    end

    unit.FireEvent("Auction:LoadBuyTabItems", Utility.JSONSerialize(itemDB_list))
end
Server.GetTopic("S_Auction:SendBuyTabItems").Add(function(param) S_Auction:SendBuyTabItems(param) end)

function S_Auction:CheckBuy(itemDB_serialized) -- 정말 구매할 것인지 물어보고 진행시킵니다.
    local itemDB = Utility.JSONParse(itemDB_serialized)

    if itemDB.moneyMode == "gold" and itemDB.price > unit.gameMoney then
        unit.SendCenterLabel("금액이 부족합니다.")
        return
    end
    
    if itemDB.moneyMode == "ruby" and itemDB.price > unit.CountItem(RUBY_ITEM_VAR) then
        unit.SendCenterLabel("금액이 부족합니다.")
        return
    end

    unit.SetStringVar(TEMP_STRING_VAR, itemDB_serialized) -- 구매할 아이템을 임시 저장합니다.
    unit.StartGlobalEvent(ASK_BUY_EVENT_VAR)
end
Server.GetTopic("S_Auction:CheckBuy").Add(function(param) S_Auction:CheckBuy(param) end)

function S_Auction:BuyItem()
    local itemDB = Utility.JSONParse(unit.GetStringVar(TEMP_STRING_VAR))

    local target_player = FindPlayerByName(itemDB.playerName) -- 판매자

    -- ※ 예외처리. 이미 팔렸을 경우
    local var = target_player.unit.GetStringVar(itemDB.varNum)
    if not var or var == "" then
        unit.SendCenterLabel("<color=Red>존재하지 않는 아이템입니다.</color>")
        return
    end

    if itemDB.moneyMode == "gold" then
        unit.AddGameMoney( -itemDB.price )
        target_player.unit.AddGameMoney( itemDB.price )
    else
        unit.RemoveItem(RUBY_ITEM_VAR, itemDB.price, false)
        target_player.unit.AddItem(RUBY_ITEM_VAR, itemDB.price, false)
    end 
    target_player.unit.SendCenterLabel("등록한 아이템이 판매되었습니다.")

    target_player.unit.SetStringVar(itemDB.varNum, nil) -- 구매했으므로 판매자의 등록된 아이템을 삭제시킵니다.

    local item = GetItemByDB(itemDB)
    unit.AddItemByTItem(item, true)

    unit.FireEvent("Auction:RefreshBuyTab")
end











---------- Utilities -------------

-- unit 기준으로 얻은 item을 parameter로 받아 dict 형식의 정돈된 테이블로 반환한다.
function ConvertItemToDict(item)
    local item_dict = {
        id = item.dataID,
        level = item.level,
        count = nil, -- nil 정보들은 아이템을 실제로 등록할 때 새로 초기화됩니다.
        price = nil,
        moneyMode = nil,
        playerName = nil,
        options = {}
    }
    for _, option in ipairs(item.options) do
        local option_dict = {type=option.type, statID=option.statID, value=option.value}
        table.insert(item_dict.options, option_dict)
    end

    return item_dict
end

function GetEmptyRegisterSpaceVarNumber() -- 등록할 공간이 있는지 확인하고 있다면 번호를 반환합니다.
    for _, var_number in ipairs(ITEM_STORAGE_STRING_VARS) do
        local var = unit.GetStringVar(var_number)
        if not var or var == "" then -- 빈 공간이 하나라도 있을 경우 번호 반환하고 종료
            return var_number
        end

        local item = Utility.JSONParse(var)
        if not item.id then -- 아이템 형식이 아닐 경우 쓰레기값(=빈공간) 이므로 이 경우에도 반환
            return var_number
        end
    end

    return nil
end

-- 플레이어가 등록한 아이템 정보들을 ItemDB_list로 반환합니다.
-- param을 보내지 않을 경우 unit 자기 자신을 기준으로 합니다.
function GetItemDBListOfPlayer(player)
    local itemDB_list = {}

    for _, var_number in ipairs(ITEM_STORAGE_STRING_VARS) do
        local var
        if player then
            var = player.unit.GetStringVar(var_number)
        else
            var = unit.GetStringVar(var_number)
        end

        if var ~= nil and var ~= "" then
            local itemDB = Utility.JSONParse(var)
            if itemDB.id then -- id에 접근하여 item 형식의 정보인지 체크합니다. (쓰레기값 들어가있는 경우 방지)
                table.insert(itemDB_list, itemDB)
            end
        end
    end

    return itemDB_list
end

function Concat(root_table, other_table) -- 기준 테이블에 다른 테이블을 연결시킵니다. (리스트형 테이블) [반환값 없음]
    for _, v in ipairs(other_table) do
        table.insert(root_table, v)
    end
end

function GetItemByDB(itemDB) -- dict형 item 테이블을 받아 아이템을 반환합니다.
    local item = Server.CreateItem(itemDB.id, itemDB.count)
    item.level = itemDB.level
    for _, option in ipairs(itemDB.options) do
        Utility.AddItemOption(item, option.type, option.statID, option.value)
    end

    return item
end

function FindPlayerByName(name)
    for _, player in ipairs(Server.players) do
        if player.name == name then
            return player
        end
    end
end