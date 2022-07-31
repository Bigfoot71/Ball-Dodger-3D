local obstacle = {}
obstacle.__index = obstacle

function obstacle:new(g3d, path, x,y,z)

    local self = setmetatable({}, obstacle)
    local vectorMeta = {}

    self.positionDefault = {x,y,z}
    self.position = setmetatable({x,y,z}, vectorMeta)
    self.model = g3d.newModel(path.."/assets/models/sphere.obj", path.."/assets/textures/ball.png", self.position, nil, .85)

    self.timer = 0
    self.timerLimit = 1.85
    self.speed = math.random(22,26)
    self.active = {false, nil} -- [1]: actif/nonactif    [2]: vrai = +points | faux = -vie

    return self

end

function obstacle:deactive(collidePlayer)

    if collidePlayer then
        self.active[2] = false
    else -- Sortie d'ecran
        self.active[2] = true
    end

    -- Prochaine position
    self.model:setTranslation(self.positionDefault[1], math.random(-11,11), self.positionDefault[3])

    -- Reinit des valeurs
    self.timer = 0
    self.timerLimit = math.random(.5,1)
    self.speed = math.random(22,25)
    self.active[1] = false

end

function obstacle:update(dt, player_position, playerOutOfScreen)

    self.timer = self.timer + dt

    if self.active[1] then -- Etat actif

        -- Check de collision
        if self.model:sphereIntersection( -- #- OPTI
            player_position[1][1],
            player_position[1][2],
            player_position[1][3],
            1.65) -- Rayon de la sphere, trouver moyen de l'obtenir (ecrire nouvelle fonction g3d pour obetnir w,h,hauteur des models)
        or (playerOutOfScreen and
            self.model:sphereIntersection(
            player_position[2][1],
            player_position[2][2],
            player_position[2][3],
            1.65))
        then
            self:deactive(true)

        else -- Obstacle en mode actif
            self.position[3] = self.position[3] - self.speed * dt   -- Deplacement
            self.model:setRotation(0, math.pi - (self.timer*4), 0)  -- Rotation
            if self.position[3] < -15 then self:deactive(false)     -- Sortie d'ecran
            else self.model:setTranslation(self.position[1], self.position[2], self.position[3]) end -- Sinon deplacement du model
            self.speed = self.speed + .2   -- Augmentation de la vitesse de chute
        end

    else -- En attente d'etre actif
        if self.timer >= self.timerLimit then
            self.active[1] = true
        end

    end
end

function obstacle:draw()
    if self.active[1] then
        self.model:draw()
    end
end

return obstacle