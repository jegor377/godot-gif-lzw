extends Node2D


var lzw = preload("res://lzw.gd")
var lsbbitpacker = preload("res://lsbbitpacker.gd")


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
	var compressed: Array = lzw.new().compress_lzw(msg, color_table)

#	for v in compressed[0]:
#		print(v)
#	print(compressed[1].to_string())
	for i in range(compressed[0].size()):
		print("CODE: %d, BITS COUNT: %d" % [compressed[0][i], compressed[2][i]])

	var decompressed = lzw.new().decompress_lzw((compressed[0] as Array).slice(1, compressed[0].size() - 2), color_table)
#	print(decompressed[1].to_string())

#	var res: String
#	var i: int = 1
#	for v in decompressed[0]:
#		res += str(v)
#		i += 1
#		if i > 10:
#			res += '\n'
#			i = 1
#	print(res)

	var are_the_same: bool = true
	if (decompressed[0] as PoolByteArray).size() == msg.size():
		for ii in range(decompressed[0].size()):
			if decompressed[0][ii] != msg[ii]:
				are_the_same = false
	else:
		are_the_same = false

	print(are_the_same)

	var lsb_bit_packer = lsbbitpacker.LSB_LZWBitPacker.new()
	for i in range(compressed[0].size()):
		lsb_bit_packer.write_bits(compressed[0][i], compressed[2][i])

	var result_packed_bits: PoolByteArray = lsb_bit_packer.pack()

	var res: String

	for v in result_packed_bits:
		res += '%X, ' % v

	print(res.substr(0, res.length() - 2))
