local classes = require("utils/classes")
local GameOverScreen = classes.class()

-- constructor
function GameOverScreen:init(params)
    print('Game over screen invoked!')
    self.a = params.a
end

-- Function that draws game over screen
function GameOverScreen:drawGameOverScreen() 
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER! Press 'P' to play infinite or 'O' to play BLIND MODE! Or press 'ESC' to quit the game! :D", 0, 250, love.graphics.getWidth(), "center")
end

return GameOverScreen