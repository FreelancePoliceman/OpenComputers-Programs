local component = require ("component")
local thread = require ("thread")
local event = require ("event")

function manage () 
	while (1) do 
		local reactor = component.br_reactor
		local percent_to_fill = math.floor (100 * reactor.getEnergyStored()/reactor.getEnergyCapacity())
		reactor.setAllControlRodLevels(percent_to_fill)
	end
end

local timer = thread.create ( -- Function for extensibility later, perhaps.
	function () 
		event.timer(10,manage(),math.huge)
	end
)

function start () -- Required for rc.d
	timer:detach()
end
