# godot-gif-lzw
GIF's LZW compression/decompression done in Godot. Whole code is based on GIF specification and [this website](http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp).

# Usage
Firstly, use code from realese only. Secondly, you should have put "gif-lzw" directory somewhere in your project modules directory and preload "lzw.gd" file. Here is how to do it:

### Compression
If you want to compress image, use `compress_lzw(image: PoolByteArray, colors: PoolByteArray) -> Array`.

```gdscript
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

```

### Decompression
If you want to decompress image, use `decompress_lzw(code_stream_data: PoolByteArray, min_code_size: int, colors: PoolByteArray) -> PoolByteArray`.

```gdscript
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

    var decompressed_index_stream: Array = lzw.decompress_lzw(
            compressed_data,
            min_code_size,
            color_table)

```

# Usefull docs
- [GIF specification](https://www.w3.org/Graphics/GIF/spec-gif89a.txt)
- [GIF format implementation tutorial](http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp) (Special thanks to author of this website. I would propably not implement GIF's compression without help of this website.)
- http://www0.cs.ucl.ac.uk/teaching/GZ05/07-images.pdf
- [GIF's LZW compression topic on Wikipedia](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch)
