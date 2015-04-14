//
//  NSImage+SceneLinear.h
//  Lattice
//
//  Created by Greg Cotten on 1/8/15.
//  Copyright (c) 2015 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VVSceneLinearImageRep.h"

@interface NSImage (SceneLinear)

+ (NSColorSpace *)genericHDRColorSpace;

-(BOOL)isSceneLinear;
-(double)minimumSceneValue;
-(double)maximumSceneValue;
-(BOOL)isNormalized;

- (void)setWithGenericHDRColorSpace;
- (void)setWithDeviceRGBColorSpace;

- (NSImage *)imageInGenericHDRColorSpace;
- (NSImage *)imageInDeviceRGBColorSpace;

- (NSImage *)imageByNormalizingSceneLinearData;
- (NSImage *)imageByDenormalizingSceneLinearData;

+ (NSImage *)imageWithSceneLinearEncodingWithData:(NSData *)data;
+ (NSImage *)imageWithSceneLinearEncodingWithContentsOfURL:(NSURL *)url;

- (BOOL)writeSceneLinearEXRToURL:(NSURL *)url;
- (NSData *)EXRRepresentation;

@end
