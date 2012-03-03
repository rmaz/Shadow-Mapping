//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

attribute highp   vec4 position;

uniform highp   mat4 modelViewProjectionMatrix;

void main()
{
    // we only care about the vertex position
    gl_Position = modelViewProjectionMatrix * position;
}
