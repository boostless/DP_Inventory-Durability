local itemsConfig = {
    ['bread'] = {usage = 2},
    ['water'] = {usage = 4},
    ['ammunition_rifle'] = {usage = 4},
    ['ammunition_pistol'] = {usage = 4}
}

local Debug = true


RegisterServerEvent('DP_Inventory:setDurability')
AddEventHandler('DP_Inventory:setDurability', function(player, item)
    local xPlayer = ESX.GetPlayerFromId(player)


    --if string.find(item, 'WEAPON_') then
        MySQL.Async.execute('INSERT INTO inventory_durability (owner,item) VALUES (@owner, @item)', {
            ['@owner'] = xPlayer.identifier,
            ['@item'] = item
        })
    --end
end)

RegisterServerEvent('DP_Inventory:removeDurability')
AddEventHandler('DP_Inventory:removeDurability', function(item, remove_a, src)
    local _source = src

    --if src ~= nil then
        --_source = source
    --else
        --_source = src
    --end

    local xPlayer = ESX.GetPlayerFromId(_source)

    local durability = getDurability(item, xPlayer)
    if durability ~= 0 then
        local remove = durability - remove_a

        if remove < 0 then
            remove = 0
        end

        MySQL.Async.execute('UPDATE inventory_durability SET durability = @remove WHERE owner = @owner AND item = @item', {
            ['@owner'] = xPlayer.identifier,
            ['@item'] = item,
            ['@remove'] = remove
        })
    end
end)

ESX.RegisterServerCallback('DP_Inventory:checkDurability', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local durability = getDurability(item, xPlayer)
    if durability ~= 0 then
        cb(true)
    else
        cb(false)
    end
end)

function getDurability(item, xPlayer)
    local data = MySQL.Sync.fetchAll('SELECT * FROM inventory_durability WHERE owner = @owner AND item = @item', {
        ['@owner'] =  xPlayer.identifier,
        ['@item'] = item
    })
    if #data ~= 0 then
        return data[1].durability
    else
        return nil
    end
end

function removeFromDB(item, xPlayer)
    local data =MySQL.Sync.fetchAll('DELETE FROM inventory_durability WHERE owner = @owner AND item = @item', {
        ['@owner'] =  xPlayer.identifier,
        ['@item'] = item
    })
end

AddEventHandler('esx:onAddInventoryItem', function(player, item, count)
    local xPlayer = ESX.GetPlayerFromId(player)
    if getDurability(item, xPlayer) == nil then
        TriggerEvent('DP_Inventory:setDurability', player, item)
    end
end)

RegisterServerEvent('esx:useItem')
AddEventHandler('esx:useItem', function(item)

    if string.find(item, 'WEAPON_') then return end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local durability = getDurability(item, xPlayer)
    local removed_d = durability - itemsConfig[item].usage

    if Debug then
        print('ITEM: ', item, 'USAGE: ', itemsConfig[item].usage, 'CUR_DURA: ', durability, 'LEFT_DURA: ', removed_d)
    end

    if removed_d > 0 then
        TriggerEvent('DP_Inventory:removeDurability', item, itemsConfig[item].usage, _source)
        xPlayer.addInventoryItem(item, 1)
    elseif removed_d < 0 then
        if xPlayer.getInventoryItem(item).count > 0  then
            removeFromDB(item, xPlayer)
            TriggerEvent('DP_Inventory:setDurability', _source, item)
            if Debug then
                print('ITEM: ', item, 'WAS REMOVED AND READDED BECAUSE ', xPlayer.getInventoryItem(item).count, 'LEFT')
            end
        else
            removeFromDB(item, xPlayer)
            if Debug then
                print('ITEM: ', item, 'REMOVED NONE LEFT')
            end
        end
    end
end)


function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
	  formatting = string.rep("  ", indent) .. k .. ": "
	  if type(v) == "table" then
		print(formatting)
		tprint(v, indent+1)
	  elseif type(v) == 'boolean' then
		print(formatting .. tostring(v))		
	  else
		print(formatting .. v)
	  end
	end
end
