#version 430

#include "../fragments/fs_common_inputs.glsl"

// We output a single color to the color buffer
layout(location = 0) out vec4 frag_color;

////////////////////////////////////////////////////////////////
/////////////// Instance Level Uniforms ////////////////////////
////////////////////////////////////////////////////////////////

// Represents a collection of attributes that would define a material
// For instance, you can think of this like material settings in 
// Unity
struct Material {
	sampler2D Diffuse;
	float     Shininess;
	sampler1D oneDLut;
};
// Create a uniform for the material
uniform Material u_Material;

////////////////////////////////////////////////////////////////
///////////// Application Level Uniforms ///////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/multiple_point_lights.glsl"

////////////////////////////////////////////////////////////////
/////////////// Frame Level Uniforms ///////////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/frame_uniforms.glsl"
#include "../fragments/color_correction.glsl"

// https://learnopengl.com/Advanced-Lighting/Advanced-Lighting
void main() {
	if (IsFlagSet(FLAG_ENABLE_NO_LIGHT))
	{
		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		frag_color = vec4(textureColor.rgb, textureColor.a);
	}
	else if (IsFlagSet(FLAG_ENABLE_AMBIENT_LIGHT))
	{
		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcAmbientLight();

		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
	else if (IsFlagSet(FLAG_ENABLE_SPECULAR_LIGHT))
	{
		// Normalize our input normal
		vec3 normal = normalize(inNormal);

		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcSpecularLight(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);

		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
	else if (IsFlagSet(FLAG_ENABLE_AMBIENT_SPECULAR_LIGHT))
	{
		// Normalize our input normal
		vec3 normal = normalize(inNormal);

		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcSpecularLight(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);
		lightAccumulation += CalcAmbientLight();
		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
	else if (IsFlagSet(FLAG_ENABLE_AMBIENT_SPECULAR_CUSTOM))
	{
		// Normalize our input normal
		vec3 normal = normalize(inNormal);

		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcSpecularLight(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);
		lightAccumulation += CalcAmbientLight();
		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		result.x = sin(result.x + u_Time * 1.2);
		result.y = sin(result.y + u_Time * 1.2 + 0.5);
		result.z = sin(result.z + u_Time * 1.2 + 1);

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}

	else if (IsFlagSet(FLAG_ENABLE_DIFFUSE_RAMP))
	{
		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		textureColor.r = texture(u_Material.oneDLut, textureColor.r).r;
		textureColor.g = texture(u_Material.oneDLut, textureColor.g).g;
		textureColor.b = texture(u_Material.oneDLut, textureColor.b).b;

		frag_color = textureColor;
	}
	else if (IsFlagSet(FLAG_ENABLE_SPECULAR_RAMP))
	{
		// Normalize our input normal
		vec3 normal = normalize(inNormal);

		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcSpecularLight(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);

		lightAccumulation.r = texture(u_Material.oneDLut, lightAccumulation.r).r;
		lightAccumulation.g = texture(u_Material.oneDLut, lightAccumulation.g).g;
		lightAccumulation.b = texture(u_Material.oneDLut, lightAccumulation.b).b;

		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}

	else
	{
		// Normalize our input normal
		vec3 normal = normalize(inNormal);

		// Use the lighting calculation that we included from our partial file
		vec3 lightAccumulation = CalcAllLightContribution(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);

		// Get the albedo from the diffuse / albedo map
		vec4 textureColor = texture(u_Material.Diffuse, inUV);

		// combine for the final result
		vec3 result = lightAccumulation  * inColor * textureColor.rgb;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
}