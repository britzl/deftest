local mock = require "deftest.mock.mock"

local M = {}


local nodes = {}

local function ensure_hash(id)
	return type(id) == "string" and hash(id) or id
end

local function new_node(id, node_type, x, y, w, h)
	id = ensure_hash(id)
	assert(not nodes[id])
	local node = {
		id = id,
		type = node_type,
		x = x, y = y, w = w, h = h,
		position = vmath.vector3(x, y, 0),
		size = vmath.vector3(w or 1, h or 1, 0),
		scale = vmath.vector3(1, 1, 1),
		rotation = vmath.quat(),
		enabled = true,
		parent = nil,
	}
	nodes[id] = node
	return node
end

local function screen_position(node, position)
	position = (position or vmath.vector3(0)) + node.position
	if node.parent then
		screen_position(node.parent, position)
	end
	return position
end

local function is_enabled(node)
	return node.enabled
end

local function get_node(id)
	id = ensure_hash(id)
	return nodes[id]
end

local function set_enabled(node, enabled)
	node.enabled = enabled
end

local function pick_node(node, x, y)
	local position = screen_position(node)
	return x >= position.x and y >= position.y and x <= (position.x + node.w) and y <= (position.y + node.h)
end

local function get_parent(node)
	return node.parent
end

local function get_font(node)
	return node.font
end

local function get_text_metrics(font, text, width, line_breaks, leading, tracking)
	return {
		width = width,
		height = 10,
		max_ascent = 8,
		max_descent = 2,
	}
end

local function set_text(node, text)
	assert(node.type == "text")
	node.text = text
end

function M.mock()
	mock.mock(gui)
	gui.get_node.replace(get_node)
	gui.is_enabled.replace(is_enabled)
	gui.set_enabled.replace(set_enabled)
	gui.pick_node.replace(pick_node)
	gui.get_parent.replace(get_parent)
	gui.get_font.replace(get_font)
	gui.get_text_metrics.replace(get_text_metrics)
	gui.reset_keyboard.replace(function() end)
	gui.show_keyboard.replace(function() end)
	gui.hide_keyboard.replace(function() end)
	gui.set_text.replace(set_text)
end

function M.unmock()
	mock.unmock(gui)
	nodes = {}
end

function M.add_box(id, x, y, w, h)
	return new_node(id, "box", x, y, w, h)
end

function M.add_text(id, x, y, w, h)
	local node = new_node(id, "text", x, y, w, h)
	node.text = ""
	node.font = hash("font")
	return node
end

return M
