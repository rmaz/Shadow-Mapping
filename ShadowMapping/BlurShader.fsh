// Copyright (c) 2013 Richard Mazorodze
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

varying mediump vec2 v_textureCoord;

uniform sampler2D s_texture;
uniform mediump vec2 u_pixelStep;
uniform mediump float u_offsets[3];
uniform lowp float u_weights[3];

// 9 tap gaussian filter implemented using linear filtering with 5 samples
// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/

void main()
{
    lowp vec4 color = texture2D(s_texture, v_textureCoord) * u_weights[0];
    for (int i = 1; i < 3; i++)
    {
        color += texture2D(s_texture, v_textureCoord - u_offsets[i] * u_pixelStep) * u_weights[i];
        color += texture2D(s_texture, v_textureCoord + u_offsets[i] * u_pixelStep) * u_weights[i];
    }
    gl_FragColor = color;
}
