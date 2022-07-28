return function()
	context("integration context", function()
		context("nested integration context", function()
			test("should execute wait_tests after a time period", 0.1, function()
				before(function()
					
				end)
				
				on_wait(function()
					assert(go.get_position(".") == vmath.vector3(0, 0, 0))
				end)
			end)

			test("should execute message_tests when a message is received", 10, function()
				before(function()
					msg.post("/echo_mock#echo_mock", "echo test", {text = "test"})
				end)

				on_message("echo", "/echo_mock#echo_mock", function()
					assert(message.text == "test")
				end)
			end)
		end)
	end)
end
