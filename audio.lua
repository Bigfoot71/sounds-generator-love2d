local floor = math.floor


-- Gen notes --

local notes = {}; do

    local A4 = 440.00
    local note_names = {
        "C", "Cs", "D",
        "Ds", "E", "F",
        "Fs", "G", "Gs",
        "A", "As", "B"
    }

    for n = 12, 131 do -- From C0 to B9
        local note_frequency = A4 * 2^((n-69)/12)
        local octave = floor(n/12)-1
        local note_index = n % 12 + 1
        local note_name = note_names[note_index]..octave
        notes[note_name] = note_frequency
    end

end


-- Gen sound functions --

local getFadeCoeff = function (fadeLength, soundData, i, rate)  -- Generally used to soften artifacts at the end of short sounds
    if fadeLength and i > (soundData:getSampleCount() - floor(fadeLength*rate)) then
        return (soundData:getSampleCount() - i) / floor(fadeLength*rate)
    end;return 1
end

local function genSound(length, tone, rate, p, waveType, fadeLength, getData)

    if type(tone) == "string" then tone = notes[tone] end

    length   = length or (1/32)              -- 0.03125 seconds
    tone     = tone or 440.0                 -- Hz
    rate     = rate or 44100                 -- samples per second
    p        = p or floor(rate/tone)         -- 100 (wave length in samples)
    waveType = waveType or "square"          -- Wave type...

    if fadeLength == true then fadeLength = 1/160 end       -- fadeLength should generally be 1/10 or 1/5 of the base length

    -- Length adjustement to sine cycle  --

    if waveType == "autoSine" then
        local sampleCount = floor(rate*length+.5)
        local cycleCount = floor(sampleCount/p+.5)
        length = cycleCount/tone
    end

    -- Generate sound --

    local soundData = love.sound.newSoundData(
        floor(length*rate), rate, 16, 1
    )

    if waveType == "sine" or waveType == "autoSine" then
        local sin, pi = math.sin, math.pi
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * sin(2*pi*i/p)) -- sine wave.
        end
    elseif waveType == "square" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (i%p<p/2 and 1 or -1)) -- square wave; the first half of the wave is 1, the second half is -1.
        end
    elseif waveType == "triangle" then
        local abs = math.abs
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (2 * abs(2*(i/p-floor(i/p+0.5)))-1))
        end
    elseif waveType == "sawtooth" then
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (2 * (i/p-floor(i/p+0.5))))
        end
    elseif waveType == "pulser" then
        local sin, pi = math.sin, math.pi
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (sin(2*pi*i/p) * sin(2*pi*10*i/p)))
        end
    elseif waveType == "composite" then
        local sin, pi = math.sin, math.pi
        for i=0, soundData:getSampleCount() - 1 do
            local fade = getFadeCoeff(fadeLength, soundData, i, rate)
            soundData:setSample(i, fade * (sin(2*pi*i/p) + sin(2*pi*2*i/p) * 0.5))
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

    local len = 0
    for i, sound in ipairs(sounds) do
        len = len + (sound.length or (1/32))
    end

    local soundData = love.sound.newSoundData(
        floor(len * rate), rate, 16, 1
    )

    local offset = 0
    for i, sound in ipairs(sounds) do

        local data = genSound(
            consts and consts.length or sound.length,
            consts and consts.tone or sound.tone,
            rate,
            consts and consts.p or sound.p,
            consts and consts.waveType or sound.waveType,
            consts and consts.fadeLength or sound.fadeLength,
            true
        )

        for j = 0, data:getSampleCount()-1 do
            soundData:setSample(j + offset, data:getSample(j))
        end

        offset = offset + data:getSampleCount()
        data:release()

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
