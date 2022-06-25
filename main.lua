--[[
    Author: Bigfoot71
    Description: 3D ball dodging game written with löve2d and g3d.
    Date: june 2022
    License: MIT license
  ]]

local g3d = require "g3d"

local obj
local timer = 0
local onPress = false

function love.load()

    obj = {

        background = require("objects/background"):new(),
        player = require("objects/player"):new(10,0,-8),
        obstacle = require("objects/obstacle"):new(10,0,12),
        hud = require("objects/hud"):new()

    }

    love.mouse.setRelativeMode(true)

end

function love.update(dt)

    timer = timer + dt

    if love.keyboard.isDown("escape") then
        love.event.push("quit")
    end

    obj.background:update(dt)
    obj.player:update(dt)
    obj.obstacle:update(dt, obj.player.position, obj.player.outOfScreen)
    obj.hud:update(obj.player.score)

    if obj.obstacle.active[2] ~= nil then

        if obj.obstacle.active[2] then
             obj.player.score = obj.player.score + 100
        else obj.player.lives = obj.player.lives - 1 end

        obj.obstacle.active[2] = nil

    end

    g3d.camera.lookInDirection() -- Refresh view

end

function love.mousemoved(x,y,dx,dy)
    -- obj.background:tmMoved(x,y,dx,dy)
    obj.player:move(dx,true)
end

function love.draw()
    obj.background:draw()
    obj.player:draw()
    obj.obstacle:draw()
    obj.hud:draw(obj.player.lives)
end

function love.resize()
    g3d.camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()
    -- G3DShader:send("projectionMatrix", GetProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio))
end
