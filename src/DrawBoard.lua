local classes = require("utils/classes")
local DrawBoard = classes.class()

-- Tetromino block class
local TetrominoesCLS = require("src/Tetrominoes")
local _tetrominoes = TetrominoesCLS.new({ a = 1 })

local _loadedSprites
local _shapes

local gridXCount = 10
local gridYCount = 20

local pieceType = 1
local pieceRotation = 1

local pieceX = 3
local pieceY = 0

local timer = 0
local d = 0

local pieceXCount = 4
local pieceYCount = 4

local rate = 1

-- Offset the drawing of player area
local offsetX = 2
local offsetY = 5

local points = 0
Mode = false

-- Constructor
function DrawBoard:init(params)
  print('Draw board invoked!')
  self.a = params.a
end

-- Function that sets up board
function DrawBoard:setupInert()
  -- Initialize
  _loadedSprites = _tetrominoes:loadAssets()
  _shapes = _tetrominoes:shapes()
  timer = 0

  -- Setup empty board
  inert = {}
  for y = 1, gridYCount do
    inert[y] = {}
    for x = 1, gridXCount do
      inert[y][x] = ' '
    end
  end
  
  -- Setup sequence
  _tetrominoes:sequence()
end

-- Function that restrains movement of pieces
function DrawBoard:canPieceMove(testX, testY, testRotation)
  for y = 1, pieceYCount do
    for x = 1, pieceXCount do
      if _shapes[pieceType][testRotation][y][x] ~= ' ' and (
          (testX + x) < 1 -- Checking left
              or (testX + x) > gridXCount -- Checking right
              or (testY + y) > gridYCount -- Checking bottom
              or inert[testY + y][testX + x] ~= ' ' -- Checking the inert
          ) then
        return false
      end
    end
  end

  return true
end

-- General Infinite time mode game loop
function DrawBoard:timer(dt)
  timer = timer + dt
  d = d + dt

  -- Check the game tick rate
  if timer >= rate then
    timer = 0

    -- falling
    local testY = pieceY + 1

    -- Checks whether piece can move
    if DrawBoard:canPieceMove(pieceX, testY, pieceRotation) then
      pieceY = testY
    else

      -- Loop that adds piece to inert
      for y = 1, pieceYCount do
        for x = 1, pieceXCount do
          local block =
          _shapes[pieceType][pieceRotation][y][x]
          if block ~= ' ' then
            inert[pieceY + y][pieceX + x] = block
          end
        end
      end

      -- Loop that checks if any row is connected and can be removed
      for y = 1, gridYCount do
        local complete = true
        for x = 1, gridXCount do
          if inert[y][x] == ' ' then
            complete = false
            break
          end
        end

        if complete then
          for removeY = y, 2, -1 do
            for removeX = 1, gridXCount do
              inert[removeY][removeX] = inert[removeY - 1][removeX]
            end
          end

          for removeX = 1, gridXCount do
            inert[1][removeX] = ' '
            points = points + 10
          end

          rate = rate - 0.02
        end
      end

      newPiece()
      DrawBoard:isGameOver()
    end
  end
end

-- Function that resets the board
function DrawBoard:reset()
  inert = {}
  for y = 1, gridYCount do
    inert[y] = {}
    for x = 1, gridXCount do
      inert[y][x] = ' '
    end
  end
  
  -- Resets the sequence
  _tetrominoes.sequence()

  -- Loads the new piece from sequence
  newPiece()

  timer = 0
  d = 0
end

-- Function that creates a new piece from the sequence
function newPiece()
  -- Setting piece position
  pieceX = 3
  pieceY = 0

  -- New pieces from sequence
  pieceType = table.remove(_tetrominoes:sequence())
  pieceRotation = 1
  if (#_tetrominoes:sequence() == 0) then
    _tetrominoes:sequence()
  end
end

-- Function that checks whether the game is over 
function DrawBoard:isGameOver()
  if not DrawBoard:canPieceMove(pieceX, pieceY, pieceRotation) then
    return false
  end

  return true
end

-- Function that checks for key inputs that is later called in love.keypressed in main
function DrawBoard:keypressed(key)
  -- Rotation
  if key == 'x' then
    local testRotation = pieceRotation + 1
    if testRotation > #_shapes[pieceType] then
      testRotation = 1
    end

    if DrawBoard:canPieceMove(pieceX, pieceY, testRotation) then
      pieceRotation = testRotation
    end

  elseif key == 'z' then
    local testRotation = pieceRotation - 1
    if testRotation < 1 then
      testRotation = #_shapes[pieceType]
    end

    if DrawBoard:canPieceMove(pieceX, pieceY, testRotation) then
      pieceRotation = testRotation
    end

  -- Drop
  elseif key == 'c' then
    while DrawBoard:canPieceMove(pieceX, pieceY + 1, pieceRotation) do
      pieceY = pieceY + 1
    end

  -- Movements
  elseif key == 'left' then
    local testX = pieceX - 1

    if DrawBoard:canPieceMove(testX, pieceY, pieceRotation) then
      pieceX = testX
    end

  elseif key == 'right' then
    local testX = pieceX + 1

    if DrawBoard:canPieceMove(testX, pieceY, pieceRotation) then
      pieceX = testX
    end

  -- Misc controlls  
  elseif key == 'q' then
    gameState = 3
    DrawBoard:reset()
  end
end

-- Function that draw the board
function DrawBoard:drawBoard()

  -- Local function that draws blocks
  local function drawBlocks(block, x, y)
    local blocks = {} -- Declaration and initialization of an empty table to store current block
    
    if not Mode then
      -- Blocks used for normal Infinite mode
      blocks = {
        [' '] = _loadedSprites["indicator"],
        i = _loadedSprites["blue"],
        j = _loadedSprites["green"],
        l = _loadedSprites["light_blue"],
        o = _loadedSprites["orange"],
        s = _loadedSprites["pink"],
        t = _loadedSprites["red"],
        z = _loadedSprites["yellow"],
        preview = _loadedSprites["indicator"],
      }

    else
      -- Blocks used for Blind mode
      blocks = {
        [' '] = _loadedSprites["indicator"],
        i = _loadedSprites["indicator"],
        j = _loadedSprites["indicator"],
        l = _loadedSprites["indicator"],
        o = _loadedSprites["indicator"],
        s = _loadedSprites["indicator"],
        t = _loadedSprites["indicator"],
        z = _loadedSprites["indicator"],
        preview = _loadedSprites["indicator"],
      }
    end

    -- Describing the blocks, later passed as params to love.graphics.rectangle and love.graphics.draw
    local colorBlock = blocks[block]
    local blockSize = 20
    local blockDrawSize = blockSize - 1

    -- If the Mode is false, the play board will be white
    if not Mode then
      love.graphics.rectangle('fill', (x - 1) * blockSize, (y - 1) * blockSize, blockDrawSize, blockDrawSize)
    end

    -- Draws a block within a piece
    love.graphics.draw(colorBlock, (x - 1) * blockSize, (y - 1) * blockSize, 0, .5, .5)
  end

  -- Points and timers
  love.graphics.print("Point: " .. points, love.graphics.getWidth() / 2, 500)
  love.graphics.print("Time: " .. math.ceil(d), love.graphics.getWidth() / 2, 550)

  -- Loop that draws grid matrix
  for y = 1, gridYCount do
    for x = 1, gridXCount do
      drawBlocks(inert[y][x], x + offsetX, y + offsetY)
    end
  end
  
  -- Current falling block
  for y = 1, pieceYCount do
    for x = 1, pieceXCount do
      local block = _shapes[pieceType][pieceRotation][y][x]
      if block ~= ' ' then
        drawBlocks(block, x + pieceX + offsetX, y + pieceY + offsetY)
      end
    end
  end

  -- Preview of next block
  if not Mode then
  for y = 1, pieceYCount do
    for x = 1, pieceXCount do
      local block = _shapes[_tetrominoes:getSequence()[#_tetrominoes:getSequence()]][1][y][x]
      if block ~= ' ' then
        drawBlocks('preview', x + 5, y + 1)
      end
    end
  end
  end
end

return DrawBoard
