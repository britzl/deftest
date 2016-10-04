local telescope = require "deftest.telescope"

local M = {}


function M.test(...)
	local args = {...}

	local co = coroutine.create(function()
		local contexts = {}
		for _,test in ipairs(args) do
			telescope.load_contexts(test, contexts)
		end
	
		local callbacks = {}
		local test_pattern = nil
		local results = telescope.run(contexts, callbacks, test_pattern)
		local summary, data = telescope.summary_report(contexts, results)
		local test_report = telescope.test_report(contexts, results)
		local error_report = telescope.error_report(contexts, results)
		print(summary)
		print(test_report)
		print(error_report)
	
		for _, v in pairs(results) do
			if v.status_code == telescope.status_codes.err or
				v.status_code == telescope.status_codes.fail then
				os.exit(1)
			end
		end
		os.exit(0)
	end)
	
	local ok, message = coroutine.resume(co)
	if not ok then
		print("Something went wrong while running tests", message)
		os.exit(1)
	end
end


return M