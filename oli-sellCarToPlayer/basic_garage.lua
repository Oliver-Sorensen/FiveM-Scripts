
MySQL.createCommand("vRP/sell_vehicle_player","UPDATE vrp_user_vehicles SET user_id = @user_id, vehicle_plate = @registration WHERE user_id = @oldUser AND vehicle = @vehicle")

-- sælg bil til spiller.
veh_actions[lang.vehicle.sellTP.title()] = {function(playerID,player,vtype,name)
	if playerID ~= nil then
		vRPclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. vRP.getUserId(k) .. "]" .. GetPlayerName(k) .. " | "
			end
			if usrList ~= "" then
				vRP.prompt(player,"Spillere i nærheden: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id ~= nil and user_id ~= "" then 
						local target = vRP.getUserSource(tonumber(user_id))
						if target ~= nil then
							vRP.prompt(player,"Price $: ","",function(player,amount)
								if (tonumber(amount)) and (tonumber(amount) > 0) then
									MySQL.query("vRP/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
										if #pvehicle > 0 then
									              	vRPclient.notify(player,{"~r~Spilleren ejer allerede denne bil."})
										else
											local tmpdata = vRP.getUserTmpTable(playerID)
											if tmpdata.rent_vehicles[name] == true then
												vRPclient.notify(player,{"~r~Du kan ikke sælge en bil der er lejet."})
												return
											else
												vRP.request(target,GetPlayerName(player).." ønsker at sælge: " ..name.. " Pris: DKK"..amount, 10, function(target,ok)
													if ok then
														local pID = vRP.getUserId(target)
														local money = vRP.getMoney(pID)
														if (tonumber(money) >= tonumber(amount)) then
															vRPclient.despawnGarageVehicle(player,{vtype,15}) 
															vRP.getUserIdentity(pID, function(identity)
																MySQL.execute("vRP/sell_vehicle_player", {user_id = user_id, registration = "P "..identity.registration, oldUser = playerID, vehicle = name}) 
															end)
															vRP.giveMoney(playerID, amount)
															vRP.setMoney(pID,money-amount)
															vRPclient.notify(player,{"~g~Du har lige solgt din bil til ".. GetPlayerName(target).." for DKK"..amount.."!"})
															vRPclient.notify(target,{"~g~"..GetPlayerName(player).." du har lige solgt din bil for DKK"..amount.."!"})
														else
															vRPclient.notify(player,{"~r~".. GetPlayerName(target).." har ikke nok penge!"})
															vRPclient.notify(target,{"~r~Du har ikke nok penge!"})
														end
													else
														vRPclient.notify(player,{"~r~"..GetPlayerName(target).." har nægtet at købe din bil."})
														vRPclient.notify(target,{"~r~Du har nægtet at købe "..GetPlayerName(player).."'s bil."})
													end
												end)
											end
											vRP.closeMenu(player)
										end
									end) 
								else
									vRPclient.notify(player,{"~r~Prisen på bilen skal være i tal."})
								end
							end)
						else
							vRPclient.notify(player,{"~r~Det ID findes ikke."})
						end
					else
						vRPclient.notify(player,{"~r~Vælg en spillers ID!"})
					end
				end)
			else
				vRPclient.notify(player,{"~r~Ingen spiller i nærheden."})
			end
		end)
	end
end, lang.vehicle.sellTP.description()}
