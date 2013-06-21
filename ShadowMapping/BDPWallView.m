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

#import "BDPWallView.h"
#import "BDPShadowShader.h"

@implementation BDPWallView

#pragma mark - Constants

// interleaved vertex, normal and colour data
// with a stride of 9 floats = 36 bytes
static const GLfloat VertexData[] = {
    -0.5, -0.5, 0.0,    0.0, 0.0, 1.0,  0.4, 0.4, 0.4,
     0.5, -0.5, 0.0,    0.0, 0.0, 1.0,  0.4, 0.4, 0.4,
    -0.5,  0.5, 0.0,    0.0, 0.0, 1.0,  0.4, 0.4, 0.4,
     0.5,  0.5, 0.0,    0.0, 0.0, 1.0,  0.4, 0.4, 0.4
};

#pragma mark - Update & Render

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)textureMatrix
{
    // set the correct shader
    BDPShadowShader *shader = self.shadowShader;
    glUseProgram(shader.program);
    
    // enable the vertex attributes
    GLsizei stride = 9 * sizeof(GLfloat);
    glEnableVertexAttribArray(BDPShadowPositionAttribute);
    glVertexAttribPointer(BDPShadowPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData);
    
    glEnableVertexAttribArray(BDPShadowNormalAttribute);
    glVertexAttribPointer(BDPShadowNormalAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 3);
    
    glEnableVertexAttribArray(BDPShadowColourAttribute);
    glVertexAttribPointer(BDPShadowColourAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 6);
    
    // set the uniforms
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, self.modelMatrix);
    glUniformMatrix4fv(shader.uniforms[BDPShadowMVPMatrixUniform], 1, GL_FALSE, mvpMatrix.m);
    
    GLKMatrix4 mvsMatrix = GLKMatrix4Multiply(textureMatrix, self.modelMatrix);
    glUniformMatrix4fv(shader.uniforms[BDPShadowMatrixUniform], 1, GL_FALSE, mvsMatrix.m);
    
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelMatrix), NULL);
    glUniformMatrix3fv(shader.uniforms[BDPShadowNormalMatrixUniform], 1, GL_FALSE, normalMatrix.m);
    
    glUniform3fv(shader.uniforms[BDPShadowLightDirectionUniform], 1, self.lightDirection.v);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.shadowTexture);
    glUniform1i(shader.uniforms[BDPShadowSamplerUniform], 0);
    
    // draw the vertices
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // cleanup
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisableVertexAttribArray(BDPShadowPositionAttribute);
    glDisableVertexAttribArray(BDPShadowNormalAttribute);
    glDisableVertexAttribArray(BDPShadowColourAttribute);
    glUseProgram(0);
}

@end
