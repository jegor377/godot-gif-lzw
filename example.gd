extends Node2D


var lzw_module = load("res://gif-lzw/lzw.gd")
var lzw = lzw_module.new()


func _ready():
	var image: PoolByteArray = [
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

	var compressed_res: Array = lzw.compress_lzw(image, color_table)
	var compressed_data: PoolByteArray = compressed_res[0]
	var min_code_size: int = compressed_res[1]

	var res: String
	for v in compressed_data:
		res += "%X, " % v
	print(res.substr(0, res.length() - 2))
	print("Min code size: %d" % min_code_size)

	var decompressed_index_stream: Array = lzw.decompress_lzw(
			compressed_data,
			min_code_size,
			color_table)

	res = ''
	var i: int = 1
	for v in decompressed_index_stream:
		res += str(v)
		i += 1
		if i > 10:
			res += '\n'
			i = 1
	print(res)

	var are_the_same: bool = true
	if (decompressed_index_stream as PoolByteArray).size() == image.size():
		for ii in range(decompressed_index_stream.size()):
			if decompressed_index_stream[ii] != image[ii]:
				are_the_same = false
	else:
		are_the_same = false

	print(are_the_same)
