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

#import "GLBlurShader.h"

@implementation GLBlurShader

#pragma mark - Init & Dealloc

- (id)init
{
    NSArray *attributes = [NSArray arrayWithObjects:@"a_position", @"a_textureCoord", nil];
    NSArray *uniforms = [NSArray arrayWithObjects:@"s_texture", @"u_pixelStep", @"u_offsets", @"u_weights", nil];
    self = [super initWithShaderName:@"BlurShader" attributes:attributes uniforms:uniforms];
    if (self != nil) {
        
    }
    return self;
}

#pragma mark - Properties

- (GLuint)sampler
{
    return self.uniforms[0];
}

- (GLuint)pixelStep
{
    return self.uniforms[1];
}

- (GLuint)filterOffsets
{
    return self.uniforms[2];
}

- (GLuint)filterWeights
{
    return self.uniforms[3];
}

@end
