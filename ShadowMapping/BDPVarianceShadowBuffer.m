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

#import "BDPVarianceShadowBuffer.h"

@implementation BDPVarianceShadowBuffer

#pragma mark - Constants

static const CGSize kShadowMapSize = { 512, 512 };

#pragma mark - Init & Dealloc

- (id)init
{
    self = [super init];
    if (self != nil) {
        // create a texture to use to render the depth & depth squared from the lights point of view
        // variance shadow maps differ in that they use an extra channel, mipmapping and filtering
        // and they do not require hardware depth compares
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        self.texture = texture;

        // we do not want to wrap, this will cause incorrect shadows to be rendered
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        // create the depth texture
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RG_EXT, kShadowMapSize.width, kShadowMapSize.height, 0, GL_RG_EXT, GL_HALF_FLOAT_OES, 0);

        // unbind it for now
        glBindTexture(GL_TEXTURE_2D, 0);

        // create a framebuffer object to attach the depth texture to
        GLuint bufferID;
        glGenFramebuffers(1, &bufferID);
        glBindFramebuffer(GL_FRAMEBUFFER, bufferID);
        self.bufferID = bufferID;

        // attach the depth texture to the render buffer
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture, 0);
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"error creating shadow FBO, status code 0x%4X", status);

        // unbind the FBO
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
    GLuint texture = self.texture;
    GLuint bufferID = self.bufferID;
    glDeleteTextures(1, &texture);
    glDeleteFramebuffers(1, &bufferID);
}

#pragma mark - Properties

- (CGSize)bufferSize
{
    return kShadowMapSize;
}

@end
