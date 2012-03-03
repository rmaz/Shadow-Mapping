//
//  BDPCameraShader.h
//  ShadowMapping
//
//  Created by Richard Mazorodze on 03/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLShader.h"

typedef enum {
    BDPLightPositionAttribute
} BDPLightShaderAttributes;

typedef enum {
    BDPLightMVPMatrixUniform
} BDPLightShaderUniforms;

@interface BDPLightShader : GLShader

@end
