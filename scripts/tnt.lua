function on_interact(x, y, z, playerid)
    audio.play_sound("ignite", x+0.5, y+0.5, z+0.5, 1, 1)
    --if block.is_replaceable_at(x, y-1, z) then
        entities.spawn("tnt:active_tnt", {x+0.5, y+0.5, z+0.5}, 
            {tnt__active_tnt={block='tnt:tnt'}})
        block.set(x, y, z, 0)
    --end
end