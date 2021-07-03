--[[
    * License: MIT
    * Author : rui-ddc
    * Link   : https://github.com/rui-ddc/skip-intro
    *
    * This script skips to the next silence in the file. The
    * intended use for this is to skip until the end of an
    * opening sequence, at which point there's often a short
    * period of silence
--]]

skip = false

local opts = {

    -- Maximum amount of noise to trigger
    quietness = -30, -- dB

    -- Minimum duration of silence to trigger
    duration  = 0.1  -- sec

}

local options = require 'mp.options'

options.read_options(opts)

af_table = mp.get_property_native("af")
vf_table = mp.get_property_native("vf")

-- `silencedetect` is an audio filter that listens for silence
-- and emits text output with details whenever silence is detected
af_table[#af_table + 1] = {
    enabled = false,
    label   = "skiptosilence",
    name    = "lavfi",
    params  = {graph = "silencedetect=noise=" .. opts.quietness .. "dB:d=" ..opts.duration}
}

-- `nullsink` interrupts the video stream requests to the decoder,
-- which stops it from bogging down the fast-forward
-- `color` generates a blank image, which renders very quickly and
-- is good for fast-forwarding
vf_table[#vf_table + 1] = {
    enabled = false,
    label   = "blackout",
    name    = "lavfi"
}

mp.set_property_native("af", af_table)
mp.set_property_native("vf", vf_table)

function setAudioFilter(state)
    if #af_table > 0 then
        for i = #af_table, 1, -1 do
            if af_table[i].label == "skiptosilence" then
                af_table[i].enabled = state
                mp.set_property_native("af", af_table)
                return
            end
        end
    end
end

function setVideoFilter(state, width, height)
    if #vf_table > 0 then
        for i = #vf_table, 1, -1 do
            if vf_table[i].label == "blackout" then
                vf_table[i].enabled = state
                vf_table[i].params  = {graph = "nullsink,color=c=black:s=" .. width .. "x" .. height}
                mp.set_property_native("vf", vf_table)
                return
            end
        end
    end
end

function foundSilence(name, value)
    if value == "{}" or value == nil then
        return -- Ignore {} and nil
    end

    skipTime = tonumber(string.match(value, "%d+%.?%d+"))
    currTime = mp.get_property_native("time-pos")
    if skipTime == nil or skipTime < currTime + 1 then
        return -- Ignore anything less than a second ahead
    end

    setAudioFilter(false)
    setVideoFilter(false, 0, 0)

    mp.unobserve_property(foundSilence)
    
    mp.set_property_bool("mute" , false)
    mp.set_property     ("speed", 1    )
    skip = false

    mp.set_property_number("time-pos", skipTime)
end

function abortEvent()
    setAudioFilter(false)
    setVideoFilter(false, 0, 0)

    mp.unobserve_property(foundSilence)

    mp.set_property_bool("mute" , false)
    mp.set_property     ("speed", 1    )

    mp.set_property_number("time-pos", abortTime)
end

function skipEvent()
    -- Video jumps back to abortTime if skip is interrupted
    abortTime = mp.get_property_native("time-pos")

    local width  = mp.get_property_native("width")
    local height = mp.get_property_native("height")
    setAudioFilter(true)
    setVideoFilter(true, width, height)

    -- Triggers whenever the `silencedetect` filter emits output
    mp.observe_property("af-metadata/skiptosilence", "string", foundSilence)
    
    mp.set_property_bool("pause", false)
    mp.set_property_bool("mute" , true )
    mp.set_property     ("speed", 100  )
end

function keyEvent()
    skip = not skip
    if skip then
        skipEvent()
    else
        abortEvent()
    end
end

mp.add_key_binding("Tab", "keyEvent", keyEvent)