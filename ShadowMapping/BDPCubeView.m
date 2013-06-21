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

#import "BDPCubeView.h"
#import "BDPShadowShader.h"

@implementation BDPCubeView

#pragma mark - Constants

static const GLfloat VertexData[] = 
{
    // data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,      colourR, colourG, colourB
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,        0.4f, 1.0f, 0.4f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,        0.4f, 1.0f, 0.4f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f,        0.4f, 1.0f, 0.4f
};


#pragma mark - Update & Render

- (void)renderWithLightMatrix:(GLKMatrix4)projectionMatrix
{
    // set the correct shader
    BDPLightShader *shader = self.lightShader;
    glUseProgram(shader.program);
    
    // set up the vertex attributes
    GLsizei stride = 9 * sizeof(GLfloat);
    glEnableVertexAttribArray(BDPLightPositionAttribute);
    glVertexAttribPointer(BDPLightPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData);
    
    // set up the uniforms
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, self.modelMatrix);
    glUniformMatrix4fv(shader.uniforms[BDPLightMVPMatrixUniform], 1, GL_FALSE, mvpMatrix.m);
    
    // draw the cube
    glDrawArrays(GL_TRIANGLES, 0, 36);

    // cleanup
    glDisableVertexAttribArray(BDPLightPositionAttribute);
    glUseProgram(0);
}

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)textureMatrix
{
    // set the correct shader
    BDPShadowShader *shader = self.shadowShader;
    glUseProgram(shader.program);
    
    // set up the vertex attributes
    GLsizei stride = 9 * sizeof(GLfloat);
    glEnableVertexAttribArray(BDPShadowPositionAttribute);
    glVertexAttribPointer(BDPShadowPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData);
    
    glEnableVertexAttribArray(BDPShadowNormalAttribute);
    glVertexAttribPointer(BDPShadowNormalAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 3);
    
    glEnableVertexAttribArray(BDPShadowColourAttribute);
    glVertexAttribPointer(BDPShadowColourAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 6);
    
    // calculate and set the uniforms
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
    
    // draw the cube
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // cleanup
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisableVertexAttribArray(BDPShadowPositionAttribute);
    glDisableVertexAttribArray(BDPShadowNormalAttribute);
    glDisableVertexAttribArray(BDPShadowColourAttribute);
    glUseProgram(0);
}

@end
