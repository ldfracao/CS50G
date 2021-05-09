--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]] PlayState = Class {__includes = BaseState}

PIPE_SPEED = 80
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.scrolling = true
    self.pause = false

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)

    if self.scrolling and not self.pause then
        -- randomizer for the time interval between pipe spawns
        randomizer = math.random(2, 100)

        -- update timer for pipe spawning
        self.timer = self.timer + dt

        -- spawn a new pipe pair every second and a half
        if self.timer > randomizer then
            -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
            -- no higher than 10 pixels below the top edge of the screen,
            -- and no lower than a gap length (90 pixels) from the bottom
            local y = math.max(-PIPE_HEIGHT + 10, math.min(
                                   self.lastY + math.random(-20, 20),
                                   VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            self.lastY = y

            -- add a new pipe pair at the end of the screen at our new Y
            table.insert(self.pipePairs, PipePair(y))

            -- reset timer
            self.timer = 0
        end

        -- for every pair of pipes..
        for k, pair in pairs(self.pipePairs) do
            -- score a point if the pipe has gone past the bird to the left all the way
            -- be sure to ignore it if it's already been scored
            if not pair.scored then
                if pair.x + PIPE_WIDTH < self.bird.x then
                    self.score = self.score + 1
                    pair.scored = true
                    sounds['score']:play()
                end
            end

            -- update position of pair
            pair:update(dt)
        end

        -- we need this second loop, rather than deleting in the previous loop, because
        -- modifying the table in-place without explicit keys will result in skipping the
        -- next pipe, since all implicit keys (numerical indices) are automatically shifted
        -- down after a table removal
        for k, pair in pairs(self.pipePairs) do
            if pair.remove then table.remove(self.pipePairs, k) end
        end

        -- simple collision between bird and all pipes in pairs
        for k, pair in pairs(self.pipePairs) do
            for l, pipe in pairs(pair.pipes) do
                if self.bird:collides(pipe) then
                    sounds['explosion']:play()
                    sounds['hurt']:play()

                    gStateMachine:change('score', {score = self.score})
                end
            end
        end

        -- update bird based on gravity and input
        self.bird:update(dt)

        -- reset if we get to the ground
        if self.bird.y > VIRTUAL_HEIGHT - 15 then
            sounds['explosion']:play()
            sounds['hurt']:play()

            gStateMachine:change('score', {score = self.score})
        end
    end

    -- checks for the first press of the p key, negates scrolling and pause
    if love.keyboard.wasPressed('p') and self.pause == false then
        sounds['music']:pause()
        sounds['pause']:play()
        self.scrolling = not self.scrolling
        self.pause = not self.pause
        
    -- checks for second press of the p key
    elseif love.keyboard.wasPressed('p') and self.pause == true then
        sounds['unpause']:play()
        -- checks if pause is true just so the sounds don't play at the same time
        if self.pause == true then
            sounds['music']:play()
        end
        self.scrolling = not self.scrolling
        self.pause = not self.pause
    end
end

function PlayState:render()

    -- if game is not paused
    if not self.pause then
        for k, pair in pairs(self.pipePairs) do pair:render() end
        love.graphics.setFont(flappyFont)
        love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
        self.bird:render()
    -- if game is paused
    else
        love.graphics.setFont(hugeFont)
        love.graphics.printf('game paused', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('press p again to unpause', 0, 140, VIRTUAL_WIDTH, 'center')
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end
