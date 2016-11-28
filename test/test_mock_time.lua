return function()
	local mock_time = require "deftest.mock.time"
	
	describe("mock.time", function()
		before(function()
			mock_time.mock()
		end)
		
		after(function()
			mock_time.unmock()
		end)
		
		local function wait(time)
			go.cancel_animations(".", "position.z")
			local co = coroutine.running()
			go.animate(".", "position.z", go.PLAYBACK_ONCE_FORWARD, go.get_position().z, go.EASING_LINEAR, time, 0, function()
				coroutine.resume(co)
			end)
			coroutine.yield()
		end

		it("should not advance time automatically", function()
			local socket_gettime = socket.gettime()
			local os_time = os.time()
			local os_date = os.date()
			
			wait(1.5)
			
			assert(socket.gettime() == socket_gettime)
			assert(os.time() == os_time)
			assert(os.date() == os_date)
		end)
		
		it("should be able to set the time manually", function()
			mock_time.set(100.99)
			assert(socket.gettime() == 100.99)
			assert(os.time() == 100)
			assert(os.date() == os.date.original(nil, 100.99))
		end)
		
		it("should be able to elapse time manually", function()
			mock_time.set(100)
			assert(socket.gettime() == 100)
			assert(os.time() == 100)
			assert(os.date() == os.date.original(nil, 100))
			
			mock_time.elapse(2.99)
			assert(socket.gettime() == 102.99)
			assert(os.time() == 102)
			assert(os.date() == os.date.original(nil, 102.99))
		end)
	end)
end
