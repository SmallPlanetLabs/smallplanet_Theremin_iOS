//
//  DepthUtility.swift
//  ThereminiOS
//
//  Created by Alec Montgomery on 11/3/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import CoreMedia

class DepthUtlity {
    
    class func pixelFormatForDepthPixelBuffer(depthDataMap: CVPixelBuffer!) -> MTLPixelFormat? {
        
        var textureFormat : MTLPixelFormat?
        
        var depthFormatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, depthDataMap, &depthFormatDescription)
        
        guard let formatDescription = depthFormatDescription else {
            NSLog("error getting format description from image buffer")
            return nil
        }
    
        let inputMediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription)
        if inputMediaSubType == kCVPixelFormatType_DepthFloat16 ||
            inputMediaSubType == kCVPixelFormatType_DisparityFloat16 {
            textureFormat = .r16Float
        } else if inputMediaSubType == kCVPixelFormatType_DepthFloat32 ||
            inputMediaSubType == kCVPixelFormatType_DisparityFloat32 {
            textureFormat = .r32Float
        } else {
            assertionFailure("Input format not supported")
        }
        
        return textureFormat
    }
}
