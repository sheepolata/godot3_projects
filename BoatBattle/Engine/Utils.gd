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