//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import "GLShader.h"

typedef enum {
    BDPShadowPositionAttribute,
    BDPShadowNormalAttribute,
    BDPShadowColourAttribute
} BDPShadowShaderAttributes;

typedef enum {
    BDPShadowMVPMatrixUniform,
    BDPShadowNormalMatrixUniform,
    BDPShadowLightDirectionUniform,
    BDPShadowMatrixUniform,
    BDPShadowSamplerUniform
} BDPShadowShaderUniforms;

@interface BDPShadowShader : GLShader

@end
