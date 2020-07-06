extends Node2D


var lzw = preload("res://lzw.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	var msg: PoolByteArray = [
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2
	]

	var compressed = lzw.new().compress_lzw(msg, PoolByteArray([0, 1, 2, 3]))

	for v in compressed[0]:
		print(v)
	print(compressed[1].to_string())

	var decompressed = lzw.new().decompress_lzw((compressed[0] as Array).slice(1, compressed[0].size() - 2), PoolByteArray([0, 1, 2, 3]))
	print(decompressed[1].to_string())

	var res: String
	var i: int = 1
	for v in decompressed[0]:
		res += str(v)
		i += 1
		if i > 10:
			res += '\n'
			i = 1
	print(res)

	var are_the_same: bool = true
	if (decompressed[0] as PoolByteArray).size() == msg.size():
		for ii in range(decompressed[0].size()):
			if decompressed[0][ii] != msg[ii]:
				are_the_same = false
	else:
		are_the_same = false

	print(are_the_same)
