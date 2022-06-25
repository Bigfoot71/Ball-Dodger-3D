local drawCenteredText = require("lib/DrawCenteredText")

local hud = {}
hud.__index = hud

function hud:new()
    local self = setmetatable({}, hud)

    self.bg = {
        x = 0, y = 0,
        w = love.graphics.getWidth(), h = 16,
        color = {0,0,0}
    }

    self.fps = {
        x = 0,
        y = 0,
        w = self.bg.w/3,
        h = self.bg.h
    }

    self.lives = {
        x = self.bg.w/3,
        y = 0,
        w = self.bg.w/3,
        h = self.bg.h
    }

    self.score = {
        x = (self.bg.w/3)*2,
        y = 0,
        w = self.bg.w/3,
        h = self.bg.h
    }

    self.score_draw = 0

    return self
end

function hud:update(player_score)
    if self.score_draw < player_score then
        self.score_draw = self.score_draw + 5
    elseif self.score_draw > player_score then
        self.score_draw = player_score
    end
end

function hud:draw(player_lives)

    love.graphics.setColor(self.bg.color)
    love.graphics.rectangle("fill",self.bg.x,self.bg.y,self.bg.w,self.bg.h)  -- Background

    love.graphics.setColor(1,1,1)

    drawCenteredText( -- FPS
        love.timer.getFPS().." FPS",
        self.fps.x,
        self.fps.y,
        self.fps.w,
        self.fps.h
    )

    drawCenteredText( -- LIVES
        "LIVES: "..player_lives,
        self.lives.x,
        self.lives.y,
        self.lives.w,
        self.lives.h
    )

    drawCenteredText( -- SCORE
        "SCORE: "..self.score_draw,
        self.score.x,
        self.score.y,
        self.score.w,
        self.score.h
    )

end

return hud