local g3d = require "lib/g3d"

local WIN_W, WIN_H = love.graphics.getDimensions()

local path = ...

local playState = {}
playState.__index = playState

function playState:new()

    local self = setmetatable({}, playState)

    self.font = love.graphics.newFont("fonts/Unibody_8_Regular.ttf", 8)

    self.background = require(path.."/objects/background"):new(g3d, path)
    self.player = require(path.."/objects/player"):new(g3d, path, 10,0,-8)
    self.ball = require(path.."/objects/ball"):new(g3d, path, 10,0,12)
    self.hud = require(path.."/objects/hud"):new()

    self.startUp = {true, 1}

    return self

end

function playState:update(dt)

    self.background:update(dt)
    self.player:update(dt)
    self.ball:update(dt, self.player.position, self.player.outOfScreen)
    self.hud:update(self.player.score)

    if self.ball.active[2] ~= nil then

        if self.ball.active[2] then
            self.player.score = self.player.score + 100
        else
            self.player.lives = self.player.lives - 1
            if self.player.lives < 1 then setState("title") end
        end

        self.ball.active[2] = nil

    end

    g3d.camera.lookInDirection() -- Refresh view

    -- Fade to "white" on startup --

    if self.startUp[1] then
        if self.startUp[2] > 0 then
            self.startUp[2] = self.startUp[2] - dt 
        else self.startUp[1] = false end
    end

end

function playState:mousePressed(x,y)
    --pass
end

function playState:mouseMoved(x,y,dx)
--  self.background:tmMoved(x,y,dx,dy)
    self.player:move(dx,true)
end

function playState:mouseReleased(x,y)
    --pass
end

function playState:draw(dt)

    love.graphics.setFont(self.font) -- Optimisé cette ligne pour ne l'appeler qu'une fois ?

    self.background:draw()
    self.player:draw()
    self.ball:draw()
    self.hud:draw(self.player.lives)

    if self.startUp[1] then
        love.graphics.setColor(0,0,0,self.startUp[2])
        love.graphics.rectangle("fill", 0, 0, WIN_W, WIN_H)
    end

end

--[[
function playState:resize()
    g3d.camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()
--  G3DShader:send("projectionMatrix", GetProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio))
end
]]

return playState
