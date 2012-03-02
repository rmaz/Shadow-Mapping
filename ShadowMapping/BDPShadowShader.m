//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import "BDPShadowShader.h"

@implementation BDPShadowShader

- (id)init
{
    NSArray *attributes = [NSArray arrayWithObjects:
                           @"position", 
                           @"normal", 
                           @"colour", 
                           nil];
    
    NSArray *uniforms = [NSArray arrayWithObjects:
                         @"modelViewProjectionMatrix",
                         @"normalMatrix", 
                         @"lightDirection",
                         @"shadowProjectionMatrix",
                         @"shadowMap",
                         nil];
    
    return [super initWithShaderName:@"ShadowShader" attributes:attributes uniforms:uniforms];
}

@end
