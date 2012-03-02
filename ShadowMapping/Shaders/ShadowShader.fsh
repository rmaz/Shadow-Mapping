//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

varying lowp  vec4 colorVarying;
varying highp vec4 shadowCoord;

uniform sampler2D shadowMap;

void main()
{
    // the threshold to compare to the vertex depth
    // we subtract a small magic constant to fix float error distortion
    highp float unobstructedDepth = (shadowCoord.z / shadowCoord.w) - 0.03;
    highp float depth = texture2DProj(shadowMap, shadowCoord).r;
    
    lowp float shadowFactor = depth >= unobstructedDepth ? 1.0 : 0.6;
    
    gl_FragColor = colorVarying * shadowFactor;
}
