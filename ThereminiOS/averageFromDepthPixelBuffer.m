/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Implements a function which extracts the smallest and largest values from a pixel buffer.
*/

#import "averageFromDepthPixelBuffer.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

void minMaxFromPixelBuffer(CVPixelBufferRef pixelBuffer, float* minValue, float* maxValue, MTLPixelFormat pixelFormat)
{
	int width  		= (int)CVPixelBufferGetWidth(pixelBuffer);
	int height 		= (int)CVPixelBufferGetHeight(pixelBuffer);
	int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);

	CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	unsigned char* pixelBufferPointer = CVPixelBufferGetBaseAddress(pixelBuffer);
	__fp16* bufferP_F16 = (__fp16 *) pixelBufferPointer;
	float*  bufferP_F32 = (float  *) pixelBufferPointer;

	bool isFloat16 = (pixelFormat == MTLPixelFormatR16Float);
	uint32_t increment = isFloat16 ?  bytesPerRow/sizeof(__fp16) : bytesPerRow/sizeof(float);

	float min = MAXFLOAT;
	float max = -MAXFLOAT;

    float values[width * height];
    int x = 0;
	for (int j=0; j < height; j++)
	{
		for (int i=0; i < width; i++)
		{
			float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
			if (!isnan(val)) {
				if (val>max) max = val;
				if (val<min) min = val;
			
                if (val != 0) {
                    values[x] = val;
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
    
    float average = calculateAverage(values, width * height);
//    NSLog(@"---average = %.2f", average);
    
	CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

	*minValue = min;
	*maxValue = max;
}

float calculateAverage(float *array, int count){
    if (count == 0) {
        return 0;
    }
    
    float total = 0;
    for (int i = 0; i < count; i++) {
        float value = array[i];
        total += value;
    }
    float average = total/count;

    return average;
}

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

NSArray* pixelConfigurationArrayFromDepthPixelBuffer(CVPixelBufferRef pixelBuffer, MTLPixelFormat pixelFormat, float depthThreshold, uint32_t* bytesPerPixel)
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
    
    NSMutableArray *pixelValues = [NSMutableArray array];
    for (int j=0; j < height; j++)
    {
        for (int i=0; i < width; i++)
        {
            float val = ( isFloat16 ) ?  bufferP_F16[i] :  bufferP_F32[i] ;
            if (!isnan(val)) {
                if (val < depthThreshold) {
                    [pixelValues addObject:@"x"];
                } else {
                    [pixelValues addObject:@"c"];
                }
            } else {
                [pixelValues addObject:@"c"];
            }
        }
        if ( isFloat16 ) {
            bufferP_F16 +=increment;
        }  else {
            bufferP_F32 +=increment;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

    *bytesPerPixel = increment;
    NSLog(@"pixelValues.count = %i, pixelFormatIsFloat16 = %@, valueBytesSize = %i", pixelValues.count, isFloat16 ? @"YES" : @"NO", isFloat16 ? sizeof(__fp16) : sizeof(float));
    
    return pixelValues;
}

