local audio = require("audio")

-- DEMO --

function love.load()

    GW, GH = love.graphics.getDimensions()

    MUSIC = audio.genMusic({
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/64},
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "C5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "G5", length = 1/4},
        {tone = 0, length = 1/16},
        {tone = "G4", length = 1/3},
        {tone = "C5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "G4", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "E4", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "A4", length = 1/3},
        {tone = 0, length = 1/128},
        {tone = "B4", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "As4", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "A4", length = 1/4},
        {tone = 0, length = 1/64},
        {tone = "G4", length = 1/4},
        {tone = 0, length = 1/64},
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/64},
        {tone = "G5", length = 1/4},
        {tone = 0, length = 1/64},
        {tone = "A5", length = 1/3},
        {tone = 0, length = 1/32},
        {tone = "F5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "G5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "E5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "C5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "D5", length = 1/4},
        {tone = 0, length = 1/32},
        {tone = "B4", length = 1/2},
    }, nil, 44100)

    SOUNDS = {
        sine = audio.genSound(1/8, 440, 44100, nil, "sine");
        square = audio.genSound(1/8, 440, 44100, nil, "square");
        triangle = audio.genSound(1/8, 440, 44100, nil, "triangle");
        sawtooth = audio.genSound(1/8, 440, 44100, nil, "sawtooth");
        pulser = audio.genSound(1/8, 440, 44100, nil, "pulser");
        composite = audio.genSound(1/8, 440, 44100, nil, "composite");
    }

    BW, BH = 192, 92

    BTN_MUSIC = {
        (GW-BW)*.5, (GH-BH)*.03125, {1,1,1}
    }

    BUTTONS = {
        {(GW-BW)*.25, (GH-BH)*.25, {1,0,0}},
        {(GW-BW)*.75, (GH-BH)*.25, {0,1,0}},
        {(GW-BW)*.25, (GH-BH)*.5, {0,0,1}},
        {(GW-BW)*.75, (GH-BH)*.5, {1,1,0}},
        {(GW-BW)*.25, (GH-BH)*.75, {1,0,1}},
        {(GW-BW)*.75, (GH-BH)*.75, {0,1,1}}
    }

    FONT = love.graphics.getFont()

end

local pressed;
function love.update(dt)

    if love.mouse.isDown(1) then

        local mx, my = love.mouse.getPosition()

        local i = 1;
        for k, sound in pairs(SOUNDS) do
            local x, y = BUTTONS[i][1], BUTTONS[i][2]
            if mx > x and mx < x+BW and my > y and my < y+BH then
                sound:play(); pressed = true; break
            end;i = i + 1
        end

        if not pressed then
            pressed = true
            local x, y = BTN_MUSIC[1], BTN_MUSIC[2]
            if mx > x and mx < x+BW and my > y and my < y+BH then
                if MUSIC:isPlaying() then
                    MUSIC:stop()
                else
                    MUSIC:play()
                end
            end
        end

    end

end

function love.mousereleased()
    pressed = false
end

function love.draw()

    -- Draw buttons

    local i = 1;
    for k, sound in pairs(SOUNDS) do

        local x, y = BUTTONS[i][1], BUTTONS[i][2]

        local fw, fh = FONT:getWidth(k), FONT:getHeight()

        love.graphics.setColor(BUTTONS[i][3])
        love.graphics.rectangle("fill", x, y, BW, BH, BW/4, BH/4)

        love.graphics.setColor(0,0,0)
        love.graphics.print(k, (x+BW/2)-fw/2, (y+BH/2)-fh/2)

        i = i + 1

    end

    -- Draw music button

    local str = (MUSIC:isPlaying()) and "Stop music" or "Play music"

    local x, y = BTN_MUSIC[1], BTN_MUSIC[2]
    local fw, fh = FONT:getWidth(str), FONT:getHeight()

    love.graphics.setColor(BTN_MUSIC[3])
    love.graphics.rectangle("fill", x, y, BW, BH, BW/4, BH/4)

    love.graphics.setColor(0,0,0)
    love.graphics.print(str, (x+BW/2)-fw/2, (y+BH/2)-fh/2)

end

