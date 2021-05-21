function testQuadDirectionalSwipes()
    if not sg then
        sg = SwipeGesture()
    end
    CodeaUnit.detailed = true
    _:describe('Quad Directional Swipes', function()
        _:before(function()
            result = SW_UNKNOWN
            listenerId = sg:addListener(function(dir)
                    result = dir
            end)
        end)
        _:after(function()
            sg:removeListener(listenerId)
        end)
        
        _:test('(100, 0) Swipes Right', function()
            sg:touched({ x = 0, y = 0, state = BEGAN, id = 1 })
            sg:touched({ x = 100, y = 0, state = CHANGED, id = 1 })
            sg:touched({ x = 0, y = 0, state = ENDED, id  = 1 })
            _:expect(result).is(SW_RIGHT)
        end)
        _:test('(-100, 0) Swipes Left', function()
            sg:touched({ x = 0, y = 0, state = BEGAN, id = 1 })
            sg:touched({ x = -100, y = 0, state = CHANGED, id = 1 })
            sg:touched({ x = 0, y = 0, state = ENDED, id  = 1 })
            _:expect(result).is(SW_LEFT)
        end)
        _:test('(0, 100) Swipes Up', function()
            sg:touched({ x = 0, y = 0, state = BEGAN, id = 1 })
            sg:touched({ x = 0, y = 100, state = CHANGED, id = 1 })
            sg:touched({ x = 0, y = 0, state = ENDED, id  = 1 })
            _:expect(result).is(SW_UP)
        end)
        _:test('(-100, 0) Swipes Down', function()
            sg:touched({ x = 0, y = 0, state = BEGAN, id = 1 })
            sg:touched({ x = 0, y = -100, state = CHANGED, id = 1 })
            sg:touched({ x = 0, y = 0, state = ENDED, id  = 1 })
            _:expect(result).is(SW_DOWN)
        end)
        
        _:test('Expiring touches are aborted', function()
            sg:touched({ x = 0, y = 0, state = BEGAN, id = 1 }, 0 )
            sg:touched({ x = 0, y = -100, state = CHANGED, id = 1 }, 1)
            sg:touched({ x = 0, y = 0, state = ENDED, id  = 1 }, 2)
            _:expect(result).is(SW_UNKNOWN)
        end)
    end)
end
