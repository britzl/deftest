return function()
	
	describe("integration tests", function()
		test("should execute wait_tests after a time period", 0.1, function()

			on_wait(function()
				assert_equal(go.get_position("."), vmath.vector3(0, 0, 0))
			end)
		end)

		it("should execute message_tests when a message is received", 10, function()
			before(function()
				msg.post("/echo_mock#echo_mock", "echo test", {text = "test"})
			end)

			on_message("echo", "/echo_mock#echo_mock", function()
				assert_equal(message.text, "test")
			end)
		end)
		
		context("car", function()
			test("should move on input", 0.2, function()
				before(function()
					msg.post("/car1", "right")
				end)

				on_wait(function()
					msg.post("/car1", "stop")
					local pos = go.get_position("/car1")
					assert_less_than(pos.x, 142)
					assert_greater_than(pos.x, 138)
				end)
			end)

			test("should send 'game_over' message when colliding with obstacles", 5, function()
				before(function()
					msg.post("/car2", "set_game_url", {game_url = msg.url()})
					factory.create("/obstacle_factory#obstacle_factory", vmath.vector3(400, 200, 0))
				end)

				on_message("game_over", "/car2#car", function()
					assert(true)
				end)
			end)
		end)
	end)
	
end
