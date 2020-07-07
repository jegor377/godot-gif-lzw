extends Node


class CodeEntry:
	var sequence: PoolByteArray

	func _init(_sequence):
		sequence = _sequence

	func equals(other):
		if self.sequence.size() == other.sequence.size():
			for i in range(self.sequence.size()):
				if self.sequence[i] != other.sequence[i]:
					return false
			return true
		return false

	func add(other):
		return CodeEntry.new(self.sequence + other.sequence)

	func to_string():
		var result: String = ''
		for element in self.sequence:
			result += str(element) + ', '
		return result.substr(0, result.length() - 2)

class CodeTable:
	var entries: Array = []
	var counter: int = 0

	func add(entry) -> int:
		entries.append({
			'id': self.counter,
			'entry': entry
		})
		counter += 1
		return counter

	func find(entry) -> int:
		for i in range(self.entries.size()):
			if self.entries[i]['entry'].equals(entry):
				return self.entries[i]['id']
		return -1

	func has(entry) -> bool:
		return self.find(entry) != -1

	func get(index) -> CodeEntry:
		for i in range(self.entries.size()):
			if self.entries[i]['id'] == index:
				return self.entries[i]['entry']
		return null

	func to_string() -> String:
		var result: String = 'CodeTable:\n'
		for entry in self.entries:
			result += str(entry['id']) + ': ' + entry['entry'].to_string() + '\n'
		result += 'Counter: ' + str(self.counter) + '\n'
		return result

func log2(value: float) -> float:
	return log(value) / log(2.0)

func get_bits_number_for(value: int) -> int:
	if value == 0:
		return 1
	return int(ceil(log2(value + 1)))

func initialize_color_code_table(colors: PoolByteArray) -> CodeTable:
	var result_code_table: CodeTable = CodeTable.new()
	for color_id in colors:
		# warning-ignore:return_value_discarded
		result_code_table.add(CodeEntry.new([color_id]))
	# move counter to the first available compression code index
	var last_color_index: int = colors.size() - 1
	var clear_code_index: int = pow(2, get_bits_number_for(last_color_index))
	print("Clear Code index: %d, colors count: %d, bits size: %d" % [clear_code_index, colors.size(), get_bits_number_for(last_color_index)])
	result_code_table.counter = clear_code_index + 2
	return result_code_table

# compression and decompression done with source:
# http://www.matthewflickinger.com/lab/whatsinagif/lzw_image_data.asp

func compress_lzw(image: PoolByteArray, colors: PoolByteArray) -> Array:
	var code_table: CodeTable = initialize_color_code_table(colors)
	# Clear Code index is 2**<code size>
	# <code size> is the amount of bits needed to write down all colors
	# from color table. We use last color index because we can write
	# all colors (for example 16 colors) with indexes from 0 to 15.
	# Number 15 is in binary 0b1111, so we'll need 4 bits to write all
	# colors down.
	var last_color_index: int = colors.size() - 1
	var clear_code_index: int = pow(2, get_bits_number_for(last_color_index))
	var code_stream: Array = [clear_code_index] # initialize with Clear Code
	var index_stream: PoolByteArray = image

	var index_buffer: CodeEntry = CodeEntry.new([index_stream[0]])
	index_stream.remove(0)
	while not index_stream.empty():
		var K: CodeEntry = CodeEntry.new([index_stream[0]])
		index_stream.remove(0)
		if code_table.has(index_buffer.add(K)):
			index_buffer = index_buffer.add(K)
		else:
			code_stream.append(code_table.find(index_buffer))
			# warning-ignore:return_value_discarded
			code_table.add(index_buffer.add(K))
			index_buffer = K
	code_stream.append(code_table.find(index_buffer))

	code_stream.append(clear_code_index + 1) # end with End Of Information Code

	return [code_stream, code_table]

func decompress_lzw(data: Array, colors: PoolByteArray) -> Array:
	var code_table: CodeTable = initialize_color_code_table(colors)
	var index_stream: PoolByteArray = PoolByteArray([])
	var code_stream: Array = data

	# CODE is an index of code table, {CODE} is sequence inside
	# code table with index CODE. The same goes for PREVCODE.

	# let CODE be the first code in the code stream
	var code: int = code_stream[0]
	# output {CODE} to index stream
	index_stream.append_array(code_table.get(code).sequence)
	code_stream.remove(0)
	# set PREVCODE = CODE
	var prevcode: int = code
	# <LOOP POINT>
	while not code_stream.empty():
		# let CODE be the next code in the code stream
		code = code_stream[0]
		code_stream.remove(0)
		# is CODE in the code table?
		var code_entry: CodeEntry = code_table.get(code)
		if code_entry != null: # if YES
			# output {CODE} to index stream
			index_stream.append_array(code_entry.sequence)
			# let K be the first index in {CODE}
			var K: CodeEntry = CodeEntry.new([code_entry.sequence[0]])
			# warning-ignore:return_value_discarded
			# add {PREVCODE} + K to the code table
			code_table.add(code_table.get(prevcode).add(K))
			# set PREVCODE = CODE
			prevcode = code
		else: # if NO
			# let K be the first index of {PREVCODE}
			var prevcode_entry: CodeEntry = code_table.get(prevcode)
			var K: CodeEntry = CodeEntry.new([prevcode_entry.sequence[0]])
			# output {PREVCODE} + K to index stream
			index_stream.append_array(prevcode_entry.add(K).sequence)
			# add {PREVCODE} + K to code table
			# warning-ignore:return_value_discarded
			code_table.add(prevcode_entry.add(K))
			# set PREVCODE = CODE
			prevcode = code

	return [index_stream, code_table]
