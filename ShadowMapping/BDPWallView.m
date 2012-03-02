//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

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
    
    // enable the vertex attributes
    GLsizei stride = 9 * sizeof(GLfloat);
    glEnableVertexAttribArray(BDPPositionAttribute);
    glVertexAttribPointer(BDPPositionAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData);
    
    glEnableVertexAttribArray(BDPNormalAttribute);
    glVertexAttribPointer(BDPNormalAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 3);
    
    glEnableVertexAttribArray(BDPColourAttribute);
    glVertexAttribPointer(BDPColourAttribute, 3, GL_FLOAT, GL_FALSE, stride, VertexData + 6);
    
    // set the uniforms
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
    
    // draw the vertices
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // cleanup
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisableVertexAttribArray(BDPPositionAttribute);
    glDisableVertexAttribArray(BDPNormalAttribute);
    glDisableVertexAttribArray(BDPColourAttribute);
    glUseProgram(0);
}

@end
