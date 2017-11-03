//
//  DepthUtility.swift
//  SilhouetteCam
//
//  Created by Alec Montgomery on 10/25/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let redShifted = (UInt32(red) << 24)
        let greenShifted = (UInt32(green) << 16)
        let blueShifted = (UInt32(blue) << 8)
        let alphaShifted = (UInt32(alpha) << 0)
        
        color = ( redShifted | greenShifted | blueShifted | alphaShifted )
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    static let red   = RGBA32(red: 255, green: 0, blue: 0, alpha: 255)
    static let green = RGBA32(red: 0, green: 255, blue: 0, alpha: 255)
    static let blue  = RGBA32(red: 0, green: 0, blue: 255, alpha: 255)
    static let clear = RGBA32(red: 0, green: 0, blue: 0, alpha: 0)
}

class DepthUtility {
 
    static var context : CGContext?
    
    class func createImageFromCIKernelFilter(depthPixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, silhouetteThreshold:Float, completionHandler: @escaping (UIImage?, String?) -> Void) {
        
    }

    class func createImage(depthPixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, silhouetteThreshold:Float, completionHandler: @escaping (UIImage?, String?) -> Void) {
    
        // if i have an array of points 320x240
        // i want the points to correspond to a another area, let's say
        // 640 x 480
        // actually i don't need to do this, i can just make an image of the depth buffer size then scale it up ...
        
//        NSArray *pixelValues = pixel
        
        let width = CVPixelBufferGetWidth(depthPixelBuffer);
        let height = CVPixelBufferGetHeight(depthPixelBuffer);

        // all the pizel values correspond to 16 bit values.
        var bytesPerPixel : uint = 0;
        let pixelValues = pixelConfigurationArrayFromDepthPixelBuffer(depthPixelBuffer, pixelFormat, silhouetteThreshold, &bytesPerPixel) as! [String]
        
        NSLog("bytesPerPixel = \(bytesPerPixel)")
        
        createImage(width: width, height: height, bytesPerPixel:bytesPerPixel, from: pixelValues, completionHandler:completionHandler);
    }
    
    class func createImage(width: Int, height: Int, bytesPerPixel: uint, from array: [String], completionHandler: @escaping (UIImage?, String?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            
            // create silhoutte image from pixel data and set to a UIImageView....
        
            let colorSpace       = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel2   = 4
            let bitsPerComponent = 8
            let bytesPerRow      = Int(bytesPerPixel2) * width
            let bitmapInfo       = RGBA32.bitmapInfo
            
            guard array.count == width * height else {
                completionHandler(nil, "Array size \(array.count) is incorrect given dimensions \(width) x \(height)")
                return
            }
            
            if (context != nil) {
                context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            }
            
            guard let context = context else {
                completionHandler(nil, "unable to create context")
                return
            }

            guard let buffer = context.data else {
                completionHandler(nil, "unable to get context data")
                return
            }
            
            let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
            
            for (index, string) in array.enumerated() {
                switch string {
                    case "w": pixelBuffer[index] = .blue
                    case "x": pixelBuffer[index] = .red
                    case "y": pixelBuffer[index] = .green
                    case "v": pixelBuffer[index] = .black
                    case "c": pixelBuffer[index] = .clear
                    default: completionHandler(nil, "Unexpected value: \(string)"); return
                }
            }
            
            let cgImage = context.makeImage()!
            let image = UIImage(cgImage: cgImage)
            
            // or
            //
            // let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            
            completionHandler(image, nil)
        }
    }
    
    class func getPixelBufferFromCGImage(image:CGImage) -> CVPixelBuffer {
        
        let options = [
//            kCVPixelBufferCGImageCompatibilityKey: NSNumber(bool: true),
//            kCVPixelBufferCGBitmapContextCompatibilityKey: NSNumber(bool: true)
            kCVPixelBufferCGImageCompatibilityKey as String : NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String : NSNumber(value:true)
        ]
        
        let h = image.height
        let w = image.width
        
        var pxbuffer : CVPixelBuffer?
        
        var status: CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, w, h,
                                                   OSType(kCVPixelFormatType_32ARGB), options as CFDictionary, &pxbuffer )
        if (status != kCVReturnSuccess || pxbuffer == nil) {
            NSLog("error in CVPixelBufferCreate")
        }
        
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue:0))
        var pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        
        if pxdata == nil{
            NSLog("error in CVPixelBufferCreate")
        }
        
        var rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue:CGImageAlphaInfo.premultipliedLast.rawValue)
        var context: CGContext = CGContext.init(data: pxdata, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 4*w, space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)!;
        
        var frameTransform: CGAffineTransform  = CGAffineTransform()
//        context.concatenate(frameTransform)
        //        CGContextConcatCTM(context, frameTransform)
     
        context.draw(image, in: CGRect(x:0.0, y:0.0, width:CGFloat(w), height:CGFloat(h) ))
        //        CGContextDrawImage(context, CGRect(x:0.0, y:0.0, width:CGFloat(w), height:CGFloat(h) ), image)
        //        CGColorSpaceRelease(rgbColorSpace)
        //        CGContextRelease(context)
     
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags.readOnly)
        
        return pxbuffer!
    }
    
//
//    func makeSilhouttePixelBufferFromDepthMap(depthMap : CVPixelBuffer) -> CVPixelBuffer {
//
//        // loop through pixel buffer, for all values less than a constant, color black...
//        // make the rest transparent...
//
//    }
//
//
//    kernel vec4 into_darkness(__sample imageColor, __sample normalizedDisparity, float power) {
//    // Adjust the fall-off intensity with the power slider
//    float scaleFactor = pow(normalizedDisparity.r, power);
//    // Scale the original color by the computed intensity
//    vec4 result = vec4(imageColor.rgb * scaleFactor, imageColor.a);
//    return result; }
//
    
    class func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    /**
     Creates a RGB pixel buffer of the specified width and height.
     */
    public func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height,
                                         kCVPixelFormatType_32BGRA, nil,
                                         &pixelBuffer)
        if status != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status)
            return nil
        }
        return pixelBuffer
    }
}
