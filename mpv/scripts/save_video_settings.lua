-- save_video_settings.lua
local utils = require('mp.utils')
local msg = require('mp.msg')
local options = require('mp.options')

-- Properties to save
local properties = {
    volume = {
        type = "number",
        property = "volume"
    },
    sub_scale = {
        type = "number",
        property = "sub-scale"
    },
    audio = {
        type = "string",
        property = "aid"
    },
    subtitle = {
        type = "string",
        property = "sid"
    },
    sub_delay = {
        type = "number",
        property = "sub-delay"
    },
    shaders = {
        type = "string",
        property = "glsl-shaders"
    }
}

-- Get config directory path
local config_dir = mp.find_config_file('.')
local config_path = utils.join_path(config_dir, 'saved_video_settings.json')

-- Get property based on its type
local function get_property(prop_info)
    if prop_info.type == "number" then
        return mp.get_property_number(prop_info.property)
    else
        return mp.get_property(prop_info.property)
    end
end

-- Set property based on its type
local function set_property(prop_info, value)
    if value == nil then return end
    
    if prop_info.type == "number" then
        mp.set_property_number(prop_info.property, value)
    else
        mp.set_property(prop_info.property, value)
    end
end

-- Load settings from file
local function load_settings()
    local file = io.open(config_path, 'r')
    if not file then return end
    
    local success, data = pcall(function()
        local content = file:read('*all')
        file:close()
        return utils.parse_json(content)
    end)
    
    if success and data then
        for prop_name, prop_info in pairs(properties) do
            if data[prop_name] then
                set_property(prop_info, data[prop_name])
            end
        end
        msg.info("Settings loaded successfully")
        mp.osd_message("Settings loaded")
    end
end

-- Save current settings to file
local function save_settings()
    local data = {}
    for prop_name, prop_info in pairs(properties) do
        data[prop_name] = get_property(prop_info)
    end
    
    local success, content = pcall(utils.format_json, data)
    if success then
        local file = io.open(config_path, 'w')
        if file then
            file:write(content)
            file:close()
            msg.info("Settings saved successfully")
            mp.osd_message("Settings saved")
        end
    end
end

-- Reset subtitle delay
local function reset_sub_delay()
    set_property(properties.sub_delay, 0)
    save_settings()
    mp.osd_message("Subtitle delay reset")
end

-- Register events
mp.register_event('end-file', save_settings)
mp.register_event('shutdown', save_settings)
mp.register_event('file-loaded', load_settings)

-- Register key bindings
mp.add_key_binding('Alt+s', 'save-settings', save_settings)
mp.add_key_binding('Alt+z', 'reset-sub-delay', reset_sub_delay)

msg.info("Save video settings script loaded")
