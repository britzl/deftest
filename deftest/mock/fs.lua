local mock = require "deftest.mock.mock"

local M = {}

local files = {}

local fail_file_operations = false
local fail_write_operations = false

--- from http://lua-users.org/wiki/CopyTable
local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function M.mock()
	mock.mock(sys)
	files = {}
	sys.load.replace(function (file)
		local t = files[file]
		if not t then
			t = {}
		end
		return t
	end)
	sys.save.replace(function (file, t)
		files[file] = deepcopy(t)
		return true
	end)

	local tmpfile_count = 0
	local output = nil
	local input = nil
	mock.mock(io)
	mock.mock(os)
	os.remove.replace(function(filename)
		assert(not fail_file_operations, "os.remove error")
		assert(filename)
		if not files[filename] or fail_file_operations then
			return nil, ("%s: No such file or directory"):format(filename)
		end
		files[filename] = nil
		return true
	end)
	os.rename.replace(function(oldname, newname)
		assert(not fail_file_operations, "os.rename error")
		assert(oldname and newname)
		if not files[oldname] or fail_file_operations then
			return nil, "No such file or directory"
		end
		files[newname] = files[oldname]
		files[oldname] = nil
		return true
	end)
	os.tmpname.replace(function()
		tmpfile_count = tmpfile_count + 1
		local filename = "tmpfile" .. tostring(tmpfile_count) .. "_" .. tostring(socket.gettime())
		files[filename] = ""
		return filename
	end)
	io.open.replace(function(filename, mode)
		assert(filename)
		if fail_file_operations then
			return nil, "Unable to open file"
		end

		local closed = false
		local mode = mode
		local file_position = 1
		local file = {
			type = "file"
		}

		mode = mode or "r"
		mode = mode:gsub("b", "")

		if mode == "w" then
			files[filename] = ""
		elseif mode == "w+" then
			files[filename] = ""
		elseif mode == "a" or mode == "a+" then
			files[filename] = files[filename] or ""
			file_position = 1 + #files[filename]
		elseif mode == "r" or mode == "r+" then
			if not files[filename] then
				return nil, filename .. ": No such file or directory"
			else
				files[filename] = files[filename]
			end
		else
			return nil, "Invalid mode"
		end

		file.write = function(self, ...)
			assert(not closed, "attempt to use a closed file")
			assert(not fail_file_operations, "io error")
			assert(not fail_write_operations, "io error")
			if mode == "r" then
				return nil, "Bad file descriptor"
			end
			local args = { ... }
			for _,data in ipairs(args) do
				if mode == "a+" then
					file_position = 1 + #files[filename]
				end
				local s = tostring(data)
				local before = files[filename]:sub(1, file_position - 1)
				local after = files[filename]:sub(file_position + #s) or ""

				files[filename] = before .. s .. after
				file_position = file_position + #s

				-- this is a bit weird but it matches actual behavior
				if mode == "a+" then
					file_position = file_position - 1
				end
			end
			return true
		end
		file.close = function()
			assert(not closed, "attempt to use a closed file")
			assert(not fail_file_operations, "io error")
			closed = true
			file.type = "closed file"
		end
		file.read = function(self, ...)
			assert(not closed, "attempt to use a closed file")
			assert(not fail_file_operations, "io error")
			if mode == "w" or mode == "a" then
				return nil, "Bad file descriptor"
			end

			local function is_eof()
				return file_position == #files[filename] + 1
			end

			local formats = { ... }
			if #formats == 0 then
				formats[1] = "*l"
			end
			local results = {}
			for i=1,#formats do
				local format = formats[i]
				if format == "*n" then
					if is_eof() then
						results[i] = nil
					else
						local s = files[filename]:sub(file_position)
						local n = s:match("([-+]?%d+%.?%d*).*")
						if n then
							results[i] = tonumber(n)
							file_position = file_position + #n
						else
							results[i] = nil
						end
					end
				elseif format == "*a" then
					if is_eof() then
						results[i] = ""
					else
						local s = files[filename]:sub(file_position)
						results[i] = s
						file_position = #files[filename] + 1
					end
				elseif format == "*l" then
					local s = files[filename]:sub(file_position)
					local line = s:match("[^\r\n]+")
					if line then
						file_position = file_position + #line + 1 -- +1 = the linebreak
					end
					results[i] = line
				elseif type(format) == "number" then
					local length = format
					if length < 0 then
						results[i] = nil
					elseif is_eof() then
						results[i] = nil
					elseif length == 0 then
						results[i] = ""
					else
						local s = files[filename]:sub(file_position, file_position + length - 1)
						file_position = file_position + #s
						results[i] = s
					end
				else
					results[i] = nil
				end
			end
			return unpack(results)
		end
		file.flush = function()
			assert(not closed, "attempt to use a closed file")
			assert(not fail_file_operations, "io error")
		end
		file.lines = function()
			assert(not closed, "attempt to use a closed file")
			assert(not fail_file_operations, "io error")
			return files[filename]:gmatch("[^\r\n]+")
		end
		file.seek = function(self, whence, offset)
			whence = whence or "cur"
			offset = offset or 0
			if whence == "set" then
				if offset < 0 then
					return nil, "Invalid argument"
				end
				file_position = 1 + offset
				return offset
			elseif whence == "cur" then
				if file_position + offset < 1 then
					return nil, "Invalid argument"
				end
				file_position = file_position + offset
				return file_position
			elseif whence == "end" then
				file_position = 1 + #files[filename] + offset
				return file_position
			end
		end
		return file
	end)
	io.type.replace(function(obj)
		return obj and obj.type or nil
	end)
	io.write.replace(function(...)
		if not output then
			return
		end
		output.write(...)
	end)
	io.read.replace(function(...)
		if not input then
			return
		end
		return input.read(...)
	end)
	io.read.replace(function(...)
		if not input then return end
		return input.read(...)
	end)
	io.output.replace(function(file)
		if not file then
			return output
		end
		if type(file) == "string" then
			output = io.open(file)
		else
			output = file
		end
		return output
	end)
	io.input.replace(function(file)
		if not file then
			return input
		end
		if type(file) == "string" then
			input = io.open(file)
		else
			input = file
		end
		return input
	end)
	io.flush.replace(function()
		if output then
			output.flush()
		end
	end)
	io.close.replace(function(file)
		if file then
			file.close()
		elseif output then
			io.output().close()
		end
	end)
	io.lines.replace(function(filename)
		if filename then
			local file = io.open(filename)
			return file.lines()
		elseif input then
			return io.input().lines()
		end
	end)
	io.popen.replace(function(prog, mode)
		error("io.popen is not mockable")
	end)
	io.tmpfile.replace(function()
		return io.open(os.tmpname())
	end)
end

function M.unmock()
	fail_file_operations = false
	fail_write_operations = false
	mock.unmock(sys)
	mock.unmock(io)
	mock.unmock(os)
end


function M.has_file(file)
	return files[file] ~= nil
end

function M.get_file(file)
	return files[file]
end

function M.set_file(file, content)
	files[file] = content
end

function M.fail()
	fail_file_operations = true
end

function M.success()
	fail_file_operations = false
end

function M.fail_writes(fail)
	fail_write_operations = fail
end

function M.files()
	return files
end

return M
