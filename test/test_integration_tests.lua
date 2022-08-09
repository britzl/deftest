return function()
	
	describe("integration tests", function()
		test("should execute wait_tests after a time period", 0.1, function()
			-- Test with the 0.1 seconds time limit.
			on_wait(function()
				-- This function is executed after 0.1 seconds after executing "before".
				assert_equal(go.get_position("."), vmath.vector3(0, 0, 0))
			end)
		end)

		it("should execute message_tests when a message is received", 10, function()
			-- Test with the 10 seconds time limit.
			before(function()
				msg.post("/echo_mock#echo_mock", "echo test", {text = "test"})
			end)

			on_message("echo", "/echo_mock#echo_mock", function()
				-- This function is executed on receiving message with message_id "echo"
				-- from "/echo_mock#echo_mock". If the message is not received in specified time limit,
				-- test fails.
				assert_equal(message.text, "test")
			end)
		end)
		
		context("car", function()
			test("should move on input", 0.2, function()
				-- Test with the 0.2 seconds time limit.
				before(function()
					msg.post("/car1", "right")
				end)

				on_wait(function()
					-- This function is executed after 0.2 seconds after executing "before".
					msg.post("/car1", "stop")
					local pos = go.get_position("/car1")
					assert_less_than(pos.x, 142)
					assert_greater_than(pos.x, 138)
				end)
			end)

			test("should send 'game_over' message when colliding with obstacles", 5, function()
				-- Test with the 5 seconds time limit.
				before(function()
					-- This function can be used to configure game object and make it send needed message.
					-- To get url of the object, which executes that test, you can use msg.url().
					msg.post("/car2", "set_game_url", {game_url = msg.url()})
					factory.create("/obstacle_factory#obstacle_factory", vmath.vector3(400, 200, 0))
				end)

				on_message("game_over", "/car2#car", function()
					-- This function is executed on receiving message with message_id "game_over"
					-- from "/car2#car". If the message is not received in specified time limit,
					-- test fails.
					assert(true)
				end)
			end)
		end)
	end)
	
end
