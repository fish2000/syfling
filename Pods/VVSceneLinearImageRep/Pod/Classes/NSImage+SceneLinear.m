//
//  NSImage+SceneLinear.m
//  Lattice
//
//  Created by Greg Cotten on 1/8/15.
//  Copyright (c) 2015 Wil Gieseler. All rights reserved.
//

#import "NSImage+SceneLinear.h"


@implementation NSImage (SceneLinear)

+ (NSColorSpace *)genericHDRColorSpace{
    static NSColorSpace *genericHDRColorSpace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"VVSceneLinearImageRepAssets" withExtension:@"bundle"]];
        NSData *data = [NSData dataWithContentsOfURL:[bundle URLForResource:@"genericHDRProfile" withExtension:@"icc"]];
        genericHDRColorSpace = [[NSColorSpace alloc] initWithICCProfileData:data];
    });
    
    return genericHDRColorSpace;
}

-(BOOL)isSceneLinear{
    return [self.representations[0] isKindOfClass:[VVSceneLinearImageRep class]];
}

-(double)minimumSceneValue{
    if (![self isSceneLinear]) {
        @throw [NSException exceptionWithName:@"NSImage+SceneLinearError" reason:@"Image is not scene linear." userInfo:nil];
    }
    return [(VVSceneLinearImageRep *)self.representations[0] minimumSceneValue];
}

-(double)maximumSceneValue{
    if (![self isSceneLinear]) {
        @throw [NSException exceptionWithName:@"NSImage+SceneLinearError" reason:@"Image is not scene linear." userInfo:nil];
    }
    return [(VVSceneLinearImageRep *)self.representations[0] maximumSceneValue];
}

-(BOOL)isNormalized{
    if (![self isSceneLinear]) {
        @throw [NSException exceptionWithName:@"NSImage+SceneLinearError" reason:@"Image is not scene linear." userInfo:nil];
    }
    return [(VVSceneLinearImageRep *)self.representations[0] isNormalized];
}

-(NSImage *)imageByNormalizingSceneLinearData{
    if (![self isSceneLinear]) {
        return nil;
    }
    NSImage *image = [self copy];
    [(VVSceneLinearImageRep *)image.representations[0] normalizeData];
    return image;
}

-(NSImage *)imageByDenormalizingSceneLinearData{
    if (![self isSceneLinear]) {
        return nil;
    }
    NSImage *image = [self copy];
    [(VVSceneLinearImageRep *)image.representations[0] denormalizeData];
    return image;
}

- (NSImage *)imageInGenericHDRColorSpace{
    if (![self isSceneLinear]) {
        return nil;
    }
    NSImage *image = [self copy];
    [image setWithGenericHDRColorSpace];
    
    return image;
}

- (NSImage *)imageInDeviceRGBColorSpace{
    if (![self isSceneLinear]) {
        return nil;
    }
    NSImage *image = [self copy];
    [image setWithDeviceRGBColorSpace];
    
    return image;
}

- (void)setWithGenericHDRColorSpace{
    [(VVSceneLinearImageRep *)self.representations[0] setColorSpaceWithICCData:[[self.class genericHDRColorSpace] ICCProfileData]];
}

- (void)setWithDeviceRGBColorSpace{
    [(VVSceneLinearImageRep *)self.representations[0] setColorSpaceName:NSDeviceRGBColorSpace];
}

+ (NSImage *)imageWithSceneLinearEncodingWithData:(NSData *)data{
    if (!data) {
        return nil;
    }
    VVSceneLinearImageRep *imageRep = [[VVSceneLinearImageRep alloc] initWithData:data];
    if (!imageRep) {
        return nil;
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh)];
    
    [image addRepresentation:imageRep];
    
    return image;
}

+ (NSImage *)imageWithSceneLinearEncodingWithContentsOfURL:(NSURL *)url{
    if (!url) {
        return nil;
    }
    VVSceneLinearImageRep *imageRep = [[VVSceneLinearImageRep alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    if (!imageRep) {
        return nil;
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh)];
    
    [image addRepresentation:imageRep];
    
    return image;
}

- (BOOL)writeSceneLinearEXRToURL:(NSURL *)url{
    if (![self isSceneLinear]) {
        return NO;
    }
    NSInteger pixelsWide = ((VVSceneLinearImageRep *)self.representations[0]).pixelsWide;
    NSInteger pixelsHigh = ((VVSceneLinearImageRep *)self.representations[0]).pixelsHigh;
    NSRect rect = NSMakeRect(0, 0, pixelsWide, pixelsHigh);
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)url, (CFStringRef)@"com.ilm.openexr-image", 1, NULL);
    CGImageRef imageRef = [[self imageByDenormalizingSceneLinearData] CGImageForProposedRect:&rect context:NULL hints:NULL];
    CGImageDestinationAddImage(dest,imageRef,NULL);
    BOOL writeSuccess = CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
    return writeSuccess;
}

- (NSData *)EXRRepresentation{
    if (![self isSceneLinear]) {
        return NO;
    }
    NSInteger pixelsWide = ((VVSceneLinearImageRep *)self.representations[0]).pixelsWide;
    NSInteger pixelsHigh = ((VVSceneLinearImageRep *)self.representations[0]).pixelsHigh;
    NSRect rect = NSMakeRect(0, 0, pixelsWide, pixelsHigh);
    
    NSMutableData *mutableData = [NSMutableData data];
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef)mutableData, (CFStringRef)@"com.ilm.openexr-image", 1, NULL);
    CGImageRef imageRef = [[self imageByDenormalizingSceneLinearData] CGImageForProposedRect:&rect context:NULL hints:NULL];
    CGImageDestinationAddImage(dest,imageRef,NULL);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
    return mutableData;
}

@end
