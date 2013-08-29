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

varying lowp  vec4 colorVarying;
varying highp vec4 shadowCoord;

uniform sampler2D shadowMap;

const highp float kMinVariance = 0.000001;
const lowp  float kShadowAmount = 0.4;

lowp float chebyshevUpperBound(highp vec3 coords)
{
	highp vec2 moments = texture2D(shadowMap, coords.xy).rg;

	// If the fragment is in front of the occluder, then it is fully lit.
    if (coords.z <= moments.r)
        return 1.0;

	// The fragment is either in shadow or penumbra.
    // Calculate the variance and clamp to a min value
    // to avoid self shadowing artifacts.
	highp float variance = moments.g - (moments.r * moments.r);
	variance = max(variance, kMinVariance);

    // Calculate the probabilistic upper bound.
	highp float d = coords.z - moments.r;
    lowp float p_max = variance / (variance + d*d);

	return p_max;
}

void main()
{
    highp vec3 postWCoord = shadowCoord.xyz / shadowCoord.w;
    lowp float pShadow = chebyshevUpperBound(postWCoord);

    gl_FragColor = colorVarying * (1.0 - kShadowAmount + kShadowAmount * pShadow);
}
