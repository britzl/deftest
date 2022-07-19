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

return C