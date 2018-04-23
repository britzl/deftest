local mock = require "deftest.mock.mock"

local M = {}

local mock_time = nil

function M.mock()
	mock.mock(os)
	mock.mock(socket)

	mock_time = socket.gettime.original()
	os.time.replace(function()
		if not mock_time then
			return os.time.original()
		end
		return math.floor(mock_time)
	end)
	os.date.replace(function(format, time)
		if not mock_time then
			return os.date.original(format, time)
		end
		return os.date.original(format, time or mock_time)
	end)
	socket.gettime.replace(function()
		if not mock_time then
			return os.time.original()
		end
		return mock_time
	end)
end

function M.unmock()
	mock_time = nil
	mock.unmock(os)
	mock.unmock(socket)
end


function M.set(time)
	if not time then
		time = socket.gettime.original()
	end
	mock_time = time
end

function M.elapse(seconds)
	assert(seconds, "You must provide the number of seconds to elapse time with")
	mock_time = mock_time + seconds
end

return M
