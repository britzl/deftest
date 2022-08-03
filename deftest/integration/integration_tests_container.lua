-- Module that stores integration tests.

local telescope = require "deftest.telescope"

local C = {}

C.context_table = {}

function C.add_processed_test(test_index, test)
	C.context_table[test_index].processed_test = test
end

function C.get_processed_tests_group()
	for index, context in pairs(C.context_table) do
		if context.context then
			context.children = {}
		end
	end
	local root = {name = "integration_tests", children = {}, context = true, parent = -1}
	for index, context in pairs(C.context_table) do
		if context.parent == 0 then
			table.insert(root.children, context)
		else
			table.insert(C.context_table[context.parent].children, context)
		end
	end
	local function get_unit_test(current_context)
		if current_context.parent == -1 then
			for index, next_context in pairs(current_context.children) do
				get_unit_test(next_context)
			end			
		elseif current_context.context then
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

function C.add_integration(args)
	local current_index = 0
	local current_test = {}

	-- Function that creates a group of integration tests.
	local function integration_context(name, func)
		table.insert(C.context_table, {parent = current_index, name = name, context = true})
		local previous_index = current_index
		current_index = #(C.context_table)
		func()
		current_index = previous_index
	end

	-- Function that create integration test.
	local function integration_test(name, max_time, func)
		local test = {}
		test.name = name
		test.max_time = max_time
		test.parent = current_index
		test.before = function() end
		test.after = function() end

		table.insert(C.context_table, test)
		test.index = #(C.context_table)
		current_test = test
		func()
	end

	-- Function that adds before function to a test.
	local function integration_before(func)
		current_test.before = func
	end

	-- Function that adds a function, which is executed after waiting.
	local function on_wait(func)
		current_test.type = "wait"
		current_test.after = func
	end

	-- Function that adds a function, which is executed after receiving a message.
	local function on_message(message_id, sender, func)
		current_test.type = "message"
		current_test.message_id = message_id
		current_test.sender = sender
		current_test.after = func
	end
	
	local env = {}
	setmetatable(env, {__index = _G})
	for _, alias in pairs(telescope.context_aliases) do
		env[alias] = integration_context
	end
	for _, alias in pairs(telescope.test_aliases) do
		env[alias] = integration_test
	end
	for _, alias in pairs(telescope.before_aliases) do
		env[alias] = integration_before
	end
	env["on_message"] = on_message
	env["on_wait"] = on_wait
	for _,test in ipairs(args) do
		setfenv(test, env)()
	end
end

return C