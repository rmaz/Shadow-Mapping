//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

attribute highp   vec4 position;
attribute mediump vec3 normal;
attribute lowp    vec3 colour;

varying lowp    vec4 colorVarying;
varying highp   vec4 shadowCoord; 

uniform highp   mat4 modelViewProjectionMatrix;
uniform mediump mat3 normalMatrix;
uniform highp   mat4 shadowProjectionMatrix;
uniform mediump vec3 lightDirection;

void main()
{
    // get the projected vertex position
    gl_Position = modelViewProjectionMatrix * position;
    
    // calculate the diffuse light contribution
    mediump vec3 eyeNormal = normalize(normalMatrix * normal);    
    mediump float nDotVP = max(0.0, -dot(eyeNormal, lightDirection));
    colorVarying = vec4(colour * nDotVP, 1.0);
    
    // calculate the coordinates to use in the shadow texture
    shadowCoord = shadowProjectionMatrix * position;
}
