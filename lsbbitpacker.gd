extends Node


class LSB_LZWBitPacker:
	var bit_index: int = 0
	var byte: int = 0

	var chunks: PoolByteArray = PoolByteArray([])

	func _get_bit(value: int, index: int) -> int:
		return (value >> index) & 1

	func _set_bit(value: int, index: int) -> int:
		return value | (1 << index)

	func put_byte():
		chunks.append(byte)
		bit_index = 0
		byte = 0

	func write_bits(value: int, bits_count: int) -> void:
		for i in range(bits_count):
			if self._get_bit(value, i) == 1:
				byte = self._set_bit(byte, bit_index)

			bit_index += 1
			if bit_index == 8:
				self.put_byte()

	func pack() -> PoolByteArray:
		if bit_index != 0:
			self.put_byte()
		return chunks

	func reset() -> void:
		bit_index = 0
		byte = 0
		chunks = PoolByteArray([])
