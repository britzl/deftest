return function()
	local unload = require "deftest.util.unload"

	
	describe("unload.lua", function()
		before(function()
		end)

		after(function()
		end)

		it("should remove specific modules from loaded packages", function()
			local unload1_module_a = require "test.data.unload1.module_a"
			local unload1_module_b = require "test.data.unload1.module_b"
			local unload2_module_a = require "test.data.unload2.module_a"
			local unload2_module_b = require "test.data.unload2.module_b"
			unload1_module_a.foo = "foo1a"
			unload1_module_b.foo = "foo1b"
			unload2_module_a.foo = "foo2a"
			unload2_module_b.foo = "foo2b"
			
			unload("^test.data.unload1.*")
			unload1_module_a = require "test.data.unload1.module_a"
			unload1_module_b = require "test.data.unload1.module_b"
			unload2_module_a = require "test.data.unload2.module_a"
			unload2_module_b = require "test.data.unload2.module_b"

			assert(not unload1_module_a.foo)
			assert(not unload1_module_b.foo)
			assert(unload2_module_a.foo == "foo2a")
			assert(unload2_module_b.foo == "foo2b")
		end)
	end)
end
