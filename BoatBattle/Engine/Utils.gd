extends Node

func normalise(x, a, b, minx, maxx):
	return (b - a) * ((x - minx) / (maxx - minx)) + a