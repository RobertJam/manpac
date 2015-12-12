local timer = {
	listeners = {}
}

function timer.update()
	local currentTime = love.timer.getTime()
	for i,listenerObject in ipairs(timer.listeners) do
		local eleapsedTime = (currentTime - listenerObject.lastCallTime) * 1000
		if eleapsedTime >= listenerObject.duration then
			listenerObject.callback()
			listenerObject.lastCallTime = currentTime
		end
	end
end

function timer.wait(listener, milliseconds)
	for i,listenerObject in ipairs(timer.listeners) do
		if listenerObject.callback == listener then
			listenerObject.lastCallTime = listenerObject.lastCallTime + (milliseconds / 1000)
			return
		end
	end
end

function timer.addListener(listener, milliseconds)
	local initialTime = love.timer.getTime()
	local listenerObject = {callback = listener,
							duration = milliseconds,
							lastCallTime = initialTime}
	
	table.insert(timer.listeners, listenerObject)
	return table.getn(timer.listeners)
end

function timer.removeListener(listener)
	for i,listenerObject in ipairs(timer.listeners) do
		if listenerObject.callback == listener then
			table.remove(timer.listeners, i)
			return
		end
	end
end

return timer