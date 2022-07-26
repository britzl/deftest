return function()
	integration_context("context", function()
		integration_context("nested integration context", function()
			wait_test("should execute wait_tests after a time period", function() end, function()
				return function()
					assert(go.get_position(".") == vmath.vector3(0, 0, 0))
				end 
			end, 1)

			message_test("should execute message_tests when a message is received", function()
				msg.post("/echo_mock#echo_mock", "echo test", {text = "test"})
			end, "echo", "/echo_mock#echo_mock", function(message)
				return function()
					assert(message.text == "test")
				end 
			end, 10)
		end)
	end)
end
