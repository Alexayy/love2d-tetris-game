local classes = require("utils/classes")
local MainMenuScreen = classes.class()

-- Constructror
function MainMenuScreen:init(params)
    print('Game over screen invoked!')
    self.a = params.a
end

-- Function that draws main menu screen
function MainMenuScreen:drawMainMenuScreen(gameFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gameFont)
    love.graphics.printf("Press 'P' to Play infinite or 'O' to play puzzle! Controls are: arrow keys for left and right, 'Z' and 'X' for rotation and 'Q' for reset! Press 'ESC' to quit! :D", 0, 250, love.graphics.getWidth(), "center")
end

return MainMenuScreen
