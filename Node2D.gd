extends Node2D


var lzw = load("res://gif-lzw/lzw.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	var msg: PoolByteArray = [
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		2, 2, 2, 0, 0, 0, 0, 1, 1, 1,
		2, 2, 2, 0, 0, 0, 0, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1,
	]

	var color_table: PoolByteArray = PoolByteArray([0, 1, 2, 3])

	var compressed_res: Array = lzw.new().compress_lzw(msg, color_table)

	var res: String
	for v in compressed_res[0]:
		res += "%X, " % v
	print(res.substr(0, res.length() - 2))
	print("Min code size: %d" % compressed_res[1])

	var decompressed_res: Array = lzw.new().decompress_lzw(compressed_res[0], compressed_res[1], color_table)

	res = ''
	var i: int = 1
	for v in decompressed_res:
		res += str(v)
		i += 1
		if i > 10:
			res += '\n'
			i = 1
	print(res)

	var are_the_same: bool = true
	if (decompressed_res as PoolByteArray).size() == msg.size():
		for ii in range(decompressed_res.size()):
			if decompressed_res[ii] != msg[ii]:
				are_the_same = false
	else:
		are_the_same = false

	print(are_the_same)
