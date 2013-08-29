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

#import "GLBlurFilter.h"
#import <GLKit/GLKit.h>
#import "GLBlurShader.h"

@interface GLBlurFilter() 

@property (nonatomic, strong) GLBlurShader *shader;

@end

@implementation GLBlurFilter
{
    GLuint _bounceFBO;
    GLuint _bounceTex;
}

#pragma mark - Constants

static const float kFilterOffsets[] = { 0, 1.440286350732807, 3.363547459718433 };
static const float kFilterWeights[] = { 0.1715822145829915, 0.28298460692918953, 0.1312242857793147 };

#pragma mark - Init & Dealloc

- (id)initWithSize:(CGSize)bufferSize
{
    self = [super init];
    if (self != nil) {
        // create textures to render to
        glGenTextures(1, &_bounceTex);
        self.size = bufferSize;
        
        // create FBOs to bounce the two stage filtering between
        glGenFramebuffers(1, &_bounceFBO);
        glBindFramebuffer(GL_FRAMEBUFFER, _bounceFBO);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _bounceTex, 0);
        
        // check everything is dandy
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"failed to create framebuffer with error 0x%4X", status);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        // create a shader to use
        self.shader = [[GLBlurShader alloc] init];
    }
    return self;
}

- (void)dealloc
{
    glDeleteTextures(1, &_bounceTex);
    glDeleteBuffers(1, &_bounceFBO);
}

#pragma mark - Properties

- (void)setSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, _size)) {
        _size = size;
        
        // recreate the buffer textures for pixel alignment
        glBindTexture(GL_TEXTURE_2D, _bounceTex);

        // even though it is pixel aligned, we use the GPU filtering to help the blur
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // no point wrapping, keep the edges darker
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RG_EXT, size.width, size.height, 0, GL_RG_EXT, GL_HALF_FLOAT_OES, 0);

        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

#pragma mark - Public Methods

- (void)blurTexture:(GLuint)texture
{
    static const GLfloat vertices[] = {
        -1, -1, 0,
         1, -1, 0,
        -1,  1, 0,
         1,  1, 0
    };
    
    static const GLfloat textureCoords[] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1
    };
    
    // get the current bound FBO and viewport size
    GLint oldFBO;
    GLint viewport[4];
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    // switch to the blur shader
    glUseProgram(self.shader.program);
    
    // set the viewport to use the whole pixel buffer
    glViewport(0, 0, self.size.width, self.size.height);
    
    // enable the vertex attributes
    glEnableVertexAttribArray(BlurShaderPositionAttribute);
    glVertexAttribPointer(BlurShaderPositionAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(BlurShaderTexCoordAttribute);
    glVertexAttribPointer(BlurShaderTexCoordAttribute, 2, GL_FLOAT, GL_FALSE, 0, textureCoords);
    
    // bind the texture to blur
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(self.shader.sampler, 0);
    
    // set the filter weights and offset steps
    glUniform1fv(self.shader.filterOffsets, 3, kFilterOffsets);
    glUniform1fv(self.shader.filterWeights, 3, kFilterWeights);
    glUniform2f(self.shader.pixelStep, 0, 1.0 / self.size.height);

    // blur in the horizontal direction into the bounce buffer
    glBindFramebuffer(GL_FRAMEBUFFER, _bounceFBO);
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // now blur in the vertical direction back into the original buffer
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindTexture(GL_TEXTURE_2D, _bounceTex);
    glUniform2f(self.shader.pixelStep, 1.0 / self.size.width, 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // cleanup
    glDisableVertexAttribArray(BlurShaderPositionAttribute);
    glDisableVertexAttribArray(BlurShaderTexCoordAttribute);
    glUseProgram(0);
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
}

@end
