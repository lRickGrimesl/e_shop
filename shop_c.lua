--[[
	Code Author: kaasis/rivor2
	Contact Info: http://steamcommunity.com/id/rivor2
]]--

local shop_gui = {tab = {},tabpanel = {},label = {},gridlist = {},window = {},button = {},memo = {}}

local shop = {
	["sf_docks"] = {
		["normal"] = {
			["supply_dealer"] = {-2316.357,2341.581,5.816,0},
			["vehicle_dealer"] = {-2318.751,2341.252,5.816,0},
			["supply_dealer_marker"] = {-2316.474,2342.978,5.816},
			["vehicle_dealer_marker"] = {-2318.938,2342.724,5.816,-2323.510,2343.452,5.816,0,0,0}, -- {marker_x,marker_y,marker_z,vehicle_spawn_x,vehicle_spawn_y,vehicle_spawn_z,rx,ry,rz}
		},
	},
	["ls_docks"] = {
		["normal"] = {
			["supply_dealer"] = {2771.237,-1605.615,11.440,-90},
			["vehicle_dealer"] = {2789.657,-1624.846,11.282,0},
			["supply_dealer_marker"] = {2772.641,-1605.640,11.440},
			["vehicle_dealer_marker"] = {2789.610,-1623.489,10.921,2787.918,-1619.733,11.006,0,0,80}, -- {marker_x,marker_y,marker_z,vehicle_spawn_x,vehicle_spawn_y,vehicle_spawn_z,rx,ry,rz}
		},
	},
}

local shop_items = {
	["normal"] = {
		["supply"] = {
			-- example: {"itemdata",amount,price};
			["Weapons"] = {
				{"weapon11",1,50,40},
				{"weapon21",1,20,18},
				{"weapon23",1,15,13},
				{"weapon20",1,30,26},
			},
			["Ammo"] = {
				{"mag5",20,12,10},
				{"mag1",15,12,10},
				{"mag3",30,12,10},
			},
			["Food"] = {
				{"fooditem4",1,10,8},
				{"fooditem5",1,10,8},
				{"fooditem1",1,10,8},
			},
			["Parts"] = {
				{"vehiclepart1",1,25,23},
				{"vehiclepart2",1,25,23},
				{"vehiclepart3",1,25,23},
				{"vehiclepart4",1,25,23},
				{"vehiclepart5",1,25,23}
			},
			["Backpacks"] = {
				{"backpack4",1,15,13},
				{"backpack3",1,25,23},
				{"backpack2",1,35,31},
			},
			["Toolbelts"] = {
				{"toolbelt4",1,10,8},
			},
			--["Convert"] = {
			--	{"zKill Bag",1,10},
			--},
		},
		["vehicle"] = {
			["Vehicles"] = {
				-- example: {"name",id,engine,rotor,tires,tankparts,scrap,slots,fuel,price}
				{"Armored Truck",528,1,0,4,1,1,50,80,500,400},
				{"HMMWV",470,1,0,4,1,1,46,100,100,180},
				{"Pickup Truck",422,1,0,4,1,1,25,80,80,60},
				{"Motorcycle",468,1,0,2,1,1,10,30,60,40},
				{"Old Bike",509,0,0,0,0,0,0,0,30,20},
			},
		},
	},
}

local currency_item = "zombieskilled";

--{[ DO NOT CHANGE THEESE ]}--
local shop_marker = nil;
local shop_marker_type = nil;
local shop_humanity_type = nil;
local vehicle_spawn_position = nil; 
local vehicle_spawn_position_col = {};
--{[ DO NOT CHANGE THEESE ]}--


function load_shop()
	for i,v in pairs(shop) do
		local current_shop = i;
		for i,v in pairs(v) do
			if (i ~= "items") then
				local humanity_type = i;
				for i,v in pairs(v) do
					if (i == "supply_dealer") then
						local supplyDealer = createPed(29,v[1],v[2],v[3],v[4],false)
						setElementFrozen(supplyDealer,true)
						setPedVoice(supplyDealer, "PED_TYPE_DISABLED")
						addEventHandler("onClientRender",root,function()
							dxDrawTextOnElement(supplyDealer,"supply dealer",0.25,10,0,0,0,255,1.02,"sans")
							dxDrawTextOnElement(supplyDealer,"supply dealer",0.26,10,0,200,100,255,1,"sans")
						end)
					elseif (i == "vehicle_dealer") then
						local vehicleDealer = createPed(28,v[1],v[2],v[3],v[4],false)
						setPedVoice(vehicleDealer, "PED_TYPE_DISABLED")
						setElementFrozen(vehicleDealer,true)
						addEventHandler("onClientRender",root,function()
							dxDrawTextOnElement(vehicleDealer,"vehicle dealer",0.25,10,0,0,0,255,1.02,"sans")
							dxDrawTextOnElement(vehicleDealer,"vehicle dealer",0.26,10,0,200,100,255,1,"sans")
						end)
					elseif (i == "supply_dealer_marker") then
						local supplyShopMarker = createMarker(v[1],v[2],v[3]-1,"cylinder",1,0,255,0,69)
						addEventHandler("onClientMarkerHit",supplyShopMarker,function(player)
							if (player == localPlayer) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "supply";
										shop_humanity_type = humanity_type;
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast 5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= -5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "supply";
										shop_humanity_type = humanity_type;
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast -5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									guiSetVisible(shop_gui.window[1],true)
									showCursor(true)
									shop_marker = current_shop;
									shop_marker_type = "supply";
									shop_humanity_type = humanity_type;
									updateShop();
								end
							end
							
						end)
						addEventHandler("onClientMarkerLeave",supplyShopMarker,function(player)
							if (player == localPlayer) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= -5000) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									for i,v in pairs(shop_items) do
										if (i == humanity_type) then
											for i,v in pairs(v) do
												if (i == shop_marker_type) then
													for i,v in pairs(v) do
														guiDeleteTab(guiGetSelectedTab(shop_gui.tabpanel[1]),shop_gui.tabpanel[1])
													end
												end
											end
										end
									end
									
									guiSetVisible(shop_gui.window[1],false)
									showCursor(false)
									if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
										removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
									end
									shop_marker = nil;
									shop_marker_type = nil;
									shop_humanity_type = nil;
									killErrorMessageTimer();
								end
							end
						end)
					elseif (i == "vehicle_dealer_marker") then
						local vehicleShopMarker = createMarker(v[1],v[2],v[3]-1,"cylinder",1,0,255,0,69)
						vehicle_spawn_position_col[current_shop] = createColSphere(v[4],v[5],v[6],4.5)
						addEventHandler("onClientMarkerHit",vehicleShopMarker,function(player)
							if (player == localPlayer) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "vehicle";
										shop_humanity_type = humanity_type;
										vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast 5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= -5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "vehicle";
										shop_humanity_type = humanity_type;
										vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast -5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									guiSetVisible(shop_gui.window[1],true)
									showCursor(true)
									vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
									shop_marker = current_shop;
									shop_marker_type = "vehicle";
									shop_humanity_type = humanity_type;
									updateShop();
								end
							end
						end)
						addEventHandler("onClientMarkerLeave",vehicleShopMarker,function(player)
							if (player == localPlayer) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										vehicle_spawn_position = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= 0) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										vehicle_spawn_position = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									for i,v in pairs(shop_items) do
										if (i == humanity_type) then
											for i,v in pairs(v) do
												if (i == shop_marker_type) then
													for i,v in pairs(v) do
														guiDeleteTab(guiGetSelectedTab(shop_gui.tabpanel[1]),shop_gui.tabpanel[1])
													end
												end
											end
										end
									end
									guiSetVisible(shop_gui.window[1],false)
									showCursor(false)
									if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
										removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
									end
									shop_marker = nil;
									shop_marker_type = nil;
									shop_humanity_type = nil;
									vehicle_spawn_position = nil;
									killErrorMessageTimer();
								end
							end
						end)
						addEventHandler("onClientColShapeHit",vehicle_spawn_position_col[current_shop],function(player)
							if (player == localPlayer and isPedInVehicle(localPlayer)) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "vehicle";
										shop_humanity_type = humanity_type;
										vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast 5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= -5000) then
										guiSetVisible(shop_gui.window[1],true)
										showCursor(true)
										shop_marker = current_shop;
										shop_marker_type = "vehicle";
										shop_humanity_type = humanity_type;
										vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
										updateShop();
									else
										outputChatBox("Dealer: You need to have atleast -5000 humanity in order to shop here.",200,55,0)
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									guiSetVisible(shop_gui.window[1],true)
									showCursor(true)
									vehicle_spawn_position = {v[4],v[5],v[6],v[7],v[8],v[9]}
									shop_marker = current_shop;
									shop_marker_type = "vehicle";
									shop_humanity_type = humanity_type;
									updateShop();
								end
							end
						end)
						addEventHandler("onClientColShapeLeave",vehicle_spawn_position_col[current_shop],function(player)
							if (player == localPlayer and isPedInVehicle(localPlayer)) then
								if (humanity_type == "hero") then
									if (getElementData(source,"humanity") >= 5000) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										vehicle_spawn_position = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "bandit") then
									if (getElementData(source,"humanity") <= 0) then
										guiSetVisible(shop_gui.window[1],false)
										showCursor(false)
										if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
											removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
										end
										shop_marker = nil;
										shop_marker_type = nil;
										shop_humanity_type = nil;
										vehicle_spawn_position = nil;
										killErrorMessageTimer();
									end
								elseif (humanity_type == "blackmarket" or humanity_type == "normal") then
									for i,v in pairs(shop_items) do
										if (i == humanity_type) then
											for i,v in pairs(v) do
												if (i == shop_marker_type) then
													for i,v in pairs(v) do
														guiDeleteTab(guiGetSelectedTab(shop_gui.tabpanel[1]),shop_gui.tabpanel[1])
													end
												end
											end
										end
									end
									guiSetVisible(shop_gui.window[1],false)
									showCursor(false)
									if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
										removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
									end
									shop_marker = nil;
									shop_marker_type = nil;
									shop_humanity_type = nil;
									vehicle_spawn_position = nil;
									killErrorMessageTimer();
								end
							end
						end)
						if (humanity_type == "hero") then
							createBlip(v[4],v[5],v[6],31,1,0,0,0,255,0,0)
						elseif (humanity_type == "bandit") then
							createBlip(v[4],v[5],v[6],32,1,0,0,0,255,0,0)
						elseif (humanity_type == "normal") then
							createBlip(v[4],v[5],v[6],18,1,0,0,0,255,0,0)
						end
					end
				end
			end
		end
	end
end
addEvent("load_shop",true);
addEventHandler("load_shop",root,load_shop);

addEventHandler("onClientResourceStart",resourceRoot,function()
	if getElementData(localPlayer,"logedin") then
		load_shop();
	end
end);

function killErrorMessageTimer()
	if isTimer(errorMessageTimer) then
		killTimer(errorMessageTimer)
		guiSetText(shop_gui.label[4],"")
		guiSetAlpha(shop_gui.label[4],1)
	end
end


function buyItem()
	if isTimer(errorMessageTimer) then
		killTimer(errorMessageTimer)
		guiSetText(shop_gui.label[4],"")
		guiSetAlpha(shop_gui.label[4],1)
		errorMessageTimer = setTimer(removeErrorMessage,275,15)
	else
		function removeErrorMessage()
			if (guiGetAlpha(shop_gui.label[4]) > 0.30) then
				guiSetAlpha(shop_gui.label[4],guiGetAlpha(shop_gui.label[4])-0.05)
			elseif (guiGetAlpha(shop_gui.label[4]) < 0.30) then
				if isTimer(errorMessageTimer) then killTimer(errorMessageTimer) end
				guiSetText(shop_gui.label[4],"")
				guiSetAlpha(shop_gui.label[4],1)
			end
		end
		errorMessageTimer = setTimer(removeErrorMessage,275,15)
	end

	if (guiGridListGetSelectedItem(shop_gui.gridlist[1] ) == -1) then
		guiSetText(shop_gui.label[4],"Please select an item")
		guiLabelSetColor (shop_gui.label[4],255,0,0)
	else
		if (shop_marker_type == "supply") then
			local target = localPlayer;
			local item = guiGridListGetItemText(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),1)
			local amount,buyprice,sellprice,itemdata = unpack(guiGridListGetItemData(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),2))
			guiLabelSetColor(shop_gui.label[4],255,0,0)

			if (getElementData(localPlayer, currency_item) >= buyprice) then
				guiSetText(shop_gui.label[4],"You successfully bought "..item..".")
				guiLabelSetColor (shop_gui.label[4],0,149,14,255)
				triggerServerEvent("MTAZeu:onClientSuccessBuysItem",localPlayer,target,itemdata,currency_item,amount,buyprice,sellprice)
			else
				guiSetText(shop_gui.label[4],"You don't have enough zKills")
			end
		elseif (shop_marker_type == "vehicle") then
			local target = localPlayer;
			local vehicleName = guiGridListGetItemText(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),1)
			local id,engine,rotor,tires,tankparts,scrap,slots,fuel,buyprice,sellprice = unpack(guiGridListGetItemData(shop_gui.gridlist[1],guiGridListGetSelectedItem(shop_gui.gridlist[1]),1))
			local x,y,z,rx,ry,rz = unpack(vehicle_spawn_position)
			guiLabelSetColor(shop_gui.label[4],255,0,0)
			if (getElementData(localPlayer,currency_item) >= buyprice) then
				for i,v in ipairs(getElementsWithinColShape(vehicle_spawn_position_col[shop_marker],"vehicle")) do
					guiSetText(shop_gui.label[4],"Vehicle spawn area is taken, clear it before buying vehicle.")
					return
				end
				guiSetVisible(shop_gui.window[1],false)
				showCursor(false)
				outputChatBox("You successfully bought "..vehicleName..".",0,255,0)
				triggerServerEvent("MTAZeu:onClientSuccessBuysVehicle",localPlayer,target,currency_item,buyprice,sellprice,x,y,z,rx,ry,rz,id,engine,rotor,tires,tankparts,scrap,slots,fuel)
			else
				guiSetText(shop_gui.label[4], "You don't have enough zKills")
			end
		end
	end
end



function sellItem()
	if isTimer(errorMessageTimer) then
		killTimer(errorMessageTimer)
		guiSetText(shop_gui.label[4],"")
		guiSetAlpha(shop_gui.label[4],1)
		errorMessageTimer = setTimer(removeErrorMessage,275,15)
	else
		function removeErrorMessage()
			if (guiGetAlpha(shop_gui.label[4]) > 0.30) then
				guiSetAlpha(shop_gui.label[4],guiGetAlpha(shop_gui.label[4])-0.05)
			elseif (guiGetAlpha(shop_gui.label[4]) < 0.30) then
				if isTimer(errorMessageTimer) then killTimer(errorMessageTimer) end
				guiSetText(shop_gui.label[4],"")
				guiSetAlpha(shop_gui.label[4],1)
			end
		end
		errorMessageTimer = setTimer(removeErrorMessage,275,15)
	end

	if (guiGridListGetSelectedItem(shop_gui.gridlist[1] ) == -1) then
		guiSetText(shop_gui.label[4],"Please select an item")
		guiLabelSetColor (shop_gui.label[4],255,0,0)
	else
		if (shop_marker_type == "supply") then
			local target = localPlayer
			local item = guiGridListGetItemText(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),1)
			local amount,buyprice,sellprice,itemdata = unpack(guiGridListGetItemData(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),2))
			guiLabelSetColor(shop_gui.label[4],255,0,0)

			if (getElementData(localPlayer, itemdata) > 0) then
				guiSetText(shop_gui.label[4],"You successfully sold "..item..".")
				guiLabelSetColor (shop_gui.label[4],0,149,14,255)
				triggerServerEvent("MTAZeu:onClientSuccessSellsItem",localPlayer,target,itemdata,currency_item,amount,buyprice,sellprice)
			else
				guiSetText(shop_gui.label[4],"You don't have enough "..item..".")
			end

		elseif (shop_marker_type == "vehicle") then
			local target = localPlayer
			local vehicleName = guiGridListGetItemText(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]), 1)
			local id, engine, rotor, tires, tankparts, scrap, slots, fuel, buyprice, sellprice = unpack(guiGridListGetItemData(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]), 1))
			local x, y, z, rx, ry, rz = unpack(vehicle_spawn_position)
			guiLabelSetColor(shop_gui.label[4], 255, 0, 0)
			
			if isPedInVehicle(localPlayer) then
				if getElementModel(getPedOccupiedVehicle(localPlayer)) == id then
					guiSetVisible(shop_gui.window[1], false)
					showCursor(false)
					outputChatBox("You successfully sold " .. vehicleName .. ".", 0, 255, 0)
					-- اضافه کردن تابع برای پاک کردن تب‌ها
					closeShopPanel()
					triggerServerEvent("MTAZeu:onClientSuccessSellsVehicle", localPlayer, target, currency_item, buyprice, sellprice, x, y, z, rx, ry, rz, id, engine, rotor, tires, tankparts, scrap, slots, fuel)
				else
					guiSetText(shop_gui.label[4], "You don't have that Vehicle")
				end
			else
				guiSetText(shop_gui.label[4], "You don't have any Vehicle")
			end
		end
		
		-- elseif (shop_marker_type == "vehicle") then
		-- 	local target = localPlayer;
		-- 	local vehicleName = guiGridListGetItemText(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),1)
		-- 	local id,engine,rotor,tires,tankparts,scrap,slots,fuel,buyprice,sellprice = unpack(guiGridListGetItemData(shop_gui.gridlist[1],guiGridListGetSelectedItem(shop_gui.gridlist[1]),1))
		-- 	local x,y,z,rx,ry,rz = unpack(vehicle_spawn_position)
		-- 	guiLabelSetColor(shop_gui.label[4],255,0,0)
		-- 	if isPedInVehicle(localPlayer) then
		-- 		if getElementModel(getPedOccupiedVehicle(localPlayer)) == id then
		-- 			-- for i,v in ipairs(getElementsWithinColShape(vehicle_spawn_position_col[shop_marker],"vehicle")) do
		-- 			-- 	guiSetText(shop_gui.label[4],"Vehicle spawn area is taken, clear it before buying vehicle.")
		-- 			-- 	return
		-- 			-- end
		-- 			guiSetVisible(shop_gui.window[1],false)
		-- 			showCursor(false)
		-- 			outputChatBox("You successfully sold "..vehicleName..".",0,255,0)
		-- 			triggerServerEvent("MTAZeu:onClientSuccessSellsVehicle",localPlayer,target,currency_item,buyprice,sellprice,x,y,z,rx,ry,rz,id,engine,rotor,tires,tankparts,scrap,slots,fuel)
		-- 		else
		-- 			guiSetText(shop_gui.label[4], "You don't have that Vehicle")
		-- 		end
		-- 	else
		-- 		guiSetText(shop_gui.label[4], "You don't have any Vehicle")
		-- 	end
		-- end
	end
end





addEventHandler("onClientGUIClick",resourceRoot,function()
	if (source == shop_gui.button[1]) then
		buyItem()
		if (shop_marker_type == "supply") then
			local amount,buyprice,sellprice,itemdata = unpack(guiGridListGetItemData(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),2))
			if (getElementData(localPlayer,itemdata) >= 0) then
				guiGridListSetItemColor(shop_gui.gridlist[1],guiGridListGetSelectedItem(shop_gui.gridlist[1]),1,0,255,0)
			end
		end
	elseif (source == shop_gui.button[2]) then
		sellItem()
		if (shop_marker_type == "supply") then
			local amount,buyprice,sellprice,itemdata = unpack(guiGridListGetItemData(shop_gui.gridlist[1], guiGridListGetSelectedItem(shop_gui.gridlist[1]),2))
			if (getElementData(localPlayer,itemdata) <= 1) then
				guiGridListSetItemColor(shop_gui.gridlist[1],guiGridListGetSelectedItem(shop_gui.gridlist[1]),1,255,255,255)
			end
		end
	elseif (source == shop_gui.button[3]) then
		if getElementData(localPlayer, "logedin") then
			for i,v in pairs(shop_items) do
				if (i == shop_humanity_type) then
					for i,v in pairs(v) do
						if (i == shop_marker_type) then
							for i,v in pairs(v) do
								guiDeleteTab(guiGetSelectedTab(shop_gui.tabpanel[1]),shop_gui.tabpanel[1])
							end
						end
					end
				end
			end
			if (guiGetVisible(shop_gui.window[1]) == true) then
				guiSetVisible( shop_gui.window[1], false )
				showCursor(false)
				if (isEventHandlerAdded("onClientGUIClick",shop_gui.gridlist[1],updateItems)) then
					removeEventHandler("onClientGUIClick",shop_gui.gridlist[1],updateItems)
				end
				shop_marker = nil;
				shop_marker_type = nil;
				shop_humanity_type = nil;
				vehicle_spawn_position = nil;
				killErrorMessageTimer();

			end
		end
	end
end)

addEventHandler("onClientElementDataChange",root,function(data)
	if getElementData(localPlayer, "logedin") then
		if (string.find(data,currency_item)) then
			guiSetText(shop_gui.label[1], " zKills: "..getElementData(localPlayer, currency_item))
		end
	end
end)



-- addEventHandler("onClientResourceStart",resourceRoot,function()

	local screenW, screenH = guiGetScreenSize()
	shop_gui.window[1] = guiCreateStaticImage((screenW - 639) / 2, (screenH - 546) / 2, 639, 546, ":e_login/window1.png", false)
	guiSetAlpha(shop_gui.window[1], 0.95)
	guiSetProperty(shop_gui.window[1], "Alpha", "0.950000")
	guiSetVisible(shop_gui.window[1],false)

	shop_gui.tabpanel[1] = guiCreateTabPanel(10, 26, 450, 485, false, shop_gui.window[1])
	
	------------------------------
	local gLW,gLH = guiGetSize(shop_gui.tabpanel[1],false)
	local gLX,gLY = guiGetPosition(shop_gui.tabpanel[1],false)
	shop_gui.gridlist[1] = guiCreateGridList(gLX, gLY + 24, gLW, gLH, false, shop_gui.window[1])
	guiGridListAddColumn(shop_gui.gridlist[1], "", 0.6)
	guiGridListAddColumn(shop_gui.gridlist[1], "Buy Price", 0.15)
	guiGridListAddColumn(shop_gui.gridlist[1], "Sell Price", 0.15)
	guiSetProperty(shop_gui.gridlist[1],"SortSettingEnabled","False")
	guiSetProperty(shop_gui.gridlist[1], "AlwaysOnTop", "True")


	shop_gui.button[1] = guiCreateButton(480, 500, 60, 32, "BUY", false, shop_gui.window[1])
	shop_gui.button[2] = guiCreateButton(555, 500, 60, 32, "SELL", false, shop_gui.window[1])
	shop_gui.button[3] = guiCreateButton(591, 20, 25, 25, "X", false, shop_gui.window[1])
	shop_gui.label[1] = guiCreateLabel(400, 20, 130, 15, " zKills: "..getElementData(localPlayer, currency_item), false, shop_gui.window[1])

	-----------------------------
	shop_gui.label[4] = guiCreateLabel(187, 22, 349, 26, "", false, shop_gui.window[1])
	guiLabelSetHorizontalAlign(shop_gui.label[4], "right", false)
	guiLabelSetVerticalAlign(shop_gui.label[4], "center")



	function updateShop()

			
		if (shop_marker_type == "supply") then
			-- guiGridListClear(shop_gui.gridlist[1])
			


			guiGridListClear(shop_gui.gridlist[1])
			guiGridListSetColumnTitle(shop_gui.gridlist[1],1,"Item")

			
			-- loads categories
			for i,v in pairs(shop_items) do
				if (i == shop_humanity_type) then
					for i,v in pairs(v) do
						if (i == shop_marker_type) then
							for i,v in pairs(v) do
								local row = guiCreateTab(i, shop_gui.tabpanel[1])
							end
						end
					end
				end
			end

			
			-- loads items from player choosed category
			
			
			
			function updateItems()
				guiGridListClear(shop_gui.gridlist[1])
				local category = guiGetText(guiGetSelectedTab(shop_gui.tabpanel[1]))
				if (category ~= "") then
					for i,v in pairs(shop_items) do
						if (i == shop_humanity_type) then
							for i,v in pairs(v) do
								if (i == shop_marker_type) then
									if v[category] then
										for i,v in ipairs(v[category]) do
											local row = guiGridListAddRow(shop_gui.gridlist[1])
											local text1 = v[1] or "N/A" -- بررسی مقداردهی
											local text2 = v[3] or "N/A" -- بررسی مقداردهی
											local text3 = v[4] or "N/A" -- بررسی مقداردهی
											guiGridListSetItemText(shop_gui.gridlist[1], row, 1, text1, false, false)
											guiGridListSetItemText(shop_gui.gridlist[1], row, 2, text2, false, false)
											guiGridListSetItemText(shop_gui.gridlist[1], row, 3, text3, false, false)
											guiGridListSetItemData(shop_gui.gridlist[1], row, 2, {v[2],v[3],v[4],v[1]})
										end
									else
										outputChatBox("Error: Table for category is nil")
									end
								end
							end
						end
					end
					removeEventHandler("onClientRender",root,updateItems)
				end
			end
			
			addEventHandler("onClientGUIClick",shop_gui.tabpanel[1],updateItems,false)
			addEventHandler("onClientRender",root,updateItems)
			
			
			
			
			
			
			
			-- function updateItems()
			-- 	guiGridListClear(shop_gui.gridlist[1])
			-- 	local category = guiGetText(guiGetSelectedTab(shop_gui.tabpanel[1]))
			-- 	if (category ~= "") then
			-- 		for i,v in pairs(shop_items) do
			-- 			if (i == shop_humanity_type) then
			-- 				for i,v in pairs(v) do
			-- 					if (i == shop_marker_type) then
			-- 						if v[category] then -- اضافه کردن بررسی برای اطمینان از مقداردهی جدول
			-- 							for i,v in ipairs(v[category]) do
			-- 								local row = guiGridListAddRow(shop_gui.gridlist[1])
			-- 								guiGridListSetItemText(shop_gui.gridlist[1], row, 1, exports.dayzepoch:getLanguageTextClient(v[1]), false, false)
			-- 								guiGridListSetItemText(shop_gui.gridlist[1], row, 2, v[3], false, false)
			-- 								guiGridListSetItemText(shop_gui.gridlist[1], row, 3, v[4], false, false)
			-- 								guiGridListSetItemData(shop_gui.gridlist[1], row, 2, {v[2],v[3],v[4],v[1]})
			-- 								-- if (getElementData(localPlayer,v[1]) > 0) then
			-- 								--     guiGridListSetItemColor(shop_gui.gridlist[1],row,1,0,255,0)
			-- 								-- end
			-- 							end
			-- 						else
			-- 							outputChatBox("Error: Table for category is nil")
			-- 						end
			-- 					end
			-- 				end
			-- 			end
			-- 		end
			-- 		removeEventHandler("onClientRender",root,updateItems)
			-- 	end
			-- end
			-- addEventHandler("onClientGUIClick",shop_gui.tabpanel[1],updateItems,false)
			-- addEventHandler("onClientRender",root,updateItems)
			


			-- function updateItems()
			-- 	guiGridListClear(shop_gui.gridlist[1])
			-- 	local category = guiGetText(guiGetSelectedTab(shop_gui.tabpanel[1]))
				
			-- 	if (category ~= "") then
			-- 		for i,v in pairs(shop_items) do
			-- 			if (i == shop_humanity_type) then
			-- 				for i,v in pairs(v) do
			-- 					if (i == shop_marker_type) then
			-- 						for i,v in ipairs(v[category]) do
			-- 							local row = guiGridListAddRow(shop_gui.gridlist[1])
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 1, exports.dayzepoch:getLanguageTextClient(v[1]), false, false)
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 2, v[3], false, false)
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 3, v[4], false, false)
			-- 							guiGridListSetItemData(shop_gui.gridlist[1], row, 2, {v[2],v[3],v[4],v[1]})
			-- 							-- if (getElementData(localPlayer,v[1]) > 0) then
			-- 							-- 	guiGridListSetItemColor(shop_gui.gridlist[1],row,1,0,255,0)
			-- 							-- end
			-- 						end
			-- 					end
			-- 				end	
			-- 			end
			-- 		end
			-- 		removeEventHandler("onClientRender",root,updateItems)
			-- 	end
			-- end
			-- addEventHandler("onClientGUIClick",shop_gui.tabpanel[1],updateItems,false) 
			-- addEventHandler("onClientRender",root,updateItems)
		elseif (shop_marker_type == "vehicle") then
			guiGridListClear(shop_gui.gridlist[1])
			guiGridListSetColumnTitle(shop_gui.gridlist[1],1,"Item")


			-- loads categories
			for i,v in pairs(shop_items) do
				if (i == shop_humanity_type) then
					for i,v in pairs(v) do
						if (i == shop_marker_type) then
							for i,v in pairs(v) do
								local row = guiCreateTab(i, shop_gui.tabpanel[1])
							end
						end
					end
				end
			end

			-- loads items from player choosed category

			-- فایل shop_c.lua

			function updateItems()
				-- پاک کردن لیست قبلی
				guiGridListClear(shop_gui.gridlist[1])
				
				local category = guiGetText(guiGetSelectedTab(shop_gui.tabpanel[1]))
				if (category ~= "") then
					for i,v in pairs(shop_items) do
						if (i == shop_humanity_type) then
							for i,v in pairs(v) do
								if (i == shop_marker_type) then
									if v[category] then
										for i,v in ipairs(v[category]) do
											local row = guiGridListAddRow(shop_gui.gridlist[1])
											local text1 = v[1] or "N/A" -- بررسی مقداردهی
											local text2 = v[10] or "N/A" -- بررسی مقداردهی
											local text3 = v[11] or "N/A" -- بررسی مقداردهی
											guiGridListSetItemText(shop_gui.gridlist[1], row, 1, text1, false, false)
											guiGridListSetItemText(shop_gui.gridlist[1], row, 2, text2, false, false)
											guiGridListSetItemText(shop_gui.gridlist[1], row, 3, text3, false, false)
											guiGridListSetItemData(shop_gui.gridlist[1], row, 1, {v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11]})
										end
									else
										outputChatBox("Error: Table for category is nil")
									end
								end
							end
						end
					end
					removeEventHandler("onClientRender", root, updateItems)
				end
			end
			
			addEventHandler("onClientGUIClick", shop_gui.tabpanel[1], updateItems, false)
			addEventHandler("onClientRender", root, updateItems)
			
			

			


			-- function updateItems()
			-- 	guiGridListClear(shop_gui.gridlist[1])
			-- 	local category = guiGetText(guiGetSelectedTab(shop_gui.tabpanel[1]))
			-- 	if (category ~= "") then
			-- 		for i,v in pairs(shop_items) do
			-- 			if (i == shop_humanity_type) then
			-- 				for i,v in pairs(v) do
			-- 					if (i == shop_marker_type) then
			-- 						for i,v in ipairs(v[category]) do
			-- 							local row = guiGridListAddRow(shop_gui.gridlist[1])
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 1, v[1], false, false)
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 2, v[10], false, false)
			-- 							guiGridListSetItemText(shop_gui.gridlist[1], row, 3, v[11], false, false)
			-- 							guiGridListSetItemData(shop_gui.gridlist[1], row, 1, {v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11]})
			-- 						end
			-- 					end
			-- 				end	
			-- 			end
			-- 		end
			-- 		removeEventHandler("onClientRender",root,updateItems)
			-- 	end
			-- end
			-- addEventHandler("onClientGUIClick",shop_gui.tabpanel[1],updateItems,false)
			-- addEventHandler("onClientRender",root,updateItems)
		end
	end
-- end)




-- [[ SOME USEFUL FUNCTIONS ]]



function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
    local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                return true
                end
            end
        end
    end
    return false
end

function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font,checkBuildings,checkVehicles,checkPeds,checkDummies,seeThroughStuff,ignoreSomeObjectsForCamera,ignoredElement)
				local x, y, z = getPedBonePosition(TheElement,6)
				local x2, y2, z2 = getPedBonePosition(localPlayer,6)
				local distance = distance or 20
				local height = height or 1
                                local checkBuildings = checkBuildings or true
                                local checkVehicles = checkVehicles or false
                                local checkPeds = checkPeds or false
                                local checkObjects = checkObjects or true
                                local checkDummies = checkDummies or true
                                local seeThroughStuff = seeThroughStuff or false
                                local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
                                local ignoredElement = ignoredElement or nil
				if (isLineOfSightClear(x, y, z, x2, y2, z2, checkBuildings, checkVehicles, checkPeds , checkObjects,checkDummies,seeThroughStuff,ignoreSomeObjectsForCamera,ignoredElement)) then
					local sx, sy = getScreenFromWorldPosition(x, y, z+height)
					if(sx) and (sy) then
						local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
						if(distanceBetweenPoints < distance) then
							dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1), font or "arial", "center", "center")
			end
		end
	end
end


---test
function closeShopPanel()
    guiGridListClear(shop_gui.gridlist[1])
    for i, tab in ipairs(guiGetChildren(shop_gui.tabpanel[1])) do
        destroyElement(tab)
    end
end
---test
