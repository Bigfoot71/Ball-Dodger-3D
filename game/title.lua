local drawCenteredText = require("lib/DrawCenteredText")
local WIN_W, WIN_H = love.graphics.getDimensions()

local titleState = {}
titleState.__index = titleState

function titleState:new()

    local self = setmetatable({}, titleState)

    self.title = {WIN_W/2, WIN_H/8, {math.random(), math.random(), math.random()}, 0}

    self.playButton = {w=WIN_W/6, h=WIN_H/8}
    self.playButton.x = (WIN_W - self.playButton.w) / 2
    self.playButton.y = WIN_H/1.25
    self.playButton.isPressedOn = false
    self.playButton.color = {1, 1, 1}

    self.font_title = love.graphics.newFont("fonts/Unibody_8_Black.ttf", 38)
    self.font_play  = love.graphics.newFont("fonts/Unibody_8_Bold.ttf", 28)

    self.startGame = {false, 0}

    return self

end

function titleState:update(dt)
    if self.title[4] > .25 then
        self.title[3][1] = math.random()
        self.title[3][2] = math.random()
        self.title[3][3] = math.random()
        self.title[4] = 0
    else
        self.title[4] = self.title[4] + dt
    end

    if self.startGame[1] then
        if self.startGame[2] > 1 then
            setState("play")
        else
            self.startGame[2] = self.startGame[2] + dt
        end
    end

end

function titleState:mousePressed(x,y)
    if  x > self.playButton.x
    and x < self.playButton.x + self.playButton.w
    and y > self.playButton.y
    and y < self.playButton.y + self.playButton.h
    then
        self.playButton.isPressedOn = true
        self:mouseMoved(x,y)
    end
end

function titleState:mouseMoved(x,y)
    if  x > self.playButton.x
    and x < self.playButton.x + self.playButton.w
    and y > self.playButton.y
    and y < self.playButton.y + self.playButton.h
    then if self.playButton.isPressedOn
        and self.playButton.color ~= {.5,.5,.5}
        then self.playButton.color = {.5,.5,.5} end
    else if self.playButton.color ~= {1,1,1} then
            self.playButton.color = {1,1,1}
        end
    end
end

function titleState:mouseReleased(x,y)
    if self.playButton.isPressedOn
    and x > self.playButton.x
    and x < self.playButton.x + self.playButton.w
    and y > self.playButton.y
    and y < self.playButton.y + self.playButton.h
    then
        self.playButton.isPressedOn = false
        self.startGame[1] = true
    else
        self.playButton.isPressedOn = false
    end
end

function titleState:draw()

    love.graphics.setFont(self.font_title)
    love.graphics.setColor(self.title[3][1], self.title[3][2], self.title[3][3])
    drawCenteredText("DODGER BALL 3D", self.title[1], self.title[2], 0, 0)

    love.graphics.setFont(self.font_play)
    love.graphics.setColor(self.playButton.color)

    drawCenteredText("PLAY",
        self.playButton.x,
        self.playButton.y,
        self.playButton.w,
        self.playButton.h
    )
    love.graphics.rectangle("line",
        self.playButton.x,
        self.playButton.y,
        self.playButton.w,
        self.playButton.h
    )

    if self.startGame[1] then
        love.graphics.setColor(0, 0, 0, self.startGame[2])
        love.graphics.rectangle("fill", 0, 0, WIN_W, WIN_H)
    end

end

return titleState