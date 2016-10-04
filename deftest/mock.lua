--- Provides the ability to mock any module.

-- @usage
--
-- mock.mock(sys)
--
-- -- specifying return values
-- sys.get_sys_info.returns({my_data})
-- ...
-- local sys_info = sys.get_sys_info() -- will be my_data
-- assert(sys.get_sys_info.calls == 1) -- call counting
-- ...
-- local sys_info = sys.get_sys_info() -- original response as we are now out of mocked answers
-- assert(sys.get_sys_info.calls == 2) -- call counting
-- ...
--
-- -- specifying a replacement function
-- sys.get_sys_info.replace(function () return my_data end)
--
-- ...
-- local sys_info = sys.get_sys_info() -- will be my_data
-- assert(sys.get_sys_info.calls == 3) -- call counting
-- ...
-- local sys_info = sys.get_sys_info() -- will still be my_data
-- assert(sys.get_sys_info.calls == 4) -- call counting
-- ...
--
-- -- cleaning up
-- mock.unmock(sys) -- restore the sys library again

local mock = {}

--- Mock the specified module.
-- Mocking the module extends the functions it contains with the ability to have their logic overridden.
-- @param module module to mock
-- @usage
--
-- -- mock module x
-- mock.mock(x)
--
-- -- make x.f return 1, 2 then the original value
-- x.f.returns({1, 2})
-- print(x.f()) -- prints 1
--
-- -- make x.f return 1 forever
-- x.f.replace(function () return 1 end)
-- while true do print(x.f()) end -- prints 1 forever
--
-- -- counting calls
-- assert(x.f.calls > 0)
--
-- -- return to original state of module x
-- mock.unmock(x)
--
function mock.mock(module)
	for k,v in pairs(module) do
		if type(v) == "function" then
			local mock_fn = {
				calls = 0,
				answers = {},
				repl_fn = nil,
				orig_fn = v,
				params = {}
			}
			function mock_fn.returns(answers)
				mock_fn.answers = answers
			end
			function mock_fn.always_returns(answer)
				mock_fn.repl_fn = function()
					return answer
				end
			end
			function mock_fn.replace(repl_fn)
				mock_fn.repl_fn = repl_fn
			end
			function mock_fn.original(...)
				return mock_fn.orig_fn(...)
			end
			function mock_fn.restore()
				mock_fn.repl_fn = nil
			end
			local mt = {
				__call = function (mock_fn, ...)
					mock_fn.calls = mock_fn.calls + 1
					local arg = {...}

					if #arg > 0 then
						for i=1,#arg do
							mock_fn.params[i] = arg[i]
						end
					end

					if mock_fn.answers[1] then
						local result = mock_fn.answers[1]
						table.remove(mock_fn.answers, 1)
						return result
					elseif mock_fn.repl_fn then
						return mock_fn.repl_fn(...)
					else
						return v(...)
					end
				end
			}
			setmetatable(mock_fn, mt)
			module[k] = mock_fn
		end
	end
end

--- Remove the mocking capabilities from a module.
-- @param module module to remove mocking from
function mock.unmock(module)
	for k,v in pairs(module) do
		if type(v) == "table" then
			if v.orig_fn then
				module[k] = v.orig_fn
			end
		end
	end
end

return mock
