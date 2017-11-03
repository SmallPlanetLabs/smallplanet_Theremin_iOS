/*
See LICENSE.txt for this sample’s licensing information.
*/

#ifndef minMaxFromBuffer_h
#define minMaxFromBuffer_h

#import <CoreVideo/CoreVideo.h>
#import <Metal/Metal.h>

float averageFromDepthPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat);

#endif /* minMaxFromBuffer_h */
