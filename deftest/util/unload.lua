local M = {}

function M.unload(pattern)
	for name,_ in pairs(package.loaded) do
		if name:match(pattern) then
			package.loaded[name] = nil
		end
	end
end

return setmetatable(M, {
	__call = function(t, ...)
		M.unload(...)
	end
})
