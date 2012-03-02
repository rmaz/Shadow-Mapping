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
    // calculate the z position of this fragment in screen space
    // we subtract a small magic constant to fix float error distortion
    highp float projectedDepth = (shadowCoord.z / shadowCoord.w) - 0.03;
    
    // read the depth in the depth buffer texture
    highp float depth = texture2DProj(shadowMap, shadowCoord).r;
    
    // if the depth buffer texture depth is less than the projected depth of this fragment
    // then the fragment is obscured by another object and is in shadow
    lowp float shadowFactor = depth < projectedDepth ? 0.6 : 1.0;
    
    gl_FragColor = colorVarying * shadowFactor;
}
