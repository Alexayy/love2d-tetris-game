-- require("mobdebug").start()

local DrawBoardCLS = require("/src/DrawBoard")
local _drawBoard = DrawBoardCLS.new({a = false})

local GameOverScreenCLS = require("/src/screens/GameOverScreen")
local _gameOverScreen = GameOverScreenCLS.new({a = 1})

local MainMenuScreenCLS = require("/src/screens/MainMenuScreen")
local _mainMenuScreen = MainMenuScreenCLS.new({a = 1})

gameFont = love.graphics.newFont( 40 )

-- Current game state: 1 - Main Screen, 2 - Game play loop, 3 - End Screen
gameState = 1 

function love.load()
    gameState = 1
    music = love.audio.newSource("/Assets/tetris_bg_loop.ogg", "static")
    music:setLooping(true)
    music:play()
    _drawBoard:setupInert()
end

function love.draw()
    if gameState == 1 then
        _mainMenuScreen:drawMainMenuScreen(gameFont)
    elseif gameState == 2 then
        _drawBoard:drawBoard()
    elseif gameState == 3 then
        _gameOverScreen:drawGameOverScreen()
    end 
end

function love.update(dt)
    if _drawBoard:isGameOver() and gameState == 2 then
        _drawBoard:timer(dt)
    elseif gameState ~= 1 then
        gameState = 3
    end
end

function love.keypressed(key)
    if gameState == 1 and key == 'p' then
        Mode = false
        gameState = 2
        
    elseif gameState == 1 and key == 'o' then
        Mode = true
        gameState = 2
        
    elseif gameState == 2 then
        _drawBoard:keypressed(key)

    elseif gameState == 2 and _drawBoard:isGameOver() then
        gameState = 3
        _drawBoard:reset()

    elseif gameState == 3 and key == 'p' then
        Mode = false
        _drawBoard:reset()
        gameState = 2

    elseif gameState == 3 and key == 'o' then
        Mode = true
        _drawBoard:reset()
        gameState = 2

    elseif key == 'escape' then
        love.event.quit()
    end
end
