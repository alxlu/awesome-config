local pairs = pairs
local floor = math.floor

local vert_tile = {}
local vcascade = {
    offset_x = 10,
    offset_y = 8,
    mwfact = 0,
    nrow = 2,
    extra_padding = 15
}

vert_tile.name = "vertical"
function vert_tile.arrange(p)
    local t = p.tag or screen[p.screen].selected_tag
    local area
    local cls = p.clients
    -- starts out at 0.5... We multiply by 10 and subtract by 4 to default to 1
    local adjusted_mwfact = floor(t.master_width_factor * 10) - 4
    area = p.workarea
    local spaced_clients = adjusted_mwfact + 2
    -- just tile them normally if the master number is set low enough.
    if #cls <= spaced_clients then
        for i = 1, #cls, 1 do
            -- put master on the bottom
            c = cls[#cls - i + 1]
            local g = {}
            g.x = area.x
            g.y = area.y + (i - 1) * (area.height / #cls)
            g.width = area.width
            g.height = area.height / #cls
            p.geometries[c] = g
        end
    else
        for i = 1, spaced_clients, 1 do
            local c = cls[i]
            local g = {}
            g.x = area.x
            g.y = area.y + (spaced_clients - i) * (area.height / spaced_clients)
            g.width = area.width
            g.height = area.height / spaced_clients
            p.geometries[c] = g
        end

        if #cls <= spaced_clients then return end

        local how_many = (#cls >= t.master_count and #cls) or t.master_count
        local current_offset_x = vcascade.offset_x * (how_many - 1)
        local current_offset_y = vcascade.offset_y * (how_many - 1)
        for i = spaced_clients, #cls, 1 do
            local c = cls[i]
            local g = {}
            g.x = area.x + (how_many - i) * vcascade.offset_x
            g.y = area.y + (i - 2) * vcascade.offset_y
            g.width = area.width - current_offset_x
            g.height = area.height / spaced_clients - current_offset_y
            if g.width < 1 then g.width = 1 end
            if g.height < 1 then g.height = 1 end
            p.geometries[c] = g
        end
    end
end

return vert_tile
