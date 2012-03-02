//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import "GLShader.h"

typedef enum {
    BDPPositionAttribute,
    BDPNormalAttribute,
    BDPColourAttribute
} BDPShadowShaderAttributes;

typedef enum {
    BDPMVPMatrixUniform,
    BDPNormalMatrixUniform,
    BDPLightDirectionUniform,
    BDPShadowMatrixUniform,
    BDPShadowSamplerUniform
} BDPShadowShaderUniforms;

@interface BDPShadowShader : GLShader

@end
