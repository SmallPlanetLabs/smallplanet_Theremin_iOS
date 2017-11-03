//
//  VWWSynthesizerGroup.m
//  Synthesizer
//
//  Created by Zakk Hoyt on 1/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSynthesizerGroup.h"
#import "VWWSynthesizerKeys.h"
#import "VWWUtilities.h"

@interface VWWSynthesizerGroup (){
    bool _muted;
    bool _isRunning;
}

@end


@implementation VWWSynthesizerGroup

//-(id)initWithXFrequencyMin:(float)xFrequencyMin xFrequencyMax:(float)xFrequencyMax xFrequencyNormalized:(float)xFrequencyNormalized
//             yFrequencyMin:(float)yFrequencyMin yFrequencyMax:(float)yFrequencyMax yFrequencyNormalized:(float)yFrequencyNormalized
//             zFrequencyMin:(float)zFrequencyMin zFrequencyMax:(float)zFrequencyMax zFrequencyNormalized:(float)zFrequencyNormalized{
-(id)initWithXFrequencyLeftMin:(float)xFrequencyLeftMin xFrequencyLeftMax:(float)xFrequencyLeftMax xFrequencyLeftNormalized:(float)xFrequencyLeftNormalized
            xFrequencyRightMin:(float)xFrequencyRightMin xFrequencyRightMax:(float)xFrequencyRightMax xFrequencyRightNormalized:(float)xFrequencyRightNormalized
             yFrequencyLeftMin:(float)yFrequencyLeftMin yFrequencyLeftMax:(float)yFrequencyLeftMax yFrequencyLeftNormalized:(float)yFrequencyLeftNormalized
            yFrequencyRightMin:(float)yFrequencyRightMin yFrequencyRightMax:(float)yFrequencyRightMax yFrequencyRightNormalized:(float)yFrequencyRightNormalized
             zFrequencyLeftMin:(float)zFrequencyLeftMin zFrequencyLeftMax:(float)zFrequencyLeftMax zFrequencyLeftNormalized:(float)zFrequencyLeftNormalized
            zFrequencyRightMin:(float)zFrequencyRightMin zFrequencyRightMax:(float)zFrequencyRightMax zFrequencyRightNormalized:(float)zFrequencyRightNormalized{

    self = [super init];
    if(self){
        _xSynthesizer = [[VWWNormalizedSynthesizer alloc]initWithFrequencyLeftMin:xFrequencyLeftMin frequencyLeftMax:xFrequencyLeftMax frequencyLeftNormalized:xFrequencyLeftNormalized
                                                                frequencyRightMin:xFrequencyRightMin frequencyRightMax:xFrequencyRightMax frequencyRightNormalized:xFrequencyRightNormalized];
        _ySynthesizer = [[VWWNormalizedSynthesizer alloc]initWithFrequencyLeftMin:yFrequencyLeftMin frequencyLeftMax:yFrequencyLeftMax frequencyLeftNormalized:yFrequencyLeftNormalized
                                                                frequencyRightMin:yFrequencyRightMin frequencyRightMax:yFrequencyRightMax frequencyRightNormalized:yFrequencyRightNormalized];
        _zSynthesizer = [[VWWNormalizedSynthesizer alloc]initWithFrequencyLeftMin:zFrequencyLeftMin frequencyLeftMax:zFrequencyLeftMax frequencyLeftNormalized:zFrequencyLeftNormalized
                                                                frequencyRightMin:zFrequencyRightMin frequencyRightMax:zFrequencyRightMax frequencyRightNormalized:zFrequencyRightNormalized];
    }
    return self;
}




- (void)start{
    _isRunning = YES;
    [self.xSynthesizer start];
    [self.ySynthesizer start];
    [self.zSynthesizer start];
}

- (void)stop{
    _isRunning = NO;
    [self.xSynthesizer stop];
    [self.ySynthesizer stop];
    [self.zSynthesizer stop];
}

-(bool)isRunning{
    return _isRunning;
}

-(bool)muted{
    return _muted;
}

-(void)setMuted:(bool)muted{
    _muted = muted;
    self.xSynthesizer.muted = _muted;
    self.ySynthesizer.muted = _muted;
    self.zSynthesizer.muted = _muted;
}

@end


@implementation VWWSynthesizerGroup (Dictionary)
-(id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if(self){
        NSDictionary *xDictionary = dictionary[VWWSynthesizerGroupXAxisKey];
        self.xSynthesizer = [[VWWNormalizedSynthesizer alloc]initWithDictionary:xDictionary];
        
        NSDictionary *yDictionary = dictionary[VWWSynthesizerGroupYAxisKey];
        self.ySynthesizer = [[VWWNormalizedSynthesizer alloc]initWithDictionary:yDictionary];
        
        NSDictionary *zDictionary = dictionary[VWWSynthesizerGroupZAxisKey];
        self.zSynthesizer = [[VWWNormalizedSynthesizer alloc]initWithDictionary:zDictionary];
        
    }
    return self;
}

-(NSDictionary*)dictionaryRepresentation{
    
    NSDictionary *dictionary = @{
                                 // TODO:
                                 // isRunning
                                 // muted
                                 // type (accel, gyro, touch, etc...)
                                 VWWSynthesizerGroupXAxisKey : [self.xSynthesizer dictionaryRepresentation],
                                 VWWSynthesizerGroupYAxisKey : [self.ySynthesizer dictionaryRepresentation],
                                 VWWSynthesizerGroupZAxisKey : [self.zSynthesizer dictionaryRepresentation]
                                 };
    
    return dictionary;
}
@end
