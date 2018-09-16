local method = {}

-- has bomb?
local function hasbomb(self)
	return player(self._id, 'bomb')
end

-- is in bomb planting area?
local function isinbombplantingarea(self)
	local x, y = player(self._id, 'tilex'), player(self._id, 'tiley')
	return tile(x, y, 'entity') ~= 0 and inentityzone(x, y, 5)
end

function method:decide()
	--[=[
	['Bomb/Defuse'] = {
		-- Terrorist
		[1] = Sequence{
			Behavior.buy,
			Behavior.look,
			Selector{
				Behavior.engage,
				Behavior.whenPanic,
				Failurer(Sequence{
					Behavior.isHiding,
					Inverter(Behavior.isCamping),
					Behavior.dontHide
				}),
				Sequence{
					Behavior.hasBomb,
					Behavior.inBombPlantingArea,
					Behavior.plantBomb
				},
				Failurer(Behavior.switchKnife),
				Sequence{
					Sequence{
						Behavior.hasNoise,
						Behavior.goToNoise
					},
					Behavior.dontHide
				},
				Sequence{
					Behavior.toHidingSpot,
					Behavior.goToHidingSpot
				},
				Sequence{
					Inverter(Behavior.isHiding),
					Selector{
						Behavior.collect,
						Sequence{
							Behavior.isBombPlanted,
							Behavior.findSpotAroundBomb
						},
						Sequence{
							Behavior.isBombDropped,
							Behavior.goToBomb
						},
						Sequence{
							Behavior.isFollower,
							Behavior.followBombHolder
						},
						Behavior.goToBombPlantingArea,
						Sequence{
							Inverter(Behavior.hasBomb),
							Inverter(Behavior.hasEnoughMorale),
							Behavior.setToPanic
						}
					}
				}
			}
		},
		-- Counter-Terrorist
		[2] = Sequence{
			Behavior.buy,
			Behavior.look,
			Selector{
				Behavior.engage,
				Behavior.whenPanic,
				Failurer(Sequence{
					Behavior.isHiding,
					Inverter(Behavior.isCamping),
					Behavior.dontHide
				}),
				Sequence{
					Behavior.isBombPlanted,
					Inverter(Behavior.isSomeoneDefusingBomb),
					Behavior.isAtBomb,
					Behavior.defuseBomb
				},
				Failurer(Behavior.switchKnife),
				Sequence{
					Sequence{
						Behavior.hasNoise,
						Behavior.goToNoise
					},
					Behavior.dontHide
				},
				Sequence{
					Behavior.toHidingSpot,
					Behavior.goToHidingSpot
				},
				Sequence{
					Inverter(Behavior.isHiding),
					Selector{
						Behavior.collect,
						Sequence{
							Behavior.isBombPlanted,
							Selector{
								Sequence{
									Behavior.isSomeoneDefusingBomb,
									Behavior.findSpotAroundBomb
								},
								Sequence{
									Behavior.inBombPlantingArea,
									Behavior.isCloseToBomb,
									Behavior.goToBomb
								}
							}
						},
						Sequence{
							Behavior.isBombDropped,
							Behavior.findSpotAroundBomb
						},
						-- Behavior.goToBombPlantingArea,
						Sequence{
							Inverter(Behavior.hasEnoughMorale),
							Inverter(Behavior.setToPanic)
						},
						Sequence{
							Inverter(Behavior.isBombPlanted),
							Behavior.goToRandomLocation
						}
					}
				}
			}
		}
	]=]
	local id = self._id
	local team = player(id, 'team')
	local tilex, tiley = player(id, 'tilex'), player(id, 'tiley')
	
	if team == 1 then
		local hasbomb = player(id, 'bomb')
		
		if hasbomb then
			-- is in bomb planting area?
			if tile(tilex, tiley, 'entity') ~= 0 and inentityzone(tilex, tiley, 5) then
				-- plant that shit!
				self._mode = 1 return
			end
		end
		
		-- let's switch to knife
		if player(id, 'weapontype') ~= 50 then
			ai_selectweapon(id, 50)
		end
	end
end

function method:behavior()
	local id = self._id
	local team = player(id, 'team')
	
	if team == 1 then
		if self._mode == 1 then
			if player(id, 'weapontype') ~= 55 then
				ai_selectweapon(id, 55)
			end
			
			ai_attack(id)
		end
	else
	end
end

return method