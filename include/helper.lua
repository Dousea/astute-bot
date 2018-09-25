function helper_angleto(x1, y1, x2, y2)
	return math.deg(math.atan2(x2-x1, y1-y2))
end

function helper_angledelta(a1, a2)
	local d = (a2-a1) % 360
	if d < -180 then d = d+360 end
	if d > 180 then d = d-360 end
	return d
end

function helper_dist(x1, y1, x2, y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end