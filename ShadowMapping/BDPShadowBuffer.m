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

#import "BDPShadowBuffer.h"

@implementation BDPShadowBuffer

#pragma mark - Constants

static const CGSize kShadowMapSize = { 512, 512 }; 

#pragma mark - Init & Dealloc

- (id)init
{
    self = [super init];
    if (self != nil) {
        // create a texture to use to render the depth from the lights point of view
        GLuint depthTexture;
        glGenTextures(1, &depthTexture);
        glBindTexture(GL_TEXTURE_2D, depthTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        self.texture = depthTexture;
        
        // we do not want to wrap, this will cause incorrect shadows to be rendered
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // set up the depth compare function to check the shadow depth in hardware
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_LEQUAL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
        
        // create the depth texture
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, kShadowMapSize.width, kShadowMapSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
        
        // unbind it for now
        glBindTexture(GL_TEXTURE_2D, 0);
        
        // create a framebuffer object to attach the depth texture to
        GLuint bufferID;
        glGenFramebuffers(1, &bufferID);
        glBindFramebuffer(GL_FRAMEBUFFER, bufferID);
        self.bufferID = bufferID;

        // attach the depth texture to the render buffer
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, self.texture, 0);
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"error creating shadow FBO, status code 0x%4x", status);
        
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
