-- Module that stores integration tests.

local C = {}

C.tests = {} -- Integration tests.
C.processed_tests = {} -- Tests with data, which is gathered after simulation.

function C.add_test(test_name, test)
	test_struct = {}
	test_struct.test = test
	C.tests[test_name] = test_struct
end

function C.add_processed_test(test_name, test)
	C.processed_tests[test_name] = test
end

-- Function that creates integration test that triggers when messege is received.
-- TODO - change for telescope-like syntax.
function message_test(name, before, message_id, sender, after, max_time)
	local test = {}
	test.type = "message"
	test.before = before
	test.message_id = message_id
	test.sender = sender
	test.after = after
	test.max_time = max_time
	return test
end

-- Function that creates integration test that triggers after a given time.
-- TODO - change for telescope-like syntax.
function wait_test(name, before, after, max_time)
	local test = {}
	test.type = "wait"
	test.before = before
	test.after = after
	test.max_time = max_time
	return test
end

return C