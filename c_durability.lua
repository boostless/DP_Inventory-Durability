local number = 0
local weapon = nil
local weapons = {
    [-1074790547] = 'WEAPON_ASSAULTRIFLE',
    [453432689] = 'WEAPON_PISTOl'
}

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        Wait(100)
        if IsPedShooting(playerPed) then
            number = number + 1
            weapon = GetSelectedPedWeapon(playerPed)
        end
        if number >= 10 then
            TriggerServerEvent('DP_Inventory:removeDurability', weapons[weapon], 1)
            number = 0
        end
    end
end)