return function()
	local mock_fs = require "deftest.mock.fs"
	
	describe("mock.fs", function()
		before(function()
			mock_fs.mock()
		end)
		
		after(function()
			mock_fs.unmock()
		end)

		it("should not write to actual files on disk", function()
			mock_fs.mock()
			local function read(filename)
				local f = io.open(filename, "rb")
				if not f then
					return nil
				end
				local d = f:read("*a")
				f:close()
				return d
			end
			
			local function is_empty(filename)
				local d = read(filename)
				return not d or d == ""
			end
						
			mock_fs.unmock()

			local filename1 = os.tmpname()
			local filename2 = os.tmpname()
			os.remove(filename1)
			os.remove(filename2)
			
			assert(is_empty(filename1), "Expected first file to be empty")
			assert(is_empty(filename2), "Expected second file to be empty")
			
			mock_fs.mock()
			
			sys.save(filename1, { foo = "bar" })
			local f = io.open(filename2, "w")
			f:write("foobar")
			f:close()
			
			mock_fs.unmock()
			
			assert(is_empty(filename1), "Expected first file to be empty after writing to it while fs is mocked")
			assert(is_empty(filename2), "Expected second file to be empty after writing to it while fs is mocked")
		end)
		
		it("should mock sys.*", function()
			--mock_fs.unmock()
			sys.save("filename1", { foo = "bar" })
			local t = sys.load("filename1")
			assert(t.foo == "bar")
		end)
		
		context("Mocked io.* functions", function()
		
			it("should not create any files until they are written to", function()
				--mock_fs.unmock()
				local f = io.open("ihopethisfiledoesnotexist" .. tostring(os.time()), "r")
				assert(not f)
			end)
			
			it("should allow the creation of a temporary file and it should be created automatically", function()
				--mock_fs.unmock()
				local f = io.open(os.tmpname(), "r")
				assert(f)
			end)
			
			it("should have a function to check if a file is open or closed", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				assert(io.type(f) == "file")
				f:close()
				assert(io.type(f) == "closed file")
			end)
			
			it("should be able to read from and write to files", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("foobar")
				f:close()
				
				local f = io.open(filename, "r")
				local d = f:read("*a")
				f:close()
				assert(d == "foobar")
			end)
			
			it("should be able to append to files", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("foobar")
				f:close()
				
				local f = io.open(filename, "a")
				f:write("foobar")
				f:close()
	
				local f = io.open(filename, "r")
				local d = f:read("*a")
				f:close()
				assert(d == "foobarfoobar")
			end)
			
			it("should only write to the end of the file in append update mode (a+) ", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("foobar")
				f:close()
				
				local f = io.open(filename, "a+")
				f:seek("set", 3)	-- this will have no effect on the write below
				f:write("foobar")
				assert(f:seek("cur") == 12)
				f:close()
	
				local f = io.open(filename, "r")
				local d = f:read("*a")
				f:close()
				assert(d == "foobarfoobar", d)
			end)
			
			it("should be able to read line by line from a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("line1\nline2\nline3\n")
				f:close()
				
				local f = io.open(filename, "r")
				assert(f:read("*l") == "line1")
				assert(f:read("*l") == "line2")
				assert(f:read("*l") == "line3")
				assert(f:read("*l") == nil)
			end)
			
			it("should be able to read a certain number of characters from a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("abcde")
				f:close()	
				
				local f = io.open(filename, "r")
				assert(f:read(2) == "ab")
				assert(f:read(2) == "cd")
				assert(f:read(2) == "e")
				assert(f:read(2) == nil)
			end)
			
			it("should be able to read a number from a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("12a34.56b-78c-90.12d")
				f:close()
				
				local f = io.open(filename, "r")
				assert(f:read("*n") == 12)
				assert(f:read(1) == "a")
				assert(f:read("*n") == 34.56)
				assert(f:read(1) == "b")
				assert(f:read("*n") == -78)
				assert(f:read(1) == "c")
				assert(f:read("*n") == -90.12)
				assert(f:read(1) == "d")
				assert(f:read("*n") == nil)
			end)
			
			it("should be able to read lines from a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("line1\nline2\nline3\n")
				f:close()
				
				local f = io.open(filename, "r")
				local lines = {}
				for line in f:lines() do
					lines[#lines + 1] = line
				end
				assert(#lines == 3)
				assert(lines[1] == "line1")
				assert(lines[2] == "line2")
				assert(lines[3] == "line3")
			end)

			it("should be able to read multiple values in one call to io.read()", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				f:write("abcline1\n123line3\nline4\n")
				f:close()
	
				local f = io.open(filename, "r")
				local r1, r2, r3, r4 = f:read(3, "*l", "*n", "*a")
				assert(r1 == "abc")
				assert(r2 == "line1")
				assert(r3 == 123)
				assert(r4 == "line3\nline4\n")
			end)

			it("should be able to write multiple values to a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				assert(f:write("ab", "cd", "ef"))
				f:close()
				
				local f = io.open(filename, "r")
				assert(f:read("*a") == "abcdef")
			end)

			it("should not be able to write in read mode", function()
				local f = io.open(os.tmpname(), "r")
				local ok, err = f:write("abc")
				assert(not ok and err)
			end)

			it("should not be able to read in write mode", function()
				local f = io.open(os.tmpname(), "w")
				local s, err = f:read()
				assert(not s and err)
			end)

			it("should not be able to read in append mode", function()
				local f = io.open(os.tmpname(), "a")
				local s, err = f:read()
				assert(not s and err)
			end)
			
			it("should be able to seek and read in a file", function()
				--mock_fs.unmock()
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				assert(f:write("abcdefg"))
				f:close()
				
				local f = io.open(filename, "r")
				assert(f:read("*a") == "abcdefg")
				assert(f:seek("set") == 0)
				assert(f:read("*a") == "abcdefg")
				assert(f:seek("set", 1) == 1)
				assert(f:read("*a") == "bcdefg")
	
				f:seek("set")
				f:seek("cur", 1)
				assert(f:read("*a") == "bcdefg")
				f:seek("cur", -1)
				assert(f:read("*a") == "g")
				f:seek("end", -1)
				assert(f:read("*a") == "g")
			end)
			
			it("should be able to seek and write in a file", function()
				--mock_fs.unmock()			
				local filename = os.tmpname()
				local f = io.open(filename, "w")
				assert(f:write("abcdefg"))
				f:seek("set", 1)
				f:write("x")
				f:close()
				
				local f = io.open(filename, "r")
				assert(f:read("*a") == "axcdefg")
			end)
		end)
	end)
end
