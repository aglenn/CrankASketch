import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/easing"
gfx = playdate.graphics

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorWhite)

arrow = gfx.sprite:new()
local arrowImage = gfx.image.new('images/arrow')
arrow:setImage(arrowImage)
local w, h = arrow:getSize()
arrow:moveTo(400 - w, 240 - h)
arrow:addSprite()


cursor = gfx.sprite:new()
local cursorImage = gfx.image.new('images/cursor')
cursor:setImage(cursorImage)
cursor:moveTo(200, 120)
cursor:addSprite()


local angle = 0

local b_LeftDown = false
local b_RightDown = false
local b_UpDown = false
local b_DownDown = false
local b_ADown = false
local b_BDown = false

function playdate.leftButtonDown()
  b_LeftDown = true
end

function playdate.rightButtonDown()
	b_RightDown = true
end

function playdate.upButtonDown()
  b_DownDown = true
end
--
function playdate.downButtonDown()
  b_UpDown = true
end

function playdate.AButtonDown()
  b_ADown = true
end

function playdate.BButtonDown()
  b_BDown = true
end

function playdate.leftButtonUp()
  b_LeftDown = false
end

function playdate.rightButtonUp()
  b_RightDown = false
end

function playdate.upButtonUp()
  b_DownDown = false
end
--
function playdate.downButtonUp()
  b_UpDown = false
end

function playdate.AButtonUp()
  b_ADown = false
end

function playdate.BButtonUp()
  b_BDown = false
end

local crank_magnitude = 0
function playdate.cranked(value)
  crank_magnitude += value
  -- get angle vector
  -- scale value for distance
  -- apply draw from current position to new
end

local waveforms = { playdate.sound.kWaveSine,
   playdate.sound.kWaveSquare,
   playdate.sound.kWaveSawtooth,
   playdate.sound.kWaveTriangle,
   playdate.sound.kWaveNoise,
   playdate.sound.kWavePOPhase,
   playdate.sound.kWavePODigital,
   playdate.sound.kWavePOVosim}
local waveIndex = 1
runningSequence = playdate.sound.sequence.new('music/runningloop.mid')
for index=1,runningSequence:getTrackCount() do
  local synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
  track = runningSequence:getTrackAtIndex(index)
  track:setInstrument(synth)
end
-- print("track instrument "..track:getInstrument())
print("sequence length: "..runningSequence:getLength().." tempo "..runningSequence:getTempo().." tracks "..runningSequence:getTrackCount())
function complete()
  print("sequence complete")
end
runningSequence:setTempo(600)
runningSequence:setLoops(0, runningSequence:getLength(), 0)
runningSequence:play(complete)


segments = {}
function playdate.update()

  dt = 1/20  
  
  if b_UpDown and b_RightDown then
    angle = 45
  elseif b_RightDown and b_DownDown then
    angle = 135
  elseif b_DownDown and b_LeftDown then
    angle = 225
  elseif b_LeftDown and b_UpDown then
    angle = 315
  elseif b_UpDown then
    angle = 0
  elseif b_RightDown then
    angle = 90
  elseif b_DownDown then
    angle = 180
  elseif b_LeftDown then
    angle = 270
  end
  
  if b_ADown then
    angle -= 5
  end
  
  if b_BDown then
    angle += 5
  end
  
  local cursor_x, cursor_y = cursor:getPosition()
  local cursor_vec = playdate.geometry.vector2D.new(cursor_x, cursor_y)
  
  -- get angle vector
  local move_x = math.sin(angle * math.pi / 180)
  local move_y = math.cos(angle * math.pi / 180)
  local move_vec = playdate.geometry.vector2D.new(move_x, move_y)
  -- scale value for distance
  move_vec = move_vec:scaledBy(crank_magnitude / 2)
  -- print("Move "..move_vec.x.." "..move_vec.y.." mag "..crank_magnitude)
  crank_magnitude = 0
  cursor_vec += move_vec
  
  if cursor_vec.x > 400 then
    cursor_vec.x = 400
  elseif (cursor.x < 0) then
    cursor_vec.x = 0
  end
  
  if cursor_vec.y > 240 then
    cursor_vec.y = 240
  elseif (cursor_vec.y < 0) then
    cursor_vec.y = 0
  end
  cursor:moveTo(cursor_vec.x, cursor_vec.y)
  
  if move_vec.x ~= 0.0 or move_vec.y ~= 0.0 then
    -- print("draw from "..cursor_x..", "..cursor_y.." to "..cursor.x..", "..cursor.y)
    table.insert(segments, playdate.geometry.lineSegment.new(cursor_x, cursor_y, cursor_vec.x, cursor_vec.y))
  end

  arrow:setRotation(angle)
  gfx.sprite.update()
  
  gfx.setColor(gfx.kColorBlack)
  gfx.setLineWidth(2)
  for _, segment in ipairs(segments) do
    gfx.drawLine(segment)
  end

end
