//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

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

#pragma mark - Init & Dealloc

- (id)init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

#pragma mark - Update & Render

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix textureMatrix:(GLKMatrix4)textureMatrix
{
    // set the correct shader
    BDPShadowShader *shader = (BDPShadowShader *)self.shader;
    glUseProgram(shader.program);
    
    // set up the vertex attributes
    GLsizei stride = 9 * sizeof(GLfloat);
    glEnableVertexAttribArray(BDPPositionAttribute);
    glVertexAttribPointer(BDPPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData);
    
    glEnableVertexAttribArray(BDPNormalAttribute);
    glVertexAttribPointer(BDPNormalAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 3);
    
    glEnableVertexAttribArray(BDPColourAttribute);
    glVertexAttribPointer(BDPColourAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 6);
    
    // calculate and set the uniforms
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, self.modelViewMatrix);    
    glUniformMatrix4fv(shader.uniforms[BDPMVPMatrixUniform], 1, GL_FALSE, mvpMatrix.m);
    
    GLKMatrix4 mvsMatrix = GLKMatrix4Multiply(textureMatrix, self.modelViewMatrix);
    glUniformMatrix4fv(shader.uniforms[BDPShadowMatrixUniform], 1, GL_FALSE, mvsMatrix.m);
    
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelViewMatrix), NULL);
    glUniformMatrix3fv(shader.uniforms[BDPNormalMatrixUniform], 1, GL_FALSE, normalMatrix.m);
    
    glUniform3fv(shader.uniforms[BDPLightDirectionUniform], 1, self.lightDirection.v);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.shadowTexture);
    glUniform1i(shader.uniforms[BDPShadowSamplerUniform], 0);
    
    // draw the cube
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // cleanup
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisableVertexAttribArray(BDPPositionAttribute);
    glDisableVertexAttribArray(BDPNormalAttribute);
    glDisableVertexAttribArray(BDPColourAttribute);
    glUseProgram(0);
}

@end
