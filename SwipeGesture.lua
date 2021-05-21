SwipeGesture = class()

local DEFAULT_GESTURE_TTL = 0.74 -- just seems like the most natural

SW_RIGHT = 'RIGHT'
SW_UP = 'UP'
SW_LEFT = 'LEFT'
SW_DOWN = 'DOWN'
SW_UNKNOWN = 'UNKNOWN'

function SwipeGesture:init(opt)
    -- you can accept and set parameters here
    opt = opt or {}
    self.gTTL = opt.gTTL or DEFAULT_GESTURE_TTL
    self.multiTouch = opt.multiTouch or 1
    self.touches = {}
    self.sumOfTouches = 0
    self.lastCaptured = {}
    self.listeners = {}
end

function SwipeGesture:addListener(cb)
    table.insert(self.listeners, cb)
    return #self.listeners
end

function SwipeGesture:removeListener(pos)
    table.remove(self.listeners, pos)
end

function SwipeGesture:capture(touchData)
    local sx, sy = touchData.start:unpack()
    local ex, ey = touchData['end']:unpack()
    local x, y = ex - sx, ey - sy
    if x + y == 0 then
        return
    end
    
    local angle = math.deg(math.atan2(y, x))
    local angleS = angle > 0 and angle or (180 + (180 + (angle)))
    local direction = SW_UNKNOWN
    if angle >= -45.5 and angle <= 45.5 then
        direction = SW_RIGHT
    elseif angle > 45.5 and angle <= 135.5 then
        direction = SW_UP
    elseif (angle > 135.5 and angle <= 180) or (angle < -135.5 and angle >= -180) then
        direction = SW_LEFT
    elseif (angle < -45.5 and angle >= -135.5) then
        direction = SW_DOWN
    end
    
    table.insert(self.lastCaptured, string.format('%s\n', direction))
    for i, cb in ipairs(self.listeners) do
        cb(direction, touchData)
    end
end

-- unlike other update meyhods, this one is called within the touched method
function SwipeGesture:update(time)
    --
    -- defines keys to remove
    local keysToRemove = {}
    -- loop touches
    for i, t in pairs(self.touches) do
        if t.ttl < time then
            -- cancel touch if didn't end in desired timeframe
            table.insert(keysToRemove, i)
            self.sumOfTouches = self.sumOfTouches - 1
            print('aborting ', i)
        end
    end
    for _, key in pairs(keysToRemove) do
        self.touches[key] = nil
    end
    
    if #self.lastCaptured > 5 then
        table.remove(self.lastCaptured, 1)
    end
end

-- not necessarily needed, can be used by running program to call the update method
-- and to debug draw the touches/results
function SwipeGesture:draw()
    pushMatrix() pushStyle()
    strokeWidth(1)
    stroke(242, 76, 19)
    
    -- loop debug touches
    for i, t in pairs(self.touches) do
        line(t.start.x, t.start.y, t["end"].x, t["end"].y)
    end
    
    -- print last caputred results in mid of screen
    translate(WIDTH // 2, ( HEIGHT // 2 ) + ( #self.lastCaptured * 20 / 2 ) )
    for i, txt in ipairs(self.lastCaptured) do    
        text(txt, 0, #self.lastCaptured - ( i * 20))
    end
    popMatrix() popStyle()
end

function SwipeGesture:touchBegan(touch, time)
    -- insert new touch if touch id doesn't exist and if multiTouchAllows it
    if self.touches[touch.id] == nil and self.sumOfTouches < self.multiTouch then
        self.touches[touch.id] = {
            id = touch.id,
            start = vec2(touch.x, touch.y),
            ["end"] = vec2(touch.x, touch.y),
            ttl = time + self.gTTL,
        }
        self.sumOfTouches = (self.sumOfTouches or 0) + 1
        return true
    end
    if self.multiTouch == 0 and not self.disabled then
        print('WARN: SwipeGesture.multiTouch, this effectively disables the gestures, use SwipeGesture.disabled = true instead')
    end
    return false
end

function SwipeGesture:touchChanged(touch)
    if self.touches[touch.id] then
        self.touches[touch.id]["end"] = vec2(touch.x, touch.y)
        return true
    end
    return false
end

function SwipeGesture:touchEnded(touch)
    if self.touches[touch.id] then
        local t = self.touches[touch.id]
        self.touches[touch.id] = nil
        self.sumOfTouches = (self.sumOfTouches or 1) - 1
        self:capture(t)
        return true
    end
    return false
end

-- optional time as second param for testing purposes mainly
function SwipeGesture:touched(touch, time)
    time = time or ElapsedTime
    self:update(time)
    -- return diectly if disabled
    if self.disabled then
        return false
    end
    
    if touch.state == BEGAN then
        return self:touchBegan(touch, time)
    elseif touch.state == CHANGED then
        return self:touchChanged(touch)
    elseif touch.state == ENDED then
        return self:touchEnded(touch)
    end
end
