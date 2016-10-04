return function()
	describe("vmath", function()
		before(function()
			print("I'm run before each vmath test")
		end)
		
		after(function()
			print("I'm run after each vmath test")
		end)
		
		test("Add two vectors", function()
			local v1 = vmath.vector3(2, 3, 4)
			local v2 = vmath.vector3(5, 6, 7)
			local res = v1 + v2
			assert(res.x == 7 and res.y == 9 and res.z == 11)
		end)
	end)
end
