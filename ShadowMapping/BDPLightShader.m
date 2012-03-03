//
//  BDPCameraShader.m
//  ShadowMapping
//
//  Created by Richard Mazorodze on 03/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BDPLightShader.h"

@implementation BDPLightShader

- (id)init
{
    NSArray *attributes = [NSArray arrayWithObjects:
                           @"position", 
                           nil];
    
    NSArray *uniforms = [NSArray arrayWithObjects:
                         @"modelViewProjectionMatrix",
                         nil];
    
    return [super initWithShaderName:@"LightShader" attributes:attributes uniforms:uniforms];
}

@end
