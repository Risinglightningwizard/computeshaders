extends Sprite2D


func _ready():
	var rd := RenderingServer.create_local_rendering_device()
	var shader_file := load("res://imageintake.gd")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	var pipeline := rd.compute_pipeline_create(shader)
	
	var img := makeimage()
	
	var buffer_uniform = RDUniform.new()
	var img_pba = img.get_data()
	var fmt = RDTextureFormat.new()
	fmt.width = img.get_width()
	fmt.height = img.get_height()
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	fmt.format = img.get_format()
	
	var v_tex = rd.texture_create(fmt, RDTextureView.new(), [img_pba])
	
	var samp_state = RDSamplerState.new()
	samp_state.unnormalized_uvw = true
	var samp = rd.sampler_create(samp_state)
	
	var tex_uniform = RDUniform.new()
	tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	tex_uniform.binding = 0
	tex_uniform.add_id(samp)
	tex_uniform.add_id(v_tex)
	var uniform_set = rd.uniform_set_create([buffer_uniform, tex_uniform], shader, 0)
	
	
func makeimage() -> Image:
	return Image.create_empty(100, 100, false, 5)
	pass
