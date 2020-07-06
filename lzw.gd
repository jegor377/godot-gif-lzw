extends Node


class CodeEntry:
	var sequence: PoolByteArray

	func _init(sequence):
		self.sequence = sequence

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

func initialize_color_table(colors: PoolByteArray) -> CodeTable:
	var result_code_table: CodeTable = CodeTable.new()
	for color_id in colors:
		result_code_table.add(CodeEntry.new([color_id]))
	result_code_table.counter += 2
	return result_code_table

func pop_front(input: PoolByteArray) -> PoolByteArray:
	if not input.empty():
		input.remove(0)
		return input
	return PoolByteArray([])

# compression and decompression done with sources:
# decompression http://www.matthewflickinger.com/lab/whatsinagif/lzw_image_data.asp
# compression http://www0.cs.ucl.ac.uk/teaching/GZ05/07-images.pdf

func compress_lzw(image: PoolByteArray, colors: PoolByteArray) -> Array:
	var code_table: CodeTable = initialize_color_table(colors)
	var input: PoolByteArray = image
	var output: Array = [colors.size()]
	var a: CodeEntry
	var b: CodeEntry

	a = CodeEntry.new([input[0]])
	input = pop_front(input)
	while not input.empty():
		b = CodeEntry.new([input[0]])
		input = pop_front(input)
		if code_table.has(a.add(b)):
			a = a.add(b)
		else:
			output.append(code_table.find(a))
			code_table.add(a.add(b))
			a = b
	output.append(code_table.find(a))
	output.append(colors.size() + 1)

	return [output, code_table]

func decompress_lzw(data: Array, colors: PoolByteArray) -> Array:
	var code_table: CodeTable = initialize_color_table(colors)
	var output: PoolByteArray
	var stream: Array = data

	var code: int = stream[0]
	output.append_array(code_table.get(code).sequence)
	stream.remove(0)
	var prevcode: int = code
	while not stream.empty():
		code = stream[0]
		stream.remove(0)
		var code_entry: CodeEntry = code_table.get(code)
		if code_entry != null:
			output.append_array(code_entry.sequence)
			var k: CodeEntry = CodeEntry.new([code_entry.sequence[0]])
			code_table.add(code_table.get(prevcode).add(k))
			prevcode = code
		else:
			var prevcode_entry: CodeEntry = code_table.get(prevcode)
			var k: CodeEntry = CodeEntry.new([prevcode_entry.sequence[0]])
			output.append_array(prevcode_entry.add(k).sequence)
			code_table.add(prevcode_entry.add(k))
			prevcode = code

	return [output, code_table]
