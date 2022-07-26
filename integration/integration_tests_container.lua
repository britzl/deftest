-- Module that stores integration tests.

local C = {}

local current_index = 0
C.context_table = {}

function C.add_test(test)
	test.parent = current_index
	table.insert(C.context_table, test)
	test.index = #(C.context_table)
end

function C.add_processed_test(test_index, test)
	C.context_table[test_index].processed_test = test
end

function C.get_processed_tests_group()
	for index, context in pairs(C.context_table) do
		if context.context then
			context.children = {}
		end
	end
	local root = {name = "integration_tests", children = {}, context = true}
	for index, context in pairs(C.context_table) do
		if context.parent == 0 then
			table.insert(root.children, context)
		else
			table.insert(C.context_table[context.parent].children, context)
		end
	end
	local function get_unit_test(current_context)
		print(current_context)
		if current_context.context then
			print(current_context.name)
			context(current_context.name, function()
				for index, next_context in pairs(current_context.children) do
					get_unit_test(next_context)
				end
			end)
		else 
			test(current_context.name, current_context.processed_test)
		end
	end
	return function()
		local env = {}
		setmetatable(env, {__index = _G})
		env["test"] = test
		env["context"] = context
		setfenv(get_unit_test, env)(root)
	end
end

-- Function that creates a group of integration tests.
function C.integration_context(name, func)
	table.insert(C.context_table, {parent = current_index, name = name, context = true})
	local previous_index = current_index
	current_index = #(C.context_table)
	func()
	current_index = previous_index
end

-- Function that creates integration test that triggers when messege is received.
function C.message_test(name, before, message_id, sender, after, max_time)
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
function C.wait_test(name, before, after, max_time)
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