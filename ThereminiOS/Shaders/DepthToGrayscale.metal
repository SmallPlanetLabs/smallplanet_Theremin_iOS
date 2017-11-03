/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Metal compute shader that translates depth values to grayscale RGB values.
*/

#include <metal_stdlib>
using namespace metal;

struct converterParameters {
	float offset;
    float range;
};

// Compute kernel
kernel void depthToGrayscale(texture2d<float, access::read>  inputTexture      [[ texture(0) ]],
						     texture2d<half, access::write> outputTexture     [[ texture(1) ]],
							 constant converterParameters& converterParameters [[ buffer(0) ]],
							 uint2 gid [[ thread_position_in_grid ]])
{
	// Ensure we don't read or write outside of the texture
	if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
		return;
	}

	float depth = inputTexture.read(gid).x;
	
	// Normalize the value between 0 and 1
	depth = (depth - converterParameters.offset) / (converterParameters.range);

    half4 outputColor = half4(depth, depth, depth, 1.0);
//    float4 outputColor = float4(0.0, 1.0, 0.0, 0.3);;
    
    if (depth > .6) {
        // make black
        float rgbValue = depth;
        outputColor = half4(rgbValue, rgbValue, rgbValue, 0.5);
    } else {
        // maybe get pixels of input texture.. ? 
        
        // make clear otherwise
        outputColor = half4(0, 0.0, 0.0, 0.3);
    }
    
	outputTexture.write(outputColor, gid);
}

//// ENSURE INPUT AND OUTPUT TEXTURES ARE CORRECT...
//kernel void silhouetteAndOriginalMix(texture2d<half, access::read>  inputTexture  [[ texture(0) ]],
//                                     texture2d<half, access::read>  inputTextureB  [[ texture(0) ]],
//                                   texture2d<half, access::write> outputTexture [[ texture(1) ]],
//                                   uint2 gid [[thread_position_in_grid]])
//{
//    // Make sure we don't read or write outside of the texture
//    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
//        return;
//    }
//
//    half4 inputColor = inputTexture.read(gid);
//
//    // finish this:::
//
//
//    // Set the output color to the input color minus the green component
//    half4 outputColor = half4(inputColor.r, inputColor.g, inputColor.b, 1.0);
//
//    if (inputColor.a == 0) {
//        outputColor =
//    }
//
//
//    outputTexture.write(outputColor, gid);
//}

