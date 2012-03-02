//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GLShader.h"

@interface GLViewObject : NSObject

@property (nonatomic, strong) GLShader *shader;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign) GLKVector3 lightDirection;
@property (nonatomic, assign) GLuint shadowTexture;

- (void)update:(NSTimeInterval)dt;
- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)textureMatrix;

@end
