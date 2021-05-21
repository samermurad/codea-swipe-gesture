# SwipeGestures.codea

A very basic implementation of a swipe gesture.

Uses timestamps and ttls marks to decide whether a swipe has been made or not.
I tried to follow a very simple heuristic, if the user didn't begin, change and ended his finger
movemoment in the specified time frame (0.76 seconds by default), the swipe is cancelled, and not event
is triggered.
However, upon performing a successfull swipe like movement, the SwipeGesture calculates the angle
of the startTouch and movingTouch, which is then turned into a direction, ergo the swipe.

Techincally supported multi-touch, although hasn't been thoroughly tested.



### Usage

```lua

function setup()
    sw = SwipeGesture()
    
    local swId = sw:addListener(
        function(dir)
            print(dir) -- LEFT/RIGHT/UP/DOWN
        end
    )
    
    -- on teardown
    sw:removeListener(swId)
end


function touched(touch)
    sw:touched(touch)
end

```