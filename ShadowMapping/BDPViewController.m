//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import "BDPViewController.h"
#import "BDPCubeView.h"
#import "BDPWallView.h"
#import "BDPShadowBuffer.h"
#import "BDPShadowShader.h"

@interface BDPViewController()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) BDPCubeView *cubeView;
@property (nonatomic, strong) BDPWallView *wallView;
@property (nonatomic, strong) BDPShadowBuffer *shadowBuffer;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) GLKMatrix4 biasMatrix;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation BDPViewController

@synthesize context = _context;
@synthesize cubeView = _cubeView;
@synthesize wallView = _wallView;
@synthesize rotation = _rotation;
@synthesize shadowBuffer = _shadowBuffer;
@synthesize biasMatrix = _biasMatrix;

#pragma mark - Constants

static const float kCubeRotationZ = -5.0;
static const float kCubeRotationRadius = 1.0;
static const float kCubeRotationSpeed = 1.0;
static const float kWallZ = -50.0;
static const float kWallSize = 40.0;
//static const GLKVector3 kLightPosition = { -1.0, 3.0, 1.0 };
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
    
    // we use a bias matrix to shift the depth texture range from [0 1] to [-1 +1]
    self.biasMatrix = GLKMatrix4Make(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0.5, 0.5, 0.5, 1.0);
    
    // create the view objects
    GLShader *shader = [[BDPShadowShader alloc] init];
    GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Subtract(kLightLookAt, kLightPosition));
    self.cubeView = [[BDPCubeView alloc] init];
    self.cubeView.lightDirection = lightDirection;
    self.cubeView.shader = shader;
    self.cubeView.shadowTexture = self.shadowBuffer.depthTexture;
    self.wallView = [[BDPWallView alloc] init];
    self.wallView.lightDirection = lightDirection;
    self.wallView.shader = shader;
    self.wallView.shadowTexture = self.shadowBuffer.depthTexture;
    
    // the wall is static, set its mv matrix now
    self.wallView.modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, kWallZ), GLKMatrix4MakeScale(kWallSize, kWallSize, 1.0));
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
    self.cubeView.modelViewMatrix = worldMatrix;
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
    
    [self.wallView renderWithProjectionMatrix:shadowMatrix textureMatrix:GLKMatrix4Identity];
    [self.cubeView renderWithProjectionMatrix:shadowMatrix textureMatrix:GLKMatrix4Identity];
    
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
