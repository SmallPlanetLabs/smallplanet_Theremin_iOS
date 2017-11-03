/*
See LICENSE.txt for this sample’s licensing information.
*/

#import "averageFromDepthPixelBuffer.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

float averageFromDepthPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat)
{
    int width          = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height         = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    unsigned char* pixelBufferPointer = CVPixelBufferGetBaseAddress(pixelBuffer);
    __fp16* bufferP_F16 = (__fp16 *) pixelBufferPointer;
    float*  bufferP_F32 = (float  *) pixelBufferPointer;
    
    bool isFloat16 = (pixelFormat == MTLPixelFormatR16Float);
    uint32_t increment = isFloat16 ?  bytesPerRow/sizeof(__fp16) : bytesPerRow/sizeof(float);
    
    int x = 0;
    float total = 0;
    for (int j=0; j < height; j++)
    {
        for (int i=0; i < width; i++)
        {
            float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
            if (!isnan(val)) {
                if (val != 0) {
                    total += val;
                    x++;
                }
            }
        }
        if ( isFloat16 ) {
            bufferP_F16 +=increment;
        }  else {
            bufferP_F32 +=increment;
        }
    }
    
    float average = total/(height * width);
    
    NSLog(@"average = %.2f", average);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return average;
}

