extends Node

func normalise(x, a, b, minx, maxx):
	if minx >= maxx:
		print("ERROR IN Utils.normalise: minx >= maxx")
		return 1
	return (b - a) * ((x - minx) / (maxx - minx)) + a