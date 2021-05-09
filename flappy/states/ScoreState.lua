--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()

    -- variables used to render images
    local gold_trophy = love.graphics.newImage('gold.png')
    local silver_trophy = love.graphics.newImage('silver.png')
    local bronze_trophy = love.graphics.newImage('bronze.png')
    local gold_width = gold_trophy:getWidth()
    local gold_height = gold_trophy:getHeight()
    local silver_width = silver_trophy:getWidth()
    local silver_height = silver_trophy:getHeight()
    local bronze_width = bronze_trophy:getWidth()
    local bronze_height = bronze_trophy:getHeight()

    -- simply render the score to the middle of the screen according to score amount
    if self.score < 3 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')
    elseif self.score >= 3 and self.score < 6 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Congratulations', 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('You unlocked the bronze trophy!!!', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(bronze_trophy, VIRTUAL_WIDTH / 2 - bronze_width / 2, VIRTUAL_HEIGHT / 2 - bronze_height / 2)
    elseif self.score >= 6 and self.score < 10 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Congratulations', 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('You unlocked the silver trophy!!!', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(silver_trophy, VIRTUAL_WIDTH / 2 - silver_width / 2, VIRTUAL_HEIGHT / 2 - silver_height / 2)
    elseif self.score >= 10 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Congratulations', 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('You unlocked the gold trophy!!!', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(gold_trophy, VIRTUAL_WIDTH / 2 - gold_width / 2, VIRTUAL_HEIGHT / 2 - gold_height / 2)
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 210, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 230, VIRTUAL_WIDTH, 'center')
end
