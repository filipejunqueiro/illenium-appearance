if not Framework.Ox() then return end

-- [ Local Variables ] --

local Ox = require '@ox_core.lib.init'
local player = Ox.GetPlayer()

-- [ Local Functions ] --

local function onSetActiveCharacter(character)
    if not character.isNew then InitAppearance() return end
    InitializeCharacter(Framework.GetGender(true))
end

local function getPlayerGroupGradeByGroupType(groupType)
    local playerData = {charId = player.get('charId'), groups = player.getGroups(), groupType = groupType}
    return lib.callback.await('illenium-appearance:server:ox:getGroupGradeByType', false, playerData)
end

-- [ Net Events ] --

RegisterNetEvent('ox:setActiveCharacter', onSetActiveCharacter)

-- [ Lib Client Callbacks ] --

lib.callback.register('illenium-appearance:client:ox:resetBlips', ResetBlips)

-- [ Global Functions ] --

function Framework.GetPlayerGender() return player.get('gender') == 'female' and 'Female' or 'Male' end

function Framework.UpdatePlayerData() end

function Framework.HasTracker() return false end

function Framework.CheckPlayerMeta() return LocalPlayer.state.isDead or IsPedCuffed(cache.ped) end

function Framework.IsPlayerAllowed(charId) return charId == player.charId end

function Framework.GetRankInputValues(groupType) return lib.callback.await('illenium-appearance:server:ox:getGroupGrades', false, groupType) end

function Framework.GetJobGrade() return getPlayerGroupGradeByGroupType('job') end

function Framework.GetGangGrade() return getPlayerGroupGradeByGroupType('gang') end

function Framework.CachePed() end

function Framework.RestorePlayerArmour() end