extends Sprite2D

@export var resolution: int = 20
var renDevice := RenderingServer.create_local_rendering_device()
var shader_file := load("res://fluidcompute.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := renDevice.shader_create_from_spirv(shader_spirv)

# Prepare our data. We use floats in the shader, so we need 32 bit.
var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
var input_bytes := input.to_byte_array()

# Create a storage buffer that can hold our float values.
# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
var buffer := renDevice.storage_buffer_create(input_bytes.size(), input_bytes)

# Create a uniform to assign the buffer to the rendering device
var uniform := RDUniform.new()

var vertical
var horizontal
var height : int
var width : int
var xsize: float
var ysize: float
func _init():
	getselfdimension()
	createarray()
	
	# Create a uniform to assign the buffer to the rendering device
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	var uniform_set := renDevice.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	
	# Create a compute pipeline
	var pipeline := renDevice.compute_pipeline_create(shader)
	var compute_list := renDevice.compute_list_begin()
	renDevice.compute_list_bind_compute_pipeline(compute_list, pipeline)
	renDevice.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	renDevice.compute_list_dispatch(compute_list, 5, 1, 1)
	renDevice.compute_list_end()

func _process(_delta):
	# Submit to GPU and wait for sync
	renDevice.submit()
	renDevice.sync()
	
	var output_bytes := renDevice.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)
	
func getselfdimension():
	xsize = self.scale.x
	ysize = self.scale.y

func createarray():
	width = floor(resolution *(xsize/(ysize+xsize)))
	height = floor(resolution *(ysize/(ysize+xsize)))
	pass
