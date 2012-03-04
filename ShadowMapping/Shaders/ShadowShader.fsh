//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#extension GL_EXT_shadow_samplers : require

varying lowp  vec4 colorVarying;
varying highp vec4 shadowCoord;

uniform sampler2DShadow shadowMap;

const lowp  float kShadowAmount = 0.5;

void main()
{    
    gl_FragColor = colorVarying * (kShadowAmount + kShadowAmount * shadow2DProjEXT(shadowMap, shadowCoord));
}
