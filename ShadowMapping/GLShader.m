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
#import "GLShader.h"

@interface GLShader () 

@property (nonatomic, assign, readwrite) GLuint program;
@property (nonatomic, assign, readwrite) NSUInteger numAttributes;

- (BOOL)loadShaders:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation GLShader
{
	GLuint *_uniforms;
}

@synthesize program = _program;
@synthesize numAttributes = _numAttributes;
@synthesize uniforms = _uniforms;

#pragma mark - Init & Dealloc

- (id)initWithShaderName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms 
{
	self = [super init];
	if (self != nil) {
		// try and load the shaders
		if (![self loadShaders:name attributes:attributes uniforms:uniforms]) {
            NSAssert(NO, @"failed to compile shader: %@", name);
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
	if (_uniforms != NULL) {
		free(_uniforms);
	}
}

#pragma mark - Helper Methods

- (BOOL)loadShaders:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms 
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
	
    // Create shader program
    self.program = glCreateProgram();
	
    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
	
    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
	
    // Attach vertex shader to program
    glAttachShader(self.program, vertShader);
	
    // Attach fragment shader to program
    glAttachShader(self.program, fragShader);
	
    // Bind attribute locations
    // this needs to be done prior to linking
	self.numAttributes = attributes.count;
	for (GLuint i = 0; i < self.numAttributes; i++) {
		glBindAttribLocation(self.program, i, [[attributes objectAtIndex:i] UTF8String]);
	}
	
    // Link program
    if (![self linkProgram:self.program])
    {
        NSLog(@"Failed to link program: %d", self.program);
		
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.program)
        {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        
        return FALSE;
    }
	
	// get the uniform locations
	_uniforms = malloc(uniforms.count * sizeof(GLuint));
	for (NSUInteger i = 0; i < uniforms.count; i ++) {
		_uniforms[i] = glGetUniformLocation(self.program, [[uniforms objectAtIndex:i] UTF8String]);
        if (_uniforms[i] == (NSUInteger)-1)
            NSLog(@"uniform with name %@ is disabled", [uniforms objectAtIndex:i]);
	}
	
    // Release vertex and fragment shaders
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
	
    return TRUE;
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
	
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
	
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
	
    glLinkProgram(prog);
	
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
	
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
	
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
	
    return TRUE;
}



@end
