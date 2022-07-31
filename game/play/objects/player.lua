local player = {}
player.__index = player

function player:new(g3d, path, x,y,z)

    local self = setmetatable({}, player)
    local vectorMeta = {}

    self.position = {
        setmetatable({x,0,z}, vectorMeta), -- Postion du joeur
        setmetatable({x,y,z}, vectorMeta)  -- Position du model joueur de transition (sortie d'ecran)
    }

    self.model = {
        g3d.newModel(path.."/assets/models/cube.obj", path.."/assets/textures/player.jpg", self.position[1], nil, nil),
        g3d.newModel(path.."/assets/models/cube.obj", path.."/assets/textures/player.jpg", self.position[2], nil, nil)
    }

    self.speedFactor = .045         -- Facteur pour DeltaPosition (dx)
    self.speedAccumulate = 0        -- Accumulation de vitesse pour un deplacement "smooth"
    self.movementValue = 0          -- Distance de deplacement
    self.movementValueFactor = .1   -- Pour "diviser" seedAccumulate obtenir la distance a effectuer
    self.collisionModels = {}

    self.score = 0
    self.lives = 3

    return self

end

function player:update(dt)

    -- Evenements de transition en ammont pour eviter glitch graphique a la transition --

    -- Debut de transition
    if not self.outOfScreen then
        if self.position[1][2] < -11 then
            self.position[2][2] = 15.65
            self.outOfScreen = "R"
        elseif self.position[1][2] > 11 then
            self.position[2][2] = -15.65
            self.outOfScreen = "L"
        end

    -- Fin de transition
    elseif self.outOfScreen == "L" then
        if self.position[1][2] > 15.65 then -- Si on sort completement de l'ecran
            self.position[1][2] = -11
            self.outOfScreen = false
        elseif self.position[1][2] < 11 then -- Si on reviens dans l'ecran
            self.outOfScreen = false
        end
    elseif self.outOfScreen == "R" then
        if self.position[1][2] < -15.65 then
            self.position[1][2] = 11
            self.outOfScreen = false
        elseif self.position[1][2] > -11 then
            self.outOfScreen = false
        end
    end

    -- Deplacement du joueur --

    if self.speedAccumulate ~= 0 then

        self.movementValue = self.speedAccumulate * .1 -- Valeur du deplacement
        self.position[1][2] = self.position[1][2] - self.movementValue -- Posi bloc primaire

        self.model[1]:setTranslation(
            self.position[1][1],
            self.position[1][2],
            self.position[1][3]
        )

        if self.outOfScreen then

            self.position[2][2] = self.position[2][2] - self.movementValue -- Posi bloc secondaire de transition

            self.model[2]:setTranslation(
                self.position[2][1],
                self.position[2][2],
                self.position[2][3]
            )

        end

        self.speedAccumulate = self.speedAccumulate - self.movementValue

    end

end

function player:move(dx,onPress) -- revoir 'onPress'

    if onPress then
        self.speedAccumulate = self.speedAccumulate + dx*self.speedFactor
    end
end

function player:draw()

    self.model[1]:draw()

    if self.outOfScreen then
        self.model[2]:draw()
    end

end

return player
