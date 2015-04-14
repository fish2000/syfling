//
//  VVSceneLinearBitmapImageRep.h
//  Lattice
//
//  Created by Greg Cotten on 1/8/15.
//  Copyright (c) 2015 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VVSceneLinearImageRep : NSBitmapImageRep <NSSecureCoding>

@property (assign) double minimumSceneValue;
@property (assign) double maximumSceneValue;
@property (assign) BOOL isNormalized;

-(void)normalizeData;
-(void)denormalizeData;
- (void)setColorSpaceWithICCData:(NSData *)iccData;

@end
