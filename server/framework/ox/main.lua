if not Framework.Ox() then return end

-- [ Local Variables ] --

local Ox = require '@ox_core.lib.init'

-- [ Local Functions ] --

---@param grades table
---@return table
local function formatGroupGrades(grades)
    local tempGrades = {}
    for i = 1, #grades do tempGrades[#tempGrades + 1] = {label = grades[i].label, value = i} end
    if not #tempGrades >= 1 then return {} end
    return tempGrades
end

---@param groupType string
---@return table
local function getGroupGrades(_, groupType)
    local group = Ox.GetGroupsByType(groupType)
    if not type(group) == 'table' then return {} end
    return formatGroupGrades(group.grades)
end

---@class PlayerData
---@field charId number
---@field groups table
---@field groupType string

---@param playerData PlayerData
---@return number
local function getGroupGradeByType(_, playerData)
    for i = 1, #playerData.groups do
        local group = playerData.groups[i]
        if group.type == playerData.groupType then
            local row = MySQL.single.await('SELECT `grade`, `isActive` FROM `character_groups` WHERE `name` = ? AND `charId` = ?', {group.name, playerData.charId})
            if row and row.isActive then return row.grade end
        end
    end
    return 0
end

---@param name string
---@param grade number
---@return table
local function fixGroupTable(name, grade)
    return {name = name, grade = grade}
end

---@param playerId number
---@param groupType string
local function getGroupByType(playerId, groupType)
    local player = Ox.GetPlayer(playerId)
    local groups = player.getGroups()
    for i = 1, #groups do
        local group = groups[i]
        if group.type == groupType then
            local row = MySQL.single.await('SELECT `grade`, `isActive` FROM `character_groups` WHERE `name` = ? AND `charId` = ?', {group.name, player.charId})
            if row and row.isActive then return fixGroupTable(group.name, row.grade) end
        end
    end
end

local function resetBlips(playerId) return lib.callback.await('illenium-appearance:client:ox:resetBlips', playerId) end

local function getPlayerId(playerId) return Ox.GetPlayer(playerId).charId end

-- [ Server Events ] --

AddEventHandler('ox:setActiveGroup', resetBlips)

AddEventHandler('ox:setGroup', resetBlips)

-- [ Lib Server Callbacks ] --

lib.callback.register('illenium-appearance:server:ox:getGroupGrades', getGroupGrades)

lib.callback.register('illenium-appearance:server:ox:getGroupGradeByType', getGroupGradeByType)

-- [ Global Functions ] --

function Framework.GetPlayerID(playerId) return getPlayerId(playerId) end

function Framework.HasMoney(playerId, item, amount) return exports.ox_inventory:GetItemCount(playerId, item) >= amount end

function Framework.RemoveMoney(playerId, type, amount) return exports.ox_inventory:RemoveItem(playerId, type, amount) end

function Framework.GetJob(playerId) return getGroupByType(playerId, 'job') end

function Framework.GetGang(playerId) return getGroupByType(playerId, 'gang') end

function Framework.SaveAppearance(appearance, charId)
    Database.PlayerSkins.UpdateActiveField(charId, 0)
    Database.PlayerSkins.DeleteByModel(charId, appearance.model)
    Database.PlayerSkins.Add(charId, appearance.model, json.encode(appearance), 1)
end

function Framework.GetAppearance(charId, model)
    local result = Database.PlayerSkins.GetByCitizenID(charId, model)
    if result then return json.decode(result) end
end