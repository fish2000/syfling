//
//  VVSceneLinearBitmapImageRep.m
//  Lattice
//
//  Created by Greg Cotten on 1/8/15.
//  Copyright (c) 2015 Wil Gieseler. All rights reserved.
//

#import "VVSceneLinearImageRep.h"

@implementation VVSceneLinearImageRep

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if(self){
        self.maximumSceneValue = [coder decodeDoubleForKey:@"maximumSceneValue"];
        self.minimumSceneValue = [coder decodeDoubleForKey:@"minimumSceneValue"];
        self.isNormalized = [coder decodeBoolForKey:@"isNormalized"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.maximumSceneValue forKey:@"maximumSceneValue"];
    [aCoder encodeDouble:self.minimumSceneValue forKey:@"minimumSceneValue"];
    [aCoder encodeBool:self.isNormalized forKey:@"isNormalized"];
}

+ (BOOL)canInitWithData:(NSData *)data{
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
    return rep.bitsPerSample == 32;
}

+ (NSArray *)imageTypes{
    return @[@"com.ilm.openexr-image"];
}

+ (NSArray *)imageUnfilteredFileTypes{
    return @[@"com.ilm.openexr-image"];
}

- (id)copyWithZone:(NSZone *)zone{
    VVSceneLinearImageRep *copy = [super copyWithZone:zone];
    copy.minimumSceneValue = self.minimumSceneValue;
    copy.maximumSceneValue = self.maximumSceneValue;
    copy.isNormalized = self.isNormalized;
    return copy;
}

- (void)initSceneLinear{
    float *bitmapData = (float *)self.bitmapData;
    
    self.minimumSceneValue = bitmapData[0];
    self.maximumSceneValue = bitmapData[0];
    
    for (int i = 0; i < self.pixelsWide*self.pixelsHigh*self.samplesPerPixel; i+=self.samplesPerPixel) {
        float red = bitmapData[i];
        float green = bitmapData[i+1];
        float blue = bitmapData[i+2];
        self.minimumSceneValue = MIN(self.minimumSceneValue, MIN(red, MIN(green, blue)));
        self.maximumSceneValue = MAX(self.maximumSceneValue, MAX(red, MAX(green, blue)));
    }
    
    if (self.minimumSceneValue == self.maximumSceneValue) {
        self.minimumSceneValue = self.maximumSceneValue-.00001;
    }
    self.isNormalized = NO;
}

- (instancetype)initWithData:(NSData *)data{
    if (self = [super initWithData:data]) {
        if (self.bitsPerSample != 32) {
            return nil;
        }
        [self initSceneLinear];
    }
    
    return self;
}

- (void)setColorSpaceWithICCData:(NSData *)iccData{
    if (!iccData) {
        return;
    }
    [self setProperty:NSImageColorSyncProfileData
            withValue:iccData];
}

double VVSceneLinearImageRep_remap(double value, double inputLow, double inputHigh, double outputLow, double outputHigh){
    return outputLow + ((value - inputLow)*(outputHigh - outputLow))/(inputHigh - inputLow);
}

-(void)normalizeData{
    if (self.isNormalized) {
        return;
    }
    float *bitmapData = (float *)self.bitmapData;
    for (int i = 0; i < self.pixelsWide*self.pixelsHigh*self.samplesPerPixel; i+=self.samplesPerPixel) {
        bitmapData[i] = VVSceneLinearImageRep_remap(bitmapData[i], self.minimumSceneValue, self.maximumSceneValue, 0, 1);
        bitmapData[i+1] = VVSceneLinearImageRep_remap(bitmapData[i+1], self.minimumSceneValue, self.maximumSceneValue, 0, 1);
        bitmapData[i+2] = VVSceneLinearImageRep_remap(bitmapData[i+2], self.minimumSceneValue, self.maximumSceneValue, 0, 1);
    }
    self.isNormalized = YES;
}

-(void)denormalizeData{
    if (self.isNormalized == NO) {
        return;
    }
    float *bitmapData = (float *)self.bitmapData;
    for (int i = 0; i < self.pixelsWide*self.pixelsHigh*self.samplesPerPixel; i+=self.samplesPerPixel) {
        bitmapData[i] = VVSceneLinearImageRep_remap(bitmapData[i], 0, 1, self.minimumSceneValue, self.maximumSceneValue);
        bitmapData[i+1] = VVSceneLinearImageRep_remap(bitmapData[i+1], 0, 1, self.minimumSceneValue, self.maximumSceneValue);
        bitmapData[i+2] = VVSceneLinearImageRep_remap(bitmapData[i+2], 0, 1, self.minimumSceneValue, self.maximumSceneValue);
    }
    self.isNormalized = NO;
}

@end
