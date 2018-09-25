local helper = require(BOT_DIR .. 'helper')
local method = {}

function method:engage()
	--[=[
	Behavior.engage = Selector{
		Sequence{
			Behavior.findTarget,
			Behavior.hasTarget,
			Behavior.isTargetValid,
			Behavior.isTargetInRange,
			Selector{
				Sequence{
					Behavior.isTargetOnSight,
					Behavior.radioEnemySpotted,
					Succeeder(Sequence{
						Behavior.isTargetOnCorrectAngle,
						Behavior.attack
					})
				},
				Behavior.whenTargetNotOnSight
			},
			Succeeder(Sequence{
				Behavior.isHiding,
				Inverter(Behavior.isCovering),
				Behavior.dontHide
			}),
			Succeeder(Selector{
				Sequence{
					Behavior.isPanic,
					Selector{
						Sequence{
							Behavior.findCover,
							Behavior.goToHidingSpot
						},
						Behavior.backOff
					}
				},
				Behavior.closeCombat
			})
		},
		Behavior.removeTarget
	}
	]=]
	local id = self._id
	local x, y = player(id, 'x'), player(id, 'y')
	local target_x, target_y = self._target_lastx, self._target_lasty
	
	if self._target > 0 then
		if ai_freeline(id, target_x, target_y) then
			-- is on enough angle to attack?
			if math.abs(helper_angledelta(player(id, 'rot'), helper_angleto(x, y, target_x, target_y))) < 20 then
				ai_iattack(id)
			end
			
			-- is the range enough for close combat?
			if itemtype(player(id, 'weapontype'), 'range') < 50 then
				ai_move(id, helper_angleto(x, y, target_x, target_y))
			end
		else
			self:goto(math.floor(target_x/32), math.floor(target_y/32))
		end
	else
		if target_x and target_y then
			self:goto(math.floor(target_x/32), math.floor(target_y/32))
		end
	end
end

return method