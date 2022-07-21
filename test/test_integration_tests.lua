return function()
	wait_test("should execute tests with the type 'wait' after a time period", function() end, function()
		return function()
			assert(true)
		end 
	end, 1)
end