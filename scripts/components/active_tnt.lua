require "explode_lib:explode"

local counter = 0
local explosion_timer = 0
local should_explode = false
local gfxID = nil

local white = false
local frequency = 5

local strenght = 26
local checkDurability = false
local pushEntity = true
local recursiveBlocks = {}
local spawnParticles = true
local playSound = true
local timetoexplode = 4

recursiveBlocks["tnt:tnt"] = {strenght, checkDurability, pushEntity, "cpy", "explode", spawnParticles, playSound}

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local blockid = ARGS.block
local blockstates = ARGS.states or 0
if SAVED_DATA.block then
    blockid = SAVED_DATA.block
    blockstates = SAVED_DATA.states or 0
else
    SAVED_DATA.block = blockid
    SAVED_DATA.states = blockstates
end

function on_grounded(force)
    local pos = tsf:get_pos()
    local ix = math.floor(pos[1])
    local iy = math.floor(pos[2])
    local iz = math.floor(pos[3])
    if block.is_replaceable_at(ix, iy, iz) then
        should_explode = true  -- отсчет до взрыва
    else
        local picking_item = block.get_picking_item(block.index(blockid))
        local drop = entities.spawn("base:drop", pos, {base__drop={id=picking_item, count=1}})
        drop.rigidbody:set_vel(vec3.spherical_rand(5.0))
        entity:despawn()
    end
end

function on_grounded(force)
    local pos = tsf:get_pos()
    local ix = math.floor(pos[1])
    local iy = math.floor(pos[2])
    local iz = math.floor(pos[3])
    if block.is_replaceable_at(ix, iy, iz) then
        if gfx then
            gfxID = gfx.particles.emit({ix+0.5, iy+1, iz+0.5}, 64, {
                lifetime = 1.0,
                spawn_interval = 0.3,
                explosion = {0, 0, 0},
                acceleration = {0, 0, 0},
                velocity = {0, 0.3, 0},
                random_sub_uv = 0,
                size = {0.2, 0.2, 0.2},
                spawn_shape = "ball",
                spawn_spread = {0.05, 0.05, 0.05},
                lighting = false,
                frames = {
                    "particles:fire_0",
                    "particles:smoke_0",
                    "particles:smoke_1"
                }
            })
            gfx.particles.set_origin(entity:get_uid())
        end
        should_explode = true
    else
        local picking_item = block.get_picking_item(block.index(blockid))
        local drop = entities.spawn("base:drop", pos, {base__drop={id=picking_item, count=1}})
        drop.rigidbody:set_vel(vec3.spherical_rand(5.0))
        entity:despawn()
    end
end

local id = block.index(blockid)
local textures = block.get_textures(id)

function on_update(tps)
    counter = counter + 1
    local ticks_needed = math.floor(tps / frequency)
    local pos = tsf:get_pos()
    local ix = math.floor(pos[1])
    local iy = math.floor(pos[2])
    local iz = math.floor(pos[3])

    if counter >= ticks_needed then
        counter = 0
        if white then
            for i, t in ipairs(textures) do
                rig:set_texture("$"..tostring(i-1), "blocks:"..textures[i])
            end
            white = false
        else
            for i, t in ipairs(textures) do
                rig:set_texture("$"..tostring(i-1), "blocks:white")
            end
            white = true
        end
    end

    if should_explode then
        explosion_timer = explosion_timer + 1/tps
        if explosion_timer >= timetoexplode then
            block.place(ix, iy, iz, block.index(blockid), blockstates)
            explode(ix, iy, iz, strenght, checkDurability, pushEntity, recursiveBlocks, spawnParticles, playSound)
            
            if gfxID then
                gfx.particles.stop(gfxID)
                gfxID = nil
            end
            
            entity:despawn()
            return
        end
    end
end