local M = {}

-- compare two values.
-- if they are tables, then compare their keys and fields recursively.
-- Source: https://github.com/stevedonovan/Penlight/blob/master/lua/pl/tablex.lua
local deepcompare
deepcompare = function(t1, t2, ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)

	if ty1 ~= ty2 then
		return false
	end

	-- non-table types can be directly compared
	if ty1 ~= 'table' then
		return t1 == t2
	end

	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1 in pairs(t1) do
		if t2[k1]==nil then
			return false
		end
	end
	for k2 in pairs(t2) do
		if t1[k2]==nil then
			return false
		end
	end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if not deepcompare(v1,v2,ignore_mt) then
			return false
		end
	end

	return true
end

function M.same(a, ...)
	local args = { ... }
	for _,arg in ipairs(args) do
		if not deepcompare(a, arg) then
			return false, ("Expected values '%s' and '%s' to be the same"):format(tostring(a), tostring(arg))
		end
	end
	return true
end

function M.unique(...)
	local args = { ... }
	for i,arg_to_compare in ipairs(args) do
		for j,arg in pairs(args) do
			if i ~= j then
				if deepcompare(arg_to_compare, arg) then
					return false, ("Expected values '%s' and '%s' to not be the same"):format(tostring(arg_to_compare), tostring(arg))
				end
			end
		end
	end
	return true
end

function M.equal(...)
	-- NOTE: {...} strips away nil values
	local args = { ... }
	-- length includes nil values
	local length = select("#", ...)
	for i = 1, length do
		for j = 1, length do
			if i ~= j then
				if args[i] ~= args[j] then
					return false, ("Expected values '%s' and '%s' to be equal (using equality operator)"):format(args[i], args[j])
				end
			end
		end
	end
	return true
end


return M