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
#import "BDPShadowBuffer.h"
#import "BDPShadowShader.h"
#import "BDPVarianceShadowBuffer.h"

@interface BDPViewController()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) BDPCubeView *cubeView;
@property (nonatomic, strong) BDPWallView *wallView;
@property (nonatomic, strong) BDPShadowBuffer *shadowBuffer;
@property (nonatomic, strong) BDPVarianceShadowBuffer *varianceShadowBuffer;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) GLKMatrix4 biasMatrix;

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
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    // create a FBO to render shadows from the lights perspective
    self.shadowBuffer = [[BDPShadowBuffer alloc] init];
    self.varianceShadowBuffer = [[BDPVarianceShadowBuffer alloc] init];

    // we use a bias matrix to shift the depth texture range from [0 1] to [-1 +1]
    self.biasMatrix = GLKMatrix4Make(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0.5, 0.5, 0.5, 1.0);
    
    // create the view objects
    BDPLightShader *lightShader = [[BDPLightShader alloc] init];
    BDPShadowShader *shadowShader = [[BDPShadowShader alloc] init];
    
    GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Subtract(kLightLookAt, kLightPosition));
    self.cubeView = [[BDPCubeView alloc] init];
    self.cubeView.lightDirection = lightDirection;
    self.cubeView.lightShader = lightShader;
    self.cubeView.shadowShader = shadowShader;
    self.cubeView.shadowTexture = self.shadowBuffer.depthTexture;
    
    self.wallView = [[BDPWallView alloc] init];
    self.wallView.lightDirection = lightDirection;
    self.wallView.lightShader = lightShader;
    self.wallView.shadowShader = shadowShader;
    self.wallView.shadowTexture = self.shadowBuffer.depthTexture;
    
    // the wall is static, set its mv matrix now
    self.wallView.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kWallZ), GLKMatrix4MakeScale(kWallSize, kWallSize, 1.0));
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // we always have face culling and depth testing
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.7, 0.7, 0.7, 1.0);
}

- (void)tearDownGL
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    self.cubeView = nil;
    self.wallView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - GLKView Delegate Methods

- (void)update
{
    NSTimeInterval dt = self.timeSinceLastUpdate;
    self.rotation += dt * kCubeRotationSpeed;
    
    // rotate the cube around it's axes
    GLKMatrix4 worldMatrix = GLKMatrix4MakeRotation(self.rotation, 1.0, 1.0, 1.0);
    
    // move the cube to the rotation radius
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kCubeRotationRadius), worldMatrix);
    
    // rotate the cube around the origin
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeYRotation(self.rotation), worldMatrix);
    
    // shift the cube into the distance
    worldMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kCubeRotationZ), worldMatrix);
    self.cubeView.modelMatrix = worldMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    float fieldOfView = GLKMathDegreesToRadians(65);
    float near = 1.0;
    float far = 1.0 - kWallZ;
    
    // first we render to the shadow FBO from the lights perspective
    glBindFramebuffer(GL_FRAMEBUFFER, self.shadowBuffer.bufferID);
    glViewport(0, 0, self.shadowBuffer.bufferSize.width, self.shadowBuffer.bufferSize.height);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // disable colour rendering for now
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    
    // create the projection matrix from the cameras view
    GLKMatrix4 cameraViewMatrix = GLKMatrix4MakeLookAt(kLightPosition.x, kLightPosition.y, kLightPosition.z, kLightLookAt.x, kLightLookAt.y, kLightLookAt.z, 0, 1, 0);
    float shadowAspect = self.shadowBuffer.bufferSize.width / self.shadowBuffer.bufferSize.height;
    GLKMatrix4 cameraProjectionMatrix = GLKMatrix4MakePerspective(fieldOfView, shadowAspect, near, far);
    GLKMatrix4 shadowMatrix = GLKMatrix4Multiply(cameraProjectionMatrix, cameraViewMatrix);
    
    // render only back faces, this avoids self shadowing
    glCullFace(GL_FRONT);
    
    // we only draw the shadow casting objects as fast as possible
    [self.cubeView renderWithLightMatrix:shadowMatrix];
    
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
    GLKMatrix4 textureMatrix = GLKMatrix4Multiply(self.biasMatrix, shadowMatrix);
    
    [self.wallView renderWithProjectionMatrix:perspectiveMatrix textureMatrix:textureMatrix];
    [self.cubeView renderWithProjectionMatrix:perspectiveMatrix textureMatrix:textureMatrix];
}
@end
