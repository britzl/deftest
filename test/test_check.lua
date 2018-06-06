local check = require "deftest.util.check"

return function()

	describe("check", function()
		test("it should be able to check that all items are the same", function()
			assert(check.same(123, 123, 123, 123))
			assert(not check.same(123, 456))
			assert(not check.same(123, "123"))

			assert(check.same({ 1, 2, 3 }, { 1, 2, 3 }))
			assert(not check.same({ 1, 2, 3 }, { 3, 2, 1 }))

			assert_same(123, 123, 123, 123)
			assert_same({ 1, 2, 3 }, { 1, 2, 3 })
		end)

		test("it should be able to check that all items are unique", function()
			assert(check.unique(1, 2, 3, 4))
			assert(not check.unique(1, 2, 3, 1))
			assert(check.unique(1, 2, 3, "1"))
						
			assert(check.unique({ 1, 2, 3 }, { 3, 2, 1 }))
			assert(not check.unique({ 1, 2, 3 }, { 1, 2, 3 }))

			assert_unique(1, 2, 3, 4)
			assert_unique({ 1, 2, 3 }, { 3, 2, 1 })
		end)

		test("it should be able to check that all items are equal", function()
			assert(check.equal(1, 1, 1))
			assert(not check.equal(1, 1, 2))
			assert(not check.equal(1, 1, "1"))
			
			local t1 = { 1, 2, 3 }
			local t2 = { 1, 2, 3 }
			assert(check.equal(t1, t1))
			assert(not check.equal(t1, t2))

			assert_equal(1, 1, 1)
			assert_equal(t1, t1)
		end)
	end)
end