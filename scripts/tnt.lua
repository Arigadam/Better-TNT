function on_interact(x, y, z, playerid)
    debug.print(0)
    local itemID, _ = inventory.get(player.get_inventory(playerid))
    debug.print(itemID)
    debug.print(item.index("tnt:tnt_starter"))
    if itemID == item.index("tnt:tnt_starter") then
        debug.print(1)
        item.uses(itemID)
        debug.print(2)
        audio.play_sound("ignite", x+0.5, y+0.5, z+0.5, 1, 1)
        debug.print(3)
        --if block.is_replaceable_at(x, y-1, z) then
            entities.spawn("tnt:active_tnt", {x+0.5, y+0.5, z+0.5}, 
                {tnt__active_tnt={block='tnt:tnt'}})
            debug.print(4)
            block.set(x, y, z, 0)
            debug.print(5)
        --end
        return true
    end
end