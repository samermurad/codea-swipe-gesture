-- SwipeGestures

function setup()
    sg = SwipeGesture()
    parameter.number('touchTTL', 0.1, 2, 0.76, function(ttl)
        sg.gTTL = ttl
    end)
    parameter.watch('#sg.touches')
    sg:addListener(function(dir)
        print(dir)
    end)
end

function draw()
    background(40, 40, 50)
    -- uncomment to debug draw swipes
    --sg:draw()
    
end

function touched(touch)
    sg:touched(touch)
end
