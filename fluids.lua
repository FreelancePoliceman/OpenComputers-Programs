local component = require ("component")
local database = component.get("df04") -- magic number; this must be found manually before running this program. Represents your database ID.
local exportbus = component.me_exportbus
local getFluids = component.me_interface.getFluidsInNetwork()
local side = 4 -- another magic number. ME export buses take a side and slot. The slot can be "set" manually through OC, but I have no idea what the "side" represents. This number depends on your setup, and you have to find this through a few manual calls.
local slot = 1 -- Set this to anything you like, but this must be consistent.
local cobblestone = 1 -- More magic numbers, these for items. They represent the order I've set them in the AE2 database. From the top left to bottom right, entries go 1...Maximum. 
local redstonedust = 2
local coalblock = 3

function setexport(item, count)
	if item == 0 then -- In case I bug future code, to prevent program crashing.
		exportbus.setExportConfiguration(side) -- This sets the bus to output nothing.
		return
	end
	exportbus.setExportConfiguration(side,slot,database,item)
	local i = 0
	-- print ("Test: count = ",count) -- Debug; useful when adding new items to the script
	while i < count do 
		if exportbus.exportIntoSlot(side,slot) then
			i = i + 1 -- Does Lua do i++ syntax...?
			print ("Exporting item; count ",i,"of ",count)
		end
	end
end

function fluidfix (item,item_mb,desired_quantity,current_quantity) -- E.g. cobblestone, 1000 (1 cobblestone = 1000 mb/1 bucket), 100000 mb in storage, current quantity in storage
	if current_quantity < desired_quantity then
		local quantity_to_send = math.floor((desired_quantity - current_quantity)/item_mb)
		setexport(item,quantity_to_send)
	end
end

function main() 
	local count = 0
	local fluid
	-- Here you must put every fluid you want checked and write the logic yourself. I'm afraid there doesn't seem to be any way to do this programmatically.
	local lava = 0
	local redstone = 0
	local creosote = 0

	for v,k in pairs(getFluids) do
		count = count + 1
		fluid = getFluids[count]
		if fluid == nil then -- Lua tables seem to output 1 more result than is "actually" there so to speak; this prevents crashing on this non-existent result.
			break
		end
		if fluid.name == "lava" then
			lava = 1
			fluidfix(cobblestone,1000,100000,fluid.amount)
		elseif fluid.name == "redstone" then
			redstone = 1
			fluidfix(redstonedust,100,10000,fluid.amount)
		elseif fluid.name == "creosote" then
			creosote = 1
			creosotefix(coalblock,2500,30000,fluid.amount)
		end
	end

	if lava == 0 then
		fluidfix(cobblestone,1000,100000,fluid.amount)
	elseif redstone == 0 then
		fluidfix(redstonedust,100,10000,fluid.amount)
	elseif creosote == 0 then
		creosotefix(coalblock,2500,30000,fluid.amount)
	end
end

main()
