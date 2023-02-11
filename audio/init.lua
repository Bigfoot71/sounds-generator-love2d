local notes = require((...)..".notes")

-- Gen sound functions --

local getFadeCoeff = function (fadeLength, soundData, i, rate)  -- Generally used to soften artifacts at the end of short sounds
    if fadeLength and i > (soundData:getSampleCount() - math.floor(fadeLength*rate)) then
        return (soundData:getSampleCount() - i) / math.floor(fadeLength*rate)
    end;return 1
end

local function genSound(length, tone, rate, p, waveType, fadeLength, getData)

    if type(tone) == "string" then tone = notes[tone] end

    length   = length or (1/32)              -- 0.03125 seconds
    tone     = tone or 440.0                 -- Hz
    rate     = rate or 44100                 -- samples per second
    p        = p or math.floor(rate/tone)    -- 100 (wave length in samples)
    waveType = waveType or "square"          -- Wave type...

    if fadeLength == true then fadeLength = 1/160 end       -- fadeLength should generally be 1/10 or 1/5 of the base length

    -- Length adjustement to sine cycle  --

    if waveType == "autoSine" then
        local sampleCount = math.floor(rate*length+.5)
        local cycleCount = math.floor(sampleCount/p+.5)
        length = cycleCount/tone
    end

    -- Generate sound --

    local soundData = love.sound.newSoundData(
        math.floor(length*rate), rate, 16, 1
    )

    if waveType == "sine" or waveType == "autoSine" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * math.sin(2*math.pi*i/p)) -- sine wave.
        end
    elseif waveType == "square" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (i%p<p/2 and 1 or -1)) -- square wave; the first half of the wave is 1, the second half is -1.
        end
    elseif waveType == "triangle" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (2 * math.abs(2*(i/p-math.floor(i/p+0.5)))-1))
        end
    elseif waveType == "sawtooth" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (2 * (i/p-math.floor(i/p+0.5))))
        end
    elseif waveType == "pulser" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (math.sin(2*math.pi*i/p) * math.sin(2*math.pi*10*i/p)))
        end
    elseif waveType == "composite" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (math.sin(2*math.pi*i/p) + math.sin(2*math.pi*2*i/p) * 0.5))
        end
    end

    -- Return data or sound --

    if getData then return soundData end
    local sound = love.audio.newSource(soundData)
    soundData:release()
    return sound

end


-- Gen music function --

local function genMusic(sounds, consts, rate)

    rate = rate or 44100

    local datas = {}
    local len = 0

    for i, sound in ipairs(sounds) do

        len = len + (sound.length or (1/32))

        datas[i] = genSound(
            consts and consts.length or sound.length,
            consts and consts.tone or sound.tone,
            rate,
            consts and consts.p or sound.p,
            consts and consts.waveType or sound.waveType,
            consts and consts.fadeLength or sound.fadeLength,
            true
        )

    end

    local soundData = love.sound.newSoundData(
        math.floor(len*rate), rate, 16, 1
    )

    local index = 0
    for i, data in ipairs(datas) do
        for j = 0, data:getSampleCount()-1 do
            if index < soundData:getSampleCount() then
                soundData:setSample(index, data:getSample(j))
            end; index = index + 1
        end; data:release()
    end


    local sound = love.audio.newSource(soundData)
    soundData:release()

    return sound

end

return {
    notes = notes;
    genSound = genSound;
    genMusic = genMusic;
}
