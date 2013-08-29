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
#import "BDPShadowShader.h"
#import "BDPVarianceShadowShader.h"
#import "BDPShadowBuffer.h"
#import "BDPVarianceShadowBuffer.h"
#import "GLBlurFilter.h"

@interface BDPViewController()
{
    EAGLContext *_context;
    BDPCubeView *_cubeView;
    BDPWallView *_wallView;
    BDPShadowBuffer *_shadowBuffer;
    BDPVarianceShadowBuffer *_varianceShadowBuffer;
    BDPLightShader *_lightShader;
    BDPVarianceLightShader *_varianceLightShader;
    BDPShadowShader *_shadowShader;
    BDPVarianceShadowShader *_varianceShadowShader;
    GLBlurFilter *_blurFilter;
    float _rotation;
    GLKMatrix4 _biasMatrix;
    BOOL _useVarianceShadows;
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

    // use a segmented control to switch the shadow map modes
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[ @"Shadow Map", @"Variance Map"]];
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    CGRect frame;
    frame.size = [segmentControl sizeThatFits:CGSizeZero];
    frame.origin.x = floorf((view.bounds.size.width - frame.size.width) / 2.0f);
    frame.origin.y = view.bounds.size.height - frame.size.height - 10;
    segmentControl.frame = frame;
    segmentControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:segmentControl];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    
    // we always have face culling and depth testing
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.7, 0.7, 0.7, 1.0);

    // create FBOs to render shadows from the lights perspective
    _shadowBuffer = [[BDPShadowBuffer alloc] init];
    _varianceShadowBuffer = [[BDPVarianceShadowBuffer alloc] init];

    // we use a bias matrix to shift the depth texture range from [0 1] to [-1 +1]
    _biasMatrix = GLKMatrix4Make(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0.5, 0.5, 0.5, 1.0);

    // create the view objects
    _lightShader = [[BDPLightShader alloc] init];
    _varianceLightShader = [[BDPVarianceLightShader alloc] init];
    _shadowShader = [[BDPShadowShader alloc] init];
    _varianceShadowShader = [[BDPVarianceShadowShader alloc] init];
    _blurFilter = [[GLBlurFilter alloc] initWithSize:_varianceShadowBuffer.bufferSize];

    GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Subtract(kLightLookAt, kLightPosition));
    _cubeView = [[BDPCubeView alloc] init];
    _cubeView.lightDirection = lightDirection;
    _cubeView.lightShader = _lightShader;
    _cubeView.shadowShader = _shadowShader;
    _cubeView.shadowTexture = _shadowBuffer.texture;

    _wallView = [[BDPWallView alloc] init];
    _wallView.lightDirection = lightDirection;
    _wallView.lightShader = _lightShader;
    _wallView.shadowShader = _shadowShader;
    _wallView.shadowTexture = _shadowBuffer.texture;

    // the wall is static, set its mv matrix now
    _wallView.modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kWallZ), GLKMatrix4MakeScale(kWallSize, kWallSize, 1.0));
}

- (void)tearDownGL
{
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
	_context = nil;
    _shadowBuffer = nil;
    _varianceShadowBuffer = nil;
    _lightShader = nil;
    _varianceLightShader = nil;
    _shadowShader = nil;
    _varianceShadowShader = nil;
    _cubeView = nil;
    _wallView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self tearDownGL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Action Methods

- (void)segmentControlChanged:(UISegmentedControl *)control
{
    _useVarianceShadows = control.selectedSegmentIndex == 1;

    BDPLightShader *lightShader;
    BDPShadowShader *shadowShader;
    GLFBO *shadowBuffer;
    if (_useVarianceShadows) {
        lightShader = _varianceLightShader;
        shadowShader = _varianceShadowShader;
        shadowBuffer = _varianceShadowBuffer;
    } else {
        lightShader = _lightShader;
        shadowShader = _shadowShader;
        shadowBuffer = _shadowBuffer;
    }

    _cubeView.lightShader = lightShader;
    _cubeView.shadowShader = shadowShader;
    _cubeView.shadowTexture = shadowBuffer.texture;
    _wallView.lightShader = lightShader;
    _wallView.shadowShader = shadowShader;
    _wallView.shadowTexture = shadowBuffer.texture;
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

    // pick the correct framebuffer to use
    GLFBO *shadowFBO = _useVarianceShadows ? _varianceShadowBuffer : _shadowBuffer;
    CGSize fboSize = shadowFBO.bufferSize;
    if (_useVarianceShadows)
        glDisable(GL_DEPTH_TEST);

    // first we render to the shadow FBO from the lights perspective
    glBindFramebuffer(GL_FRAMEBUFFER, shadowFBO.bufferID);
    glViewport(0, 0, fboSize.width, fboSize.height);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // create the projection matrix from the cameras view
    GLKMatrix4 cameraViewMatrix = GLKMatrix4MakeLookAt(kLightPosition.x, kLightPosition.y, kLightPosition.z, kLightLookAt.x, kLightLookAt.y, kLightLookAt.z, 0, 1, 0);
    float shadowAspect = fboSize.width / fboSize.height;
    GLKMatrix4 cameraProjectionMatrix = GLKMatrix4MakePerspective(fieldOfView, shadowAspect, near, far);
    GLKMatrix4 shadowMatrix = GLKMatrix4Multiply(cameraProjectionMatrix, cameraViewMatrix);
    
    // render only back faces, this avoids self shadowing
    glCullFace(GL_FRONT);
    
    // we only draw the shadow casting objects as fast as possible
    [_cubeView renderWithLightMatrix:shadowMatrix];

    // if we are using variance shadow maps, blur the textures now
    if (_useVarianceShadows) {
        [_blurFilter blurTexture:_varianceShadowBuffer.bufferID];
    }
    
    // switch back to the main render buffer
    // this will also restore the viewport
    [view bindDrawable];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
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
