// Copyright (c) 2012 Richard Mazorodze
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

attribute highp   vec4 position;
attribute mediump vec3 normal;
attribute lowp    vec3 colour;

varying lowp  vec4 colorVarying;
varying highp vec4 shadowCoord; 

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
