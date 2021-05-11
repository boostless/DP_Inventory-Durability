RegisterServerEvent('DP_Inventory:addDurability')
AddEventHandler('DP_Inventory:addDurability', function(player, item)
    local xPlayer = ESX.GetPlayerFromId(player)
    if string.find(item, 'WEAPON_') then
        MySQL.Async.execute('INSERT INTO inventory_durability (owner,item) VALUES (@owner, @item)', {
            ['@owner'] = xPlayer.identifier,
            ['@item'] = item
        })
    end
end)

RegisterServerEvent('DP_Inventory:removeDurability')
AddEventHandler('DP_Inventory:removeDurability', function(item, remove_a)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local durability = getDurability(item, xPlayer)
    if durability ~= 0 then
        local remove = durability - remove_a
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
    local data =MySQL.Sync.fetchAll('SELECT * FROM inventory_durability WHERE owner = @owner AND item = @item', {
        ['@owner'] =  xPlayer.identifier,
        ['@item'] = item
    })
    return data[1].durability
end

AddEventHandler('esx:onAddInventoryItem', function(player, item, count)
    TriggerEvent('DP_Inventory:addDurability', player, item)
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