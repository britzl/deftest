local mock = require "deftest.mock.mock"

local M = {}

local instance_count = 0

local nodes = {}

local function ensure_hash(id)
	return type(id) == "string" and hash(id) or id
end

local function new_node(id, node_type, x, y, z, w, h)
	id = ensure_hash(id)
	assert(not nodes[id])
	local node = {
		id = id,
		type = node_type,
		x = x, y = y, w = w, h = h,
		position = vmath.vector3(x, y, z),
		size = vmath.vector3(w or 1, h or 1, 0),
		scale = vmath.vector3(1, 1, 1),
		rotation = vmath.quat(),
		color = vmath.vector4(1, 1, 1, 1),
		enabled = true,
		parent = nil,
		animations = {},
	}
	nodes[id] = node
	return node
end

local function clone(node)
	local clone = {}
	clone.id = hash("")
	clone.x = node.x
	clone.y = node.y
	clone.w = node.w
	clone.h = node.h
	clone.position = vmath.vector3(node.position)
	clone.size = vmath.vector3(node.size)
	clone.scale = vmath.vector3(node.scale)
	clone.rotation = vmath.quat(node.rotation)
	clone.color = vmath.vector4(node.color)
	clone.enabled = node.enabled
	clone.parent = node.parent
	clone.animations = {}
	for k,v in pairs(node) do
		if clone[k] == nil then
			clone[k] = v
		end
	end
	nodes[clone.id] = clone
	return clone
end

local function screen_position(node, position)
	local position = vmath.vector3(node.position)
	if node.parent then
		position = position + screen_position(node.parent)
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

local function get_id(node)
	return node.id
end

local function set_id(node, id)
	nodes[node.id] = nil
	node.id = ensure_hash(id)
	nodes[node.id] = node
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

local function set_parent(node, parent)
	node.parent = parent
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

local function get_text(node)
	assert(node.type == "text")
	return node.text
end

local function set_color(node, color)
	node.color = color
end

local function get_color(node)
	return node.color
end

local function get_position(node)
	return vmath.vector3(node.position)
end

local function set_position(node, position)
	node.position = vmath.vector3(position)
end

local function delete_node(node)
	nodes[node.id] = nil
	for _,child in pairs(nodes) do
		if child.parent == node then
			delete_node(child)
		end
	end
end

local function set_size(node, size)
	node.size = vmath.vector3(size)
end

local function get_size(node)
	return vmath.vector3(node.size)
end

local function set_scale(node, scale)
	node.scale = scale
end

local function get_scale(node)
	return node.scale
end

local function new_box_node(pos, size)
	instance_count = instance_count + 1
	local node = new_node("instance" .. tostring(instance_count), "box", pos.x, pos.y, pos.z, size.x, size.y)
	return node
end

local function new_text_node(pos, text)
	instance_count = instance_count + 1
	local node = new_node("instance" .. tostring(instance_count), "text", pos.x, pos.y, pos.z, 0, 0)
	node.text = text
	node.font = hash("font")
	return node
end

local function animate(node, property, to, easing, duration, delay, callback, playback)
	if node.animations[property] then
		timer.cancel(node.animations[property])
	end
	local timer_id = timer.delay(duration, false, function()
		if property == gui.PROP_COLOR then
			node.color = vmath.vector4(to)
		elseif property == gui.PROP_FILL_ANGLE then
			error("Not implemented")
		elseif property == gui.PROP_INNER_RADIUS then
			error("Not implemented")
		elseif property == gui.PROP_OUTLINE then
			error("Not implemented")
		elseif property == gui.PROP_POSITION then
			node.position = vmath.vector3(to)
		elseif property == gui.PROP_ROTATION then
			node.rotation = vmath.quat(to)
		elseif property == gui.PROP_SCALE then
			node.scale = vmath.vector3(to)
		elseif property == gui.PROP_SHADOW then
			error("Not implemented")
		elseif property == gui.PROP_SIZE then
			node.size = vmath.vector3(to)
		elseif property == gui.PROP_SLICE9 then
			error("Not implemented")
		end
		callback({}, node)
	end)
	node.animations[property] = timer_id
end

local function cancel_animation(node, property)
	if node.animations[property] then
		timer.cancel(node.animations[property])
		node.animations[property] = nil
	end
end

function M.mock()
	mock.mock(gui)
	gui.get_node.replace(get_node)
	gui.get_id.replace(get_id)
	gui.set_id.replace(set_id)

	gui.is_enabled.replace(is_enabled)
	gui.set_enabled.replace(set_enabled)
	gui.delete_node.replace(delete_node)

	gui.pick_node.replace(pick_node)

	gui.get_parent.replace(get_parent)
	gui.set_parent.replace(set_parent)

	gui.get_font.replace(get_font)
	gui.get_text_metrics.replace(get_text_metrics)

	gui.reset_keyboard.replace(function() end)
	gui.show_keyboard.replace(function() end)
	gui.hide_keyboard.replace(function() end)

	gui.set_text.replace(set_text)
	gui.get_text.replace(get_text)

	gui.set_color.replace(set_color)
	gui.get_color.replace(get_color)

	gui.get_position.replace(get_position)
	gui.set_position.replace(set_position)

	gui.set_size.replace(set_size)
	gui.get_size.replace(get_size)

	gui.set_scale.replace(set_scale)
	gui.get_scale.replace(get_scale)

	gui.new_box_node.replace(new_box_node)
	gui.new_text_node.replace(new_text_node)

	gui.clone.replace(clone)

	gui.animate.replace(animate)
	gui.cancel_animation.replace(cancel_animation)
end

function M.unmock()
	mock.unmock(gui)
	nodes = {}
end

function M.add_box(id, x, y, w, h)
	return new_node(id, "box", x, y, 0, w, h)
end

function M.add_text(id, x, y, w, h)
	local node = new_node(id, "text", x, y, 0, w, h)
	node.text = ""
	node.font = hash("font")
	return node
end

return M
