//
//  ShadowMapping
//
//  Created by Richard on 62/3/12.
//  Copyright (c) 2012 BDP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLShader : NSObject 

@property (nonatomic, assign, readonly) GLuint program;
@property (nonatomic, assign, readonly) NSUInteger numAttributes;
@property (nonatomic, readonly) GLuint *uniforms;

- (id)initWithShaderName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms;

@end
