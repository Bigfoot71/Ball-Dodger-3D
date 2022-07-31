--[[

    Code of Ikroth revamped by Bigfoot71.
    Original code taken from the löve2d community.
    Original post: https://love2d.org/forums/viewtopic.php?t=83267

  ]]

--[[
local function sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

local function round(n, places)
    local t = math.pow(10, places)
    return math.floor(n*t)/t
end
]]

--[[
local function randomizeColors()
    hue = love.math.random(0, 360)
    saturation = love.math.random(50, 100)
    value = love.math.random(75, 100)
end
]]

local u = 0;
local function random(x, y)
    u = u + 1
    if x ~= nil and y ~= nil then
        return math.floor(x +(math.random(math.randomseed(os.time()+u))*999999 %y))
    else
        return math.floor((math.random(math.randomseed(os.time()+u))*100))
    end
end

local background = {}
background.__index = background

function background:new(g3d, path)
    local self = setmetatable({}, background)

    self.paused = false
    self.zoom = 1
    self.zoomVel = 0
    self.translateX = 0
    self.translateY = 0
    self.maxIterations = 256
    self.realConst = 0.5
    self.imagConst = 0.5
    self.circleRadius = 2
    self.supersampling = 1
    self.mode = "julia" -- julia, mandelbrot

    -- Couleur de la fractale
    self.hue = random(0, 360)
    self.saturation = 70
    self.value = random(60, 120)

    -- Couleurs changeantes en permanence
    self.rainbowMode = true
    self.timer = 0

    -- Shader
    self.juliaShader = love.graphics.newShader(path.."/assets/shader/julia.frag")

    -- Canvas pour enregistrer texture a afficher en skybox
    self.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    self.model = g3d.newModel(path.."/assets/models/sphere.obj", self.canvas, {0,0,0}, nil, 500)

    -- Pour deplacer le bg automatiquement --

    self.factor_x = random(50, 250) -- Valeur initiale de la disposition
    self.factor_y = self.factor_x

    self.xMr, self.yMr = true, true -- Mr = more (incrementer ou non)
    self.xIn, self.yIn = 2,1 -- nb d'incrementation des facteurs
    self.xLm0, self.yLm0 = 480, 480 -- limite d'incrementation des facteurs
    self.xLm1, self.yLm1 = -380, -380 -- limite de soustraction des facteurs

    return self
end

function background:update(dt)

    dt = math.min(1/30, dt)
    if not self.paused then
        self.timer = self.timer + dt
    end

    --[[ Pour zoomer/dezoomer

    self.zoomVel = self.zoomVel * 0.95
    if math.abs(self.zoomVel) < 0.1 then
        self.zoomVel = 0
    end
    if math.abs(self.zoomVel) > 3 * self.zoom then
        self.zoomVel = 3 * sign(self.zoomVel) * self.zoom
    end
    self.zoom = self.zoom + self.zoomVel * dt

    if self.zoom < 0.25 then
        self.zoom = 0.25
        self.zoomVel = 0
    end

    ]]

    if self.rainbowMode and not self.paused then
        self.hue = self.timer*15 % 360
        self.saturation = math.sin(self.timer) * 10 + 80
    end


    local major, minor, revision = love.getVersion()

    if self.mode == "julia" then
        self.juliaShader:send("translateX", self.translateX)
        self.juliaShader:send("translateY", self.translateY)
        self.juliaShader:send("zoom", self.zoom)
        self.juliaShader:send("realConst", self.realConst)
        self.juliaShader:send("imagConst", self.imagConst)
        self.juliaShader:send("hue", self.hue/360)
        self.juliaShader:send("saturation", self.saturation/100)
        self.juliaShader:send("value", self.value/100)
        self.juliaShader:send("circleRadius", self.circleRadius)

        -- Targets 0+.10+.2+
        if major > 0 or (major == 0 and minor > 10) or (major == 0 and minor == 10 and revision >= 2) then
            self.juliaShader:send("maxIterations", self.maxIterations)
            self.juliaShader:send("supersampling", self.supersampling)
            self.juliaShader:send("mode", 1)
        else
            self.juliaShader:sendInt("maxIterations", self.maxIterations)
            self.juliaShader:sendInt("supersampling", self.supersampling)
            self.juliaShader:sendInt("mode", 1)
        end

    elseif self.mode == "mandelbrot" then
        self.juliaShader:send("translateX", self.translateX) 
        self.juliaShader:send("translateY", self.translateY) 
        self.juliaShader:send("zoom", self.zoom) 
        self.juliaShader:send("hue", self.hue/360)
        self.juliaShader:send("saturation", self.saturation/100)
        self.juliaShader:send("value", self.value/100)
        self.juliaShader:send("circleRadius", self.circleRadius)

        -- Targets 0+.10+.2+
        if major > 0 or (major == 0 and minor > 10) or (major == 0 and minor == 10 and revision >= 2) then
            self.juliaShader:send("maxIterations", self.maxIterations)
            self.juliaShader:send("supersampling", self.supersampling)
            self.juliaShader:send("mode", 2)
        else
            self.juliaShader:sendInt("maxIterations", self.maxIterations)
            self.juliaShader:sendInt("supersampling", self.supersampling)
            self.juliaShader:sendInt("mode", 2)
        end
    end

    self:effectUpdate()

end

--function love.wheelmoved(x, y)
--    zoomVel = zoomVel + sign(y)/5 * zoom
--end

--[[
function background:tmMoved(x,y,dx,dy)
    if love.mouse.isDown(2) then
        self.translateX = self.translateX - dx/love.graphics.getWidth()/self.zoom * 2
        self.translateY = self.translateY - dy/love.graphics.getHeight()/self.zoom * 2
    elseif not paused then
        self.realConst = (love.graphics.getWidth()/2 - x)/love.graphics.getWidth() * -2
        self.imagConst = (love.graphics.getHeight()/2 - y)/love.graphics.getHeight() * -2
    end
end
]]

function background:effectUpdate()

    self.factor_x = self.factor_x + self.xIn
    self.factor_y = self.factor_y + self.yIn

    self.realConst = (love.graphics.getWidth()/2 - self.factor_x)/love.graphics.getWidth() * -2
    self.realConst = (love.graphics.getHeight()/2 - self.factor_y)/love.graphics.getHeight() * -2

    if self.factor_x >= self.xLm0 
    or self.factor_x <= self.xLm1 then
        self.xMr = not self.xMr
        self.xIn = -self.xIn
    end

    if self.factor_y >= self.yLm0
    or self.factor_y <= self.yLm1 then
        self.yMr = not self.yMr
        self.yIn = -self.yIn
    end

end

function background:draw()

    love.graphics.setCanvas(self.canvas)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setShader(self.juliaShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    love.graphics.setCanvas()

    self.model.texture = self.canvas
    self.model:setRotation(math.pi - self.timer, 0, 0) -- Rotation
    self.model:draw()

end

return background