//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "BDPLightShader.h"
#import "BDPShadowShader.h"

@interface GLViewObject : NSObject

@property (nonatomic, strong) BDPLightShader *lightShader;
@property (nonatomic, strong) BDPShadowShader *shadowShader;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;
@property (nonatomic, assign) GLKVector3 lightDirection;
@property (nonatomic, assign) GLuint shadowTexture;

- (void)renderWithLightMatrix:(GLKMatrix4)projectionMatrix;
- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)textureMatrix;

@end
