
--Start of Global Scope---------------------------------------------------------

-- Create and configure camera
local camera = Image.Provider.Camera.create()

local config = Image.Provider.Camera.V2DConfig.create()
config:setBurstLength(1) -- Single image
config:setShutterTime(700) -- us
config:setStartSource('DI1', 'ON_ACTIVE') -- Trigger

camera:setConfig(config)

-- Create viewer
local viewer = View.create()

local t = 1000 -- ms delay to symbolize processing time

local tic
local toc
local previousTic

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  camera:enable()
  -- Init timer value
  tic = DateTime.getTimestamp()
end
Script.register('Engine.OnStarted', main)

local function processImage(im, sensorData)
  previousTic = tic -- To remember timer value from previous acquisition
  tic = DateTime.getTimestamp()
  viewer:clear()
  viewer:addImage(im)
  viewer:present()

  -- Image processing
  Script.sleep(t) -- Dummy processing

  -- Timing
  toc = DateTime.getTimestamp()
  local processingTime = toc - tic
  local cycleTime = tic - previousTic
  print('Timestamp (ms) = ' .. sensorData:getTimestamp())
  print('Processing time (ms) = ' .. processingTime)
  print('Cycle time (ms) = ' .. cycleTime)

  -- Image queue usage
  local poolSize = Image.Provider.Camera.V2DStatus.getMaxImagePoolSize()
  local freeImages = Image.Provider.Camera.V2DStatus.getNumFreeImagesInPool()
  print('Number of queued images = ' .. (poolSize - freeImages))
  print('Number of free images = ' .. freeImages)
  print('-----------------------------')
end

camera:register('OnNewImage', processImage)

--End of Function and Event Scope--------------------------------------------------
