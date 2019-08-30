extends Node

func normalise(x, a, b, minx, maxx):
	if minx >= maxx:
		print("ERROR IN Utils.normalise: minx >= maxx")
		return 1
	return (b - a) * ((x - minx) / (maxx - minx)) + a
	
#From a to b, step n
func slide(a,b, n):
    if abs(a-b) < n:  return b
    if a > b:  return a-n
    if b > a:  return a+n
	
# returns the difference (in degrees) between angle1 and angle 2
# the given angles must be in the range [0, 360)
# the returned value is in the range (-180, 180]
func angle_difference(angle1, angle2):
    var diff = angle2 - angle1
    return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

#Return angle in [0, 360)
func clamp_angle_degrees(angle):
	if angle > 360:
		return angle - 180
	elif angle < 0:
		return 360 + angle
	else:
		return angle

#return a IN [x, y]
func is_between(a, x, y):
	return a <= y and a >= x

#return a approx. equals b with a offset of offset
func near(a, b, offset) -> bool:
	return is_between(a, b-offset, b+offset)
	
	













