local reporter = require "luacov.reporter"

local function exists(filename)
	local file = io.open(filename, "r")
	if not file then
		return false
	end
	io.close(file)
	return true
end

local function fix_filename(filename)
	local filename = filename:gsub("^=", "")
	if exists(filename) then
		return filename
	end
	-- foo.bar -> foo/bar.lua
	local parsed_name = filename:gsub("%.", "/")..".lua"
	if exists(parsed_name) then
		return parsed_name
	end
	-- foobar.scriptc -> foobar.script
	parsed_name = filename:gsub("^/", ""):gsub("%.scriptc$$", ".script")
	if exists(parsed_name) then
		return parsed_name
	end
	-- foobar.gui_scriptc -> foobar.gui_script
	parsed_name = filename:gsub("^/", ""):gsub("%.gui_scriptc$$", ".gui_script")
	if exists(parsed_name) then
		return parsed_name
	end
	-- foobar.gui_scriptc -> foobar.gui_script
	parsed_name = filename:gsub("^/", ""):gsub("%.render_scriptc$$", ".render_script")
	if exists(parsed_name) then
		return parsed_name
	end
	return filename
end

local DefoldReporter = setmetatable({}, reporter.DefaultReporter) do
	DefoldReporter.__index = DefoldReporter

	function DefoldReporter:run()
		print("Generating code coverage report")
		self:on_start()

		-- convert filenames to match those on disk
		-- filenames will start with =/ since they aren't coming
		-- from files on disk when run in Defold
		local d = {}
		for filename,stats in pairs(self._data) do
			d[fix_filename(filename)] = stats
		end
		self._data = d
		for i,filename in pairs(self._files) do
			self._files[i] = fix_filename(filename)
		end
		
		for _, filename in ipairs(self:files()) do
			if exists(filename) then
				print("  Processing:", filename)
				self:_run_file(filename)
			else
				print("  Skipping:", filename)
			end
		end

		self:on_end()
	end
	
end

return DefoldReporter