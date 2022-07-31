--[[
    Author: Bigfoot71
    Description: 3D ball dodging game written with löve2d and g3d.
    Date: june 2022
    License: MIT license
  ]]

local gameState,
      titleState,
      playState

function setState(state)

    if state == "title" then
        love.mouse.setRelativeMode(false)
        titleState = require("game/title"):new()
        gameState = titleState

    elseif state == "play" then
        love.mouse.setRelativeMode(true)
        playState = require("game/play"):new()
        gameState = playState

    end
end

function love.load()
    setState("title")
end

function love.update(dt)

    if love.keyboard.isDown("escape") then
        love.event.push("quit")
    end

    gameState:update(dt)

end

function love.mousepressed(x,y,dx,dy)
    gameState:mousePressed(x,y,dx,dy)
end

function love.mousemoved(x,y,dx,dy)
    gameState:mouseMoved(x,y,dx,dy)
end

function love.mousereleased(x,y,dx,dy)
    gameState:mouseReleased(x,y,dx,dy)
end

function love.draw()
    gameState:draw()
end
