//
//  VWWSynthesizerNotes.m
//  Synthesizer
//
//  Created by Zakk Hoyt on 8/12/12.
//  Copyright (c) 2012 Zakk Hoyt. All rights reserved.
//

#import "VWWSynthesizerNotes.h"


@interface VWWSynthesizerNotes ()
@property (nonatomic, strong) NSArray* notesInChromatic;
@property (nonatomic, strong) NSArray* notesInAMinor;
@property (nonatomic, strong) NSArray* notesInAMajor;
@property (nonatomic, strong) NSArray* notesInBMinor;
@property (nonatomic, strong) NSArray* notesInBMajor;
@property (nonatomic, strong) NSArray* notesInCMajor;
@property (nonatomic, strong) NSArray* notesInDMinor;
@property (nonatomic, strong) NSArray* notesInDMajor;
@property (nonatomic, strong) NSArray* notesInEMinor;
@property (nonatomic, strong) NSArray* notesInEMajor;
@property (nonatomic, strong) NSArray* notesInFMajor;
@property (nonatomic, strong) NSArray* notesInGMinor;
@property (nonatomic, strong) NSArray* notesInGMajor;

-(void)initializeClass;
@end

@implementation VWWSynthesizerNotes


+(VWWSynthesizerNotes *)sharedInstance{
    static VWWSynthesizerNotes* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VWWSynthesizerNotes alloc]init];
    });
    return instance;
}


-(id)init{
    self = [super init];
    if(self){
        [self initializeClass];
    }
    return self;
}

+(float)getClosestNoteForFrequency:(float)frequency{
    return [[VWWSynthesizerNotes sharedInstance]getClosestNote:frequency];
}

+(float)getClosestNoteForFrequency:(float)frequency inKey:(VWWKeyType)key {
    NSArray *notesForKey = [[VWWSynthesizerNotes sharedInstance] notesForKey:key];
    
//    NSLog(@"notes count = %i", notesForKey.count);
    
    return [[VWWSynthesizerNotes sharedInstance]getClosestNoteForFrequency:frequency notes:notesForKey];
}



-(NSArray*)notesForKey:(VWWKeyType)key{
    switch(key){
        case VWWKeyTypeAMinor:
            return self.notesInAMinor;
        case VWWKeyTypeAMajor:
            return self.notesInAMajor;
        case VWWKeyTypeBMinor:
            return self.notesInBMinor;
        case VWWKeyTypeBMajor:
            return self.notesInBMajor;
        case VWWKeyTypeCMajor:
            return self.notesInCMajor;
        case VWWKeyTypeDMinor:
            return self.notesInDMinor;
        case VWWKeyTypeDMajor:
            return self.notesInDMajor;
        case VWWKeyTypeEMinor:
            return self.notesInEMinor;
        case VWWKeyTypeFMajor:
            return self.notesInEMajor;
        case VWWKeyTypeGMinor:
            return self.notesInGMinor;
        case VWWKeyTypeGMajor:
            return self.notesInGMajor;
        case VWWKeyTypeChromatic:
        default:
            return self.notesInChromatic;
    }
}
-(float)getClosestNoteForFrequency:(float)frequency notes:(NSArray*)notes{
    
    // Since our notes are sorted ascending, use binary search pattern
    
    int min = 0;
    int max = self.notesInChromatic.count;
    int mid = 0;
    
    bool foundValue = false;
    while(min < max){
        mid = (min + max) / 2;
        NSLog(@"min = %i , max = %i, mid = %i",min,max,mid);
        float temp = ((NSNumber*)(notes)[mid]).floatValue;
        NSLog(@"temp = %f frequency = %f", temp, frequency);
        if (temp == frequency){
            foundValue = true;
            break;
        }
        else if (frequency > ((NSNumber*)(notes)[mid]).floatValue){
            min = mid+1;
        }
        else{
            max = mid-1;
        }
    }
    
    // frequency likely falls between two indicies. See which one it's closer to and return that
    float r = 0;
    if(mid == 0){
        // This is to catch a bug. The code below can potentially try to
        // access objectAtIndex:-1. Just return 0 if we are already at 0
        r = ((NSNumber*)(notes)[mid]).floatValue;
    }
    else{
        if(frequency < ((NSNumber*)(notes)[mid]).floatValue){
            // See if it's closer to mid or mid-1
            float temp1 = abs(frequency - ((NSNumber*)(notes)[mid]).floatValue);
            float temp2 = abs(frequency - ((NSNumber*)(notes)[mid-1]).floatValue);
            if(temp1 < temp2)
                r = ((NSNumber*)(notes)[mid]).floatValue;
            else
                r = ((NSNumber*)(notes)[mid-1]).floatValue;
        }
        else{
            // See if it's closer to mid of mid+1
            float temp1 = abs(frequency - ((NSNumber*)(notes)[mid]).floatValue);
            float temp2 = abs(frequency - ((NSNumber*)(notes)[mid+1]).floatValue);
            if(temp1 < temp2)
                r = ((NSNumber*)(notes)[mid]).floatValue;
            else
                r = ((NSNumber*)(notes)[mid+1]).floatValue;
        }
    }
    return r;
}



-(float)getClosestNote:(float)frequency{
    // Since our notes are sorted ascending, use binary search pattern
    
    int min = 0;
    int max = self.notesInChromatic.count;
    int mid = 0;
    
    bool foundValue = false;
    while(min < max){
        mid = (min + max) / 2;
//        NSLog(@"min = %i , max = %i, mid = %i",min,max,mid);
        float temp = ((NSNumber*)(self.notesInChromatic)[mid]).floatValue;
//        NSLog(@"temp = %f frequency = %f", temp, frequency);
        if (temp == frequency){
            foundValue = true;
            break;
        }
        else if (frequency > ((NSNumber*)(self.notesInChromatic)[mid]).floatValue){
            min = mid+1;
        }
        else{
            max = mid-1;
        }
    }
    
    // frequency likely falls between two indicies. See which one it's closer to and return that
    float r = 0;
    if(mid == 0){
        // This is to catch a bug. The code below can potentially try to
        // access objectAtIndex:-1. Just return 0 if we are already at 0
        r = ((NSNumber*)(self.notesInChromatic)[mid]).floatValue;
    }
    else{
        if(frequency < ((NSNumber*)(self.notesInChromatic)[mid]).floatValue){
            // See if it's closer to mid or mid-1
            float temp1 = abs(frequency - ((NSNumber*)(self.notesInChromatic)[mid]).floatValue);
            float temp2 = abs(frequency - ((NSNumber*)(self.notesInChromatic)[mid-1]).floatValue);
            if(temp1 < temp2)
                r = ((NSNumber*)(self.notesInChromatic)[mid]).floatValue;
            else
                r = ((NSNumber*)(self.notesInChromatic)[mid-1]).floatValue;
        }
        else{
            // See if it's closer to mid of mid+1
            float temp1 = abs(frequency - ((NSNumber*)(self.notesInChromatic)[mid]).floatValue);
            float temp2 = abs(frequency - ((NSNumber*)(self.notesInChromatic)[mid+1]).floatValue);
            if(temp1 < temp2)
                r = ((NSNumber*)(self.notesInChromatic)[mid]).floatValue;
            else
                r = ((NSNumber*)(self.notesInChromatic)[mid+1]).floatValue;
        }
    }
    return r;
}

// I precalculated these frequendies with the formula f = 2^n/12 * 27.5 with n from 1 .. 114
-(void)initializeAllNotes{
    self.notesInChromatic = @[@(27.50),
                  @(29.14),
                  @(30.87),
                  @(32.70),
                  @(34.65),
                  @(36.71),
                  @(38.89),
                  @(41.20),
                  @(43.65),
                  @(46.25),
                  @(49.00),
                  @(51.91),
                  @(55.00),
                  @(58.27),
                  @(61.74),
                  @(65.41),
                  @(69.30),
                  @(73.42),
                  @(77.78),
                  @(82.41),
                  @(87.31),
                  @(92.50),
                  @(98.00),
                  @(103.83),
                  @(110.00),
                  @(116.54),
                  @(123.47),
                  @(130.81),
                  @(138.59),
                  @(146.83),
                  @(155.56),
                  @(164.81),
                  @(174.61),
                  @(185.00),
                  @(196.00),
                  @(207.65),
                  @(220.00),
                  @(233.08),
                  @(246.94),
                  @(261.63),
                  @(277.18),
                  @(293.66),
                  @(311.13),
                  @(329.63),
                  @(349.23),
                  @(369.99),
                  @(392.00),
                  @(415.30),
                  @(440.00),
                  @(466.16),
                  @(493.88),
                  @(523.25),
                  @(554.37),
                  @(587.33),
                  @(622.25),
                  @(659.26),
                  @(698.46),
                  @(739.99),
                  @(783.99),
                  @(830.61),
                  @(880.00),
                  @(932.33),
                  @(987.77),
                  @(1046.50),
                  @(1108.73),
                  @(1174.66),
                  @(1244.51),
                  @(1318.51),
                  @(1396.91),
                  @(1479.98),
                  @(1567.98),
                  @(1661.22),
                  @(1760.00),
                  @(1864.66),
                  @(1975.53),
                  @(2093.00),
                  @(2217.46),
                  @(2349.32),
                  @(2489.02),
                  @(2637.02),
                  @(2793.83),
                  @(2959.96),
                  @(3135.96),
                  @(3322.44),
                  @(3520.00),
                  @(3729.31),
                  @(3951.07),
                  @(4186.01),
                  @(4434.92),
                  @(4698.64),
                  @(4978.03),
                  @(5274.04),
                  @(5587.65),
                  @(5919.91),
                  @(6271.93),
                  @(6644.88),
                  @(7040.00),
                  @(7458.62),
                  @(7902.13),
                  @(8372.02),
                  @(8869.84),
                  @(9397.27),
                  @(9956.06),
                  @(10548.08),
                  @(11175.30),
                  @(11839.82),
                  @(12543.85),
                  @(13289.75),
                  @(14080.00),
                  @(14917.24),
                  @(15804.27),
                  @(16744.04),
                  @(17739.69),
                  @(18794.55),
                  @(19912.13)];
}


//// major = 0, 2, 4, 5, 7, 9, 11
// Guitar pattern
//D:9xBCx
//A:45x7x
//E:x0x2x

//// minor = 0, 2, 3, 5, 7, 8, 10,
// Guitar pattern
//D:xAxCx
//A:x5x78
//E:x0x23


-(void)initializeNotesInAMinor{
    _notesInAMinor = [NSArray new];
}
-(void)initializeNotesInAMajor{
    _notesInAMajor = [NSArray new];
}
-(void)initializeNotesInBMinor{
    _notesInBMinor = [NSArray new];
}
-(void)initializeNotesInBMajor{
    _notesInBMajor = [NSArray new];
}
-(void)initializeNotesInCMajor{
    _notesInCMajor = @[
                       @(16.3516),
                       @(18.3540),
                       @(20.6017),
                       @(24.4997),
                       @(27.5000),
                       @(30.8677),
                       @(32.7032),
                       @(36.7081),
                       @(41.2034),
                       @(43.6535),
                       @(48.9994),
                       @(55.0000),
                       @(61.7354),
                       @(65.4064),
                       @(73.4162),
                       @(82.4069),
                       @(87.3071),
                       @(97.9989),
                       @(110.000),
                       @(123.471),
                       @(130.813),
                       @(146.832),
                       @(164.814),
                       @(174.614),
                       @(195.998),
                       @(220.000),
                       @(246.942),
                       @(261.626),
                       @(293.665),
                       @(329.628),
                       @(349.228),
                       @(391.995),
                       @(440.000),
                       @(493.883),
                       @(523.251),
                       @(587.330),
                       @(659.255),
                       @(698.456),
                       @(783.991),
                       @(880.000),
                       @(987.767),
                       @(1046.50),
                       @(1174.66),
                       @(1318.51),
                       @(1396.91),
                       @(1567.98),
                       @(1760.00),
                       @(1975.53),
                       @(2093.00),
                       @(2349.32),
                       @(2637.02),
                       @(2793.83),
                       @(3135.96),
                       @(3520.00),
                       @(3951.07),
                       @(4186.01),
                       @(4698.64),
                       @(5274.04),
                       @(5587.65),
                       ];
}
-(void)initializeNotesInDMinor{
    _notesInDMinor = [NSArray new];
}
-(void)initializeNotesInDMajor{
    _notesInDMajor = [NSArray new];
}
-(void)initializeNotesInEMinor{
    _notesInEMinor = [NSArray new];
}
-(void)initializeNotesInEMajor{
    _notesInEMajor = [NSArray new];
}
-(void)initializeNotesInFMajor{
    _notesInFMajor = [NSArray new];
}
-(void)initializeNotesInGMinor{
    _notesInGMinor = [NSArray new];
}
-(void)initializeNotesInGMajor{
    _notesInGMajor = [NSArray new];
}


-(void)initializeClass{
    [self initializeAllNotes];
    [self initializeNotesInAMinor];
    [self initializeNotesInAMajor];
    [self initializeNotesInBMinor];
    [self initializeNotesInBMajor];
    [self initializeNotesInCMajor];
    [self initializeNotesInDMinor];
    [self initializeNotesInDMajor];
    [self initializeNotesInEMinor];
    [self initializeNotesInEMajor];
    [self initializeNotesInFMajor];
    [self initializeNotesInGMinor];
    [self initializeNotesInGMajor];
}


@end



