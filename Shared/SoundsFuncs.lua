

function VZ_RandomSound(random_sound_tbl)
    local random_s_id = math.random(random_sound_tbl.random_start, random_sound_tbl.random_to)
    local random_s_id_str = tostring(random_s_id)
    if random_sound_tbl.always_digits then
        if string.len(random_s_id_str) ~= random_sound_tbl.always_digits then
            local add_x_0 = ""
            for i = 1, random_sound_tbl.always_digits - string.len(random_s_id_str) do
                add_x_0 = add_x_0 .. "0"
            end
            random_s_id_str = add_x_0 .. random_s_id_str
        end
    end
    return random_sound_tbl.base_ref .. random_s_id_str
end