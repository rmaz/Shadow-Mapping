//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import "GLViewObject.h"

@implementation GLViewObject

@synthesize shader = _shader;
@synthesize modelViewMatrix = _modelMatrix;
@synthesize lightDirection = _lightDirection;
@synthesize shadowTexture = _shadowTexture;

#pragma mark - Init & Dealloc

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.modelViewMatrix = GLKMatrix4Identity;
    }
    return self;
}

#pragma mark - Public Methods

- (void)update:(NSTimeInterval)dt
{
    
}

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)shadowMatrix
{
    
}

@end
