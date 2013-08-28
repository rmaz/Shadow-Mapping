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

#import "BDPViewController.h"
#import "BDPCubeView.h"
#import "BDPWallView.h"
#import "BDPLightShader.h"
#import "BDPVarianceLightShader.h"
#import "BDPShadowBuffer.h"
#import "BDPShadowShader.h"
#import "BDPVarianceShadowBuffer.h"

@interface BDPViewController()
{
    EAGLContext *_context;
    BDPCubeView *_cubeView;
    BDPWallView *_wallView;
    BDPShadowBuffer *_shadowBuffer;
    BDPVarianceShadowBuffer *_varianceShadowBuffer;
    BDPLightShader *_lightShader;
    BDPVarianceLightShader *_varianceLightShader;
    float _rotation;
    GLKMatrix4 _biasMatrix;
}

@end

@implementation BDPViewController

#pragma mark - Constants

static const float kCubeRotationZ = -5.0;
static const float kCubeRotationRadius = 1.0;
static const float kCubeRotationSpeed = 1.0;
static const float kWallZ = -50.0;
static const float kWallSize = 40.0;
static const GLKVector3 kLightPosition = { -0.5, 1.0, 0.0 };
static const GLKVector3 kLightLookAt = { 0.0, 0.0, -15.0 };

#pragma mark - View lifecycle

- (void)loadView
{
    GLKView *glkView = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    glkView.delegate = self;
    self.view = glkView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    // create FBOs to render shadows from the lights perspective
    _shadowBuffer = [[BDPShadowBuffer alloc] init];
    _varianceShadowBuffer = [[BDPVarianceShadowBuffer alloc] init];

    // we use a bias matrix to shift the depth texture range from [0 1] to [-1 +1]
    _biasMatrix = GLKMatrix4Make(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0.5, 0.5, 0.5, 1.0);
    
    // create the view objects
    _lightShader = [[BDPLightShader alloc] init];
    _varianceLightShader = [[BDPVarianceLightShader alloc] init];
    BDPShadowShader *shadowShader = [[BDPShadowShader alloc] init];
    
    GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Subtract(kLightLookAt, kLightPosition));
    _cubeView = [[BDPCubeView alloc] init];
    _cubeView.lightDirection = lightDirection;
    _cubeView.lightShader = _lightShader;
    _cubeView.shadowShader = shadowShader;
    _cubeView.shadowTexture = _shadowBuffer.depthTexture;
    
    _wallView = [[BDPWallView alloc] init];
    _wallView.lightDirection = lightDirection;
    _wallView.lightShader = _lightShader;
    _wallView.shadowShader = shadowShader;
    _wallView.shadowTexture = _shadowBuffer.depthTexture;
    
    // the wall is static, set its mv matrix now
    _wallView.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kWallZ), GLKMatrix4MakeScale(kWallSize, kWallSize, 1.0));
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    
    // we always have face culling and depth testing
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.7, 0.7, 0.7, 1.0);
}

- (void)tearDownGL
{
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
	_context = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    _cubeView = nil;
    _wallView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - GLKView Delegate Methods

- (void)update
{
    NSTimeInterval dt = self.timeSinceLastUpdate;
    _rotation += dt * kCubeRotationSpeed;
    
    // rotate the cube around it's axes
    GLKMatrix4 worldMatrix = GLKMatrix4MakeRotation(_rotation, 1.0, 1.0, 1.0);
    
    // move the cube to the rotation radius
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kCubeRotationRadius), worldMatrix);
    
    // rotate the cube around the origin
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeYRotation(_rotation), worldMatrix);
    
    // shift the cube into the distance
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kCubeRotationZ), worldMatrix);
    _cubeView.modelMatrix = worldMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    float fieldOfView = GLKMathDegreesToRadians(65);
    float near = 1.0;
    float far = 1.0 - kWallZ;
    
    // first we render to the shadow FBO from the lights perspective
    glBindFramebuffer(GL_FRAMEBUFFER, _shadowBuffer.bufferID);
    glViewport(0, 0, _shadowBuffer.bufferSize.width, _shadowBuffer.bufferSize.height);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // disable colour rendering for now
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    
    // create the projection matrix from the cameras view
    GLKMatrix4 cameraViewMatrix = GLKMatrix4MakeLookAt(kLightPosition.x, kLightPosition.y, kLightPosition.z, kLightLookAt.x, kLightLookAt.y, kLightLookAt.z, 0, 1, 0);
    float shadowAspect = _shadowBuffer.bufferSize.width / _shadowBuffer.bufferSize.height;
    GLKMatrix4 cameraProjectionMatrix = GLKMatrix4MakePerspective(fieldOfView, shadowAspect, near, far);
    GLKMatrix4 shadowMatrix = GLKMatrix4Multiply(cameraProjectionMatrix, cameraViewMatrix);
    
    // render only back faces, this avoids self shadowing
    glCullFace(GL_FRONT);
    
    // we only draw the shadow casting objects as fast as possible
    [_cubeView renderWithLightMatrix:shadowMatrix];
    
    // switch back to the main render buffer
    // this will also restore the viewport
    [view bindDrawable];
    
    // reenable colour rendering
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render only front faces
    glCullFace(GL_BACK);
    
    // calculate a perspective matrix for the current view size
    float aspectRatio = rect.size.width / rect.size.height;
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(fieldOfView, aspectRatio, near, far);
    
    // calculate the texture projection matrix, takes the pixels from world space
    // to light projection space
    GLKMatrix4 textureMatrix = GLKMatrix4Multiply(_biasMatrix, shadowMatrix);
    
    [_wallView renderWithProjectionMatrix:perspectiveMatrix textureMatrix:textureMatrix];
    [_cubeView renderWithProjectionMatrix:perspectiveMatrix textureMatrix:textureMatrix];
}
@end
