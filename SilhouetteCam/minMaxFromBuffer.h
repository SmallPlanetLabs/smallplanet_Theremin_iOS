/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Defines a function which extracts the smallest and largest values from a pixel buffer.
*/

#ifndef minMaxFromBuffer_h
#define minMaxFromBuffer_h

#import <CoreVideo/CoreVideo.h>
#import <Metal/Metal.h>

//----
void minMaxFromPixelBuffer(CVPixelBufferRef pixelBuffer, float* minValue, float* maxValue, MTLPixelFormat pixelFormat);

// rename
NSArray* pixelConfigurationArrayFromDepthPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat, float depthThreshold, uint32_t* bytesPerPixel);
float calculateAverage(float *array, int count);
#endif /* minMaxFromBuffer_h */
