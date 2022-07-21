-- Module that stores integration tests.

local C = {}

C.tests = {} -- Integration tests.
C.processed_tests = {} -- Tests with data, which is gathered after simulation.

function C.add_test(test)
	C.tests[test.name] = test
end

function C.add_processed_test(test_name, test)
	C.processed_tests[test_name] = test
end

function C.get_processed_tests_group()
	return function()
		context("integration tests", function() 
			for test_name, processed_test in pairs(C.processed_tests) do
				test(test_name, processed_test)
			end
		end)
	end
end

-- Function that creates integration test that triggers when messege is received.
-- TODO - change for telescope-like syntax.
function message_test(name, before, message_id, sender, after, max_time)
	local test = {}
	test.name = name
	test.type = "message"
	test.before = before
	test.message_id = message_id
	test.sender = sender
	test.after = after
	test.max_time = max_time
	C.add_test(test)
	return test
end

-- Function that creates integration test that triggers after a given time.
-- TODO - change for telescope-like syntax.
function wait_test(name, before, after, max_time)
	local test = {}
	test.name = name
	test.type = "wait"
	test.before = before
	test.after = after
	test.max_time = max_time
	C.add_test(test)
	return test
end

return C