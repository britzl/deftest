return function()
	-- here we use the fact that all tests are run in a courotine to pause the
	-- entire test until we get a response
	local function http_request(url, method, headers, post_data, options)
		local co = coroutine.running()
		http.request(url, method, function(self, id, response)
			coroutine.resume(co, id, response)
		end, headers or {}, post_data or nil, options or {})
		return coroutine.yield()
	end

	describe("http", function()
		test("http.request should return a response and status code", function()
			local id, response = http_request("https://www.defold.com", "GET", nil, nil, nil, { timeout = 1 })
			assert(response)
			assert(response.status)
			assert(response.response)
			assert(response.headers)
		end)
	end)
end