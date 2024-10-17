--[[
	Code Author: kaasis/rivor2
	Contact Info: http://steamcommunity.com/id/rivor2
]]--

-- give item if all went success
function onClientSuccessBuysItem(target,item,currency,amount,buyprice,sellprice)
	setElementData(target,item,getElementData(target,item)+amount)
	setElementData(target,currency,getElementData(target,currency)-buyprice)
end
addEvent("MTAZeu:onClientSuccessBuysItem",true)
addEventHandler("MTAZeu:onClientSuccessBuysItem",getRootElement(),onClientSuccessBuysItem)

function onClientSuccessSellsItem(target,item,currency,amount,buyprice,sellprice)
	setElementData(target,item,getElementData(target,item)-amount)
	setElementData(target,currency,getElementData(target,currency)+sellprice)
end
addEvent("MTAZeu:onClientSuccessSellsItem",true)
addEventHandler("MTAZeu:onClientSuccessSellsItem",getRootElement(),onClientSuccessSellsItem)

-- spawn vehicle if all went success
function onClientSuccessBuysVehicle(target,currency,buyprice,sellprice,x,y,z,rx,ry,rz,id,engine,rotor,tires,tankparts,scrap,slots,fuel)
	if getElementData(target,currency) < buyprice then return; end
	local veh = createVehicle(id,x,y,z,rx,ry,rz);
	local vehCol = createColSphere(x,y,z,2.5);
	if (id == 528) then setVehicleDamageProof(veh,true); end
	attachElements(vehCol,veh);
	setElementData(vehCol,"parent",veh);
	setElementData(veh,"parent",vehCol);
	setElementData(vehCol,"vehicle",true);
	setElementData(veh,"dayzvehicle",0);
	setElementData(vehCol,"MAX_Slots",tonumber(slots));
	setElementData(vehCol,"Engine_inVehicle",engine);
	setElementData(vehCol,"Rotor_inVehicle",rotor);
	setElementData(vehCol,"Tire_inVehicle",tires);
	setElementData(vehCol,"Parts_inVehicle",tankparts);
	setElementData(vehCol,"Scrap_inVehicle",scrap);
	setElementData(vehCol,"needtires", tires);
	setElementData(vehCol,"needparts", tankparts);
	setElementData(vehCol,"needscrap", scrap);
	setElementData(vehCol,"needrotor", rotor);
	setElementData(vehCol,"needengines", engine);
	setElementData(vehCol,"spawn",{id,x,y,z});
	setElementData(vehCol,"fuel",fuel);
	setElementData(target,currency,getElementData(target,currency)-buyprice)
end
addEvent("MTAZeu:onClientSuccessBuysVehicle",true)
addEventHandler("MTAZeu:onClientSuccessBuysVehicle",getRootElement(),onClientSuccessBuysVehicle)


function onClientSuccessSellsVehicle(target,currency,buyprice,sellprice,x,y,z,rx,ry,rz,id,engine,rotor,tires,tankparts,scrap,slots,fuel)
	local attachedElementsToVeh1 = getAttachedElements(getPedOccupiedVehicle(target))
	for i,v in ipairs(attachedElementsToVeh1) do
		if (getElementType(v) == "colshape") then
			setElementData(v, "deadVehicle", true)
			setElementData(v,"parent",nil)
			destroyElement(v)
			-- outputChatBox("deleted colshape")
		end
	end
	local veh = getPedOccupiedVehicle(target)
	setElementData(veh,"parent",nil)
	setElementData(veh, "isExploded", true)
	setTimer(function()
		destroyElement(veh)
	end,100,1,veh)
	-- outputChatBox("vehicle destroyed")

	setElementData(target,currency,getElementData(target,currency)+sellprice)
end
addEvent("MTAZeu:onClientSuccessSellsVehicle",true)
addEventHandler("MTAZeu:onClientSuccessSellsVehicle",getRootElement(),onClientSuccessSellsVehicle)

addEventHandler("onPlayerLogin",root,function()
	triggerClientEvent(source,"load_shop",source);
end)